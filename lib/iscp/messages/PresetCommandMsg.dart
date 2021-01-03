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
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";
import "EnumParameterMsg.dart";
import "ReceiverInformationMsg.dart";

enum PresetCommand
{
    NONE,
    UP,
    DOWN
}

/*
 * Preset Command (Include Tuner Pack Model Only)
 */
class PresetCommandMsg extends ZonedMessage
{
    static const String CODE = "PRS";
    static const String ZONE2_CODE = "PRZ";
    static const String ZONE3_CODE = "PR3";
    static const String ZONE4_CODE = "PR4";

    static const List<String> ZONE_COMMANDS = [CODE, ZONE2_CODE, ZONE3_CODE, ZONE4_CODE];

    static const int NO_PRESET = -1;

    static const ExtEnum<PresetCommand> ValueEnum = ExtEnum<PresetCommand>([
        EnumItem(PresetCommand.NONE, defValue: true),
        EnumItem(PresetCommand.UP, descrList: Strings.l_preset_command_up, icon: Drawables.cmd_right),
        EnumItem(PresetCommand.DOWN, descrList: Strings.l_preset_command_down, icon: Drawables.cmd_left)
    ]);

    EnumItem<PresetCommand> _command;
    Preset _presetConfig;
    int _preset;

    PresetCommandMsg(EISCPMessage raw) : super(ZONE_COMMANDS, raw)
    {
        _command = null;
        _presetConfig = null;
        _preset = ISCPMessage.nonNullInteger(getData, 16, NO_PRESET);
    }

    PresetCommandMsg.outputCmd(int zoneIndex, final PresetCommand command) :
            super.output(ZONE_COMMANDS, zoneIndex, ValueEnum.valueByKey(command).getCode)
    {
        _command = ValueEnum.valueByKey(command);
        _presetConfig = null;
        _preset = NO_PRESET;
    }

    PresetCommandMsg.outputCfg(int zoneIndex, final Preset presetConfig) :
            super.output(ZONE_COMMANDS, zoneIndex, _getParameterAsString(presetConfig))
    {
        _command = null;
        _presetConfig = presetConfig;
        _preset = NO_PRESET;
    }

    static String _getParameterAsString(final Preset presetConfig)
    {
        return presetConfig.getId.toRadixString(16).padLeft(2, '0');
    }

    EnumItem<PresetCommand> get getCommand
    => _command;

    Preset get getPresetConfig
    => _presetConfig;

    int get getPreset
    => _preset;

    @override
    String toString()
    => super.toString()
            + "[CMD=" + (_command != null ? _command.toString() : "null")
            + "; PRS_CFG=" + (_presetConfig != null ? _presetConfig.getName : "null")
            + "; PRESET=" + _preset.toString() + "]";

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }
}
