/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2023 by Mikhail Kulesh
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
import "../DcpHeosMessage.dart";
import "../ISCPMessage.dart";

/*
 * Denon control protocol:
 * Player Queue Changed Event
 * {
 *   "heos": {
 *   "command": " event/player_queue_changed",
 *   "message": "pid='player_id'"
 *   }
 * }
 */
class DcpMediaEventMsg extends ISCPMessage
{
    static const String CODE = "D07";

    DcpMediaEventMsg._dcp(final String event) : super.output(CODE, event);

    static const String HEOS_EVENT_QUEUE = "event/player_queue_changed";
    static const String HEOS_EVENT_SERVICEOPT = "browse/set_service_option";

    static DcpMediaEventMsg processHeosMessage(DcpHeosMessage jsonMsg)
    {
        if (HEOS_EVENT_QUEUE == jsonMsg.command || HEOS_EVENT_SERVICEOPT == jsonMsg.command)
        {
            return DcpMediaEventMsg._dcp(jsonMsg.command);
        }
        return null;
    }
}