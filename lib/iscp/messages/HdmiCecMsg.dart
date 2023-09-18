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
import "../ConnectionIf.dart";
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";
import "EnumParameterMsg.dart";

enum HdmiCec
{
    NONE,
    OFF,
    ON,
    TOGGLE
}

/*
 * HDMI CEC settings
 */
class HdmiCecMsg extends EnumParameterMsg<HdmiCec>
{
    static const String CODE = "CEC";

    static const ExtEnum<HdmiCec> ValueEnum = ExtEnum<HdmiCec>([
        EnumItem.code(HdmiCec.NONE, "N/A",
            descrList: Strings.l_device_two_way_switch_none, defValue: true),
        EnumItem.code(HdmiCec.OFF, "00", dcpCode: "OFF",
            descrList: Strings.l_device_two_way_switch_off),
        EnumItem.code(HdmiCec.ON, "01", dcpCode: "ON",
            descrList: Strings.l_device_two_way_switch_on),
        EnumItem.code(HdmiCec.TOGGLE, "UP",
            descrList: Strings.l_device_two_way_switch_toggle)
    ]);

    HdmiCecMsg(EISCPMessage raw) : super(CODE, raw, ValueEnum);

    HdmiCecMsg.toggle(EnumItem<HdmiCec> s, ProtoType proto) :
            super.output(CODE, _toggle(s.key, proto), ValueEnum);

    HdmiCecMsg._dcp(HdmiCec v) : super.output(CODE, v, ValueEnum);

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }

    static HdmiCec _toggle(HdmiCec s, ProtoType proto)
    => (proto == ProtoType.ISCP) ? HdmiCec.TOGGLE :
        ((s == HdmiCec.OFF) ? HdmiCec.ON : HdmiCec.OFF);

    /*
     * Denon control protocol
     */
    static const String _DCP_COMMAND = "SSHOS";
    static const String _DCP_COMMAND_EXT = "CON";

    static List<String> getAcceptedDcpCodes()
    => [ _DCP_COMMAND ];

    static HdmiCecMsg? processDcpMessage(String dcpMsg)
    {
        final EnumItem<HdmiCec>? s = ValueEnum.valueByDcpCommand(_DCP_COMMAND + _DCP_COMMAND_EXT, dcpMsg);
        return s != null ? HdmiCecMsg._dcp(s.key) : null;
    }

    @override
    String? buildDcpMsg(bool isQuery)
    => _DCP_COMMAND + (isQuery ? (" " + ISCPMessage.DCP_MSG_REQ) :
        _DCP_COMMAND_EXT + " " + getValue.getDcpCode);
}
