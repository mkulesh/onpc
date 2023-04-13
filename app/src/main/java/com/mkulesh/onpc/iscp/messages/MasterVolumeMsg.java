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

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ZonedMessage;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Arrays;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
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
    public static final int MAX_VOLUME_1_STEP = 0x64;

    @SuppressWarnings("unused")
    public enum Command implements DcpStringParameterIf
    {
        UP("UP", R.string.master_volume_up, R.drawable.volume_amp_up),
        DOWN("DOWN", R.string.master_volume_down, R.drawable.volume_amp_down),
        UP1("N/A", R.string.master_volume_up1, R.drawable.volume_amp_up),
        DOWN1("N/A", R.string.master_volume_down1, R.drawable.volume_amp_down);

        final String dcpCode;

        @StringRes
        final int descriptionId;

        @DrawableRes
        final int imageId;

        Command(final String dcpCode, @StringRes final int descriptionId, @DrawableRes final int imageId)
        {
            this.dcpCode = dcpCode;
            this.descriptionId = descriptionId;
            this.imageId = imageId;
        }

        public String getCode()
        {
            return toString();
        }

        @NonNull
        public String getDcpCode()
        {
            return dcpCode;
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

    private Command command;
    private int volumeLevel = NO_LEVEL;

    MasterVolumeMsg(EISCPMessage raw) throws Exception
    {
        super(raw, ZONE_COMMANDS);
        try
        {
            volumeLevel = Integer.parseInt(data, 16);
            command = null;
        }
        catch (Exception e)
        {
            command = (Command) searchParameter(data, Command.values(), Command.UP);
        }
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

    /*
     * Denon control protocol
     */
    private final static String[] DCP_COMMANDS = new String[]{ "MV", "Z2", "Z3" };

    @NonNull
    public static ArrayList<String> getAcceptedDcpCodes()
    {
        return new ArrayList<>(Arrays.asList(DCP_COMMANDS));
    }

    public static MasterVolumeMsg processDcpMessage(@NonNull String dcpMsg)
    {
        for (int i = 0; i < DCP_COMMANDS.length; i++)
        {
            if (dcpMsg.startsWith(DCP_COMMANDS[i]) && !dcpMsg.contains("MAX"))
            {
                final String par = dcpMsg.substring(DCP_COMMANDS[i].length()).trim();
                try
                {
                    float volumeLevel = Integer.parseInt(par);
                    int volumeLevelInt = i == 0 ?
                            scaleValueMainZone(volumeLevel, par) : scaleValueExtZone(volumeLevel);
                    return new MasterVolumeMsg(i, volumeLevelInt);
                }
                catch (Exception e)
                {
                    Logging.info(MasterVolumeMsg.class, "Unable to parse volume level " + par);
                    return null;
                }
            }
        }
        return null;
    }

    @Nullable
    @Override
    public String buildDcpMsg(boolean isQuery)
    {
        if (isQuery)
        {
            return DCP_COMMANDS[0] + DCP_MSG_REQ;
        }
        else if (zoneIndex < DCP_COMMANDS.length)
        {
            if (command != null)
            {
                return DCP_COMMANDS[zoneIndex] + command.getDcpCode();
            }
            else if (volumeLevel != NO_LEVEL)
            {
                final String par = zoneIndex == 0 ? getValueMainZone() : getValueExtZone();
                if (!par.isEmpty())
                {
                    return DCP_COMMANDS[zoneIndex] + par;
                }
            }
        }
        return null;
    }

    private static int scaleValueMainZone(float volumeLevel, String par)
    {
        if (par.length() > 2)
        {
            volumeLevel = volumeLevel / 10;
        }
        return (int) (2.0 * volumeLevel);
    }

    private String getValueMainZone()
    {
        final float f = 10.0f * ((float) volumeLevel / 2.0f);
        final DecimalFormat df = Utils.getDecimalFormat("000");
        final String fullStr = df.format(f);
        return fullStr.endsWith("0") ? fullStr.substring(0, 2) : (fullStr.endsWith("5") ? fullStr : "");
    }

    private static int scaleValueExtZone(float volumeLevel)
    {
        return (int) volumeLevel;
    }

    private String getValueExtZone()
    {
        final float f = (float) volumeLevel;
        final DecimalFormat df = Utils.getDecimalFormat("00");
        return df.format(f);
    }
}
