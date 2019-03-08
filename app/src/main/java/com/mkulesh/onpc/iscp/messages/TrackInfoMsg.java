/*
 * Copyright (C) 2018. Mikhail Kulesh
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

import android.support.annotation.NonNull;

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

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
            throw new Exception("Can not find parameter split character in message " + raw.toString());
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

    public Integer getCurrentTrack()
    {
        return currentTrack;
    }

    public Integer getMaxTrack()
    {
        return maxTrack;
    }

    public static String getTrackInfo(Integer currentTrack, Integer maxTrack)
    {
        final StringBuilder str = new StringBuilder();
        str.append(currentTrack != null ? Integer.toString(currentTrack) : "----");
        str.append("/");
        str.append(maxTrack != null ? Integer.toString(maxTrack) : "----");
        return str.toString();
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + currentTrack + "; " + maxTrack + "]";
    }

}
