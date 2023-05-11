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

import java.util.ArrayList;
import java.util.Collections;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

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

    /*
     * Denon control protocol
     */
    private final static String DCP_COMMAND_STATUS = "OPTPSTUNER";

    @NonNull
    public static ArrayList<String> getAcceptedDcpCodes()
    {
        return new ArrayList<>(Collections.singletonList(DCP_COMMAND_STATUS));
    }

    @Nullable
    public static PresetMemoryMsg processDcpMessage(@NonNull String dcpMsg)
    {
        if (dcpMsg.startsWith(DCP_COMMAND_STATUS))
        {
            final String par = dcpMsg.substring(DCP_COMMAND_STATUS.length()).trim();
            final String[] pars = par.split(" ");
            if (pars.length > 1)
            {
                return new PresetMemoryMsg(Integer.parseInt(pars[0]));
            }
        }
        return null;
    }

    @SuppressLint("DefaultLocale")
    @Nullable
    @Override
    public String buildDcpMsg(boolean isQuery)
    {
        // For some reason, TPANMEM does not work for DAB stations:
        // return "TPANMEM" + (isQuery ? DCP_MSG_REQ : String.format("%02d", preset));
        // Use APP_COMMAND instead:
        return String.format("<cmd id=\"1\">SetTunerPresetMemory</cmd><presetno>%d</presetno>", preset);
    }
}
