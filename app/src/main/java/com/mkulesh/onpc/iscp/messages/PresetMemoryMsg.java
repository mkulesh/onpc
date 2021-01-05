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

import androidx.annotation.NonNull;

/*
 * Preset Memory Command (Include Tuner Pack Model Only)
 * sets Preset No. 1 - 40 (In hexadecimal representation)
 */
public class PresetMemoryMsg extends ISCPMessage
{
    public final static String CODE = "PRM";
    public final static int MAX_NUMBER = 40;

    private int preset;

    PresetMemoryMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        try
        {
            preset = Integer.parseInt(data, 16);
        }
        catch (Exception e)
        {
            // nothing to do
        }
    }

    public PresetMemoryMsg(final int preset)
    {
        super(0, null);
        this.preset = preset;
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + preset + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return new EISCPMessage(CODE, String.format("%02x", preset));
    }

    @Override
    public boolean hasImpactOnMediaList()
    {
        return false;
    }
}
