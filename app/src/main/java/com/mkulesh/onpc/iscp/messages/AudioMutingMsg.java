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

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ZonedMessage;
import com.mkulesh.onpc.utils.Utils;

import java.util.ArrayList;
import java.util.Arrays;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;

/*
 * Audio Muting Command
 */
public class AudioMutingMsg extends ZonedMessage
{
    final static String CODE = "AMT";
    final static String ZONE2_CODE = "ZMT";
    final static String ZONE3_CODE = "MT3";
    final static String ZONE4_CODE = "MT4";

    public final static String[] ZONE_COMMANDS = new String[]{ CODE, ZONE2_CODE, ZONE3_CODE, ZONE4_CODE };

    public enum Status implements DcpStringParameterIf
    {
        NONE("N/A", "N/A", R.string.audio_muting_none),
        OFF("00", "OFF", R.string.audio_muting_off),
        ON("01", "ON", R.string.audio_muting_on),
        TOGGLE("TG", "N/A", R.string.audio_muting_toggle);

        final String code, dcpCode;

        @StringRes
        final int descriptionId;

        Status(String code, String dcpCode, @StringRes final int descriptionId)
        {
            this.code = code;
            this.dcpCode = dcpCode;
            this.descriptionId = descriptionId;
        }

        public String getCode()
        {
            return code;
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
    }

    private final Status status;

    AudioMutingMsg(EISCPMessage raw) throws Exception
    {
        super(raw, ZONE_COMMANDS);
        status = (Status) searchParameter(data, Status.values(), Status.NONE);
    }

    public AudioMutingMsg(int zoneIndex, Status level)
    {
        super(0, null, zoneIndex);
        this.status = level;
    }

    @Override
    public String getZoneCommand()
    {
        return ZONE_COMMANDS[zoneIndex];
    }

    public Status getStatus()
    {
        return status;
    }

    @NonNull
    @Override
    public String toString()
    {
        return getZoneCommand() + "[" + data
                + "; ZONE_INDEX=" + zoneIndex
                + "; STATUS=" + status.toString() + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return new EISCPMessage(getZoneCommand(), status.getCode());
    }

    @Override
    public boolean hasImpactOnMediaList()
    {
        return false;
    }

    public static Status toggle(Status s, Utils.ProtoType proto)
    {
        return proto == Utils.ProtoType.ISCP ? Status.TOGGLE :
                ((s == Status.OFF) ? Status.ON : Status.OFF);
    }

    /*
     * Denon control protocol
     */
    private final static String[] DCP_COMMANDS = new String[]{ "MU", "Z2MU", "Z3MU" };

    @NonNull
    public static ArrayList<String> getAcceptedDcpCodes()
    {
        return new ArrayList<>(Arrays.asList(DCP_COMMANDS));
    }

    @Nullable
    public static AudioMutingMsg processDcpMessage(@NonNull String dcpMsg)
    {
        for (int i = 0; i < DCP_COMMANDS.length; i++)
        {
            final Status s = (Status) searchDcpParameter(DCP_COMMANDS[i], dcpMsg, Status.values());
            if (s != null)
            {
                return new AudioMutingMsg(i, s);
            }
        }
        return null;
    }

    @Nullable
    @Override
    public String buildDcpMsg(boolean isQuery)
    {
        if (zoneIndex < DCP_COMMANDS.length)
        {
            return DCP_COMMANDS[zoneIndex] + (isQuery ? DCP_MSG_REQ : status.getDcpCode());
        }
        return null;
    }
}
