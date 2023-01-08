/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2022 by Mikhail Kulesh
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
import "../ISCPMessage.dart";
import "../MessageChannel.dart";
import "../State.dart";
import "../messages/PowerStatusMsg.dart";
import "MessageScriptIf.dart";

enum AutoPowerMode
{
    POWER_ON,
    ALL_STANDBY
}

//
// The class performs receiver auto-power on startup
//
class AutoPower implements MessageScriptIf
{
    final AutoPowerMode autoPowerMode;
    bool _done = false;

    AutoPower(this.autoPowerMode);

    @override
    bool isValid()
    {
        return true;
    }

    @override
    void initialize(final String data)
    {
        // nothing to do
    }

    @override
    void start(final State state, MessageChannel channel)
    {
        Logging.info(this, "started script");
        _done = false;
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
            else if (autoPowerMode == AutoPowerMode.ALL_STANDBY && state.isOn)
            {
                Logging.info(this, "request all-standby on startup");
                final PowerStatusMsg cmd = PowerStatusMsg.output(state.getActiveZone,
                    state.receiverInformation.zones.length > 1 ? PowerStatus.ALL_STB : PowerStatus.STB);
                channel.sendMessage(cmd.getCmdMsg());
                // Close the app since remote device is off
                SystemNavigator.pop();
                _done = true;
            }
        }
    }
}
