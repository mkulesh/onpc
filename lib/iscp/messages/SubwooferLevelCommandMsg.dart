/*
 * Enhanced Controller for Onkyo and Pioneer Pro
 * Copyright (C) 2019-2021 by Mikhail Kulesh
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

/*
 * Subwoofer (temporary) Level Command
 */
class SubwooferLevelCommandMsg extends ISCPMessage
{
    static const String CODE = "SWL";

    static const String KEY = "Subwoofer Level";
    static const int NO_LEVEL = 0xFF;

    int _level = NO_LEVEL;
    int _cmdLength = NO_LEVEL;

    SubwooferLevelCommandMsg(EISCPMessage raw) : super(CODE, raw)
    {
        _level = ISCPMessage.nonNullInteger(getData, 16, NO_LEVEL);
        _cmdLength = getData == null ? NO_LEVEL : getData.length;
    }

    SubwooferLevelCommandMsg.output(int level, int cmdLength) :
            super.output(CODE, _getParameterAsString(level, cmdLength))
    {
        _level = level;
        _cmdLength = cmdLength;
    }

    static String _getParameterAsString(int level, int cmdLength)
    {
        if (level == 0)
        {
            return cmdLength == 2 ? "00" : "000";
        }
        else
        {
            final String s = level < 0 ? "-" : "+";
            final String format = cmdLength == 2 ?
                level.abs().toRadixString(16) : level.abs().toRadixString(16).padLeft(2, '0');
            return s + format.toUpperCase();
        }
    }

    int get getLevel
    => _level;

    int get getCmdLength
    => _cmdLength;

    @override
    String toString()
    => super.toString() + "[LEVEL=" + _level.toString() + "; CMD_LENGTH=" + _cmdLength.toString() + "]";


    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }
}
