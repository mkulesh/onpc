package com.mkulesh.onpc.iscp.messages;

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

/*
 * NET/USB Album Name (variable-length, 64 ASCII letters max)
 */
public class AlbumNameMsg extends ISCPMessage
{
    public final static String CODE = "NAL";

    AlbumNameMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
    }

    @Override
    public String toString()
    {
        return CODE + "[" + data + "]";
    }
}
