/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2023 by Mikhail Kulesh
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU
 * General Public License as published by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
 * even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details. You should have received a copy of the GNU General
 * Public License along with this program.
 */

package com.mkulesh.onpc.iscp.messages;

import android.annotation.SuppressLint;

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/*
 * Reorder PlayQueue List (from Network Control Only)
 */
public class PlayQueueReorderMsg extends ISCPMessage
{
    final static String CODE = "PQO";

    // The Index number in the PlayQueue of the item to be moved
    // (0000-FFFF : 1st to 65536th Item [4 HEX digits] )  .
    private final int itemIndex;

    // The Index number in the PlayQueue of destination.
    // (0000-FFFF : 1st to 65536th Item [4 HEX digits] )
    private final int targetIndex;

    PlayQueueReorderMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        itemIndex = Integer.parseInt(data.substring(0, 4), 16);
        targetIndex = Integer.parseInt(data.substring(4), 16);
    }

    public PlayQueueReorderMsg(final int itemIndex, final int targetIndex)
    {
        super(0, null);
        this.itemIndex = itemIndex;
        this.targetIndex = targetIndex;
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[INDEX=" + itemIndex + "; TARGET=" + targetIndex + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        final String param = String.format("%04x", itemIndex) +
                String.format("%04x", targetIndex);
        return new EISCPMessage(CODE, param);
    }

    /*
     * Denon control protocol
     */
    @SuppressLint("DefaultLocale")
    @Nullable
    @Override
    public String buildDcpMsg(boolean isQuery)
    {
        return String.format("heos://player/move_queue_item?pid=%s&sqid=%d&dqid=%d",
                DCP_HEOS_PID, itemIndex, targetIndex);
    }
}
