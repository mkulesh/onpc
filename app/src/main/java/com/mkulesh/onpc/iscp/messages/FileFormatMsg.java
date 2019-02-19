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
 * NET/USB File Info (variable-length, 64 ASCII letters max)
 */
public class FileFormatMsg extends ISCPMessage
{
    public final static String CODE = "NFI";

    private final String format, sampleFrequency, bitRate;

    FileFormatMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        final String[] pars = data.split(PAR_SEP);
        format = pars.length > 0 ? pars[0] : "";
        sampleFrequency = pars.length > 1 ? pars[1] : "";
        bitRate = pars.length > 2 ? pars[2] : "";
    }

    public String getFullFormat()
    {
        final StringBuilder str = new StringBuilder();
        str.append(format);
        if (!str.toString().isEmpty() && !sampleFrequency.isEmpty())
        {
            str.append("/");
        }
        str.append(sampleFrequency);
        if (!str.toString().isEmpty() && !bitRate.isEmpty())
        {
            str.append("/");
        }
        str.append(bitRate);
        return str.toString();
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + data
                + "; FORMAT=" + format
                + "; FREQUENCY=" + sampleFrequency
                + "; BITRATE=" + bitRate
                + "]";
    }

}
