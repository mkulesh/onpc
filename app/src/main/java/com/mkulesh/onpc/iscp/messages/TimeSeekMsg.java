package com.mkulesh.onpc.iscp.messages;

import android.annotation.SuppressLint;

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

/*
 * NET/USB Time Seek
 */
public class TimeSeekMsg extends ISCPMessage
{
    public final static String CODE = "NTS";

    private final int hours, minutes, seconds;

    public TimeSeekMsg(final int hours, final int minutes, final int seconds)
    {
        super(0, null);
        this.hours = hours;
        this.minutes = minutes;
        this.seconds = seconds;
    }

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
}
