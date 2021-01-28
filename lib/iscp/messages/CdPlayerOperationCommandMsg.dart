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

import "../../constants/Drawables.dart";
import "../../constants/Strings.dart";
import "EnumParameterMsg.dart";

enum CdPlayerOperationCommand
{
    UNDEFINED,
    POWER,
    TRACK,
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
    D_MODE,
    FF,
    REW,
    OP_CL,
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
    NUMBER_GREATER_10,
    DISC_F,
    DISC_R,
    DISC1,
    DISC2,
    DISC3,
    DISC4,
    DISC5,
    DISC6
}

/*
 * CD Player Operation Command
 */
class CdPlayerOperationCommandMsg extends EnumParameterMsg<CdPlayerOperationCommand>
{
    static const String CODE = "CCD";

    // Controls that allow the control of build-in CD player via CCD command
    static const String CONTROL_CD_INT1 = "CD Control";
    static const String CONTROL_CD_INT2 = "CD Control(NewRemote)";

    static const ExtEnum<CdPlayerOperationCommand> ValueEnum = ExtEnum<CdPlayerOperationCommand>([
        EnumItem.code(CdPlayerOperationCommand.UNDEFINED, "N/A",
            descr: Strings.dashed_string, defValue: true),
        EnumItem.code(CdPlayerOperationCommand.POWER, "POWER",
            descrList: Strings.l_cd_cmd_power, icon: Drawables.menu_power_standby),
        EnumItem.code(CdPlayerOperationCommand.TRACK, "TRACK",
            descrList: Strings.l_cd_cmd_track),
        EnumItem.code(CdPlayerOperationCommand.PLAY, "PLAY",
            descrList: Strings.l_cd_cmd_play, icon: Drawables.cmd_play),
        EnumItem.code(CdPlayerOperationCommand.STOP, "STOP",
            descrList: Strings.l_cd_cmd_stop, icon: Drawables.cmd_stop),
        EnumItem.code(CdPlayerOperationCommand.PAUSE, "PAUSE",
            descrList: Strings.l_cd_cmd_pause, icon: Drawables.cmd_pause),
        EnumItem.code(CdPlayerOperationCommand.SKIP_F, "SKIP.F",
            descrList: Strings.l_cd_cmd_skip_f, icon: Drawables.cmd_next),
        EnumItem.code(CdPlayerOperationCommand.SKIP_R, "SKIP.R",
            descrList: Strings.l_cd_cmd_skip_r, icon: Drawables.cmd_previous),
        EnumItem.code(CdPlayerOperationCommand.MEMORY, "MEMORY",
            descrList: Strings.l_cd_cmd_memory),
        EnumItem.code(CdPlayerOperationCommand.CLEAR, "CLEAR", name: "C",
            descrList: Strings.l_cd_cmd_clear, icon: Drawables.numeric_clean),
        EnumItem.code(CdPlayerOperationCommand.REPEAT, "REPEAT",
            descrList: Strings.l_cd_cmd_repeat, icon: Drawables.repeat_all),
        EnumItem.code(CdPlayerOperationCommand.RANDOM, "RANDOM",
            descrList: Strings.l_cd_cmd_random, icon: Drawables.cmd_random),
        EnumItem.code(CdPlayerOperationCommand.DISP, "DISP",
            descrList: Strings.l_cd_cmd_disp),
        EnumItem.code(CdPlayerOperationCommand.D_MODE, "D.MODE",
            descrList: Strings.l_cd_cmd_d_mode),
        EnumItem.code(CdPlayerOperationCommand.FF, "FF",
            descrList: Strings.l_cd_cmd_ff),
        EnumItem.code(CdPlayerOperationCommand.REW, "REW",
            descrList: Strings.l_cd_cmd_rew),
        EnumItem.code(CdPlayerOperationCommand.OP_CL, "OP/CL",
            descrList: Strings.l_cd_cmd_op_cl, icon: Drawables.cd_eject),
        EnumItem.code(CdPlayerOperationCommand.NUMBER_1, "1", name: "1",
            descrList: Strings.l_cd_cmd_number_1, icon: Drawables.numeric_1),
        EnumItem.code(CdPlayerOperationCommand.NUMBER_2, "2", name: "2",
            descrList: Strings.l_cd_cmd_number_2, icon: Drawables.numeric_2),
        EnumItem.code(CdPlayerOperationCommand.NUMBER_3, "3", name: "3",
            descrList: Strings.l_cd_cmd_number_3, icon: Drawables.numeric_3),
        EnumItem.code(CdPlayerOperationCommand.NUMBER_4, "4", name: "4",
            descrList: Strings.l_cd_cmd_number_4, icon: Drawables.numeric_4),
        EnumItem.code(CdPlayerOperationCommand.NUMBER_5, "5", name: "5",
            descrList: Strings.l_cd_cmd_number_5, icon: Drawables.numeric_5),
        EnumItem.code(CdPlayerOperationCommand.NUMBER_6, "6", name: "6",
            descrList: Strings.l_cd_cmd_number_6, icon: Drawables.numeric_6),
        EnumItem.code(CdPlayerOperationCommand.NUMBER_7, "7", name: "7",
            descrList: Strings.l_cd_cmd_number_7, icon: Drawables.numeric_7),
        EnumItem.code(CdPlayerOperationCommand.NUMBER_8, "8", name: "8",
            descrList: Strings.l_cd_cmd_number_8, icon: Drawables.numeric_8),
        EnumItem.code(CdPlayerOperationCommand.NUMBER_9, "9", name: "9",
            descrList: Strings.l_cd_cmd_number_9, icon: Drawables.numeric_9),
        EnumItem.code(CdPlayerOperationCommand.NUMBER_0, "0", name: "0",
            descrList: Strings.l_cd_cmd_number_0, icon: Drawables.numeric_0),
        EnumItem.code(CdPlayerOperationCommand.NUMBER_10, "10", name: "10",
            descrList: Strings.l_cd_cmd_number_10),
        EnumItem.code(CdPlayerOperationCommand.NUMBER_GREATER_10, "+10", name: ">9",
            descrList: Strings.l_cd_cmd_number_greater_10, icon: Drawables.numeric_greater_9),
        EnumItem.code(CdPlayerOperationCommand.DISC_F, "DISC.F",
            descrList: Strings.l_cd_cmd_disc_f),
        EnumItem.code(CdPlayerOperationCommand.DISC_R, "DISC.R",
            descrList: Strings.l_cd_cmd_disc_r),
        EnumItem.code(CdPlayerOperationCommand.DISC1, "DISC1",
            descrList: Strings.l_cd_cmd_disc1),
        EnumItem.code(CdPlayerOperationCommand.DISC2, "DISC2",
            descrList: Strings.l_cd_cmd_disc2),
        EnumItem.code(CdPlayerOperationCommand.DISC3, "DISC3",
            descrList: Strings.l_cd_cmd_disc3),
        EnumItem.code(CdPlayerOperationCommand.DISC4, "DISC4",
            descrList: Strings.l_cd_cmd_disc4),
        EnumItem.code(CdPlayerOperationCommand.DISC5, "DISC5",
            descrList: Strings.l_cd_cmd_disc5),
        EnumItem.code(CdPlayerOperationCommand.DISC6, "DISC6",
            descrList: Strings.l_cd_cmd_disc6)
    ]);

    CdPlayerOperationCommandMsg.output(CdPlayerOperationCommand v) : super.output(CODE, v, ValueEnum);

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }
}
