/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2022 by Mikhail Kulesh
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
 * Remove from PlayQueue List (from Network Control Only)
 */
public class PlayQueueRemoveMsg extends ISCPMessage
{
    final static String CODE = "PQR";

    // Remove Type: 0:Specify Line, (1:ALL)
    private final int type;

    // The Index number in the PlayQueue of the item to delete(0000-FFFF : 1st to 65536th Item [4 HEX digits] )
    private final int itemIndex;

    PlayQueueRemoveMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        type = Integer.parseInt(data.substring(0, 1), 10);
        itemIndex = Integer.parseInt(data.substring(1), 16);
    }

    public PlayQueueRemoveMsg(final int type, final int itemIndex)
    {
        super(0, null);
        this.type = type;
        this.itemIndex = itemIndex;
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[TYPE=" + type + "; INDEX=" + itemIndex + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        final String param = type + String.format("%04x", itemIndex);
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
        switch (type)
        {
        case 0:
            return String.format("heos://player/remove_from_queue?pid=%s&qid=%d", DCP_HEOS_PID, itemIndex);
        case 1:
            return String.format("heos://player/clear_queue?pid=%s", DCP_HEOS_PID);
        }
        return null;
    }
}
