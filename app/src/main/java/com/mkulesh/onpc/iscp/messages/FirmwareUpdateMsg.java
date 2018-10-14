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
 * Firmware Update message
 */
public class FirmwareUpdateMsg extends ISCPMessage
{
    public final static String CODE = "UPD";
    public final static String UPD_NET = "NET";
    private final boolean newFirmware;

    FirmwareUpdateMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        newFirmware = ("01".equals(data) || "02".equals(data));
    }

    public boolean isNewFirmware()
    {
        return newFirmware;
    }

    @Override
    public String toString()
    {
        return CODE + "[NEW_VERSION=" + newFirmware + "]";
    }
}
