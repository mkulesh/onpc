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
import com.mkulesh.onpc.iscp.ISCPMessage;

import java.util.ArrayList;
import java.util.Collections;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;

/*
 * Denon control protocol - DCP audio restorer
 */
public class DcpAudioRestorerMsg extends ISCPMessage
{
    public final static String CODE = "D04";
    private final static String DCP_COMMAND = "PSRSTR";

    @NonNull
    public static ArrayList<String> getAcceptedDcpCodes()
    {
        return new ArrayList<>(Collections.singletonList(DCP_COMMAND));
    }

    public enum Status implements DcpStringParameterIf
    {
        NONE("N/A", R.string.device_dcp_audio_restorer_none),
        OFF("OFF", R.string.device_dcp_audio_restorer_off),
        LOW("LOW", R.string.device_dcp_audio_restorer_low),
        MED("MED", R.string.device_dcp_audio_restorer_medium),
        HI("HI", R.string.device_dcp_audio_restorer_high);

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

    DcpAudioRestorerMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        status = (Status) searchParameter(data, Status.values(), Status.NONE);
    }

    public DcpAudioRestorerMsg(Status status)
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
    public static DcpAudioRestorerMsg processDcpMessage(@NonNull String dcpMsg)
    {
        final Status s = (Status) searchDcpParameter(DCP_COMMAND, dcpMsg, Status.values());
        return s != null ? new DcpAudioRestorerMsg(s) : null;
    }

    @Nullable
    @Override
    public String buildDcpMsg(boolean isQuery)
    {
        // A space is needed for this command
        return DCP_COMMAND + " " + (isQuery ? DCP_MSG_REQ : status.getDcpCode());
    }

    public static Status toggle(Status s)
    {
        switch (s)
        {
        case OFF:
            return Status.LOW;
        case LOW:
            return Status.MED;
        case MED:
            return Status.HI;
        case HI:
            return Status.OFF;
        default:
            return Status.NONE;
        }
    }
}
