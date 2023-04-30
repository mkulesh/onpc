/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2022 by Mikhail Kulesh
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

package com.mkulesh.onpc.iscp.messages;

import com.mkulesh.onpc.iscp.ISCPMessage;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

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
public class DcpMediaEventMsg extends ISCPMessage
{
    public final static String CODE = "D07";

    DcpMediaEventMsg(final String event)
    {
        super(0, event);
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + data + "]";
    }

    /*
     * Denon control protocol
     */
    public final static String HEOS_EVENT_QUEUE = "event/player_queue_changed";
    public final static String HEOS_EVENT_SERVICEOPT = "browse/set_service_option";

    @Nullable
    public static DcpMediaEventMsg processHeosMessage(@NonNull final String command)
    {
        if (HEOS_EVENT_QUEUE.equals(command) || HEOS_EVENT_SERVICEOPT.equals(command))
        {
            return new DcpMediaEventMsg(command);
        }
        return null;
    }
}
