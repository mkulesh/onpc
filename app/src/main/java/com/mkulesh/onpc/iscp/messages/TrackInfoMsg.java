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
