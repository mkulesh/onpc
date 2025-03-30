/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2025 by Mikhail Kulesh
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

enum DcpAllZoneStereo
{
    NONE,
    ON,
    OFF
}

/*
 * Denon control protocol - "All Zone Stereo" direct Control
 */
class DcpAllZoneStereoMsg extends EnumParameterMsg<DcpAllZoneStereo>
{
    static const String CODE = "D10";
    static const String _DCP_COMMAND = "MNZST";

    static List<String> getAcceptedDcpCodes()
    => [ _DCP_COMMAND ];

    static const ExtEnum<DcpAllZoneStereo> ValueEnum = ExtEnum<DcpAllZoneStereo>([
        EnumItem.code(DcpAllZoneStereo.NONE, "N/A",
            descrList: Strings.l_device_two_way_switch_none, defValue: true),
        EnumItem.code(DcpAllZoneStereo.OFF, "OFF",
            descrList: Strings.l_device_two_way_switch_off),
        EnumItem.code(DcpAllZoneStereo.ON, "ON",
            descrList: Strings.l_device_two_way_switch_on)
    ]);

    DcpAllZoneStereoMsg(EISCPMessage raw) : super(CODE, raw, ValueEnum);

    DcpAllZoneStereoMsg.output(DcpAllZoneStereo v) : super.output(CODE, v, ValueEnum);

    @override
    bool hasImpactOnMediaList()
    => false;

    static DcpAllZoneStereoMsg? processDcpMessage(String dcpMsg)
    {
        final EnumItem<DcpAllZoneStereo>? s = ValueEnum.valueByDcpCommand(_DCP_COMMAND, dcpMsg);
        return s != null ? DcpAllZoneStereoMsg.output(s.key) : null;
    }

    @override
    String? buildDcpMsg(bool isQuery)
    => buildDcpRequest(isQuery, _DCP_COMMAND, sep: " ");
}