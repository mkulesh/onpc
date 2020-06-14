/*
 * Copyright (C) 2020. Mikhail Kulesh, John Orr
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU
 * General Public License as published by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
 * even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details. You should have received a copy of the GNU General
 * Public License along with this program.
 */
package com.mkulesh.onpc.iscp.scripts;

import android.content.Intent;

import com.mkulesh.onpc.iscp.ConnectionIf;
import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.iscp.MessageChannel;
import com.mkulesh.onpc.iscp.State;
import com.mkulesh.onpc.iscp.messages.ReceiverInformationMsg;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.List;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import androidx.annotation.NonNull;

public class MessageScript implements ConnectionIf, MessageScriptIf
{
    enum ActionType
    {
        CMD,
        WAIT
    }

    enum ActionState
    {
        PENDING, // the action is not started
        PERFORMING, // the action is started, dow example WAIT action waits given time
        DONE // the action is performed
    }

    class Action
    {
        // action type
        final ActionType actionType;

        // command used for actions CMD and WAIT
        final String cmd;

        // parameter used for actions CMD and WAIT. Empty string means no parameter is used.
        final String par;

        // Delay in milliseconds used for action WAIT. Zero means no delay.
        final int milliseconds;

        // The attribute that holds the actual state of this action
        ActionState state = ActionState.PENDING;

        Action(ActionType actionType, String cmd, String par, final int milliseconds)
        {
            this.actionType = actionType;
            this.cmd = cmd;
            this.par = par;
            this.milliseconds = milliseconds;
        }

        @NonNull
        public String toString()
        {
            String s = "Action:";
            if (actionType == ActionType.CMD)
            {
                s += "CMD";
            }
            else if (actionType == ActionType.WAIT)
            {
                s += "WAIT";
            }
            s += "," + cmd + "," + par + "," + milliseconds;
            return s;
        }

    }

    // optional connected host (ConnectionIf)
    private String host = ConnectionIf.EMPTY_HOST;
    private int port = ConnectionIf.EMPTY_PORT;

    // optional target zone
    private int zone = ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE;

    // Actions to be performed
    private final List<Action> actions = new ArrayList<>();

    @Override
    public boolean isValid()
    {
        return !actions.isEmpty();
    }

    @Override
    public void initialize(@NonNull final Intent intent)
    {
        final String data = intent.getDataString();
        if (data == null || data.isEmpty())
        {
            Logging.info(this, "intent data parameter empty: no script to parse");
            return;
        }

        // In good case, the intent data already logged by caller, no need to log it twice

        try
        {
            InputStream stream = new ByteArrayInputStream(data.getBytes(Charset.forName("UTF-8")));
            final DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            // https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Prevention_Cheat_Sheet
            factory.setExpandEntityReferences(false);
            final DocumentBuilder builder = factory.newDocumentBuilder();
            final Document doc = builder.parse(stream);
            final Node object = doc.getDocumentElement();
            //noinspection ConstantConditions
            if (object instanceof Element)
            {
                //noinspection CastCanBeRemovedNarrowingVariableType
                final Element elem = (Element) object;
                if (elem.getTagName().equals("onpcScript"))
                {
                    if (elem.getAttribute("host") != null)
                    {
                        host = elem.getAttribute("host");
                    }
                    port = Utils.parseIntAttribute(elem, "port", ConnectionIf.EMPTY_PORT);
                    zone = Utils.parseIntAttribute(elem, "zone", ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE);
                }
                for (Node prop = elem.getFirstChild(); prop != null; prop = prop.getNextSibling())
                {
                    if (prop instanceof Element)
                    {
                        final Element action = (Element) prop;
                        if (action.getTagName().equals("send"))
                        {
                            final String cmd = action.getAttribute("cmd");
                            if (cmd == null)
                            {
                                throw new Exception("missing command code in 'send' command");
                            }
                            final String par = action.getAttribute("par");
                            if (par == null)
                            {
                                throw new Exception("missing command parameter in 'send' command");
                            }
                            actions.add(new Action(ActionType.CMD, cmd, par, 0));
                        }
                        else if (action.getTagName().equals("wait"))
                        {
                            final int milliseconds = Utils.parseIntAttribute(action, "milliseconds", -1);
                            final String response = action.getAttribute("response");
                            if (milliseconds < 0 && (response == null || response.isEmpty()))
                            {
                                Logging.info(this, "missing time or response  in 'wait' command");
                                return;
                            }
                            actions.add(new Action(ActionType.WAIT, response,
                                    action.getAttribute("par"), milliseconds));
                        }
                    }
                }
            }
        }
        catch (Exception e)
        {
            // TODO - raise this to the user's attention - they stuffed up and they'd probably like to know
            Logging.info(this, "Failed to parse onpcScript pass in intent: " + e.getLocalizedMessage());
            actions.clear();
        }
        for (Action a : actions)
        {
            Logging.info(this, a.toString());
        }
    }

    @Override
    public void start()
    {
        // If necessary, implement startup handling. Currently, nothing to do.
    }

    @Override
    public void processMessage(@NonNull ISCPMessage msg, @NonNull final State state, @NonNull MessageChannel channel)
    {
        // Implement message handling with respect to the "command"-"wait" logic:
        // - in "actions" list, search the first non-performed action
        // - if this action as a "wait" command that waits on a specific message (and
        //   optional parameter), check whether this condition is fulfilled. If yes, set the
        //   action as done and perform the next action
        // - if the action to be performed is a "cmd" command, send the message (for example
        //   see method AutoPower.processMessage)
        // - if the action to be performed is a "wait" command with given time (in milliseconds),
        //   set the state to "processing" and start the timer, where the timer body is the
        //   code that shall perform the next message
        //   - I suggest to collect the code that performs the action in a separate method
        //   "processAction" since we can have a sequence of "wait" commands that will result in
        //   a sequence of timer calls
        // - How to work with timer, see method StateManager.doInBackground. Here, I use
        //   thread-safety variable timerQueue that ensures that every time not more than
        //   one instance of the timer is active. I suggest to implement the same logic here.
    }

    @NonNull
    @Override
    public String getHost()
    {
        return host;
    }

    @Override
    public int getPort()
    {
        return port;
    }

    @NonNull
    @Override
    public String getHostAndPort()
    {
        return Utils.ipToString(host, port);
    }
}
