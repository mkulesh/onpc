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

import "../EISCPMessage.dart";
import "../ISCPMessage.dart";
import "EnumParameterMsg.dart";

enum SubwooferLevelCommand
{
    NONE,
    UP,
    DOWN
}

/*
 * Subwoofer (temporary) Level Command
 */
class SubwooferLevelCommandMsg extends ISCPMessage
{
    static const String CODE = "SWL";

    static const String KEY = "Subwoofer Level";
    static const int NO_LEVEL = 0xFF;

    static const ExtEnum<SubwooferLevelCommand> ValueEnum = ExtEnum<SubwooferLevelCommand>([
        EnumItem(SubwooferLevelCommand.NONE, defValue: true),
        EnumItem(SubwooferLevelCommand.UP),
        EnumItem(SubwooferLevelCommand.DOWN)
    ]);

    late EnumItem<SubwooferLevelCommand> _command;
    int _level = NO_LEVEL;
    int _cmdLength = NO_LEVEL;

    SubwooferLevelCommandMsg(EISCPMessage raw) : super(CODE, raw)
    {
        _command = ValueEnum.defValue;
        _level = ISCPMessage.nonNullInteger(getData, 16, NO_LEVEL);
        _cmdLength = getData.length;
    }

    SubwooferLevelCommandMsg.output(SubwooferLevelCommand v) :
            super.output(CODE, ValueEnum.valueByKey(v).getCode)
    {
        _command = ValueEnum.valueByKey(v);
        _level = NO_LEVEL;
        _cmdLength = NO_LEVEL;
    }

    SubwooferLevelCommandMsg.value(int level, int cmdLength) :
            super.output(CODE, _getParameterAsString(level, cmdLength))
    {
        _command = ValueEnum.defValue;
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
    => super.toString() + "[COMMAND=" + _command.toString()
        + "; LEVEL=" + _level.toString()
        + "; CMD_LENGTH=" + _cmdLength.toString() + "]";

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }
}
