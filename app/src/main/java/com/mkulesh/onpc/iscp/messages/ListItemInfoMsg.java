package com.mkulesh.onpc.iscp.messages;

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

/*
 * NET/USB List Info (Update item, need processing XML data, for Network Control Only)
 */
public class ListItemInfoMsg extends ISCPMessage
{
    public final static String CODE = "NLU";

    private final int index, number;

    ListItemInfoMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        index = Integer.parseInt(data.substring(0, 4), 16);
        number = Integer.parseInt(data.substring(4, 8), 16);
    }

    @Override
    public String toString()
    {
        return CODE + "[" + data + "; " + index + "/" + number + "]";
    }
}
