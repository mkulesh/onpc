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

enum LateNightMode
{
    NONE,
    DISABLED,
    OFF,
    LOW,
    HIGH,
    AUTO,
    UP
}

/*
 * Late Night Command
 */
class LateNightCommandMsg extends EnumParameterMsg<LateNightMode>
{
    static const String CODE = "LTN";

    static const ExtEnum<LateNightMode> ValueEnum = ExtEnum<LateNightMode>([
        EnumItem.code(LateNightMode.NONE, "NONE", descrList: Strings.l_device_late_night_none),
        EnumItem.code(LateNightMode.DISABLED, "N/A", descrList: Strings.l_device_late_night_disabled, defValue: true),
        EnumItem.code(LateNightMode.OFF, "00", descrList: Strings.l_device_late_night_off),
        EnumItem.code(LateNightMode.LOW, "01", descrList: Strings.l_device_late_night_low),
        EnumItem.code(LateNightMode.HIGH, "02", descrList: Strings.l_device_late_night_high),
        EnumItem.code(LateNightMode.AUTO, "03", descrList: Strings.l_device_late_night_auto),
        EnumItem.code(LateNightMode.UP, "UP", descrList: Strings.l_device_late_night_up)
    ]);

    LateNightCommandMsg(EISCPMessage raw) : super(CODE, raw, ValueEnum);

    LateNightCommandMsg.output(LateNightMode v) : super.output(CODE, v, ValueEnum);

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }
}