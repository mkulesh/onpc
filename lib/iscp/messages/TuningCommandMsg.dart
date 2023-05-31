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
import "../../constants/Drawables.dart";
import "../../constants/Strings.dart";
import "../../utils/Convert.dart";
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";
import "DcpTunerModeMsg.dart";
import "EnumParameterMsg.dart";
import "ReceiverInformationMsg.dart";

enum TuningCommand
{
    NONE,
    UP,
    DOWN
}

/*
 * Tuning Command (Include Tuner Pack Model Only)
 */
class TuningCommandMsg extends ZonedMessage
{
    static const String CODE = "TUN";
    static const String ZONE2_CODE = "TUZ";
    static const String ZONE3_CODE = "TU3";
    static const String ZONE4_CODE = "TU4";

    static const List<String> ZONE_COMMANDS = [CODE, ZONE2_CODE, ZONE3_CODE, ZONE4_CODE];

    static const ExtEnum<TuningCommand> ValueEnum = ExtEnum<TuningCommand>([
        EnumItem(TuningCommand.NONE, defValue: true),
        EnumItem(TuningCommand.UP, dcpCode: "UP",
            descrList: Strings.l_tuning_command_up, icon: Drawables.cmd_fast_forward),
        EnumItem(TuningCommand.DOWN, dcpCode: "DOWN",
            descrList: Strings.l_tuning_command_down, icon: Drawables.cmd_fast_backward)
    ]);

    EnumItem<TuningCommand> _command;
    DcpTunerMode _dcpTunerMode;

    TuningCommandMsg(EISCPMessage raw) : super(ZONE_COMMANDS, raw)
    {
        _command = ValueEnum.valueByCode(getData);
        _dcpTunerMode = DcpTunerMode.NONE;
    }

    TuningCommandMsg.outputCmd(int zoneIndex, final TuningCommand command) :
            super.output(ZONE_COMMANDS, zoneIndex, ValueEnum.valueByKey(command).getCode)
    {
        _command = ValueEnum.valueByKey(command);
        _dcpTunerMode = DcpTunerMode.NONE;
    }

    TuningCommandMsg.dcp(int zoneIndex, String frequency, DcpTunerMode dcpTunerMode) :
            super.output(ZONE_COMMANDS, zoneIndex, frequency)
    {
        _command = null;
        _dcpTunerMode = dcpTunerMode;
    }

    EnumItem<TuningCommand> get getCommand
    => _command;

    String get getFrequency
    => getData;

    DcpTunerMode get getDcpTunerMode
    => _dcpTunerMode;

    @override
    String toString()
    => super.toString() + "[CMD=" + (_command != null ? _command.toString() : "null")
        + "; FREQ=" + getFrequency
        + "; MODE=" + Convert.enumToString(_dcpTunerMode.toString())
        + "]";

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }

    /*
     * Denon control protocol
     */
    static const String _DCP_COMMAND_FM = "TFAN";
    static const String _DCP_COMMAND_DAB = "DAFRQ";

    static List<String> getAcceptedDcpCodes()
    => [ _DCP_COMMAND_FM, _DCP_COMMAND_DAB ];

    static TuningCommandMsg processDcpMessage(String dcpMsg, int zone)
    {
        if (dcpMsg.startsWith(_DCP_COMMAND_FM))
        {
            final String par = dcpMsg.substring(_DCP_COMMAND_FM.length).trim();
            if (int.tryParse(par) != null)
            {
                return TuningCommandMsg.dcp(zone, par, DcpTunerMode.FM);
            }
        }
        if (dcpMsg.startsWith(_DCP_COMMAND_DAB))
        {
            final String par = dcpMsg.substring(_DCP_COMMAND_DAB.length).trim();
            return TuningCommandMsg.dcp(zone, par, DcpTunerMode.DAB);
        }
        return null;
    }

    @override
    String buildDcpMsg(bool isQuery)
    {
        if (zoneIndex == ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE)
        {
            // Only available for main zone
            return _DCP_COMMAND_FM + (isQuery ? ISCPMessage.DCP_MSG_REQ :
                (_command != null ? _command.getDcpCode : null));
        }
        return null;
    }
}
