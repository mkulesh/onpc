package com.mkulesh.onpc.iscp.messages;

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

/*
 * Reorder PlayQueue List (from Network Control Only)
 */
public class PlayQueueReorderMsg extends ISCPMessage
{
    public final static String CODE = "PQO";

    // The Index number in the PlayQueue of the item to be moved
    // (0000-FFFF : 1st to 65536th Item [4 HEX digits] )  .
    private final int itemIndex;

    // The Index number in the PlayQueue of destination.
    // (0000-FFFF : 1st to 65536th Item [4 HEX digits] )
    private final int targetIndex;

    public PlayQueueReorderMsg(final int itemIndex, final int targetIndex)
    {
        super(0, null);
        this.itemIndex = itemIndex;
        this.targetIndex = targetIndex;
    }

    @Override
    public String toString()
    {
        return CODE + "[INDEX=" + Integer.toString(itemIndex) + "; TARGET=" + Integer.toString(targetIndex) + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        final String param = String.format("%04x", itemIndex) +
                String.format("%04x", targetIndex);
        return new EISCPMessage('1', CODE, param);
    }
}
