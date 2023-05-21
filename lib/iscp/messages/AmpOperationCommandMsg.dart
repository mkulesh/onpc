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
import "EnumParameterMsg.dart";

enum AmpOperationCommand
{
    UNDEFINED,
    MVLUP,
    MVLDOWN,
    SLIUP,
    SLIDOWN,
    AMTON,
    AMTOFF,
    AMTTG,
    PWRON,
    PWROFF,
    PWRTG
}

/*
 * RI Amplifier Operation Commands
 */
class AmpOperationCommandMsg extends EnumParameterMsg<AmpOperationCommand>
{
    static const String CODE = "CAP";

    static const ExtEnum<AmpOperationCommand> ValueEnum = ExtEnum<AmpOperationCommand>([
        EnumItem.code(AmpOperationCommand.UNDEFINED, "N/A",
            descr: Strings.dashed_string, defValue: true),
        EnumItem.code(AmpOperationCommand.MVLUP, "MVLUP",
            descrList: Strings.l_amp_cmd_volume_up, icon: Drawables.volume_amp_up),
        EnumItem.code(AmpOperationCommand.MVLDOWN, "MVLDOWN",
            descrList: Strings.l_amp_cmd_volume_down, icon: Drawables.volume_amp_down),
        EnumItem.code(AmpOperationCommand.SLIUP, "SLIUP",
            descrList: Strings.l_amp_cmd_selector_up, icon: Drawables.input_selector_up),
        EnumItem.code(AmpOperationCommand.SLIDOWN, "SLIDOWN",
            descrList: Strings.l_amp_cmd_selector_down, icon: Drawables.input_selector_down),
        EnumItem.code(AmpOperationCommand.AMTON, "AMTON",
            descrList: Strings.l_amp_cmd_audio_muting_on, icon: Drawables.volume_amp_muting),
        EnumItem.code(AmpOperationCommand.AMTOFF, "AMTOFF",
            descrList: Strings.l_amp_cmd_audio_muting_off, icon: Drawables.volume_amp_muting),
        EnumItem.code(AmpOperationCommand.AMTTG, "AMTTG",
            descrList: Strings.l_amp_cmd_audio_muting_toggle, icon: Drawables.volume_amp_muting),
        EnumItem.code(AmpOperationCommand.PWRON, "PWRON",
            descrList: Strings.l_amp_cmd_system_on, icon: Drawables.menu_power_standby),
        EnumItem.code(AmpOperationCommand.PWROFF, "PWROFF",
            descrList: Strings.l_amp_cmd_system_standby, icon: Drawables.menu_power_standby),
        EnumItem.code(AmpOperationCommand.PWRTG, "PWRTG",
            descrList: Strings.l_amp_cmd_system_on_toggle, icon: Drawables.menu_power_standby)
    ]);

    AmpOperationCommandMsg.output(AmpOperationCommand v) : super.output(CODE, v, ValueEnum);

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }
}
