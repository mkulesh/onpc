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

enum MasterVolume
{
    NONE,
    UP,
    DOWN,
    UP1,
    DOWN1
}

/*
 * Master Volume Command
 */
class MasterVolumeMsg extends ZonedMessage
{
    static const String CODE = "MVL";
    static const String ZONE2_CODE = "ZVL";
    static const String ZONE3_CODE = "VL3";
    static const String ZONE4_CODE = "VL4";

    static const List<String> ZONE_COMMANDS = [CODE, ZONE2_CODE, ZONE3_CODE, ZONE4_CODE];

    static const int NO_LEVEL = -1;
    static const int MAX_VOLUME_1_STEP = 0x64;

    static const ExtEnum<MasterVolume> ValueEnum = ExtEnum<MasterVolume>([
        EnumItem(MasterVolume.NONE, defValue: true),
        EnumItem(MasterVolume.UP, descrList: Strings.l_master_volume_up, icon: Drawables.volume_amp_up),
        EnumItem(MasterVolume.DOWN, descrList: Strings.l_master_volume_down, icon: Drawables.volume_amp_down),
        EnumItem(MasterVolume.UP1, descrList: Strings.l_master_volume_up1, icon: Drawables.volume_amp_up),
        EnumItem(MasterVolume.DOWN1, descrList: Strings.l_master_volume_down1, icon: Drawables.volume_amp_down)
    ]);

    EnumItem<MasterVolume> _command;
    int _volumeLevel = NO_LEVEL;

    MasterVolumeMsg(EISCPMessage raw) : super(ZONE_COMMANDS, raw)
    {
        _command = ValueEnum.defValue;
        _volumeLevel = ISCPMessage.nonNullInteger(getData, 16, NO_LEVEL);
    }

    MasterVolumeMsg.output(int zoneIndex, MasterVolume v) :
            super.output(ZONE_COMMANDS, zoneIndex, ValueEnum.valueByKey(v).getCode)
    {
        _command = ValueEnum.valueByKey(v);
        _volumeLevel = NO_LEVEL;
    }

    MasterVolumeMsg.value(int zoneIndex, int v) :
            super.output(ZONE_COMMANDS, zoneIndex, v.toRadixString(16).padLeft(2, '0'))
    {
        _command = ValueEnum.defValue;
        _volumeLevel = v;
    }

    EnumItem<MasterVolume> get getCommand
    => _command;

    int get getVolumeLevel
    => _volumeLevel;

    @override
    String toString()
    => super.toString() + "[COMMAND=" + _command.toString() + "; LEVEL=" + _volumeLevel.toString() + "]";

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }
}
