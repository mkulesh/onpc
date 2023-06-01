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

enum DcpAudioRestorer
{
    NONE,
    OFF,
    LOW,
    MED,
    HI
}

/*
 * Denon control protocol - DCP audio restorer
 */
class DcpAudioRestorerMsg extends EnumParameterMsg<DcpAudioRestorer>
{
    static const String CODE = "D04";
    static const String _DCP_COMMAND = "PSRSTR";

    static List<String> getAcceptedDcpCodes()
    => [ _DCP_COMMAND ];

    static const ExtEnum<DcpAudioRestorer> ValueEnum = ExtEnum<DcpAudioRestorer>([
        EnumItem.code(DcpAudioRestorer.NONE, "N/A",
            descrList: Strings.l_device_dcp_audio_restorer_none, defValue: true),
        EnumItem.code(DcpAudioRestorer.OFF, "OFF",
            descrList: Strings.l_device_dcp_audio_restorer_off),
        EnumItem.code(DcpAudioRestorer.LOW, "LOW",
            descrList: Strings.l_device_dcp_audio_restorer_low),
        EnumItem.code(DcpAudioRestorer.MED, "MED",
            descrList: Strings.l_device_dcp_audio_restorer_medium),
        EnumItem.code(DcpAudioRestorer.HI, "HI",
            descrList: Strings.l_device_dcp_audio_restorer_high)
    ]);

    DcpAudioRestorerMsg(EISCPMessage raw) : super(CODE, raw, ValueEnum);

    DcpAudioRestorerMsg.toggle(EnumItem<DcpAudioRestorer> s) :
            super.output(CODE, _toggle(s.key), ValueEnum);

    DcpAudioRestorerMsg._dcp(DcpAudioRestorer v) : super.output(CODE, v, ValueEnum);

    @override
    bool hasImpactOnMediaList()
    => false;

    static DcpAudioRestorerMsg processDcpMessage(String dcpMsg)
    {
        final EnumItem<DcpAudioRestorer> s = ValueEnum.valueByDcpCommand(_DCP_COMMAND, dcpMsg);
        return s != null ? DcpAudioRestorerMsg._dcp(s.key) : null;
    }

    @override
    String buildDcpMsg(bool isQuery)
    => buildDcpRequest(isQuery, _DCP_COMMAND, sep: " ");

    static DcpAudioRestorer _toggle(DcpAudioRestorer s)
    {
        switch (s)
        {
        case DcpAudioRestorer.OFF:
            return DcpAudioRestorer.LOW;
        case DcpAudioRestorer.LOW:
            return DcpAudioRestorer.MED;
        case DcpAudioRestorer.MED:
            return DcpAudioRestorer.HI;
        case DcpAudioRestorer.HI:
            return DcpAudioRestorer.OFF;
        default:
            return DcpAudioRestorer.NONE;
        }
    }
}