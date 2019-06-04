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

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ZonedMessage;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;
import androidx.annotation.StringRes;

/*
 * Master Volume Command
 */
public class MasterVolumeMsg extends ZonedMessage
{
    final static String CODE = "MVL";
    final static String ZONE2_CODE = "ZVL";
    final static String ZONE3_CODE = "VL3";
    final static String ZONE4_CODE = "VL4";

    public final static String[] ZONE_COMMANDS = new String[]{ CODE, ZONE2_CODE, ZONE3_CODE, ZONE4_CODE };

    public final static int NO_LEVEL = -1;
    public static final int MAX_VOLUME_0_5_STEP = 0xC8;
    public static final int MAX_VOLUME_1_STEP = 0x64;

    public enum Command implements StringParameterIf
    {
        UP(R.string.master_volume_up, R.drawable.volume_amp_up),
        DOWN(R.string.master_volume_down, R.drawable.volume_amp_down),
        UP1(R.string.master_volume_up1, R.drawable.volume_amp_up),
        DOWN1(R.string.master_volume_down1, R.drawable.volume_amp_down);

        @StringRes
        final int descriptionId;

        @DrawableRes
        final int imageId;

        Command(@StringRes final int descriptionId, @DrawableRes final int imageId)
        {
            this.descriptionId = descriptionId;
            this.imageId = imageId;
        }

        public String getCode()
        {
            return toString();
        }

        @StringRes
        public int getDescriptionId()
        {
            return descriptionId;
        }

        @DrawableRes
        public int getImageId()
        {
            return imageId;
        }
    }

    private final Command command;
    private int volumeLevel = NO_LEVEL;

    MasterVolumeMsg(EISCPMessage raw) throws Exception
    {
        super(raw, ZONE_COMMANDS);
        try
        {
            volumeLevel = Integer.parseInt(data, 16);
        }
        catch (Exception e)
        {
            // nothing to do
        }
        command = null;
    }

    public MasterVolumeMsg(int zoneIndex, Command level)
    {
        super(0, null, zoneIndex);
        this.command = level;
        this.volumeLevel = NO_LEVEL;
    }

    public MasterVolumeMsg(int zoneIndex, int volumeLevel)
    {
        super(0, null, zoneIndex);
        this.command = null;
        this.volumeLevel = volumeLevel;
    }

    @Override
    public String getZoneCommand()
    {
        return ZONE_COMMANDS[zoneIndex];
    }

    public int getVolumeLevel()
    {
        return volumeLevel;
    }

    @NonNull
    @Override
    public String toString()
    {
        return getZoneCommand() + "[" + data
                + "; ZONE_INDEX=" + zoneIndex
                + "; LEVEL=" + volumeLevel
                + "; CMD=" + (command != null ? command.toString() : "null") + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        String par = "";
        if (command != null)
        {
            par = command.getCode();
        }
        else if (volumeLevel != NO_LEVEL)
        {
            par = String.format("%02x", volumeLevel);
        }
        return new EISCPMessage(getZoneCommand(), par);
    }

    @Override
    public boolean hasImpactOnMediaList()
    {
        return false;
    }
}
