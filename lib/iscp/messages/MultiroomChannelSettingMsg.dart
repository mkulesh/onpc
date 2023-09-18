/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2023 by Mikhail Kulesh
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

import "../EISCPMessage.dart";
import "../ISCPMessage.dart";
import "EnumParameterMsg.dart";
import "MultiroomDeviceInformationMsg.dart";

/*
 * Multiroom Speaker (Channel) Setting Command
 */
class MultiroomChannelSettingMsg extends ISCPMessage
{
    static const String CODE = "MSS";

    late int _zone;
    late EnumItem<ChannelType> _channelType;

    MultiroomChannelSettingMsg(EISCPMessage raw) : super(CODE, raw)
    {
        _zone = ISCPMessage.nonNullInteger(getData.substring(0, 1), 10, 0);
        _channelType = MultiroomZone.ChannelTypeEnum.valueByCode(getData.substring(1));
    }

    MultiroomChannelSettingMsg.output(int zone, EnumItem<ChannelType> channelType) :
            super.output(CODE, zone.toString() + channelType.toString())
    {
        this._zone = zone;
        this._channelType = channelType;
    }

    EnumItem<ChannelType> get channelType
    => _channelType;

    @override
    String toString()
    => super.toString() + "[ZONE=" + _zone.toString() + ", TYPE=" + _channelType.toString() + "]";

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }

    static EnumItem<ChannelType> getUpType(ChannelType ch)
    {
        switch (ch)
        {
            case ChannelType.FL:
                return MultiroomZone.ChannelTypeEnum.valueByKey(ChannelType.FR);
            case ChannelType.FR:
                return MultiroomZone.ChannelTypeEnum.valueByKey(ChannelType.ST);
            case ChannelType.ST:
                return MultiroomZone.ChannelTypeEnum.valueByKey(ChannelType.FL);
            default:
                return MultiroomZone.ChannelTypeEnum.valueByKey(ch);
        }
    }
}
