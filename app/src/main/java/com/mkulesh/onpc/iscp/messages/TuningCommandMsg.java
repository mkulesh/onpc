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
import com.mkulesh.onpc.utils.Utils;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;

/*
 * Tuning Command (Include Tuner Pack Model Only)
 */
public class TuningCommandMsg extends ZonedMessage
{
    public final static String CODE = "TUN";
    final static String ZONE2_CODE = "TUZ";
    final static String ZONE3_CODE = "TU3";
    final static String ZONE4_CODE = "TU4";

    public final static String[] ZONE_COMMANDS = new String[]{ CODE, ZONE2_CODE, ZONE3_CODE, ZONE4_CODE };

    public enum Command implements StringParameterIf
    {
        UP(R.string.tuning_command_up, R.drawable.cmd_fast_forward),
        DOWN(R.string.tuning_command_down, R.drawable.cmd_fast_backward);

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
    private final String frequency;
    private final DcpTunerModeMsg.TunerMode dcpTunerMode;

    TuningCommandMsg(EISCPMessage raw) throws Exception
    {
        super(raw, ZONE_COMMANDS);
        this.command = (Command) searchParameter(data, Command.values(), null);
        this.frequency = (command == null) ? data : "";
        this.dcpTunerMode = DcpTunerModeMsg.TunerMode.NONE;
    }

    public TuningCommandMsg(int zoneIndex, final String command)
    {
        super(0, null, zoneIndex);
        this.command = (Command) searchParameter(command, Command.values(), null);
        this.frequency = "";
        this.dcpTunerMode = DcpTunerModeMsg.TunerMode.NONE;
    }

    public TuningCommandMsg(final String frequency, @NonNull DcpTunerModeMsg.TunerMode dcpTunerMode)
    {
        super(0, null, ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE);
        this.command = null;
        this.frequency = String.valueOf(frequency);
        this.dcpTunerMode = dcpTunerMode;
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

    public String getFrequency()
    {
        return frequency;
    }

    @NonNull
    @Override
    public String toString()
    {
        return getZoneCommand() + "[" + data
                + "; ZONE_INDEX=" + zoneIndex
                + "; CMD=" + (command != null ? command.toString() : "null")
                + "; FREQ=" + frequency
                + "; MODE=" + dcpTunerMode
                + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return new EISCPMessage(getZoneCommand(), command.getCode());
    }

    @Override
    public boolean hasImpactOnMediaList()
    {
        return false;
    }

    /*
     * Denon control protocol
     */
    private final static String DCP_COMMAND_FM = "TFAN";
    private final static String DCP_COMMAND_DAB = "DAFRQ";

    @Nullable
    public static TuningCommandMsg processDcpMessage(@NonNull String dcpMsg)
    {
        if (dcpMsg.startsWith(DCP_COMMAND_FM))
        {
            final String par = dcpMsg.substring(DCP_COMMAND_FM.length()).trim();
            if (Utils.isInteger(par))
            {
                return new TuningCommandMsg(par, DcpTunerModeMsg.TunerMode.FM);
            }
        }
        if (dcpMsg.startsWith(DCP_COMMAND_DAB))
        {
            final String par = dcpMsg.substring(DCP_COMMAND_DAB.length()).trim();
            return new TuningCommandMsg(par, DcpTunerModeMsg.TunerMode.DAB);
        }
        return null;
    }

    @Nullable
    @Override
    public String buildDcpMsg(boolean isQuery)
    {
        if (zoneIndex == ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE)
        {
            // Only available for main zone
            return DCP_COMMAND_FM + (isQuery ? DCP_MSG_REQ : (command != null ? command.name() : null));
        }
        return null;
    }

    @NonNull
    public DcpTunerModeMsg.TunerMode getDcpTunerMode()
    {
        return dcpTunerMode;
    }
}
