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

import android.content.Context;

import com.mkulesh.onpc.iscp.ConnectionIf;
import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.iscp.MessageChannel;
import com.mkulesh.onpc.iscp.State;
import com.mkulesh.onpc.iscp.messages.InputSelectorMsg;
import com.mkulesh.onpc.iscp.messages.ListTitleInfoMsg;
import com.mkulesh.onpc.iscp.messages.NetworkServiceMsg;
import com.mkulesh.onpc.iscp.messages.OperationCommandMsg;
import com.mkulesh.onpc.iscp.messages.PowerStatusMsg;
import com.mkulesh.onpc.iscp.messages.ReceiverInformationMsg;
import com.mkulesh.onpc.iscp.messages.ServiceType;
import com.mkulesh.onpc.iscp.messages.XmlListInfoMsg;
import com.mkulesh.onpc.iscp.messages.XmlListItemMsg;
import com.mkulesh.onpc.utils.Utils;

import org.w3c.dom.Element;
import org.w3c.dom.Node;

import java.util.ArrayList;
import java.util.List;
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
                    + "[" + cmd
                    + "," + par
                    + "," + wait
                    + "," + resp
                    + "," + listitem
                    + "]/" + ACTION_STATES[state.ordinal()];
        }

    }

    // optional connected host (ConnectionIf)
    private String host = ConnectionIf.EMPTY_HOST;
    private int port = ConnectionIf.EMPTY_PORT;

    // optional target zone
    private int zone = ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE;

    // optional target tab
    public String tab = null;

    // Actions to be performed
    private final List<Action> actions = new ArrayList<>();

    private final Context context;

    public MessageScript(Context context, @NonNull final String data)
    {
        this.context = context;
        initialize(data);
    }

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
                if (elem.getAttribute("tab") != null)
                {
                    tab = elem.getAttribute("tab");
                }
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
        processNextActions(state, channel);
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
        for (Action a : actions)
        {
            if (a.state == ActionState.DONE)
            {
                continue;
            }
            if (a.state == ActionState.WAITING && a.wait != null)
            {
                String log = a.toString() + ": compare with message " + msg.toString();
                if (isResponseMatched(state, a, msg.getCode(), msg.getData()))
                {
                    info(this, log + " -> response matched");
                    a.state = ActionState.DONE;
                    processNextActions(state, channel);
                    return;
                }
                if (state.serviceType == ServiceType.TUNEIN_RADIO && a.wait.equals(XmlListInfoMsg.CODE) &&
                        !a.listitem.isEmpty() && msg.getCode().equals(ListTitleInfoMsg.CODE) && state.isPlaybackMode())
                {
                    // Upon change to some services like TuneIn, the receiver may automatically
                    // start the latest playback and no XmlListItemMsg will be received. In this case,
                    // we shall stop playback and resent the service selection command
                    info(this, log + " -> waiting media item, but playing active -> change to list");
                    final OperationCommandMsg cmd = new OperationCommandMsg(OperationCommandMsg.Command.STOP);
                    channel.sendMessage(cmd.getCmdMsg());
                    channel.sendMessage(new EISCPMessage(a.cmd, a.par));
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

    private void processNextActions(@NonNull final State state, @NonNull MessageChannel channel)
    {
        if (!channel.isActive())
        {
            info(this, "message channel stopped");
            return;
        }

        ActionState aState = ActionState.DONE;
        for (Action a : actions)
        {
            if (a.state != ActionState.DONE)
            {
                aState = processAction(state, a, channel);
                if (aState != ActionState.DONE)
                {
                    break;
                }
            }
        }

        if (aState == ActionState.DONE)
        {
            info(this, "all commands send");
        }
    }

    private boolean isStateSet(@NonNull final State state, @NonNull final String cmd, @NonNull final String par)
    {
        switch (cmd)
        {
        case OperationCommandMsg.CODE:
            return par.equals(OperationCommandMsg.Command.TOP.toString()) && state.isTopLayer();
        case PowerStatusMsg.CODE:
            return par.equals(state.powerStatus.getCode());
        case InputSelectorMsg.CODE:
            return par.equals(state.inputType.getCode());
        case NetworkServiceMsg.CODE:
            return par.equals(state.serviceType.getCode() + "0");
        default:
            return false;
        }
    }

    private boolean isResponseMatched(@NonNull final State state, @NonNull Action a, @NonNull final String cmd, @Nullable final String par)
    {
        if (a.wait.equals(cmd))
        {
            if (!a.listitem.isEmpty())
            {
                final List<XmlListItemMsg> mediaItems = state.cloneMediaItems();
                for (XmlListItemMsg item : mediaItems)
                {
                    if (item.getTitle().equals(a.listitem))
                    {
                        return true;
                    }
                }
                final List<NetworkServiceMsg> serviceItems = state.cloneServiceItems();
                for (NetworkServiceMsg item : serviceItems)
                {
                    if (context.getString(item.getService().getDescriptionId()).equals(a.listitem))
                    {
                        return true;
                    }
                }
            }
            else return par != null && (a.resp.isEmpty() || a.resp.equals(par));
        }
        return false;
    }

    private ActionState processAction(@NonNull final State state, @NonNull final Action a, @NonNull MessageChannel channel)
    {
        if (isStateSet(state, a.cmd, a.par))
        {
            boolean isMatched = (!a.resp.isEmpty() && isStateSet(state, a.wait, a.resp)) ||
                    isResponseMatched(state, a, a.wait, null);
            a.state = isMatched ? ActionState.DONE : ActionState.WAITING;
            info(this, a.toString() + ": the required state is already set, no need to send action message");
            if (a.state == ActionState.DONE)
            {
                return a.state;
            }
        }
        else if (a.cmd.equals("NA") && a.par.equals("NA"))
        {
            info(this, a.toString() + ": no action message to send");
        }
        else
        {
            EISCPMessage msg = null;
            if (a.cmd.equals(XmlListInfoMsg.CODE))
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
            info(this, a.toString() + ": sent message " + msg.toString());
        }

        a.state = ActionState.WAITING;
        if (a.milliseconds >= 0)
        {
            info(this, a.toString() + ": scheduling timer for " + a.milliseconds + " milliseconds");
            final Timer t = new Timer();
            t.schedule(new java.util.TimerTask()
            {
                @Override
                public void run()
                {
                    info(MessageScript.this, a.toString() + ": timer expired");
                    a.state = ActionState.DONE;
                    processNextActions(state, channel);
                }
            }, a.milliseconds);
        }
        return a.state;
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
