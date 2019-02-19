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

import android.support.annotation.NonNull;
import android.support.annotation.StringRes;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ZonedMessage;

/*
 * Speaker A Command (For Main zone and Zone 2 only)
 */
public class SpeakerACommandMsg extends ZonedMessage
{
    final static String CODE = "SPA";
    final static String ZONE2_CODE = "ZPA";

    public final static String[] ZONE_COMMANDS = new String[]{ CODE, ZONE2_CODE, CODE, CODE };

    public enum Status implements StringParameterIf
    {
        NONE("N/A", R.string.device_two_way_switch_none),
        OFF("00", R.string.device_two_way_switch_off),
        ON("01", R.string.device_two_way_switch_on),
        TOGGLE("UP", R.string.speaker_a_command_toggle); /* Only available for main zone */

        final String code;
        final int descriptionId;

        Status(final String code, final int descriptionId)
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

    SpeakerACommandMsg(EISCPMessage raw) throws Exception
    {
        super(raw, ZONE_COMMANDS);
        status = (Status) searchParameter(data, Status.values(), Status.NONE);
    }

    public SpeakerACommandMsg(int zoneIndex, Status level)
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
        return new EISCPMessage('1', getZoneCommand(), status.getCode());
    }

    @Override
    public boolean hasImpactOnMediaList()
    {
        return false;
    }

    public static Status toggle(Status s)
    {
        return (s == Status.OFF) ? Status.ON : Status.OFF;
    }
}
