/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2024 by Mikhail Kulesh
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

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Map;

/*
 * NET/USB Track Info
 */
public class TrackInfoMsg extends ISCPMessage
{
    public final static String CODE = "NTR";

    /*
     * (Current Track/Total Track Max 9999. If Track is unknown, this response is ----)
     */
    private Integer currentTrack, maxTrack;

    TrackInfoMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        final String[] pars = data.split(PAR_SEP);
        if (pars.length != 2)
        {
            throw new Exception("Can not find parameter split character in message " + raw);
        }
        try
        {
            currentTrack = Integer.parseInt(pars[0]);
        }
        catch (Exception e)
        {
            currentTrack = null;
        }
        try
        {
            maxTrack = Integer.parseInt(pars[1]);
        }
        catch (Exception e)
        {
            maxTrack = null;
        }
    }

    private TrackInfoMsg(@Nullable Integer currentTrack, @Nullable Integer maxTrack)
    {
        super(0, null);
        this.currentTrack = currentTrack;
        this.maxTrack = maxTrack;
    }

    public TrackInfoMsg(@NonNull Integer currentTrack)
    {
        super(0, null);
        this.currentTrack = currentTrack;
        this.maxTrack = -1;
    }

    public Integer getCurrentTrack()
    {
        return currentTrack;
    }

    public Integer getMaxTrack()
    {
        return maxTrack;
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[DATA=" + data + "; CURR=" + currentTrack + "; MAX=" + maxTrack + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return new EISCPMessage(CODE, currentTrack + PAR_SEP + maxTrack);
    }

    /*
     * Denon control protocol
     * Request queue length: heos://player/get_queue?pid=PID&range=X,Y
     * Response: {"heos": {"command": "player/get_queue", "result": "success", "message": "pid=PID&range=X,Y&returned=17&count=17"}, "payload": []}
     */
    private final static String HEOS_COMMAND = "player/get_queue";

    @Nullable
    public static TrackInfoMsg processHeosMessage(@NonNull final String command, @NonNull final Map<String, String> tokens)
    {
        if (HEOS_COMMAND.equals(command))
        {
            final String countTag = tokens.get("count");
            final String rangeTag = tokens.get("range");
            if (countTag == null || rangeTag == null)
            {
                return null;
            }
            try
            {
                final int count = Integer.parseInt(countTag);
                if (count == 0)
                {
                    return new TrackInfoMsg(null, null);
                }
                final String[] rangeStr = rangeTag.split(",");
                if (rangeStr.length == 2 && rangeStr[0] != null && rangeStr[0].equals(rangeStr[1]))
                {
                    // process get_queue response with equal start and end items
                    final int current = Integer.parseInt(rangeStr[0]);
                    return new TrackInfoMsg(current + 1, count);
                }
            }
            catch (Exception e)
            {
                return null;
            }
        }
        return null;
    }

    @Nullable
    @Override
    public String buildDcpMsg(boolean isQuery)
    {
        if (currentTrack != null)
        {
            final int c = Math.max(0, currentTrack - 1);
            return "heos://" + HEOS_COMMAND + "?pid=" + ISCPMessage.DCP_HEOS_PID +
                    "&range=" + c + "," + c;
        }
        return null;
    }
}
