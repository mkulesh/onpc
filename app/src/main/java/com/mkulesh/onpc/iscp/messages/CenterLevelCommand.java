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

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.utils.Utils;

import androidx.annotation.NonNull;

/*
 * Center (temporary) Level Command
 */
public class CenterLevelCommand extends ISCPMessage
{
    public final static String CODE = "CTL";

    public final static String KEY = "Center Level";
    public final static int NO_LEVEL = 0xFF;
    private int level;

    CenterLevelCommand(EISCPMessage raw) throws Exception
    {
        super(raw);
        try
        {
            level = Integer.parseInt(data, 16);
        }
        catch (Exception e)
        {
            level = NO_LEVEL;
        }
    }

    public CenterLevelCommand(int level)
    {
        super(0, null);
        this.level = level;
    }

    public int getLevel()
    {
        return level;
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + data + "; LEVEL=" + level + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return new EISCPMessage(CODE, Utils.intToneToString(level));
    }

    @Override
    public boolean hasImpactOnMediaList()
    {
        return false;
    }
}
