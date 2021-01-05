/*
 * Enhanced Controller for Onkyo and Pioneer
 * Copyright (C) 2018-2021 by Mikhail Kulesh
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
 * Subwoofer (temporary) Level Command
 */
public class SubwooferLevelCommandMsg extends ISCPMessage
{
    public final static String CODE = "SWL";

    public final static String KEY = "Subwoofer Level";
    public final static int NO_LEVEL = 0xFF;
    private int level, cmdLength;

    SubwooferLevelCommandMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        try
        {
            level = Integer.parseInt(data, 16);
            cmdLength = data.length();
        }
        catch (Exception e)
        {
            level = NO_LEVEL;
            cmdLength = NO_LEVEL;
        }
    }

    public SubwooferLevelCommandMsg(int level, int cmdLength)
    {
        super(0, null);
        this.level = level;
        this.cmdLength = cmdLength;
    }

    public int getLevel()
    {
        return level;
    }

    public int getCmdLength()
    {
        return cmdLength;
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + data + "; LEVEL=" + level + "; CMD_LENGTH=" + cmdLength + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return new EISCPMessage(CODE, Utils.intLevelToString(level, cmdLength));
    }

    @Override
    public boolean hasImpactOnMediaList()
    {
        return false;
    }
}
