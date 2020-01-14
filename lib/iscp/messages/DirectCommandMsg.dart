/*
 * Copyright (C) 2020. Mikhail Kulesh
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

enum DirectCommand
{
    NONE,
    OFF,
    ON,
    TOGGLE
}

/*
 * Direct Command
 */
class DirectCommandMsg extends EnumParameterMsg<DirectCommand>
{
    static const String CODE = "DIR";
    static const String CONTROL = "Tone Direct";

    static const ExtEnum<DirectCommand> ValueEnum = ExtEnum<DirectCommand>([
        EnumItem.code(DirectCommand.NONE, "N/A",
            descrList: Strings.l_device_two_way_switch_none, defValue: true),
        EnumItem.code(DirectCommand.OFF, "00",
            descrList: Strings.l_device_two_way_switch_off),
        EnumItem.code(DirectCommand.ON, "01",
            descrList: Strings.l_device_two_way_switch_on),
        EnumItem.code(DirectCommand.TOGGLE, "TG",
            descrList: Strings.l_device_two_way_switch_toggle)
    ]);

    DirectCommandMsg(EISCPMessage raw) : super(CODE, raw, ValueEnum);

    DirectCommandMsg.output(DirectCommand v) : super.output(CODE, v, ValueEnum);

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }
}
