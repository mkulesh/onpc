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
import com.mkulesh.onpc.iscp.EISCPMessage;
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
import java.util.ListIterator;
import java.util.Timer;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import androidx.annotation.NonNull;

public class MessageScript implements ConnectionIf, MessageScriptIf
{
    enum ActionState
    {
        UNSENT, // the command is not yet sent
        WAITING, // the command has been sent and is waiting for an ack message or time-based wait
        DONE // the command has completed
    }

    private final static String[] ACTION_STATES = new String[]{ "UNSENT", "WAITING", "DONE" };

    class Action
    {
        // command to be sent
        final String cmd;

        // parameter used for actions command. Empty string means no parameter is used.
        final String par;

        // Delay in milliseconds used for action WAIT. Zero means no delay.
        final int milliseconds;

        // the command to wait for. Null if time based (or no) wait is used
        final String wait;

        // regex that must match the acknowledgement message
        final String resp;

        // The attribute that holds the actual state of this action
        ActionState state = ActionState.UNSENT;

        Action(String cmd, String par, final int milliseconds, String wait, String resp)
        {
            this.cmd = cmd;
            this.par = par;
            this.milliseconds = milliseconds;
            this.wait = wait;
            this.resp = resp;
        }

        @NonNull
        public String toString()
        {
            return "Action"
                    + ":" + cmd
                    + "," + par
                    + "," + milliseconds
                    + "," + wait
                    + "," + resp
                    + "," + ACTION_STATES[state.ordinal()];
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
                            final int milliseconds = Utils.parseIntAttribute(action, "wait", -1);
                            final String wait = action.getAttribute("wait");
                            final String resp = action.getAttribute("resp");
                            if (milliseconds < 0 && (wait == null || wait.isEmpty()))
                            {
                                Logging.info(this, "missing time or wait CMD in 'send' command");
                                return;
                            }
                            actions.add(new Action(cmd, par, milliseconds, wait, resp));
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
    public void start(@NonNull final State state, @NonNull MessageChannel channel)
    {
        // Startup handling.
        processAction(actions.listIterator(), state, channel);
    }

    /**
     * The method implements message handling with respect to the "command"-"wait" logic:
     * - in "actions" list, search the first non-performed action
     * - if this action as a "wait" command that waits on a specific message (and
     *   optional parameter), check whether this condition is fulfilled. If yes, set the
     *   action as done and perform the next action
     * - if the action to be performed is a "cmd" command, send the message (for example
     *   see method AutoPower.processMessage)
     * - if the action to be performed is a "wait" command with given time (in milliseconds),
     *   set the state to "processing" and start the timer, where the timer body is the
     *   code that shall perform the next message
     **/
    @Override
    public void processMessage(@NonNull ISCPMessage msg, @NonNull final State state, @NonNull MessageChannel channel)
    {
        ListIterator<Action> actionIterator = actions.listIterator();
        while (actionIterator.hasNext())
        {
            Action a = actionIterator.next();
            if (a.state == ActionState.DONE)
            {
                continue;
            }
            Logging.info(this, "Testing match between action " + a.toString() + " and msg " + msg.toString());
            if (a.state == ActionState.WAITING && a.wait != null)
            {
                if (a.wait.equals(msg.getCmdMsg().getCode()))
                {
                    Logging.info(this, "Message code matched");
                    if (a.resp == null || a.resp.equals(msg.getCmdMsg().getParameters()))
                    {
                        Logging.info(this, "Message parameters matched");
                        a.state = ActionState.DONE;
                        // Process the next action
                        processAction(actionIterator, state, channel);
                        return;
                    }
                }
                Logging.info(this, "Continue waiting for " + a.toString());
                return;
            }
        }
    }

    public void processAction(ListIterator<Action> actionIterator, @NonNull final State state, @NonNull MessageChannel channel)
    {
        if (!actionIterator.hasNext())
        {
            Logging.info(this, "all commands sent");
            return;
        }
        if (!channel.isActive())
        {
            Logging.info(this, "message channel stopped");
            return;
        }
        if (!state.isOn())
        {
            Logging.info(this, "receiver off ?");
            // return;
        }

        Action a = actionIterator.next();
        EISCPMessage msg = new EISCPMessage(a.cmd, a.par);
        channel.sendMessage(msg);
        Logging.info(this, "sent message " + msg.toString() + " for action " + a.toString());
        a.state = ActionState.WAITING;

        if (a.milliseconds >= 0)
        {
            Logging.info(this, "scheduling timer for " + a.milliseconds + " milliseconds");
            final Timer t = new Timer();
            t.schedule(new java.util.TimerTask()
            {
                @Override
                public void run()
                {
                    Logging.info(this, "timer expired");
                    processAction(actionIterator, state, channel);
                }
            }, a.milliseconds);
        }
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

    public int getZone()
    {
        return zone;
    }
}
