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

package com.mkulesh.onpc.iscp;

public abstract class ZonedMessage extends ISCPMessage
{
    protected int zoneIndex;

    protected ZonedMessage(EISCPMessage raw, final String[] zoneCommands) throws Exception
    {
        super(raw);
        for (int i = 0; i < zoneCommands.length; i++)
        {
            if (zoneCommands[i].toUpperCase().equals(raw.getCode().toUpperCase()))
            {
                zoneIndex = i;
                return;
            }
        }
        throw new Exception("No zone defined for message " + raw.getCode());
    }

    @SuppressWarnings("SameParameterValue")
    protected ZonedMessage(final int messageId, final String data, int zoneIndex)
    {
        super(messageId, data);
        this.zoneIndex = zoneIndex;
    }

    @SuppressWarnings("unused")
    abstract public String getZoneCommand();
}
