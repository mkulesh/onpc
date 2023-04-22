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

import com.jayway.jsonpath.JsonPath;
import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/*
 * Denon control protocol - media item
 * Get Now Playing Media Command: heos://player/get_now_playing_media?pid=player_id
 */
public class DcpMediaItemMsg extends ISCPMessage
{
    public final static String CODE = "D06";

    private final int sid;

    DcpMediaItemMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        sid = -1;
    }

    DcpMediaItemMsg(final String mid, final int sid)
    {
        super(0, mid);
        this.sid = sid;
    }

    public int getSid()
    {
        return sid;
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + data + ", SID=" + sid + "]";
    }

    /*
     * Denon control protocol
     */
    private final static String HEOS_COMMAND = "player/get_now_playing_media";

    @Nullable
    public static DcpMediaItemMsg processHeosMessage(@NonNull final String command, @NonNull final String heosMsg)
    {
        if (HEOS_COMMAND.equals(command))
        {
            final String mid = JsonPath.read(heosMsg, "$.payload.mid");
            final int sid = JsonPath.read(heosMsg, "$.payload.sid");
            return new DcpMediaItemMsg(mid, sid);
        }
        return null;
    }

    @Nullable
    @Override
    public String buildDcpMsg(boolean isQuery)
    {
        if (isQuery)
        {
            return "heos://" + HEOS_COMMAND + "?pid=" + DCP_HEOS_PID;
        }
        return null;
    }
}
