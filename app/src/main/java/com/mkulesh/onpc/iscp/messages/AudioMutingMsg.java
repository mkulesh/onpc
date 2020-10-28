/*
 * Enhanced Controller for Onkyo and Pioneer
 * Copyright (C) 2018-2020. Mikhail Kulesh
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

import androidx.annotation.NonNull;
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

    public enum Status implements StringParameterIf
    {
        NONE("N/A", R.string.audio_muting_none),
        OFF("00", R.string.audio_muting_off),
        ON("01", R.string.audio_muting_on),
        TOGGLE("TG", R.string.audio_muting_toggle);

        final String code;

        @StringRes
        final int descriptionId;

        Status(final String code, @StringRes final int descriptionId)
        {
            this.code = code;
            this.descriptionId = descriptionId;
        }

        public String getCode()
        {
            return code;
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
}
