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
import com.mkulesh.onpc.iscp.ISCPMessage;

/*
 * System Power Command
 */
public class PowerStatusMsg extends ISCPMessage
{
    public final static String CODE = "PWR";

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
        super(raw);
        powerStatus = (PowerStatus) searchParameter(data, PowerStatus.values(), powerStatus);
    }

    public PowerStatusMsg(PowerStatus powerStatus)
    {
        super(0, null);
        this.powerStatus = powerStatus;
    }

    public PowerStatus getPowerStatus()
    {
        return powerStatus;
    }

    @Override
    public String toString()
    {
        return CODE + "[" + data + "; PWR=" + powerStatus.toString() + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return new EISCPMessage('1', CODE, powerStatus.getCode());
    }
}
