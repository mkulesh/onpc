package com.mkulesh.onpc.iscp.messages;

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

/*
 * NET/USB Device Name
 */
class DeviceNameMsg extends ISCPMessage
{
    public final static String CODE = "NDN";

    DeviceNameMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
    }

    @Override
    public String toString()
    {
        return CODE + "[" + data + "]";
    }
}
