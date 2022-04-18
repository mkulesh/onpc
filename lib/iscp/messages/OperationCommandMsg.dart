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
import "../../constants/Drawables.dart";
import "../../constants/Strings.dart";
import "EnumParameterMsg.dart";

enum OperationCommand
{
    PLAY,
    STOP,
    PAUSE,
    P_P,
    TRUP,
    TRDN,
    FF,
    REW,
    REPEAT,
    RANDOM,
    REP_SHF,
    DISPLAY,
    ALBUM,
    ARTIST,
    GENRE,
    PLAYLIST,
    RIGHT,
    LEFT,
    UP,
    DOWN,
    SELECT,
    KEY_0,
    KEY_1,
    KEY_2,
    KEY_3,
    KEY_4,
    KEY_5,
    KEY_6,
    KEY_7,
    KEY_8,
    KEY_9,
    DELETE,
    CAPS,
    LOCATION,
    LANGUAGE,
    SETUP,
    RETURN,
    CHUP,
    CHDN,
    MENU,
    TOP,
    MODE,
    LIST,
    MEMORY,
    F1,
    F2,
    SORT
}

/*
 * Network/USB Operation Command (Network Model Only after TX-NR905)
 */
class OperationCommandMsg extends EnumParameterZonedMsg<OperationCommand>
{
    static const String CODE = "NTC";
    static const String ZONE2_CODE = "NTZ";
    static const String ZONE3_CODE = "NT3";
    static const String ZONE4_CODE = "NT4";

    static const List<String> ZONE_COMMANDS = [CODE, ZONE2_CODE, ZONE3_CODE, ZONE4_CODE];

    static const ExtEnum<OperationCommand> ValueEnum = ExtEnum<OperationCommand>([
        EnumItem.code(OperationCommand.PLAY, "PLAY",
            descrList: Strings.l_cmd_description_play, icon: Drawables.cmd_play),
        EnumItem.code(OperationCommand.STOP, "STOP",
            descrList: Strings.l_cmd_description_stop, icon: Drawables.cmd_stop),
        EnumItem.code(OperationCommand.PAUSE, "PAUSE",
            descrList: Strings.l_cmd_description_pause, icon: Drawables.cmd_pause),
        EnumItem.code(OperationCommand.P_P, "P/P",
            descrList: Strings.l_cmd_description_p_p),
        EnumItem.code(OperationCommand.TRUP, "TRUP",
            descrList: Strings.l_cmd_description_trup, icon: Drawables.cmd_next),
        EnumItem.code(OperationCommand.TRDN, "TRDN",
            descrList: Strings.l_cmd_description_trdn, icon: Drawables.cmd_previous),
        EnumItem.code(OperationCommand.FF, "FF",
            descrList: Strings.l_cmd_description_ff, icon: Drawables.cmd_fast_forward),
        EnumItem.code(OperationCommand.REW, "REW",
            descrList: Strings.l_cmd_description_rew, icon: Drawables.cmd_fast_backward),
        EnumItem.code(OperationCommand.REPEAT, "REPEAT",
            descrList: Strings.l_cmd_description_repeat, icon: Drawables.repeat_all),
        EnumItem.code(OperationCommand.RANDOM, "RANDOM",
            descrList: Strings.l_cmd_description_random, icon: Drawables.cmd_random),
        EnumItem.code(OperationCommand.REP_SHF, "REP/SHF",
            descrList: Strings.l_cmd_description_rep_shf),
        EnumItem.code(OperationCommand.DISPLAY, "DISPLAY",
            descrList: Strings.l_cmd_description_display),
        EnumItem.code(OperationCommand.ALBUM, "ALBUM",
            descrList: Strings.l_cmd_description_album),
        EnumItem.code(OperationCommand.ARTIST, "ARTIST",
            descrList: Strings.l_cmd_description_artist),
        EnumItem.code(OperationCommand.GENRE, "GENRE",
            descrList: Strings.l_cmd_description_genre),
        EnumItem.code(OperationCommand.PLAYLIST, "PLAYLIST",
            descrList: Strings.l_cmd_description_playlist),
        EnumItem.code(OperationCommand.RIGHT, "RIGHT",
            descrList: Strings.l_cmd_description_right, icon: Drawables.cmd_right),
        EnumItem.code(OperationCommand.LEFT, "LEFT",
            descrList: Strings.l_cmd_description_left, icon: Drawables.cmd_left),
        EnumItem.code(OperationCommand.UP, "UP",
            descrList: Strings.l_cmd_description_up, icon: Drawables.cmd_up),
        EnumItem.code(OperationCommand.DOWN, "DOWN",
            descrList: Strings.l_cmd_description_down, icon: Drawables.cmd_down),
        EnumItem.code(OperationCommand.SELECT, "SELECT",
            descrList: Strings.l_cmd_description_select, icon: Drawables.cmd_select),
        EnumItem.code(OperationCommand.KEY_0, "0",
            descrList: Strings.l_cmd_description_key_0),
        EnumItem.code(OperationCommand.KEY_1, "1",
            descrList: Strings.l_cmd_description_key_1),
        EnumItem.code(OperationCommand.KEY_2, "2",
            descrList: Strings.l_cmd_description_key_2),
        EnumItem.code(OperationCommand.KEY_3, "3",
            descrList: Strings.l_cmd_description_key_3),
        EnumItem.code(OperationCommand.KEY_4, "4",
            descrList: Strings.l_cmd_description_key_4),
        EnumItem.code(OperationCommand.KEY_5, "5",
            descrList: Strings.l_cmd_description_key_5),
        EnumItem.code(OperationCommand.KEY_6, "6",
            descrList: Strings.l_cmd_description_key_6),
        EnumItem.code(OperationCommand.KEY_7, "7",
            descrList: Strings.l_cmd_description_key_7),
        EnumItem.code(OperationCommand.KEY_8, "8",
            descrList: Strings.l_cmd_description_key_8),
        EnumItem.code(OperationCommand.KEY_9, "9",
            descrList: Strings.l_cmd_description_key_9),
        EnumItem.code(OperationCommand.DELETE, "DELETE",
            descrList: Strings.l_cmd_description_delete, icon: Drawables.cmd_delete),
        EnumItem.code(OperationCommand.CAPS, "CAPS",
            descrList: Strings.l_cmd_description_caps),
        EnumItem.code(OperationCommand.LOCATION, "LOCATION",
            descrList: Strings.l_cmd_description_location),
        EnumItem.code(OperationCommand.LANGUAGE, "LANGUAGE",
            descrList: Strings.l_cmd_description_language),
        EnumItem.code(OperationCommand.SETUP, "SETUP",
            descrList: Strings.l_cmd_description_setup, icon: Drawables.cmd_setup),
        EnumItem.code(OperationCommand.RETURN, "RETURN",
            descrList: Strings.l_cmd_description_return, icon: Drawables.cmd_return),
        EnumItem.code(OperationCommand.CHUP, "CHUP",
            descrList: Strings.l_cmd_description_chup),
        EnumItem.code(OperationCommand.CHDN, "CHDN",
            descrList: Strings.l_cmd_description_chdn),
        EnumItem.code(OperationCommand.MENU, "MENU",
            descrList: Strings.l_cmd_description_menu, icon: Drawables.cmd_track_menu),
        EnumItem.code(OperationCommand.TOP, "TOP",
            descrList: Strings.l_cmd_description_top, icon: Drawables.cmd_top),
        EnumItem.code(OperationCommand.MODE, "MODE",
            descrList: Strings.l_cmd_description_mode),
        EnumItem.code(OperationCommand.LIST, "LIST",
            descrList: Strings.l_cmd_description_list),
        EnumItem.code(OperationCommand.MEMORY, "MEMORY",
            descrList: Strings.l_cmd_description_memory),
        EnumItem.code(OperationCommand.F1, "F1",
            descrList: Strings.l_cmd_description_f1, icon: Drawables.feed_like),
        EnumItem.code(OperationCommand.F2, "F2",
            descrList: Strings.l_cmd_description_f2, icon: Drawables.feed_dont_like),
        EnumItem.code(OperationCommand.SORT, "SORT",
            descrList: Strings.l_cmd_description_sort, icon: Drawables.cmd_sort)
    ]);

    OperationCommandMsg.output(int zoneIndex, OperationCommand v) :
            super.output(ZONE_COMMANDS, zoneIndex, v, ValueEnum);

    @override
    bool hasImpactOnMediaList()
    {
        switch (getValue.key)
        {
            case OperationCommand.REPEAT:
            case OperationCommand.RANDOM:
            case OperationCommand.F1:
            case OperationCommand.F2:
                return false;
            default:
                return true;
        }
    }
}
