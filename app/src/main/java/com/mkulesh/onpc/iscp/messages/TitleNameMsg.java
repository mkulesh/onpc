package com.mkulesh.onpc.iscp.messages;

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

/*
 * NET/USB Title Name (variable-length, 64 ASCII letters max)
 */
public class TitleNameMsg extends ISCPMessage
{
    public final static String CODE = "NTI";

    TitleNameMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
    }

    @Override
    public String toString()
    {
        return CODE + "[" + data + "]";
    }
}
