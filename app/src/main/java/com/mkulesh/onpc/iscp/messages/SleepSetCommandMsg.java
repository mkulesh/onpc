/*
 * Enhanced Controller for Onkyo and Pioneer
 * Copyright (C) 2018-2020. Mikhail Kulesh
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
 * Sleep Set Command
 */
public class SleepSetCommandMsg extends ISCPMessage
{
    public final static String CODE = "SLP";

    public final static int NOT_APPLICABLE = 0xFF;
    public final static int SLEEP_OFF = 0x00;
    private int sleepTime;

    SleepSetCommandMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        try
        {
            sleepTime = "OFF".equals(data) ? SLEEP_OFF : Integer.parseInt(data, 16);
        }
        catch (Exception e)
        {
            sleepTime = NOT_APPLICABLE;
        }
    }

    public SleepSetCommandMsg(int sleepTime)
    {
        super(0, null);
        this.sleepTime = sleepTime;
    }

    public int getSleepTime()
    {
        return sleepTime;
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + data + "; SLEEP_TIME=" + sleepTime + "min]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        final String cmd = sleepTime == SLEEP_OFF ? "OFF" : String.format("%02x", sleepTime);
        return new EISCPMessage(CODE, cmd);
    }

    @Override
    public boolean hasImpactOnMediaList()
    {
        return false;
    }

    public static int toggle(int sleepTime)
    {
        final int res = 15 * ((int) ((float) sleepTime / 15.0) + 1);
        return res > 90 ? 0 : res;
    }
}
