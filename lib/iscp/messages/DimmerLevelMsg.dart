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
// @dart=2.9
import "../../constants/Strings.dart";
import "../EISCPMessage.dart";
import "EnumParameterMsg.dart";

enum DimmerLevel
{
    NONE,
    BRIGHT,
    DIM,
    DARK,
    SHUT_OFF,
    OFF,
    TOGGLE
}

/*
 * Dimmer Level Command
 */
class DimmerLevelMsg extends EnumParameterMsg<DimmerLevel>
{
    static const String CODE = "DIM";

    static const ExtEnum<DimmerLevel> ValueEnum = ExtEnum<DimmerLevel>([
        EnumItem.code(DimmerLevel.NONE, "N/A",
            descrList: Strings.l_device_dimmer_level_none, defValue: true),
        EnumItem.code(DimmerLevel.BRIGHT, "00",
            descrList: Strings.l_device_dimmer_level_bright),
        EnumItem.code(DimmerLevel.DIM, "01",
            descrList: Strings.l_device_dimmer_level_dim),
        EnumItem.code(DimmerLevel.DARK, "02",
            descrList: Strings.l_device_dimmer_level_dark),
        EnumItem.code(DimmerLevel.SHUT_OFF, "03",
            descrList: Strings.l_device_dimmer_level_shut_off),
        EnumItem.code(DimmerLevel.OFF, "08",
            descrList: Strings.l_device_dimmer_level_off),
        EnumItem.code(DimmerLevel.TOGGLE, "DIM",
            descrList: Strings.l_device_dimmer_level_toggle)
    ]);

    DimmerLevelMsg(EISCPMessage raw) : super(CODE, raw, ValueEnum);

    DimmerLevelMsg.output(DimmerLevel v) : super.output(CODE, v, ValueEnum);

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }
}
