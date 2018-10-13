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

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

/*
 * NET/USB Track Info
 */
public class TrackInfoMsg extends ISCPMessage
{
    public final static String CODE = "NTR";

    /*
     * (Current Track/Toral Track Max 9999. If Track is unknown, this response is ----)
     */
    private String currentTrack, maxTrack;

    TrackInfoMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        final String[] pars = data.split(PAR_SEP);
        if (pars.length != 2)
        {
            throw new Exception("Can not find parameter split character in message " + raw.toString());
        }
        currentTrack = pars[0];
        maxTrack = pars[1];
    }

    public String getCurrentTrack()
    {
        return currentTrack;
    }

    public String getMaxTrack()
    {
        return maxTrack;
    }

    public boolean isValidTrack()
    {
        return currentTrack != null && !currentTrack.equals("----");
    }

    @Override
    public String toString()
    {
        return CODE + "[" + currentTrack + "; " + maxTrack + "]";
    }

}
