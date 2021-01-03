/*
 * Enhanced Controller for Onkyo and Pioneer Pro
 * Copyright (C) 2019-2021 by Mikhail Kulesh
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

enum AutoPower
{
    NONE,
    OFF,
    ON,
    TOGGLE
}

/*
 * Auto Power Command
 */
class AutoPowerMsg extends EnumParameterMsg<AutoPower>
{
    static const String CODE = "APD";

    static const ExtEnum<AutoPower> ValueEnum = ExtEnum<AutoPower>([
        EnumItem.code(AutoPower.NONE, "N/A",
            descrList: Strings.l_device_two_way_switch_none, defValue: true),
        EnumItem.code(AutoPower.OFF, "00",
            descrList: Strings.l_device_two_way_switch_off),
        EnumItem.code(AutoPower.ON, "01",
            descrList: Strings.l_device_two_way_switch_on),
        EnumItem.code(AutoPower.TOGGLE, "UP",
            descrList: Strings.l_device_two_way_switch_toggle)
    ]);

    AutoPowerMsg(EISCPMessage raw) : super(CODE, raw, ValueEnum);

    AutoPowerMsg.output(AutoPower v) : super.output(CODE, v, ValueEnum);

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }
}
