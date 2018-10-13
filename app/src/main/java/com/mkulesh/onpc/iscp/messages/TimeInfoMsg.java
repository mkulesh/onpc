package com.mkulesh.onpc.iscp.messages;

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

/*
 * NET/USB Time Info
 */
public class TimeInfoMsg extends ISCPMessage
{
    public final static String CODE = "NTM";

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
        return currentTime;
    }

    public String getMaxTime()
    {
        return maxTime;
    }

    @Override
    public String toString()
    {
        return CODE + "[" + currentTime + "; " + maxTime + "]";
    }
}
