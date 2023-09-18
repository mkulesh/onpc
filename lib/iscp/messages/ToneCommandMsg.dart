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

import 'package:sprintf/sprintf.dart';

import "../../utils/Logging.dart";
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";
import "DcpReceiverInformationMsg.dart";
import "EnumParameterMsg.dart";

enum ToneCommand
{
    NONE,
    BUP,
    BDOWN,
    TUP,
    TDOWN
}

/*
 * Tone/Front (for main zone) and Tone (for zones 2, 3) command
 */
class ToneCommandMsg extends ZonedMessage
{
    static const String CODE = "TFR";
    static const String ZONE2_CODE = "ZTN";
    static const String ZONE3_CODE = "TN3";

    // Tone command is not available for zone 4

    static const List<String> ZONE_COMMANDS = [CODE, ZONE2_CODE, ZONE3_CODE];

    static const int NO_LEVEL = 0xFF;

    static const ExtEnum<ToneCommand> ValueEnum = ExtEnum<ToneCommand>([
        EnumItem(ToneCommand.NONE, dcpCode: "N/A", defValue: true),
        EnumItem(ToneCommand.BUP, dcpCode: "UP"),
        EnumItem(ToneCommand.BDOWN, dcpCode: "DOWN"),
        EnumItem(ToneCommand.TUP, dcpCode: "UP"),
        EnumItem(ToneCommand.TDOWN, dcpCode: "DOWN")
    ]);

    late final bool _tonJoined;
    late EnumItem<ToneCommand> _command;

    static const String BASS_KEY = "Bass";
    static const String BASS_MARKER = "B";
    int _bassLevel = NO_LEVEL;

    static const String TREBLE_KEY = "Treble";
    static const String TREBLE_MARKER = "T";
    int _trebleLevel = NO_LEVEL;

    ToneCommandMsg(EISCPMessage raw) : _tonJoined = true, super(ZONE_COMMANDS, raw)
    {
        _command = ValueEnum.valueByCode(getData);
        for (int i = 0; i < getData.length; i++)
        {
            if (getData != EISCPMessage.QUERY && getData.substring(i, i + 1) == BASS_MARKER)
            {
                _bassLevel = ISCPMessage.nonNullInteger(getData.substring(i + 1, i + 3), 16, NO_LEVEL);
            }
            if (getData != EISCPMessage.QUERY && getData.substring(i, i + 1) == TREBLE_MARKER)
            {
                _trebleLevel = ISCPMessage.nonNullInteger(getData.substring(i + 1, i + 3), 16, NO_LEVEL);
            }
        }
    }

    ToneCommandMsg.output(int zoneIndex, ToneCommand v) :
            _tonJoined = false,
            super.output(ZONE_COMMANDS, zoneIndex, ValueEnum.valueByKey(v).getCode)
    {
        _command = ValueEnum.valueByKey(v);
        _bassLevel = NO_LEVEL;
        _trebleLevel = NO_LEVEL;
    }

    ToneCommandMsg.value(int zoneIndex, int bass, int treble) :
            _tonJoined = false,
            super.output(ZONE_COMMANDS, zoneIndex, _getParameterAsString(bass, treble))
    {
        _command = ValueEnum.defValue;
        _bassLevel = bass;
        _trebleLevel = treble;
    }

    static String _getParameterAsString(int bass, int treble)
    {
        String par = "";
        if (bass != NO_LEVEL)
        {
            par += _intToneToString(BASS_MARKER, bass);
        }
        if (treble != NO_LEVEL)
        {
            par += _intToneToString(TREBLE_MARKER, treble);
        }
        return par;
    }

    bool get isTonJoined
    => _tonJoined;

    int get getBassLevel
    => _bassLevel;

    int get getTrebleLevel
    => _trebleLevel;

    @override
    String toString()
    => super.toString() + "[COMMAND=" + _command.toString()
        + "; BASS=" + _bassLevel.toString()
        + "; TREBLE=" + _trebleLevel.toString() + "]";

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }

    static String _intToneToString(String m, int tone)
    {
        if (tone == 0)
        {
            return m + tone.toRadixString(16).padLeft(2, '0');
        }
        final String s = tone < 0 ? "-" : "+";
        return m + s + tone.abs().toRadixString(16).substring(0, 1).toUpperCase();
    }

    /*
     * Denon control protocol
     */
    static List<String> getAcceptedDcpCodes()
    => [];

    static ToneCommandMsg? processDcpMessage(String dcpMsg)
    {
        // Bass
        for (int i = 0; i < DcpReceiverInformationMsg.DCP_COMMANDS_BASS.length; i++)
        {
            if (dcpMsg.startsWith(DcpReceiverInformationMsg.DCP_COMMANDS_BASS[i]))
            {
                final String par = dcpMsg.substring(
                    DcpReceiverInformationMsg.DCP_COMMANDS_BASS[i].length).trim();
                final int? value = int.tryParse(par);
                if (value != null)
                {
                    final int level = value - DcpReceiverInformationMsg.DCP_TON_SHIFT[i];
                    return ToneCommandMsg.value(i, level, NO_LEVEL);
                }
                else
                {
                    Logging.info(ToneCommandMsg, "Unable to parse bass level " + par);
                    return null;
                }
            }
        }
        // Treble
        for (int i = 0; i < DcpReceiverInformationMsg.DCP_COMMANDS_TREBLE.length; i++)
        {
            if (dcpMsg.startsWith(DcpReceiverInformationMsg.DCP_COMMANDS_TREBLE[i]))
            {
                final String par = dcpMsg.substring(
                DcpReceiverInformationMsg.DCP_COMMANDS_TREBLE[i].length).trim();
                final int? value = int.tryParse(par);
                if (value != null)
                {
                    final int level = value - DcpReceiverInformationMsg.DCP_TON_SHIFT[i];
                    return ToneCommandMsg.value(i, NO_LEVEL, level);
                }
                else
                {
                    Logging.info(ToneCommandMsg, "Unable to parse treble level " + par);
                    return null;
                }
            }
        }
        return null;
    }

    @override
    String? buildDcpMsg(bool isQuery)
    {
        if (isQuery)
        {
            final String bassReq = DcpReceiverInformationMsg.DCP_COMMANDS_BASS[zoneIndex] + " " + ISCPMessage.DCP_MSG_REQ;
            final String trebleReq = DcpReceiverInformationMsg.DCP_COMMANDS_TREBLE[zoneIndex] + " " + ISCPMessage.DCP_MSG_REQ;
            return bassReq + ISCPMessage.DCP_MSG_SEP + trebleReq;
        }

        if (_command.dcpCode == null)
        {
            return null;
        }
        switch(_command.key)
        {
        case ToneCommand.BUP:
        case ToneCommand.BDOWN:
            return DcpReceiverInformationMsg.DCP_COMMANDS_BASS[zoneIndex] + " " + _command.dcpCode!;
        case ToneCommand.TUP:
        case ToneCommand.TDOWN:
            return DcpReceiverInformationMsg.DCP_COMMANDS_TREBLE[zoneIndex] + " " + _command.dcpCode!;
        default:
            if (_bassLevel != NO_LEVEL)
            {
                final String par = sprintf("%02d", [ _bassLevel + DcpReceiverInformationMsg.DCP_TON_SHIFT[zoneIndex] ]);
                return DcpReceiverInformationMsg.DCP_COMMANDS_BASS[zoneIndex] + " " + par;
            }
            else if (_trebleLevel != NO_LEVEL)
            {
                final String par = sprintf("%02d", [ _trebleLevel + DcpReceiverInformationMsg.DCP_TON_SHIFT[zoneIndex] ]);
                return DcpReceiverInformationMsg.DCP_COMMANDS_TREBLE[zoneIndex] + " " + par;
            }
        }
        return null;
    }
}
