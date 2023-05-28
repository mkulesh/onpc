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
import "../EISCPMessage.dart";
import "EnumParameterMsg.dart";

enum PowerStatus
{
    STB, ON, ALL_STB, NONE
}

/*
 * System Power Command
 */
class PowerStatusMsg extends EnumParameterZonedMsg<PowerStatus>
{
    static const String CODE = "PWR";
    static const String ZONE2_CODE = "ZPW";
    static const String ZONE3_CODE = "PW3";
    static const String ZONE4_CODE = "PW4";

    static const List<String> ZONE_COMMANDS = [CODE, ZONE2_CODE, ZONE3_CODE, ZONE4_CODE];

    /*
     * Play Status: "00": System Standby, "01":  System On, "ALL": All Zone(including Main Zone) Standby
     */
    static const ExtEnum<PowerStatus> ValueEnum = ExtEnum<PowerStatus>([
        EnumItem.code(PowerStatus.STB, "00", dcpCode: "OFF"),
        EnumItem.code(PowerStatus.ON, "01", dcpCode: "ON"),
        EnumItem.code(PowerStatus.ALL_STB, "ALL", dcpCode: "STANDBY"),
        EnumItem.code(PowerStatus.NONE, "N/A", defValue: true)
    ]);

    PowerStatusMsg(EISCPMessage raw) : super(ZONE_COMMANDS, raw, ValueEnum);

    PowerStatusMsg.output(int zoneIndex, PowerStatus v) :
            super.output(ZONE_COMMANDS, zoneIndex, v, ValueEnum);

    /*
     * Denon control protocol
     */
    static const List<String> _DCP_COMMANDS = [ "ZM", "Z2", "Z3" ];

    static List<String> getAcceptedDcpCodes()
    => _DCP_COMMANDS;

    static PowerStatusMsg processDcpMessage(String dcpMsg)
    {
        for (int i = 0; i < _DCP_COMMANDS.length; i++)
        {
            final EnumItem<PowerStatus> s = ValueEnum.valueByDcpCommand(_DCP_COMMANDS[i], dcpMsg);
            return (s != null) ? PowerStatusMsg.output(i, s.key) : null;
        }
        return null;
    }

    @override
    String buildDcpMsg(bool isQuery)
    => (getValue.key == PowerStatus.ALL_STB) ?
        "PW" + getValue.getDcpCode : buildDcpRequest(isQuery, _DCP_COMMANDS);
}