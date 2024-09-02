/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2024 by Mikhail Kulesh
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

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ZonedMessage;
import com.mkulesh.onpc.utils.Logging;

import java.util.ArrayList;
import java.util.Collections;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;

/*
 * Preset Command (Include Tuner Pack Model Only)
 */
public class PresetCommandMsg extends ZonedMessage
{
    public final static String CODE = "PRS";
    final static String ZONE2_CODE = "PRZ";
    final static String ZONE3_CODE = "PR3";
    final static String ZONE4_CODE = "PR4";

    public final static String[] ZONE_COMMANDS = new String[]{ CODE, ZONE2_CODE, ZONE3_CODE, ZONE4_CODE };

    public final static int NO_PRESET = -1;

    public enum Command implements DcpStringParameterIf
    {
        UP(R.string.preset_command_up, R.drawable.cmd_right),
        DOWN(R.string.preset_command_down, R.drawable.cmd_left);

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

        @NonNull
        public String getDcpCode()
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
    private final ReceiverInformationMsg.Preset presetConfig;
    private int preset = NO_PRESET;

    PresetCommandMsg(EISCPMessage raw) throws Exception
    {
        super(raw, ZONE_COMMANDS);
        command = (Command) searchParameter(data, Command.values(), null);
        presetConfig = null;
        try
        {
            preset = command == null ? Integer.parseInt(data, 16) : NO_PRESET;
        }
        catch (Exception e)
        {
            // nothing to do
        }
    }

    public PresetCommandMsg(int zoneIndex, final String command)
    {
        super(ZONE_COMMANDS, zoneIndex, command);
        this.command = (Command) searchParameter(command, Command.values(), null);
        this.presetConfig = null;
        this.preset = NO_PRESET;
    }

    public PresetCommandMsg(int zoneIndex, final ReceiverInformationMsg.Preset presetConfig, final int preset)
    {
        super(0, null, zoneIndex);
        this.command = null;
        this.presetConfig = presetConfig;
        this.preset = preset;
    }

    @Override
    public String getZoneCommand()
    {
        return ZONE_COMMANDS[zoneIndex];
    }

    public Command getCommand()
    {
        return command;
    }

    public ReceiverInformationMsg.Preset getPresetConfig()
    {
        return presetConfig;
    }

    public int getPreset()
    {
        return preset;
    }

    @NonNull
    @Override
    public String toString()
    {
        return getZoneCommand() + "[" + data
                + "; ZONE_INDEX=" + zoneIndex
                + "; CMD=" + (command != null ? command.toString() : "null")
                + "; PRS_CFG=" + (presetConfig != null ? presetConfig.getName() : "null")
                + "; PRESET=" + preset + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        String par = "";
        if (command != null)
        {
            par = command.getCode();
        }
        else if (presetConfig != null)
        {
            par = String.format("%02x", presetConfig.getId());
        }
        return new EISCPMessage(getZoneCommand(), par);
    }

    @Override
    public boolean hasImpactOnMediaList()
    {
        return false;
    }

    /*
     * Denon control protocol. The same message is used for both zones.
     */
    private final static String DCP_COMMAND = "TPAN";
    private final static String DCP_COMMAND_OFF = "OFF";

    @NonNull
    public static ArrayList<String> getAcceptedDcpCodes()
    {
        return new ArrayList<>(Collections.singletonList(DCP_COMMAND));
    }

    public static PresetCommandMsg processDcpMessage(@NonNull String dcpMsg, int zone)
    {
        if (dcpMsg.startsWith(DCP_COMMAND))
        {
            final String par = dcpMsg.substring(DCP_COMMAND.length()).trim();
            if (par.equalsIgnoreCase(DCP_COMMAND_OFF))
            {
                return new PresetCommandMsg(zone, null, NO_PRESET);
            }
            try
            {
                final int preset = Integer.parseInt(par);
                return new PresetCommandMsg(zone, null, preset);
            }
            catch (Exception e)
            {
                Logging.info(PresetCommandMsg.class, "Unable to parse preset " + par);
                return null;
            }
        }
        return null;
    }

    @SuppressLint("DefaultLocale")
    @Nullable
    @Override
    public String buildDcpMsg(boolean isQuery)
    {
        return DCP_COMMAND + (isQuery ? DCP_MSG_REQ :
                (command != null ? command.getDcpCode() : String.format("%02d", preset)));
    }

}
