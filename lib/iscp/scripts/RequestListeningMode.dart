/*
 * Enhanced Controller for Onkyo and Pioneer Pro
 * Copyright (C) 2019-2021 by Mikhail Kulesh
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
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";
import "../MessageChannel.dart";
import "../State.dart";
import "../messages/ListeningModeMsg.dart";
import "MessageScriptIf.dart";

//
// For some models, it does seem that the listening mode is enabled some
// seconds after power on - as though it's got things to initialize before
// turning on the audio circuits. The initialization time is unknown.
// The solution is to periodically send a constant number of requests
// (for example 5 requests) with time interval 1 second until listening
// mode still be unknown.
//
class RequestListeningMode implements MessageScriptIf
{
    static final Duration LISTENING_MODE_DELAY = Duration(milliseconds: 1000);
    static final int MAX_LISTENING_MODE_REQUESTS = 5;
    int listeningModeRequests = 0;
    Timer listeningModeTimer;

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
    void start(State state, MessageChannel channel)
    {
        Logging.info(this, "started script");
        listeningModeRequests = 0;
        listeningModeTimer = null;
    }

    @override
    void processMessage(ISCPMessage msg, State state, MessageChannel channel)
    {
        if (msg is ListeningModeMsg &&
            msg.getValue.key == ListeningMode.MODE_FF &&
            listeningModeRequests < MAX_LISTENING_MODE_REQUESTS &&
            listeningModeTimer == null)
        {
            Logging.info(this, "scheduling listening mode request in " + LISTENING_MODE_DELAY.toString() + "ms");
            listeningModeTimer = Timer(LISTENING_MODE_DELAY, ()
            {
                listeningModeRequests++;
                listeningModeTimer = null;
                Logging.info(this, "re-requesting LM state [" + listeningModeRequests.toString() + "]...");
                channel.sendMessage(EISCPMessage.query(ListeningModeMsg.CODE));
            });
        }
    }
}
