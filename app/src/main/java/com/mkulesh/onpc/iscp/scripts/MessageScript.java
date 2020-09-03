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

import com.mkulesh.onpc.iscp.ConnectionIf;
import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.iscp.MessageChannel;
import com.mkulesh.onpc.iscp.State;
import com.mkulesh.onpc.iscp.messages.ReceiverInformationMsg;
import com.mkulesh.onpc.iscp.messages.XmlListItemMsg;
import com.mkulesh.onpc.utils.Utils;

import org.w3c.dom.Element;
import org.w3c.dom.Node;

import java.util.ArrayList;
import java.util.List;
import java.util.ListIterator;
import java.util.Timer;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import static com.mkulesh.onpc.utils.Logging.info;

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

        // string that must match the acknowledgement message
        final String resp;

        // string that must appear as a media list item in an NLA message
        final String listitem;

        // The attribute that holds the actual state of this action
        ActionState state = ActionState.UNSENT;

        Action(String cmd, String par, final int milliseconds, String wait, String resp, String listitem)
        {
            this.cmd = cmd;
            this.par = par;
            this.milliseconds = milliseconds;
            this.wait = wait;
            this.resp = resp;
            this.listitem = listitem;
        }

        @NonNull
        public String toString()
        {
            return "Action"
                    + ":" + cmd
                    + "," + par
                    + "," + wait
                    + "," + resp
                    + "," + listitem
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

    @NonNull
    private String unEscape(@NonNull String str)
    {
        str = str.replace("~lt~", "<");
        str = str.replace("~gt~", ">");
        str = str.replace("~dq~", "\"");
        return str;
    }

    @Override
    public void initialize(@NonNull final String data)
    {
        Utils.openXml(this, data, (final Element elem) ->
        {
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
                        String par = action.getAttribute("par");
                        if (par == null)
                        {
                            throw new Exception("missing command parameter in 'send' command");
                        }
                        par = unEscape(par);
                        final int milliseconds = Utils.parseIntAttribute(action, "wait", -1);
                        final String wait = action.getAttribute("wait");
                        final String resp = unEscape(action.getAttribute("resp"));
                        final String listitem = unEscape(action.getAttribute("listitem"));
                        if (milliseconds < 0 && (wait == null || wait.isEmpty()))
                        {
                            throw new Exception("missing time or wait CMD in 'send' command");
                        }
                        actions.add(new Action(cmd, par, milliseconds, wait, resp, listitem));
                    }
                }
            }
        });
        for (Action a : actions)
        {
            info(this, a.toString());
        }
    }

    @Override
    public void start(@NonNull final State state, @NonNull MessageChannel channel)
    {
        // Startup handling.
        info(this, "started script");
        processAction(actions.listIterator(), state, channel, null);
    }

    private boolean nlaListContainsItem(@NonNull final State state, @NonNull ISCPMessage msg, @NonNull Action a)
    {
        if (!msg.getCode().equals("NLA") ||
                a.listitem == null || a.listitem.isEmpty())
        {
            return false;
        }
        final List<XmlListItemMsg> cloneMediaItems = state.cloneMediaItems();
        for (XmlListItemMsg item : cloneMediaItems)
        {
            if (item.getTitle().equals(a.listitem))
            {
                return true;
            }
        }
        return false;
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
            String log = "testing match between action " + a.toString() + " and msg " + msg.toString();
            if (a.state == ActionState.WAITING && a.wait != null)
            {
                if (a.wait.equals(msg.getCode()))
                {
                    log += " -> code matched";
                    if ((a.resp == null || a.resp.isEmpty() || a.resp.equals(msg.getData())) &&
                            (a.listitem == null || a.listitem.isEmpty() || nlaListContainsItem(state, msg, a)))
                    {
                        log += " -> parameter matched";
                        info(this, log);
                        a.state = ActionState.DONE;
                        // Process the next action
                        if (processAction(actionIterator, state, channel, msg) != null)
                        {
                            processMessage(msg, state, channel);
                        }
                        return;
                    }
                }
                info(this, log + " -> continue waiting");
                return;
            }
            else
            {
                info(this, "Something's wrong, didn't expect to be here");
            }
        }
    }

    private Action processAction(ListIterator<Action> actionIterator, @NonNull final State state, @NonNull MessageChannel channel, @Nullable final ISCPMessage triggerMsg)
    {
        if (!actionIterator.hasNext())
        {
            info(this, "all commands sent");
            return null;
        }
        if (!channel.isActive())
        {
            info(this, "message channel stopped");
            return null;
        }

        final Action a = actionIterator.next();
        if (a.cmd.equals("NA") && a.par.equals("NA"))
        {
            info(this, "no action message to send");
        }
        else if (triggerMsg != null && a.cmd.equals(triggerMsg.getCode()) && a.par.equals(triggerMsg.getData()))
        {
            info(this, "the required state is already set, no need to send action message");
            a.state = ActionState.WAITING;
            return a;
        }
        else
        {
            EISCPMessage msg = null;
            if (a.cmd.equals("NLA"))
            {
                final List<XmlListItemMsg> cloneMediaItems = state.cloneMediaItems();
                for (XmlListItemMsg item : cloneMediaItems)
                {
                    if (item.getTitle().equals(a.par))
                    {
                        msg = item.getCmdMsg();
                    }
                }
            }
            if (msg == null)
            {
                msg = new EISCPMessage(a.cmd, a.par);
            }
            channel.sendMessage(msg);
            info(this, "sent message " + msg.toString() + " for action " + a.toString());
        }

        a.state = ActionState.WAITING;
        if (a.milliseconds >= 0)
        {
            info(this, "scheduling timer for " + a.milliseconds + " milliseconds");
            final Timer t = new Timer();
            t.schedule(new java.util.TimerTask()
            {
                @Override
                public void run()
                {
                    info(MessageScript.this, "timer expired");
                    a.state = ActionState.DONE;
                    processAction(actionIterator, state, channel, null);
                }
            }, a.milliseconds);
        }
        return null;
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
