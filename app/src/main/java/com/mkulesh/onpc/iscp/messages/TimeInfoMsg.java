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

package com.mkulesh.onpc.iscp.messages;

import android.annotation.SuppressLint;

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.utils.Utils;

import java.util.Map;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/*
 * NET/USB Time Info
 */
public class TimeInfoMsg extends ISCPMessage
{
    public final static String CODE = "NTM";
    public final static String INVALID_TIME = "--:--:--";

    /*
     * (Elapsed time/Track Time Max 99:59:59. If time is unknown, this response is --:--)
     */
    private final String currentTime;
    private final String maxTime;

    TimeInfoMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        final String[] pars = data.split(PAR_SEP);
        if (pars.length != 2)
        {
            throw new Exception("Can not find parameter split character in message " + raw);
        }
        currentTime = pars[0];
        maxTime = pars[1];
    }

    TimeInfoMsg(String currentTime, String maxTime)
    {
        super(0, null);
        this.currentTime = currentTime;
        this.maxTime = maxTime;
    }

    public String getCurrentTime()
    {
        return (currentTime == null || currentTime.isEmpty()) ? INVALID_TIME : currentTime;
    }

    public String getMaxTime()
    {
        return (maxTime == null || maxTime.isEmpty()) ? INVALID_TIME : maxTime;
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + currentTime + "; " + maxTime + "]";
    }

    /*
     * Denon control protocol
     * - Player Now Playing Progress
     * {
     * "heos": {
     *     "command": " event/player_now_playing_progress",
     *     "message": "pid=player_id&cur_pos=position_ms&duration=duration_ms"
     *     }
     * }
     */
    private final static String HEOS_COMMAND = "event/player_now_playing_progress";

    @Nullable
    @SuppressLint("SimpleDateFormat")
    public static TimeInfoMsg processHeosMessage(@NonNull final String command, @NonNull final Map<String, String> tokens)
    {
        if (HEOS_COMMAND.equals(command))
        {
            final String curPosStr = tokens.get("cur_pos");
            final String durationStr = tokens.get("duration");
            if (curPosStr != null && durationStr != null)
            {
                return new TimeInfoMsg(
                        Utils.millisToTime(Integer.parseInt(curPosStr)),
                        Utils.millisToTime(Integer.parseInt(durationStr)));
            }
        }
        return null;
    }
}
