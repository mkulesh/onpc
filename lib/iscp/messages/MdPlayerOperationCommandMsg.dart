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

enum MdPlayerOperationCommand
{
    UNDEFINED,
    POWER,
    PLAY,
    STOP,
    PAUSE,
    SKIP_F,
    SKIP_R,
    MEMORY,
    CLEAR,
    REPEAT,
    RANDOM,
    DISP,
    FF,
    REW,
    EJECT,
    NUMBER_1,
    NUMBER_2,
    NUMBER_3,
    NUMBER_4,
    NUMBER_5,
    NUMBER_6,
    NUMBER_7,
    NUMBER_8,
    NUMBER_9,
    NUMBER_0,
    NUMBER_10,
    NUMBER_GREATER_10
}

/*
 * RI MD Recorder Operation Command
 */
class MdPlayerOperationCommandMsg extends EnumParameterMsg<MdPlayerOperationCommand>
{
    static const String CODE = "CMD";

    static const ExtEnum<MdPlayerOperationCommand> ValueEnum = ExtEnum<MdPlayerOperationCommand>([
        EnumItem.code(MdPlayerOperationCommand.UNDEFINED, "N/A",
            descr: Strings.dashed_string, defValue: true),
        EnumItem.code(MdPlayerOperationCommand.POWER, "POWER",
            descrList: Strings.l_cd_cmd_power, icon: Drawables.menu_power_standby),
        EnumItem.code(MdPlayerOperationCommand.PLAY, "PLAY",
            descrList: Strings.l_cd_cmd_play, icon: Drawables.cmd_play),
        EnumItem.code(MdPlayerOperationCommand.STOP, "STOP",
            descrList: Strings.l_cd_cmd_stop, icon: Drawables.cmd_stop),
        EnumItem.code(MdPlayerOperationCommand.PAUSE, "PAUSE",
            descrList: Strings.l_cd_cmd_pause, icon: Drawables.cmd_pause),
        EnumItem.code(MdPlayerOperationCommand.SKIP_F, "SKIP.F",
            descrList: Strings.l_cd_cmd_skip_f, icon: Drawables.cmd_next),
        EnumItem.code(MdPlayerOperationCommand.SKIP_R, "SKIP.R",
            descrList: Strings.l_cd_cmd_skip_r, icon: Drawables.cmd_previous),
        EnumItem.code(MdPlayerOperationCommand.MEMORY, "MEMORY",
            descrList: Strings.l_cd_cmd_memory),
        EnumItem.code(MdPlayerOperationCommand.CLEAR, "CLEAR", name: "C",
            descrList: Strings.l_cd_cmd_clear, icon: Drawables.numeric_clean),
        EnumItem.code(MdPlayerOperationCommand.REPEAT, "REPEAT",
            descrList: Strings.l_cd_cmd_repeat, icon: Drawables.repeat_all),
        EnumItem.code(MdPlayerOperationCommand.RANDOM, "RANDOM",
            descrList: Strings.l_cd_cmd_random, icon: Drawables.cmd_random),
        EnumItem.code(MdPlayerOperationCommand.DISP, "DISP",
            descrList: Strings.l_cd_cmd_disp),
        EnumItem.code(MdPlayerOperationCommand.FF, "FF",
            descrList: Strings.l_cd_cmd_ff),
        EnumItem.code(MdPlayerOperationCommand.REW, "REW",
            descrList: Strings.l_cd_cmd_rew),
        EnumItem.code(MdPlayerOperationCommand.EJECT, "EJECT",
            descrList: Strings.l_cd_cmd_op_cl, icon: Drawables.cd_eject),
        EnumItem.code(MdPlayerOperationCommand.NUMBER_1, "1", name: "1",
            descrList: Strings.l_cd_cmd_number_1, icon: Drawables.numeric_1),
        EnumItem.code(MdPlayerOperationCommand.NUMBER_2, "2", name: "2",
            descrList: Strings.l_cd_cmd_number_2, icon: Drawables.numeric_2),
        EnumItem.code(MdPlayerOperationCommand.NUMBER_3, "3", name: "3",
            descrList: Strings.l_cd_cmd_number_3, icon: Drawables.numeric_3),
        EnumItem.code(MdPlayerOperationCommand.NUMBER_4, "4", name: "4",
            descrList: Strings.l_cd_cmd_number_4, icon: Drawables.numeric_4),
        EnumItem.code(MdPlayerOperationCommand.NUMBER_5, "5", name: "5",
            descrList: Strings.l_cd_cmd_number_5, icon: Drawables.numeric_5),
        EnumItem.code(MdPlayerOperationCommand.NUMBER_6, "6", name: "6",
            descrList: Strings.l_cd_cmd_number_6, icon: Drawables.numeric_6),
        EnumItem.code(MdPlayerOperationCommand.NUMBER_7, "7", name: "7",
            descrList: Strings.l_cd_cmd_number_7, icon: Drawables.numeric_7),
        EnumItem.code(MdPlayerOperationCommand.NUMBER_8, "8", name: "8",
            descrList: Strings.l_cd_cmd_number_8, icon: Drawables.numeric_8),
        EnumItem.code(MdPlayerOperationCommand.NUMBER_9, "9", name: "9",
            descrList: Strings.l_cd_cmd_number_9, icon: Drawables.numeric_9),
        EnumItem.code(MdPlayerOperationCommand.NUMBER_0, "0", name: "0",
            descrList: Strings.l_cd_cmd_number_0, icon: Drawables.numeric_0),
        EnumItem.code(MdPlayerOperationCommand.NUMBER_10, "10", name: "10",
            descrList: Strings.l_cd_cmd_number_10),
        EnumItem.code(MdPlayerOperationCommand.NUMBER_GREATER_10, "nn/nnn", name: ">9",
            descrList: Strings.l_cd_cmd_number_greater_10, icon: Drawables.numeric_greater_9),
    ]);

    MdPlayerOperationCommandMsg.output(MdPlayerOperationCommand v) : super.output(CODE, v, ValueEnum);

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }
}
