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

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ZonedMessage;

import java.util.ArrayList;
import java.util.Arrays;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/*
 * System Power Command
 */
public class PowerStatusMsg extends ZonedMessage
{
    public final static String CODE = "PWR";
    final static String ZONE2_CODE = "ZPW";
    final static String ZONE3_CODE = "PW3";
    final static String ZONE4_CODE = "PW4";

    public final static String[] ZONE_COMMANDS = new String[]{ CODE, ZONE2_CODE, ZONE3_CODE, ZONE4_CODE };

    /*
     * Play Status: "00": System Standby, "01":  System On, "ALL": All Zone(including Main Zone) Standby
     */
    public enum PowerStatus implements DcpStringParameterIf
    {
        STB("00", "OFF"),
        ON("01", "ON"),
        ALL_STB("ALL", "STANDBY"),
        NONE("N/A", "N/A");

        final String code, dcpCode;

        PowerStatus(String code, String dcpCode)
        {
            this.code = code;
            this.dcpCode = dcpCode;
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
    }

    private PowerStatus powerStatus = PowerStatus.NONE;

    PowerStatusMsg(EISCPMessage raw) throws Exception
    {
        super(raw, ZONE_COMMANDS);
        powerStatus = (PowerStatus) searchParameter(data, PowerStatus.values(), powerStatus);
    }

    public PowerStatusMsg(int zoneIndex, PowerStatus powerStatus)
    {
        super(0, null, zoneIndex);
        this.powerStatus = powerStatus;
    }

    @Override
    public String getZoneCommand()
    {
        return ZONE_COMMANDS[zoneIndex];
    }

    public PowerStatus getPowerStatus()
    {
        return powerStatus;
    }

    @NonNull
    @Override
    public String toString()
    {
        return getZoneCommand() + "[" + data
                + "; ZONE_INDEX=" + zoneIndex
                + "; PWR=" + powerStatus.toString() + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return new EISCPMessage(getZoneCommand(), powerStatus.getCode());
    }

    /*
     * Denon control protocol
     */
    private final static String[] DCP_COMMANDS = new String[]{ "ZM", "Z2", "Z3" };

    @NonNull
    public static ArrayList<String> getAcceptedDcpCodes()
    {
        return new ArrayList<>(Arrays.asList(DCP_COMMANDS));
    }

    @Nullable
    public static PowerStatusMsg processDcpMessage(@NonNull String dcpMsg)
    {
        for (int i = 0; i < DCP_COMMANDS.length; i++)
        {
            final PowerStatus s = (PowerStatus) searchDcpParameter(DCP_COMMANDS[i], dcpMsg, PowerStatus.values());
            if (s != null)
            {
                return new PowerStatusMsg(i, s);
            }
        }
        return null;
    }

    @Nullable
    @Override
    public String buildDcpMsg(boolean isQuery)
    {
        if (powerStatus == PowerStatus.ALL_STB)
        {
            return "PW" + powerStatus.getDcpCode();
        }
        else if (zoneIndex < DCP_COMMANDS.length)
        {
            return DCP_COMMANDS[zoneIndex] + (isQuery ? DCP_MSG_REQ : powerStatus.getDcpCode());
        }
        return null;
    }
}
