/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2023 by Mikhail Kulesh
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

enum DcpEcoMode
{
    NONE,
    OFF,
    ON,
    AUTO
}

/*
 * Denon control protocol - DCP ECO mode
 */
class DcpEcoModeMsg extends EnumParameterMsg<DcpEcoMode>
{
    static const String CODE = "D03";
    static const String _DCP_COMMAND = "ECO";

    static List<String> getAcceptedDcpCodes()
    => [ _DCP_COMMAND ];

    static const ExtEnum<DcpEcoMode> ValueEnum = ExtEnum<DcpEcoMode>([
        EnumItem.code(DcpEcoMode.NONE, "N/A",
            descrList: Strings.l_device_two_way_switch_none, defValue: true),
        EnumItem.code(DcpEcoMode.OFF, "OFF",
            descrList: Strings.l_device_two_way_switch_off),
        EnumItem.code(DcpEcoMode.ON, "ON",
            descrList: Strings.l_device_two_way_switch_on),
        EnumItem.code(DcpEcoMode.AUTO, "AUTO",
            descrList: Strings.l_device_two_way_switch_auto)
    ]);

    DcpEcoModeMsg(EISCPMessage raw) : super(CODE, raw, ValueEnum);

    DcpEcoModeMsg.toggle(EnumItem<DcpEcoMode> s) :
            super.output(CODE, _toggle(s.key), ValueEnum);

    DcpEcoModeMsg._dcp(DcpEcoMode v) : super.output(CODE, v, ValueEnum);

    @override
    bool hasImpactOnMediaList()
    => false;

    static DcpEcoModeMsg processDcpMessage(String dcpMsg)
    {
        final EnumItem<DcpEcoMode> s = ValueEnum.valueByDcpCommand(_DCP_COMMAND, dcpMsg);
        return s != null ? DcpEcoModeMsg._dcp(s.key) : null;
    }

    @override
    String buildDcpMsg(bool isQuery)
    => buildDcpRequest(isQuery, _DCP_COMMAND);

    static DcpEcoMode _toggle(DcpEcoMode s)
    {
        switch (s)
        {
        case DcpEcoMode.OFF:
            return DcpEcoMode.AUTO;
        case DcpEcoMode.AUTO:
            return DcpEcoMode.ON;
        case DcpEcoMode.ON:
            return DcpEcoMode.OFF;
        default:
            return DcpEcoMode.NONE;
        }
    }
}