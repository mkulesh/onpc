/*
 * Copyright (C) 2018. Mikhail Kulesh
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

/*
 * System Power Command
 */
public class PowerStatusMsg extends ZonedMessage
{
    final static String MAIN_CODE = "PWR";
    final static String ZONE2_CODE = "ZPW";
    final static String ZONE3_CODE = "PW3";
    final static String ZONE4_CODE = "PW4";

    public final static String[] ZONE_COMMANDS = new String[]{ MAIN_CODE, ZONE2_CODE, ZONE3_CODE, ZONE4_CODE };

    /*
    * Play Status: "00": System Standby, "01":  System On, "ALL": All Zone(including Main Zone) Standby
    */
    public enum PowerStatus implements StringParameterIf
    {
        STB("00"), ON("01"), ALL_STB("ALL");
        final String code;

        PowerStatus(String code)
        {
            this.code = code;
        }

        public String getCode()
        {
            return code;
        }
    }

    private PowerStatus powerStatus = PowerStatus.STB;

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
        return new EISCPMessage('1', getZoneCommand(), powerStatus.getCode());
    }
}
