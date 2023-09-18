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

import "../../constants/Drawables.dart";
import "../../constants/Strings.dart";
import "EnumParameterMsg.dart";

enum TapeOperationCommand
{
    UNDEFINED,
    PLAY_F,
    PLAY_R,
    STOP,
    RC_PAU,
    FF,
    REW
}

/*
 * RI Tape1(A) Operation Commands
 */
class TapeOperationCommandMsg extends EnumParameterMsg<TapeOperationCommand>
{
    static const String CODE = "CT1";

    static const ExtEnum<TapeOperationCommand> ValueEnum = ExtEnum<TapeOperationCommand>([
        EnumItem.code(TapeOperationCommand.UNDEFINED, "N/A",
            descr: Strings.dashed_string, defValue: true),
        EnumItem.code(TapeOperationCommand.PLAY_F, "PLAY.F",
            descrList: Strings.l_tape_cmd_play_ff, icon: Drawables.cmd_play),
        EnumItem.code(TapeOperationCommand.PLAY_R, "PLAY.R",
            descrList: Strings.l_tape_cmd_play_rew),
        EnumItem.code(TapeOperationCommand.STOP, "STOP",
            descrList: Strings.l_tape_cmd_stop, icon: Drawables.cmd_stop),
        EnumItem.code(TapeOperationCommand.RC_PAU, "RC/PAU",
            descrList: Strings.l_tape_cmd_record),
        EnumItem.code(TapeOperationCommand.FF, "FF",
            descrList: Strings.l_tape_cmd_ff, icon: Drawables.cmd_next),
        EnumItem.code(TapeOperationCommand.REW, "REW",
            descrList: Strings.l_tape_cmd_rew, icon: Drawables.cmd_previous)
    ]);

    TapeOperationCommandMsg.output(TapeOperationCommand v) : super.output(CODE, v, ValueEnum);

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }
}
