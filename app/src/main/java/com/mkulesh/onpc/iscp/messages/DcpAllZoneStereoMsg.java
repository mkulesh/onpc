/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2025 by Mikhail Kulesh
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

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

import java.util.ArrayList;
import java.util.Collections;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/*
 * Denon control protocol - "All Zone Stereo" direct Control
 */
public class DcpAllZoneStereoMsg extends ISCPMessage
{
    public final static String CODE = "D10";
    public final static String DCP_COMMAND = "MNZST";

    @NonNull
    public static ArrayList<String> getAcceptedDcpCodes()
    {
        return new ArrayList<>(Collections.singletonList(DCP_COMMAND));
    }

    public enum Status implements DcpStringParameterIf
    {
        NONE("N/A"),
        OFF("OFF"),
        ON("ON");

        final String code;

        Status(final String code)
        {
            this.code = code;
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
    }

    private final Status status;

    DcpAllZoneStereoMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        status = (Status) searchParameter(data, Status.values(), Status.NONE);
    }

    public DcpAllZoneStereoMsg(Status status)
    {
        super(0, null);
        this.status = status;
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
    public static DcpAllZoneStereoMsg processDcpMessage(@NonNull String dcpMsg)
    {
        final Status s = (Status) searchDcpParameter(DCP_COMMAND, dcpMsg, Status.values());
        return s != null ? new DcpAllZoneStereoMsg(s) : null;
    }

    @Nullable
    @Override
    public String buildDcpMsg(boolean isQuery)
    {
        // A space is needed for this command
        return DCP_COMMAND + " " + (isQuery ? DCP_MSG_REQ : status.getDcpCode());
    }
}