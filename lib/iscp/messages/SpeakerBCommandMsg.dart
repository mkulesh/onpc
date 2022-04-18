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
import "../../constants/Strings.dart";
import "../EISCPMessage.dart";
import "EnumParameterMsg.dart";

enum SpeakerBCommand
{
    NONE,
    OFF,
    ON,
    TOGGLE
}

/*
 * Speaker B Command (For Main zone and Zone 2 only)
 */
class SpeakerBCommandMsg extends EnumParameterZonedMsg<SpeakerBCommand>
{
    static const String CODE = "SPB";
    static const String ZONE2_CODE = "ZPB";

    static const List<String> ZONE_COMMANDS = [CODE, ZONE2_CODE, CODE, CODE];

    static const ExtEnum<SpeakerBCommand> ValueEnum = ExtEnum<SpeakerBCommand>([
        EnumItem.code(SpeakerBCommand.NONE, "N/A",
            descrList: Strings.l_device_two_way_switch_none, defValue: true),
        EnumItem.code(SpeakerBCommand.OFF, "00",
            descrList: Strings.l_device_two_way_switch_off),
        EnumItem.code(SpeakerBCommand.ON, "01",
            descrList: Strings.l_device_two_way_switch_on),
        EnumItem.code(SpeakerBCommand.TOGGLE, "UP",
            descrList: Strings.l_speaker_b_command_toggle) /* Only available for main zone */
    ]);

    SpeakerBCommandMsg(EISCPMessage raw) : super(ZONE_COMMANDS, raw, ValueEnum);

    SpeakerBCommandMsg.output(int zoneIndex, SpeakerBCommand v) :
            super.output(ZONE_COMMANDS, zoneIndex, v, ValueEnum);

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }
}
