/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2023 by Mikhail Kulesh
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
// @dart=2.9
import 'package:flutter/services.dart';

import "../../utils/Logging.dart";
import "../ConnectionIf.dart";
import "../ISCPMessage.dart";
import "../MessageChannel.dart";
import "../State.dart";
import "../messages/PowerStatusMsg.dart";
import "../messages/ReceiverInformationMsg.dart";
import "MessageScriptIf.dart";

enum AutoPowerMode
{
    POWER_ON,
    ALL_STANDBY
}

enum _AllStandbyStep
{
    NONE,
    ALL_STB_SEND,
    STB_SEND
}

//
// The class performs receiver auto-power on startup
//
class AutoPower implements MessageScriptIf
{
    final AutoPowerMode autoPowerMode;
    bool _done = false;
    _AllStandbyStep _allStandbyStep = _AllStandbyStep.NONE;

    AutoPower(this.autoPowerMode);

    @override
    bool isValid(ProtoType protoType)
    => true;

    @override
    void initialize(final String data)
    {
        // nothing to do
    }

    @override
    void start(final State state, MessageChannel channel)
    {
        Logging.info(this, "started script: " + autoPowerMode.toString());
        _done = false;
        _allStandbyStep = _AllStandbyStep.NONE;
    }

    @override
    void processMessage(ISCPMessage msg, final State state, MessageChannel channel)
    {
        // Auto power-on once at first PowerStatusMsg
        if (msg is PowerStatusMsg && !_done)
        {
            if (autoPowerMode == AutoPowerMode.POWER_ON && !state.isOn)
            {
                Logging.info(this, "request auto-power on startup");
                final PowerStatusMsg cmd = PowerStatusMsg.output(state.getActiveZone, PowerStatus.ON);
                channel.sendMessage(cmd.getCmdMsg());
                _done = true;
            }
            else if (autoPowerMode == AutoPowerMode.ALL_STANDBY)
            {
                switch (_allStandbyStep)
                {
                case _AllStandbyStep.NONE:
                    Logging.info(this, "request all-standby on startup");
                    final PowerStatusMsg cmd = PowerStatusMsg.output(
                      ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE, PowerStatus.ALL_STB);
                    channel.sendMessage(cmd.getCmdMsg());
                    _allStandbyStep = _AllStandbyStep.ALL_STB_SEND;
                    break;
                case _AllStandbyStep.ALL_STB_SEND:
                    if (msg.getValue.key == PowerStatus.STB || msg.getValue.key == PowerStatus.ALL_STB)
                    {
                        _done = true;
                    }
                    else
                    {
                        Logging.info(this, "request standby on startup");
                        final PowerStatusMsg cmd = PowerStatusMsg.output(
                            ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE, PowerStatus.STB);
                        channel.sendMessage(cmd.getCmdMsg());
                        _allStandbyStep = _AllStandbyStep.STB_SEND;
                    }
                    break;
                case _AllStandbyStep.STB_SEND:
                    _done = true;
                    break;
                }
                if (_done)
                {
                    Logging.info(this, "close app after all-standby on startup");
                    SystemNavigator.pop();
                }
            }
        }
    }
}
