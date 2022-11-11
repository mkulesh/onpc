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
import com.mkulesh.onpc.iscp.ISCPMessage;

import androidx.annotation.NonNull;
import androidx.annotation.StringRes;


/*
 * Late Night Command
 */
public class LateNightCommandMsg extends ISCPMessage
{
    public final static String CODE = "LTN";

    public enum Status implements StringParameterIf
    {
        NONE("N/A", R.string.device_late_night_none),
        OFF("00", R.string.device_late_night_off),
        LOW("01", R.string.device_late_night_low),
        HIGH("02", R.string.device_late_night_high),
        AUTO("03", R.string.device_late_night_auto),
        DISABLED("DISABLED", R.string.device_late_night_disabled),
        UP("UP", R.string.device_late_night_up);

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

    LateNightCommandMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        status = (Status) searchParameter(data, Status.values(), Status.DISABLED);
    }

    public LateNightCommandMsg(Status level)
    {
        super(0, null);
        this.status = level;
    }

    public Status getStatus()
    {
        return status;
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + status.toString() + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return new EISCPMessage(CODE, status.getCode());
    }

    @Override
    public boolean hasImpactOnMediaList()
    {
        return false;
    }
}