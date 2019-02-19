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

import android.annotation.SuppressLint;
import android.support.annotation.NonNull;

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

/*
 * NET/USB Time Seek
 */
public class TimeSeekMsg extends ISCPMessage
{
    private final static String CODE = "NTS";

    private final int hours, minutes, seconds;

    public TimeSeekMsg(final int hours, final int minutes, final int seconds)
    {
        super(0, null);
        this.hours = hours;
        this.minutes = minutes;
        this.seconds = seconds;
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + Integer.toString(hours)
                + ":" + Integer.toString(minutes)
                + ":" + Integer.toString(seconds) + "]";
    }

    @SuppressLint("DefaultLocale")
    public String getTimeAsString()
    {
        return String.format("%02d", hours)
                + ":" + String.format("%02d", minutes)
                + ":" + String.format("%02d", seconds);
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return new EISCPMessage('1', CODE, getTimeAsString());
    }

    @Override
    public boolean hasImpactOnMediaList()
    {
        return false;
    }
}
