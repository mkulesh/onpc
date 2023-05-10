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

import com.jayway.jsonpath.JsonPath;
import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;

/*
 * Firmware Update message
 */
public class FirmwareUpdateMsg extends ISCPMessage
{
    public final static String CODE = "UPD";

    public enum Status implements DcpStringParameterIf
    {
        NONE("N/A", "N/A", R.string.device_firmware_none),
        ACTUAL("FF", "update_none", R.string.device_firmware_actual),
        NEW_VERSION("00", "update_exist", R.string.device_firmware_new_version),
        NEW_VERSION_NORMAL("01", "N/A", R.string.device_firmware_new_version),
        NEW_VERSION_FORCE("02", "N/A", R.string.device_firmware_new_version),
        UPDATE_STARTED("Dxx-xx", "N/A", R.string.device_firmware_update_started),
        UPDATE_COMPLETE("CMP", "N/A", R.string.device_firmware_update_complete),
        NET("NET", "N/A", R.string.device_firmware_net);

        final String code, dcpCode;

        @StringRes
        final int descriptionId;

        Status(final String code, final String dcpCode, @StringRes final int descriptionId)
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

    FirmwareUpdateMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        status = (Status) searchParameter(data, Status.values(), Status.NONE);
    }

    public FirmwareUpdateMsg(Status status)
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
        return CODE + "[" + data + "; STATUS=" + status.getCode() + "]";
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

    /*
     * Denon control protocol
     */
    private final static String HEOS_COMMAND = "player/check_update";

    @Nullable
    public static FirmwareUpdateMsg processHeosMessage(@NonNull final String command, @NonNull final String heosMsg)
    {
        if (HEOS_COMMAND.equals(command))
        {
            final Status s = (Status) searchDcpParameter(
                    JsonPath.read(heosMsg, "$.payload.update"), Status.values(), null);
            if (s != null)
            {
                return new FirmwareUpdateMsg(s);
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
            return "heos://" + HEOS_COMMAND + "?pid=" + DCP_HEOS_PID;
        }
        return null;
    }
}
