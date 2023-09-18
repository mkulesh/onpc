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

enum DigitalFilter
{
    NONE,
    F00,
    F01,
    F02,
    TOGGLE
}

/*
 * Dimmer Level Command
 */
class DigitalFilterMsg extends EnumParameterMsg<DigitalFilter>
{
    static const String CODE = "DGF";

    static const ExtEnum<DigitalFilter> ValueEnum = ExtEnum<DigitalFilter>([
        EnumItem.code(DigitalFilter.NONE, "N/A",
            descrList: Strings.l_device_digital_filter_none, defValue: true),
        EnumItem.code(DigitalFilter.F00, "00",
            descrList: Strings.l_device_digital_filter_slow),
        EnumItem.code(DigitalFilter.F01, "01",
            descrList: Strings.l_device_digital_filter_sharp),
        EnumItem.code(DigitalFilter.F02, "02",
            descrList: Strings.l_device_digital_filter_short),
        EnumItem.code(DigitalFilter.TOGGLE, "UP",
            descrList: Strings.l_device_digital_filter_toggle)
    ]);

    DigitalFilterMsg(EISCPMessage raw) : super(CODE, raw, ValueEnum);

    DigitalFilterMsg.output(DigitalFilter v) : super.output(CODE, v, ValueEnum);

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }
}
