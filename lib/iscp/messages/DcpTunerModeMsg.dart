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

import "../../constants/Drawables.dart";
import "../../constants/Strings.dart";
import "../EISCPMessage.dart";
import "EnumParameterMsg.dart";

enum DcpTunerMode
{
    NONE,
    FM,
    DAB
}

/*
 * Denon control protocol - actual tuner mode
 */
class DcpTunerModeMsg extends EnumParameterMsg<DcpTunerMode>
{
    static const String CODE = "D02";
    static const String _DCP_COMMAND = "TMAN";

    static List<String> getAcceptedDcpCodes()
    => [ _DCP_COMMAND ];

    static const ExtEnum<DcpTunerMode> ValueEnum = ExtEnum<DcpTunerMode>([
        EnumItem.code(DcpTunerMode.NONE, "N/A",
            descr: Strings.dashed_string,
            icon: Drawables.media_item_unknown, defValue: true),
        EnumItem.code(DcpTunerMode.FM, "FM",
            descrList: Strings.l_input_selector_fm,
            icon: Drawables.media_item_radio_fm),
        EnumItem.code(DcpTunerMode.DAB, "DAB",
            descrList: Strings.l_input_selector_dab,
            icon: Drawables.media_item_radio_dab)
    ]);

    DcpTunerModeMsg(EISCPMessage raw) : super(CODE, raw, ValueEnum);

    DcpTunerModeMsg.output(DcpTunerMode v) : super.output(CODE, v, ValueEnum);

    @override
    bool hasImpactOnMediaList()
    => false;

    static DcpTunerModeMsg? processDcpMessage(String dcpMsg)
    {
        final EnumItem<DcpTunerMode>? s = ValueEnum.valueByDcpCommand(_DCP_COMMAND, dcpMsg);
        return s != null ? DcpTunerModeMsg.output(s.key) : null;
    }

    @override
    String? buildDcpMsg(bool isQuery)
    => buildDcpRequest(isQuery, _DCP_COMMAND);
}