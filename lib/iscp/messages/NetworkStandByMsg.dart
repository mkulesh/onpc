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

import "../../constants/Strings.dart";
import "../EISCPMessage.dart";
import "EnumParameterMsg.dart";

enum NetworkStandBy
{
    NONE,
    OFF,
    ON
}

/*
 * Network Standby Settings (for Network Control Only and Available if AVR is PowerOn)
 */
class NetworkStandByMsg extends EnumParameterMsg<NetworkStandBy>
{
    static const String CODE = "NSB";

    static const ExtEnum<NetworkStandBy> ValueEnum = ExtEnum<NetworkStandBy>([
        EnumItem.code(NetworkStandBy.NONE, "N/A",
            descrList: Strings.l_device_two_way_switch_none, defValue: true),
        EnumItem.code(NetworkStandBy.OFF, "OFF",
            descrList: Strings.l_device_two_way_switch_off),
        EnumItem.code(NetworkStandBy.ON, "ON",
            descrList: Strings.l_device_two_way_switch_on)
    ]);

    NetworkStandByMsg(EISCPMessage raw) : super(CODE, raw, ValueEnum);

    NetworkStandByMsg.output(NetworkStandBy v) : super.output(CODE, v, ValueEnum);

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }
}
