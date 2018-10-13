package com.mkulesh.onpc.iscp.messages;

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
        return format + "/" + sampleFrequency + "/" + bitRate;
    }

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
