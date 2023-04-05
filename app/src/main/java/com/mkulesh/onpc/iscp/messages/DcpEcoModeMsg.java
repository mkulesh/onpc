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
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;

/*
 * Denon control protocol - DCP ECO mode
 */
public class DcpEcoModeMsg extends ISCPMessage
{
    public final static String CODE = "D03";
    private final static String DCP_COMMAND = "ECO";

    public enum Status implements DcpStringParameterIf
    {
        NONE("N/A", R.string.device_two_way_switch_none),
        OFF("OFF", R.string.device_two_way_switch_off),
        ON("ON", R.string.device_two_way_switch_on),
        AUTO("AUTO", R.string.device_two_way_switch_auto);

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

        @NonNull
        public String getDcpCode()
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

    DcpEcoModeMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        status = (Status) searchParameter(data, Status.values(), Status.NONE);
    }

    public DcpEcoModeMsg(Status status)
    {
        super(0, null);
        this.status = status;
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

    @Nullable
    public static DcpEcoModeMsg processDcpMessage(@NonNull String dcpMsg)
    {
        final Status s = (Status) searchDcpParameter(DCP_COMMAND, dcpMsg, Status.values());
        return s != null ? new DcpEcoModeMsg(s) : null;
    }

    @Nullable
    @Override
    public String buildDcpMsg(boolean isQuery)
    {
        return DCP_COMMAND + (isQuery ? DCP_MSG_REQ : status.getDcpCode());
    }

    public static Status toggle(Status s)
    {
        switch (s)
        {
        case OFF:
            return Status.AUTO;
        case AUTO:
            return Status.ON;
        case ON:
            return Status.OFF;
        default:
            return Status.NONE;
        }
    }
}
