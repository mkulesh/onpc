package com.mkulesh.onpc.iscp.messages;

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

/*
 * NET/USB Artist Name (variable-length, 64 ASCII letters max)
 */
public class ArtistNameMsg extends ISCPMessage
{
    public final static String CODE = "NAT";

    ArtistNameMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
    }

    @Override
    public String toString()
    {
        return CODE + "[" + data + "]";
    }
}
