/*
 * Enhanced Controller for Onkyo and Pioneer
 * Copyright (C) 2018-2021 by Mikhail Kulesh
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

import androidx.annotation.NonNull;

import static com.mkulesh.onpc.iscp.messages.MultiroomDeviceInformationMsg.ChannelType;

/*
 * Multiroom Speaker (Channel) Setting Command
 */
public class MultiroomChannelSettingMsg extends ISCPMessage
{
    public final static String CODE = "MSS";

    private int zone;
    private ChannelType channelType;

    MultiroomChannelSettingMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        try
        {
            zone = Integer.parseInt(data.substring(0, 1), 10);
            channelType = ChannelType.valueOf(data.substring(1));
        }
        catch (Exception e)
        {
            zone = 0;
            channelType = ChannelType.NONE;
        }
    }

    public MultiroomChannelSettingMsg(int zone, ChannelType channelType)
    {
        super(0, null);
        this.zone = zone;
        this.channelType = channelType;
    }

    public ChannelType getChannelType()
    {
        return channelType;
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[zone=" + zone + ", type=" + channelType.toString() + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return new EISCPMessage(CODE, zone + channelType.toString());
    }

    @Override
    public boolean hasImpactOnMediaList()
    {
        return false;
    }

    public static ChannelType getUpType(ChannelType ch)
    {
        switch (ch)
        {
        case FL:
            return ChannelType.FR;
        case FR:
            return ChannelType.ST;
        case ST:
            return ChannelType.FL;
        default:
            return ch;
        }
    }
}
