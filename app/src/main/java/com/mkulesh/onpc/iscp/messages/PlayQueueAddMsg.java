/*
 * Copyright (C) 2018. Mikhail Kulesh
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

import android.support.annotation.NonNull;

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

/*
 * Add PlayQueue List in List View (from Network Control Only)
 */
public class PlayQueueAddMsg extends ISCPMessage
{
    public final static String CODE = "PQA";

    // The Index number of the item to be added in the content list
    // (0000-FFFF : 1st to 65536th Item [4 HEX digits] )
    // It is also possible to set folder.
    private final int itemIndex;

    // Add Type: 0:Now, 1:Next, 2:Last
    private final int type;

    // The Index number in the PlayQueue to be added(0000-FFFF : 1st to 65536th Item [4 HEX digits] )
    private final int targetIndex;

    public PlayQueueAddMsg(final int itemIndex, final int type)
    {
        super(0, null);
        this.itemIndex = itemIndex;
        this.type = type;
        this.targetIndex = 0;
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[INDEX=" + Integer.toString(itemIndex) + "; TYPE=" + Integer.toString(type) + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        final String param = String.format("%04x", itemIndex) +
                Integer.toString(type) +
                String.format("%04x", targetIndex);
        return new EISCPMessage('1', CODE, param);
    }
}
