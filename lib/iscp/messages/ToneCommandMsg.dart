/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2022 by Mikhail Kulesh
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
import "../ISCPMessage.dart";
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
        EnumItem(ToneCommand.NONE, defValue: true),
        EnumItem(ToneCommand.BUP),
        EnumItem(ToneCommand.BDOWN),
        EnumItem(ToneCommand.TUP),
        EnumItem(ToneCommand.TDOWN)
    ]);

    EnumItem<ToneCommand> _command;

    static const String BASS_KEY = "Bass";
    static const String BASS_MARKER = "B";
    int _bassLevel = NO_LEVEL;

    static const String TREBLE_KEY = "Treble";
    static const String TREBLE_MARKER = "T";
    int _trebleLevel = NO_LEVEL;

    ToneCommandMsg(EISCPMessage raw) : super(ZONE_COMMANDS, raw)
    {
        _command = ValueEnum.defValue;
        for (int i = 0; i < getData.length; i++)
        {
            if (getData.substring(i, i + 1) == BASS_MARKER)
            {
                _bassLevel = ISCPMessage.nonNullInteger(getData.substring(i + 1, i + 3), 16, NO_LEVEL);
            }
            if (getData.substring(i, i + 1) == TREBLE_MARKER)
            {
                _trebleLevel = ISCPMessage.nonNullInteger(getData.substring(i + 1, i + 3), 16, NO_LEVEL);
            }
        }
    }

    ToneCommandMsg.output(int zoneIndex, ToneCommand v) :
            super.output(ZONE_COMMANDS, zoneIndex, ValueEnum.valueByKey(v).getCode)
    {
        _command = ValueEnum.valueByKey(v);
        _bassLevel = NO_LEVEL;
        _trebleLevel = NO_LEVEL;
    }

    ToneCommandMsg.value(int zoneIndex, int bass, int treble) :
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
}
