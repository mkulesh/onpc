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
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";
import "EnumParameterMsg.dart";

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
        EnumItem(TuningCommand.UP, descrList: Strings.l_tuning_command_up, icon: Drawables.cmd_fast_forward),
        EnumItem(TuningCommand.DOWN, descrList: Strings.l_tuning_command_down, icon: Drawables.cmd_fast_backward)
    ]);

    EnumItem<TuningCommand> _command;

    TuningCommandMsg(EISCPMessage raw) : super(ZONE_COMMANDS, raw)
    {
        _command = null;
    }

    TuningCommandMsg.outputCmd(int zoneIndex, final TuningCommand command) :
            super.output(ZONE_COMMANDS, zoneIndex, ValueEnum.valueByKey(command).getCode)
    {
        _command = ValueEnum.valueByKey(command);
    }

    EnumItem<TuningCommand> get getCommand
    => _command;

    String get getFrequency
    => getData;

    @override
    String toString()
    => super.toString() + "[CMD=" + (_command != null ? _command.toString() : "null") + "; FREQ=" + getFrequency + "]";

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }
}
