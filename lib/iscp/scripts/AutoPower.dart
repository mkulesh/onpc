/*
 * Copyright (C) 2020. Mikhail Kulesh
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

import "../../utils/Logging.dart";
import "../ISCPMessage.dart";
import "../MessageChannel.dart";
import "../State.dart";
import "../messages/PowerStatusMsg.dart";
import "MessageScriptIf.dart";

//
// The class performs receiver auto-power on startup
//
class AutoPower implements MessageScriptIf
{
    bool _done = false;

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
        if (!state.isOn && msg is PowerStatusMsg && !_done)
        {
            Logging.info(this, "request auto-power on startup");
            // Auto power-on once at first PowerStatusMsg
            final PowerStatusMsg cmd = PowerStatusMsg.output(state.getActiveZone, PowerStatus.ON);
            channel.sendMessage(cmd.getCmdMsg());
            _done = true;
        }
    }
}
