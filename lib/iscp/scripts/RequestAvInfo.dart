/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2024 by Mikhail Kulesh
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

import "dart:async";

import "../../utils/Logging.dart";
import "../ConnectionIf.dart";
import "../ISCPMessage.dart";
import "../MessageChannel.dart";
import "../State.dart";
import "../messages/AudioInformationMsg.dart";
import "MessageScriptIf.dart";

//
// For DCP protocol, audio-video info shall be requested periodically
//
class RequestAvInfo implements MessageScriptIf
{
    static final Duration DELAY = Duration(milliseconds: 5000);
    Timer? _timer;

    @override
    bool isValid(ProtoType protoType)
    => protoType == ProtoType.DCP;

    @override
    bool initialize(final State state, MessageChannel channel)
    => isValid(state.protoType);

    @override
    void start(State state, MessageChannel channel)
    {
        Logging.info(this, "started script");
        _timer = null;
    }

    @override
    void processMessage(ISCPMessage msg, State state, MessageChannel channel)
    {
        if (msg is AudioInformationMsg)
        {
            if (_timer == null)
            {
                Logging.info(this, "scheduling AV info request in " + DELAY.toString() + "ms");
                _timer = Timer(DELAY, ()
                {
                    _timer = null;
                    channel.sendQueries(state.trackState.getAvInfoQueries());
                });
            }
        }
    }
}
