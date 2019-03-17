/*
 * Copyright (C) 2019. Mikhail Kulesh
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
 * Friendly Name Setting Command
 */
public class FriendlyNameMsg extends ISCPMessage
{
    public final static String CODE = "NFN";

    private final String friendlyName;

    FriendlyNameMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        String str = "";
        if (data != null && !data.equals("."))
        {
            str = data.startsWith(".") ? data.substring(1) : data;
        }
        friendlyName = str.trim();
    }

    public FriendlyNameMsg(String name)
    {
        super(0, null);
        this.friendlyName = name;
    }

    public String getFriendlyName()
    {
        return friendlyName;
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + friendlyName + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return new EISCPMessage(CODE,
                friendlyName.isEmpty() ? " " : friendlyName);
    }

    @Override
    public boolean hasImpactOnMediaList()
    {
        return false;
    }
}
