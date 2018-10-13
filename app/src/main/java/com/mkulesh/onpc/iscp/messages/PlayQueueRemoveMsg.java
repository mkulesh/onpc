package com.mkulesh.onpc.iscp.messages;

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

/*
 * Remove from PlayQueue List (from Network Control Only)
 */
public class PlayQueueRemoveMsg extends ISCPMessage
{
    public final static String CODE = "PQR";

    // Remove Type: 0:Specify Line, (1:ALL)
    private final int type;

    // The Index number in the PlayQueue of the item to delete(0000-FFFF : 1st to 65536th Item [4 HEX digits] )
    private final int itemIndex;

    public PlayQueueRemoveMsg(final int type, final int itemIndex)
    {
        super(0, null);
        this.type = type;
        this.itemIndex = itemIndex;
    }

    @Override
    public String toString()
    {
        return CODE + "[TYPE=" + Integer.toString(type) + "; INDEX=" + Integer.toString(itemIndex) + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        final String param = Integer.toString(type) +
                String.format("%04x", itemIndex);
        return new EISCPMessage('1', CODE, param);
    }
}
