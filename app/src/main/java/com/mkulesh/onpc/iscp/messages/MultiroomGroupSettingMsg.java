/*
 * Copyright (C) 2019. Mikhail Kulesh
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
import java.util.List;

import androidx.annotation.NonNull;

/*
 * Multiroom Group Setting Command
 */
public class MultiroomGroupSettingMsg extends ISCPMessage
{
    private final static String CODE = "MGS";
    public final static int TARGET_ZONE_ID = 1;

    public enum Command
    {
        ADD_SLAVE,
        GROUP_DISSOLUTION,
        REMOVE_SLAVE
    }

    private final Command command;
    private final int zone, groupId, maxDelay;
    private final List<String> devices = new ArrayList<>();

    public MultiroomGroupSettingMsg(final Command command, final int zone, final int groupId, final int maxDelay)
    {
        super(0, null);
        this.command = command;
        this.zone = zone;
        this.groupId = groupId;
        this.maxDelay = maxDelay;
    }

    @NonNull
    public List<String> getDevice()
    {
        return devices;
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + command.toString()
                + ", zone=" + zone
                + ", groupId=" + groupId
                + ", maxDelay=" + maxDelay
                + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        switch (command)
        {
        case ADD_SLAVE:
        {
            final StringBuilder cmd = new StringBuilder();
            cmd.append("<mgs zone=\"");
            cmd.append(zone);
            cmd.append("\"><groupid>");
            cmd.append(groupId);
            cmd.append("</groupid><maxdelay>");
            cmd.append(maxDelay);
            cmd.append("</maxdelay><devices>");
            for (String d : devices)
            {
                cmd.append("<device id=\"").append(d).append("\" zoneid=\"1\"/>");
            }
            cmd.append("</devices></mgs>");
            return new EISCPMessage(CODE, cmd.toString());
        }
        case GROUP_DISSOLUTION:
        {
            final StringBuilder cmd = new StringBuilder();
            cmd.append("<mgs zone=\"");
            cmd.append(zone);
            cmd.append("\"><groupid>");
            cmd.append(groupId);
            cmd.append("</groupid></mgs>");
            return new EISCPMessage(CODE, cmd.toString());
        }
        case REMOVE_SLAVE:
        {
            final StringBuilder cmd = new StringBuilder();
            cmd.append("<mgs zone=\"");
            cmd.append(zone);
            cmd.append("\"><groupid>");
            cmd.append(groupId);
            cmd.append("</groupid><maxdelay>");
            cmd.append(maxDelay);
            cmd.append("</maxdelay><devices>");
            for (String d : devices)
            {
                cmd.append("<device id=\"").append(d).append("\" zoneid=\"" + TARGET_ZONE_ID + "\"/>");
            }
            cmd.append("</devices></mgs>");
            return new EISCPMessage(CODE, cmd.toString());
        }
        }
        return null;
    }

    @Override
    public boolean hasImpactOnMediaList()
    {
        return false;
    }
}
