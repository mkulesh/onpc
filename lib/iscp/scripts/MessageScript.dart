/*
 * Copyright (C) 2020. Mikhail Kulesh, John Orr
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU
 * General License as published by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
 * even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General License for more details. You should have received a copy of the GNU General
 * License along with this program.
 */

import 'dart:async';

import "package:xml/xml.dart" as xml;

import "../../utils/Logging.dart";
import "../ConnectionIf.dart";
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";
import "../MessageChannel.dart";
import "../State.dart";
import "../messages/InputSelectorMsg.dart";
import "../messages/ListTitleInfoMsg.dart";
import "../messages/NetworkServiceMsg.dart";
import "../messages/OperationCommandMsg.dart";
import "../messages/PowerStatusMsg.dart";
import "../messages/ReceiverInformationMsg.dart";
import "../messages/XmlListInfoMsg.dart";
import "../messages/XmlListItemMsg.dart";
import "MessageScriptIf.dart";

enum ActionState
{
    UNSENT, // the command is not yet sent
    WAITING, // the command has been sent and is waiting for an ack message or time-based wait
    DONE // the command has completed
}

class Action
{
    static final List<String> ACTION_STATES = ["UNSENT", "WAITING", "DONE"];

    // command to be sent
    String cmd;

    // parameter used for actions command. Empty string means no parameter is used.
    String par;

    // Delay in milliseconds used for action WAIT. Zero means no delay.
    int milliseconds;

    // the command to wait for. Null if time based (or no) wait is used
    String wait;

    // string that must match the acknowledgement message
    String resp;

    // string that must appear as a media list item in an NLA message
    String listitem;

    // The attribute that holds the actual state of this action
    ActionState state = ActionState.UNSENT;

    Action.fromXml(xml.XmlElement action)
    {
        cmd = ISCPMessage.nonNullString(action.getAttribute("cmd"));
        if (cmd.isEmpty)
        {
            throw Exception("missing command code in 'send' command");
        }
        par = ISCPMessage.nonNullString(action.getAttribute("par"));
        if (par.isEmpty)
        {
            throw Exception("missing command parameter in 'send' command");
        }
        par = _unEscape(par);
        milliseconds = ISCPMessage.nonNullInteger(action.getAttribute("wait"), 10, -1);
        wait = ISCPMessage.nonNullString(action.getAttribute("wait"));
        resp = _unEscape(ISCPMessage.nonNullString(action.getAttribute("resp")));
        if (milliseconds < 0 && wait.isEmpty)
        {
            throw Exception("missing time or wait CMD in 'send' command");
        }
        listitem = _unEscape(ISCPMessage.nonNullString(action.getAttribute("listitem")));
    }

    @override
    String toString()
    => "Action [" + cmd + "," + par + "," + wait + "," + resp + "," + listitem + "]/" + ACTION_STATES[state.index];

    String _unEscape(String str)
    {
        str = str.replaceAll("~lt~", "<");
        str = str.replaceAll("~gt~", ">");
        str = str.replaceAll("~dq~", "\"");
        return str;
    }
}


class MessageScript with ConnectionIf implements MessageScriptIf
{
    // optional target zone
    int zone = ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE;

    // Actions to be performed
    final List<Action> actions = List();

    MessageScript(final String data)
    {
        initialize(data);
    }

    @override
    bool isValid()
    => actions.isNotEmpty;

    @override
    void initialize(final String data)
    {
        try
        {
            final xml.XmlDocument document = xml.XmlDocument.parse(data);
            document.findAllElements("onpcScript").forEach((xml.XmlElement e)
            {
                setHost(ISCPMessage.nonNullString(e.getAttribute("host")));
                setPort(ISCPMessage.nonNullInteger(e.getAttribute("port"), 10, ConnectionIf.EMPTY_PORT));
                zone = ISCPMessage.nonNullInteger(e.getAttribute("zone"), 10, ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE);
            });
            document.findAllElements("send").forEach((xml.XmlElement action)
            => actions.add(Action.fromXml(action)));
        }
        on Exception catch (e)
        {
            Logging.info(this, "can not create action: " + e.toString());
            actions.clear();
        }
        actions.forEach((a)
        => Logging.info(this, a.toString()));
    }

    @override
    void start(final State state, MessageChannel channel)
    {
        // Startup handling.
        Logging.info(this, "started script");
        _processNextActions(state, channel);
    }

    /*
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
     */
    @override
    void processMessage(ISCPMessage msg, final State state, MessageChannel channel)
    {
        for (Action a in actions)
        {
            if (a.state == ActionState.DONE)
            {
                continue;
            }
            if (a.state == ActionState.WAITING && a.wait != null)
            {
                final String log = a.toString() + ": compare with message " + msg.toString();
                if (_isResponseMatched(state, a, msg.getCode, msg.getData))
                {
                    Logging.info(this, log + " -> response matched");
                    a.state = ActionState.DONE;
                    _processNextActions(state, channel);
                    return;
                }
                if (state.mediaListState.isTuneIn && a.wait == XmlListItemMsg.CODE && a.listitem.isNotEmpty &&
                    msg.getCode == ListTitleInfoMsg.CODE && state.mediaListState.isPlaybackMode)
                {
                    // Upon change to some services like TuneIn, the receiver may automatically
                    // start the latest playback and no XmlListItemMsg will be received. In this case,
                    // we shall stop playback and resent the service selection command
                    Logging.info(this, log + " -> waiting media item, but playing active -> change to list");
                    channel.sendMessage(OperationCommandMsg.output(
                        State.DEFAULT_ACTIVE_ZONE, OperationCommand.STOP).getCmdMsg());
                    channel.sendMessage(EISCPMessage.output(a.cmd, a.par));
                }
                Logging.info(this, log + " -> continue waiting");
                return;
            }
            else
            {
                Logging.info(this, "Something's wrong, didn't expect to be here");
            }
        }
    }

    void _processNextActions(final State state, MessageChannel channel)
    {
        if (!channel.isConnected)
        {
            Logging.info(this, "message channel stopped");
            return;
        }

        ActionState aState = ActionState.DONE;
        for (Action a in actions)
        {
            if (a.state != ActionState.DONE)
            {
                aState = _processAction(state, a, channel);
                if (aState != ActionState.DONE)
                {
                    break;
                }
            }
        }

        if (aState == ActionState.DONE)
        {
            Logging.info(this, "all commands send");
        }
    }

    bool _isStateSet(final State state, final String cmd, final String par)
    {
        switch (cmd)
        {
            case OperationCommandMsg.CODE:
                return par == "TOP" && state.mediaListState.isTopLayer();
            case PowerStatusMsg.CODE:
                return par == PowerStatusMsg.ValueEnum
                    .valueByKey(state.receiverInformation.powerStatus)
                    .getCode;
            case InputSelectorMsg.CODE:
                return par == state.mediaListState.inputType.getCode;
            case NetworkServiceMsg.CODE:
                return par == state.mediaListState.serviceType.getCode + "0";
            default:
                return false;
        }
    }

    bool _isResponseMatched(final State state, Action a, final String cmd, final String par)
    {
        if (a.wait == cmd)
        {
            if (a.listitem.isNotEmpty)
            {
                for (ISCPMessage item in state.mediaListState.mediaItems)
                {
                    if (item is XmlListItemMsg && item.getTitle == a.listitem)
                    {
                        return true;
                    }
                    if (item is NetworkServiceMsg && item.getValue.description == a.listitem)
                    {
                        return true;
                    }
                }
            }
            else
            {
                return par != null && (a.resp.isEmpty || a.resp == par);
            }
        }
        return false;
    }

    ActionState _processAction(final State state, final Action a, MessageChannel channel)
    {
        if (_isStateSet(state, a.cmd, a.par))
        {
            final bool isMatched = (a.resp.isNotEmpty && _isStateSet(state, a.wait, a.resp)) ||
                _isResponseMatched(state, a, a.wait, null);
            a.state = isMatched ? ActionState.DONE : ActionState.WAITING;
            Logging.info(this, a.toString() + ": the required state is already set, no need to send action message");
            if (a.state == ActionState.DONE)
            {
                return a.state;
            }
        }
        else if (a.cmd == "NA" && a.par == "NA")
        {
            Logging.info(this, a.toString() + ": no action message to send");
        }
        else
        {
            EISCPMessage msg;
            if (a.cmd == XmlListInfoMsg.CODE)
            {
                for (ISCPMessage item in state.mediaListState.mediaItems)
                {
                    if (item is XmlListItemMsg && item.getTitle == a.par)
                    {
                        msg = item.getCmdMsg();
                    }
                }
            }
            if (msg == null)
            {
                msg = EISCPMessage.output(a.cmd, a.par);
            }
            channel.sendMessage(msg);
            Logging.info(this, a.toString() + ": sent message " + msg.toString());
        }

        a.state = ActionState.WAITING;
        if (a.milliseconds >= 0)
        {
            Logging.info(this, a.toString() + ": scheduling timer for " + a.milliseconds.toString() + " milliseconds");
            Timer(Duration(milliseconds: a.milliseconds), ()
            {
                Logging.info(this, a.toString() + ": timer expired");
                a.state = ActionState.DONE;
                _processNextActions(state, channel);
            });
        }
        return a.state;
    }

    int getZone()
    {
        return zone;
    }
}
