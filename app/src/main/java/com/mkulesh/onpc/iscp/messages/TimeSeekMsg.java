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

import androidx.annotation.NonNull;

/*
 * NET/USB Time Seek
 */
public class TimeSeekMsg extends ISCPMessage
{
    private final static String CODE = "NTS";

    private enum TimeFormat
    {
        MM60_SS, /* MM60 here minutes between 0 and 59 */
        MM99_SS, /* MM99 here minutes between 0 and 99, like for CR-N765 */
        HH_MM_SS
    }

    private final TimeFormat timeFormat;
    private final int hours, minutes, seconds;

    public TimeSeekMsg(final String model, final int hours, final int minutes, final int seconds)
    {
        super(0, null);
        switch (model)
        {
        case "CR-N765":
            timeFormat = TimeFormat.MM99_SS;
            break;
        case "NT-503":
            timeFormat = hours > 0 ? TimeFormat.HH_MM_SS : TimeFormat.MM60_SS;
            break;
        default:
            timeFormat = TimeFormat.HH_MM_SS;
            break;
        }
        this.hours = hours;
        this.minutes = minutes;
        this.seconds = seconds;
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + getTimeAsString() + ", FORMAT=" + timeFormat.toString() + "]";
    }

    @SuppressLint("DefaultLocale")
    public String getTimeAsString()
    {
        int MM99_MAX_MIN = 99;
        switch (timeFormat)
        {
        case MM60_SS:
            return String.format("%02d", minutes)
                    + ":" + String.format("%02d", seconds);
        case MM99_SS:
            return String.format("%02d", Math.min(MM99_MAX_MIN, 60 * hours + minutes))
                    + ":" + String.format("%02d", seconds);
        case HH_MM_SS: /* it is also default case*/
        default:
            return String.format("%02d", hours)
                    + ":" + String.format("%02d", minutes)
                    + ":" + String.format("%02d", seconds);
        }
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return new EISCPMessage(CODE, getTimeAsString());
    }

    @Override
    public boolean hasImpactOnMediaList()
    {
        return false;
    }
}
