/*
 * Enhanced Controller for Onkyo and Pioneer
 * Copyright (C) 2018-2021 by Mikhail Kulesh
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
    private String currentTime, maxTime;

    TimeInfoMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        final String[] pars = data.split(PAR_SEP);
        if (pars.length != 2)
        {
            throw new Exception("Can not find parameter split character in message " + raw.toString());
        }
        currentTime = pars[0];
        maxTime = pars[1];
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
}
