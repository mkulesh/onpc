/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2025 by Mikhail Kulesh
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

import 'dart:async';

import "package:xml/xml.dart" as xml;

import "../../config/CfgFavoriteShortcuts.dart";
import "../../utils/Logging.dart";
import "../ConnectionIf.dart";
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";
import "../MessageChannel.dart";
import "../State.dart";
import "../messages/DcpAllZoneStereoMsg.dart";
import "../messages/DcpMediaContainerMsg.dart";
import "../messages/InputSelectorMsg.dart";
import "../messages/ListTitleInfoMsg.dart";
import "../messages/ListeningModeMsg.dart";
import "../messages/MessageFactory.dart";
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
    late String cmd;

    // parameter used for actions command. Empty string means no parameter is used.
    late String par;

    // flag to be applied for given action: AID for DCP protocol
    late String actionFlag;

    // Delay in milliseconds used for action WAIT. Zero means no delay.
    late int milliseconds;

    // the command to wait for. Null if time based (or no) wait is used
    late String wait;

    // string that must match the acknowledgement message
    late String resp;

    // string that must appear as a media list item in an NLA message
    late String listitem;

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
        actionFlag = ISCPMessage.nonNullString(action.getAttribute("flag"));
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
    => "Action [cmd=" + cmd + ", par=" + par + ", flag=" + actionFlag + ", wait=" + wait + ", resp=" + resp + ", listitem=" + listitem + "]/" + ACTION_STATES[state.index];

    String _unEscape(String str)
    {
        str = str.replaceAll("~lt~", "<");
        str = str.replaceAll("~gt~", ">");
        str = str.replaceAll("~dq~", "\"");
        return str;
    }

    String _changeZone(final State state, final String cmd)
    {
        final int newIdx = state.getActiveZone;
        for (List<String> zm in MessageFactory.getAllZonedMessages())
        {
            final int oldIdx = zm.indexWhere((element) => element.toLowerCase() == cmd.toLowerCase());
            if (oldIdx >= 0 && oldIdx != newIdx && newIdx < zm.length)
            {
                return zm[newIdx];
            }
        }
        return cmd;
    }

    void shiftZone(State state)
    {
        cmd = _changeZone(state, cmd);
        wait = _changeZone(state, wait);
    }
}


class MessageScript with ConnectionIf implements MessageScriptIf
{
    static final String SCRIPT_NAME = "onpcScript";

    // input data
    final String? intent;
    final Shortcut? shortcut;

    // optional target zone
    int _zone = ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE;

    int get zone
    => _zone;

    // optional target tab
    String _tab = "";

    String get tab
    => _tab;

    // Actions to be performed
    final List<Action> actions = [];

    MessageScript({this.intent, this.shortcut})
    {
        if (intent != null)
        {
            _read(intent!);
        }
    }

    void _read(String data)
    {
        actions.clear();
        try
        {
            final xml.XmlDocument document = xml.XmlDocument.parse(data);
            document.findAllElements(SCRIPT_NAME).forEach((xml.XmlElement e)
            {
                setHost(ISCPMessage.nonNullString(e.getAttribute("host")));
                setPort(ISCPMessage.nonNullInteger(e.getAttribute("port"), 10, ConnectionIf.EMPTY_PORT));
                _zone = ISCPMessage.nonNullInteger(e.getAttribute("zone"), 10, ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE);
                _tab = ISCPMessage.nonNullString(e.getAttribute("tab"));
            });
            document.findAllElements("send").forEach((xml.XmlElement action)
            => actions.add(Action.fromXml(action)));
        }
        on Exception catch (e)
        {
            Logging.info(this, "can not create action: " + e.toString());
            actions.clear();
        }
    }

    @override
    bool isValid(ProtoType protoType)
    => actions.isNotEmpty;

    @override
    bool initialize(final State state, MessageChannel channel)
    {
        Logging.info(this, "initialization...");
        if (intent == null && shortcut == null)
        {
            Logging.info(this, "either intent or shortcut shall be provided. Script aborted.");
            return false;
        }

        final String data = intent != null ? intent! : shortcut!.toScript(
            state.protoType, state.receiverInformation.model, state.mediaListState);
        _read(data);
        actions.forEach((a)
        {
            if (state.protoType == ProtoType.DCP)
            {
                a.shiftZone(state);
            }
            Logging.info(this, a.toString());
        });
        return isValid(state.protoType);
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
            if (a.state == ActionState.WAITING)
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
                return state.protoType == ProtoType.ISCP && par == "TOP" && state.mediaListState.isTopLayer();
            case PowerStatusMsg.CODE:
            case PowerStatusMsg.ZONE2_CODE:
            case PowerStatusMsg.ZONE3_CODE:
            case PowerStatusMsg.ZONE4_CODE:
                return par == PowerStatusMsg.ValueEnum
                    .valueByKey(state.receiverInformation.powerStatus)
                    .getCode;
            case InputSelectorMsg.CODE:
            case InputSelectorMsg.ZONE2_CODE:
            case InputSelectorMsg.ZONE3_CODE:
            case InputSelectorMsg.ZONE4_CODE:
                return par == state.mediaListState.inputType.getCode;
            case NetworkServiceMsg.CODE:
                return par == state.mediaListState.serviceType.getCode + "0";
            case ListeningModeMsg.CODE:
                return par == state.soundControlState.listeningMode.getCode;
            default:
                return false;
        }
    }

    bool _isResponseMatched(final State state, Action a, final String cmd, final String? par)
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
            // DCP all zone stereo mode
            if (state.protoType == ProtoType.DCP && a.cmd == ListeningModeMsg.CODE)
            {
                final DcpAllZoneStereoMsg? allZoneStereoMsg =
                    state.soundControlState.toggleAllZoneStereo(ListeningModeMsg.ValueEnum.valueByDcpCode(a.par));
                if (allZoneStereoMsg != null)
                {
                    channel.sendMessage(allZoneStereoMsg.getCmdMsg());
                }
            }
            // Media item
            XmlListItemMsg? item;
            if (a.cmd == XmlListInfoMsg.CODE || a.cmd == DcpMediaContainerMsg.CODE)
            {
                for (ISCPMessage i in state.mediaListState.mediaItems)
                {
                    if (i is XmlListItemMsg && i.getTitle == a.par)
                    {
                        item = i;
                    }
                }
            }
            // DCP command
            final DcpMediaContainerMsg? dcpMsg =
                item != null? state.mediaListState.getDcpContainerMsg(item) : null;
            if (item != null && dcpMsg != null)
            {
                if (a.actionFlag.isNotEmpty)
                {
                    final DcpMediaContainerMsg dcpMsg1 = DcpMediaContainerMsg.copy(dcpMsg);
                    dcpMsg1.setAid(a.actionFlag);
                    channel.sendIscp(dcpMsg1);
                    Logging.info(this, a.toString() + ": sent DCP media container message with action " + dcpMsg1.toString());
                }
                else
                {
                    state.mediaListState.prepareDcpNextLayer(item);
                    channel.sendIscp(dcpMsg);
                    Logging.info(this, a.toString() + ": sent DCP media container message " + dcpMsg.toString());
                }
            }
            else
            {
                // ISCP command
                EISCPMessage? msg = item?.getCmdMsg();
                if (msg == null)
                {
                    msg = EISCPMessage.output(a.cmd, a.par);
                }
                channel.sendMessage(msg);
                Logging.info(this, a.toString() + ": sent message " + msg.toString());
            }
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
}
