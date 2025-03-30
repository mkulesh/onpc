/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2025 by Mikhail Kulesh
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
import "../../utils/Convert.dart";
import "../EISCPMessage.dart";
import "EnumParameterMsg.dart";

enum ListeningMode
{
    NONE,
    // Integra
    MODE_00,
    MODE_01,
    MODE_02,
    MODE_03,
    MODE_04,
    MODE_05,
    MODE_06,
    MODE_07,
    MODE_08,
    MODE_09,
    MODE_0A,
    MODE_0B,
    MODE_0C,
    MODE_0D,
    MODE_0E,
    MODE_0F,
    MODE_11,
    MODE_12,
    MODE_13,
    MODE_14,
    MODE_15,
    MODE_16,
    MODE_17,
    MODE_1F,
    MODE_40,
    MODE_41,
    MODE_42,
    MODE_43,
    MODE_44,
    MODE_45,
    MODE_50,
    MODE_51,
    MODE_52,
    MODE_80,
    MODE_81,
    MODE_82,
    MODE_83,
    MODE_84,
    MODE_85,
    MODE_86,
    MODE_87,
    MODE_88,
    MODE_89,
    MODE_8A,
    MODE_8B,
    MODE_8C,
    MODE_8D,
    MODE_8E,
    MODE_8F,
    MODE_90,
    MODE_91,
    MODE_92,
    MODE_93,
    MODE_94,
    MODE_95,
    MODE_96,
    MODE_97,
    MODE_98,
    MODE_99,
    MODE_9A,
    MODE_A0,
    MODE_A1,
    MODE_A2,
    MODE_A3,
    MODE_A4,
    MODE_A5,
    MODE_A6,
    MODE_A7,
    MODE_FF,
    
    // Denon
    MODE_DCP_DIRECT,
    MODE_DCP_PURE_DIRECT,
    MODE_DCP_STEREO,
    MODE_DCP_ALL_ZONE_STEREO,
    MODE_DCP_AUTO,
    MODE_DCP_DOLBY_DIGITAL,
    MODE_DCP_DTS_SURROUND,
    MODE_DCP_AURO3D,
    MODE_DCP_AURO2DSURR,
    MODE_DCP_MCH_STEREO,
    MODE_DCP_WIDE_SCREEN,
    MODE_DCP_SUPER_STADIUM,
    MODE_DCP_ROCK_ARENA,
    MODE_DCP_JAZZ_CLUB,
    MODE_DCP_CLASSIC_CONCERT,
    MODE_DCP_MONO_MOVIE,
    MODE_DCP_MATRIX,
    MODE_DCP_VIDEO_GAME,
    MODE_DCP_VIRTUAL,
    
    // Control
    UP,
    DOWN,
    MUSIC,
    MOVIE,
    GAME,
    STEREO,
    THX
}

/*
 * Listening Mode Command
 */
class ListeningModeMsg extends EnumParameterMsg<ListeningMode>
{
    static const String CODE = "LMD";

    static const ExtEnum<ListeningMode> ValueEnum = ExtEnum<ListeningMode>([
        EnumItem.code(ListeningMode.NONE, "--",
            descr: Strings.dashed_string, defValue: true),

        // Integra
        EnumItem.code(ListeningMode.MODE_00, "00",
            descr: Strings.listening_mode_mode_00),
        EnumItem.code(ListeningMode.MODE_01, "01",
            descr: Strings.listening_mode_mode_01),
        EnumItem.code(ListeningMode.MODE_02, "02",
            descr: Strings.listening_mode_mode_02),
        EnumItem.code(ListeningMode.MODE_03, "03",
            descr: Strings.listening_mode_mode_03),
        EnumItem.code(ListeningMode.MODE_04, "04",
            descr: Strings.listening_mode_mode_04),
        EnumItem.code(ListeningMode.MODE_05, "05",
            descr: Strings.listening_mode_mode_05),
        EnumItem.code(ListeningMode.MODE_06, "06",
            descr: Strings.listening_mode_mode_06),
        EnumItem.code(ListeningMode.MODE_07, "07",
            descr: Strings.listening_mode_mode_07),
        EnumItem.code(ListeningMode.MODE_08, "08",
            descr: Strings.listening_mode_mode_08),
        EnumItem.code(ListeningMode.MODE_09, "09",
            descr: Strings.listening_mode_mode_09),
        EnumItem.code(ListeningMode.MODE_0A, "0A",
            descr: Strings.listening_mode_mode_0a),
        EnumItem.code(ListeningMode.MODE_0B, "0B",
            descr: Strings.listening_mode_mode_0b),
        EnumItem.code(ListeningMode.MODE_0C, "0C",
            descr: Strings.listening_mode_mode_0c),
        EnumItem.code(ListeningMode.MODE_0D, "0D",
            descr: Strings.listening_mode_mode_0d),
        EnumItem.code(ListeningMode.MODE_0E, "0E",
            descr: Strings.listening_mode_mode_0e),
        EnumItem.code(ListeningMode.MODE_0F, "0F",
            descr: Strings.listening_mode_mode_0f),
        EnumItem.code(ListeningMode.MODE_11, "11",
            descr: Strings.listening_mode_mode_11),
        EnumItem.code(ListeningMode.MODE_12, "12",
            descr: Strings.listening_mode_mode_12),
        EnumItem.code(ListeningMode.MODE_13, "13",
            descr: Strings.listening_mode_mode_13),
        EnumItem.code(ListeningMode.MODE_14, "14",
            descr: Strings.listening_mode_mode_14),
        EnumItem.code(ListeningMode.MODE_15, "15",
            descr: Strings.listening_mode_mode_15),
        EnumItem.code(ListeningMode.MODE_16, "16",
            descr: Strings.listening_mode_mode_16),
        EnumItem.code(ListeningMode.MODE_17, "17",
            descr: Strings.listening_mode_mode_17),
        EnumItem.code(ListeningMode.MODE_1F, "1F",
            descr: Strings.listening_mode_mode_1f),
        EnumItem.code(ListeningMode.MODE_40, "40",
            descr: Strings.listening_mode_mode_40),
        EnumItem.code(ListeningMode.MODE_41, "41",
            descr: Strings.listening_mode_mode_41),
        EnumItem.code(ListeningMode.MODE_42, "42",
            descr: Strings.listening_mode_mode_42),
        EnumItem.code(ListeningMode.MODE_43, "43",
            descr: Strings.listening_mode_mode_43),
        EnumItem.code(ListeningMode.MODE_44, "44",
            descr: Strings.listening_mode_mode_44),
        EnumItem.code(ListeningMode.MODE_45, "45",
            descr: Strings.listening_mode_mode_45),
        EnumItem.code(ListeningMode.MODE_50, "50",
            descr: Strings.listening_mode_mode_50),
        EnumItem.code(ListeningMode.MODE_51, "51",
            descr: Strings.listening_mode_mode_51),
        EnumItem.code(ListeningMode.MODE_52, "52",
            descr: Strings.listening_mode_mode_52),
        EnumItem.code(ListeningMode.MODE_80, "80",
            descr: Strings.listening_mode_mode_80),
        EnumItem.code(ListeningMode.MODE_81, "81",
            descr: Strings.listening_mode_mode_81),
        EnumItem.code(ListeningMode.MODE_82, "82",
            descr: Strings.listening_mode_mode_82),
        EnumItem.code(ListeningMode.MODE_83, "83",
            descr: Strings.listening_mode_mode_83),
        EnumItem.code(ListeningMode.MODE_84, "84",
            descr: Strings.listening_mode_mode_84),
        EnumItem.code(ListeningMode.MODE_85, "85",
            descr: Strings.listening_mode_mode_85),
        EnumItem.code(ListeningMode.MODE_86, "86",
            descr: Strings.listening_mode_mode_86),
        EnumItem.code(ListeningMode.MODE_87, "87",
            descr: Strings.listening_mode_mode_87),
        EnumItem.code(ListeningMode.MODE_88, "88",
            descr: Strings.listening_mode_mode_88),
        EnumItem.code(ListeningMode.MODE_89, "89",
            descr: Strings.listening_mode_mode_89),
        EnumItem.code(ListeningMode.MODE_8A, "8A",
            descr: Strings.listening_mode_mode_8a),
        EnumItem.code(ListeningMode.MODE_8B, "8B",
            descr: Strings.listening_mode_mode_8b),
        EnumItem.code(ListeningMode.MODE_8C, "8C",
            descr: Strings.listening_mode_mode_8c),
        EnumItem.code(ListeningMode.MODE_8D, "8D",
            descr: Strings.listening_mode_mode_8d),
        EnumItem.code(ListeningMode.MODE_8E, "8E",
            descr: Strings.listening_mode_mode_8e),
        EnumItem.code(ListeningMode.MODE_8F, "8F",
            descr: Strings.listening_mode_mode_8f),
        EnumItem.code(ListeningMode.MODE_90, "90",
            descr: Strings.listening_mode_mode_90),
        EnumItem.code(ListeningMode.MODE_91, "91",
            descr: Strings.listening_mode_mode_91),
        EnumItem.code(ListeningMode.MODE_92, "92",
            descr: Strings.listening_mode_mode_92),
        EnumItem.code(ListeningMode.MODE_93, "93",
            descr: Strings.listening_mode_mode_93),
        EnumItem.code(ListeningMode.MODE_94, "94",
            descr: Strings.listening_mode_mode_94),
        EnumItem.code(ListeningMode.MODE_95, "95",
            descr: Strings.listening_mode_mode_95),
        EnumItem.code(ListeningMode.MODE_96, "96",
            descr: Strings.listening_mode_mode_96),
        EnumItem.code(ListeningMode.MODE_97, "97",
            descr: Strings.listening_mode_mode_97),
        EnumItem.code(ListeningMode.MODE_98, "98",
            descr: Strings.listening_mode_mode_98),
        EnumItem.code(ListeningMode.MODE_99, "99",
            descr: Strings.listening_mode_mode_99),
        EnumItem.code(ListeningMode.MODE_9A, "9A",
            descr: Strings.listening_mode_mode_9a),
        EnumItem.code(ListeningMode.MODE_A0, "A0",
            descr: Strings.listening_mode_mode_a0),
        EnumItem.code(ListeningMode.MODE_A1, "A1",
            descr: Strings.listening_mode_mode_a1),
        EnumItem.code(ListeningMode.MODE_A2, "A2",
            descr: Strings.listening_mode_mode_a2),
        EnumItem.code(ListeningMode.MODE_A3, "A3",
            descr: Strings.listening_mode_mode_a3),
        EnumItem.code(ListeningMode.MODE_A4, "A4",
            descr: Strings.listening_mode_mode_a4),
        EnumItem.code(ListeningMode.MODE_A5, "A5",
            descr: Strings.listening_mode_mode_a5),
        EnumItem.code(ListeningMode.MODE_A6, "A6",
            descr: Strings.listening_mode_mode_a6),
        EnumItem.code(ListeningMode.MODE_A7, "A7",
            descr: Strings.listening_mode_mode_a7),
        EnumItem.code(ListeningMode.MODE_FF, "FF",
            descr: Strings.listening_mode_mode_ff),

        // Denon
        EnumItem.code(ListeningMode.MODE_DCP_DIRECT, "DIRECT", 
            descr: Strings.listening_mode_mode_01),
        EnumItem.code(ListeningMode.MODE_DCP_PURE_DIRECT, "PURE DIRECT", 
            descr: Strings.listening_mode_pure_direct),
        EnumItem.code(ListeningMode.MODE_DCP_STEREO, "STEREO", 
            descr: Strings.listening_mode_mode_00),
        EnumItem.code(ListeningMode.MODE_DCP_ALL_ZONE_STEREO, "ALL ZONE STEREO",
            descr: Strings.listening_mode_all_zone_stereo),
        EnumItem.code(ListeningMode.MODE_DCP_AUTO, "AUTO",
            descr: Strings.listening_mode_auto),
        EnumItem.code(ListeningMode.MODE_DCP_DOLBY_DIGITAL, "DOLBY DIGITAL", 
            descr: Strings.listening_mode_mode_40),
        EnumItem.code(ListeningMode.MODE_DCP_DTS_SURROUND, "DTS SURROUND", 
            descr: Strings.listening_mode_dts_surround),
        EnumItem.code(ListeningMode.MODE_DCP_AURO3D, "AURO3D", 
            descr: Strings.listening_mode_auro3d),
        EnumItem.code(ListeningMode.MODE_DCP_AURO2DSURR, "AURO2DSURR", 
            descr: Strings.listening_mode_auro2d_surr),
        EnumItem.code(ListeningMode.MODE_DCP_MCH_STEREO, "MCH STEREO", 
            descr: Strings.listening_mode_mch_stereo),
        EnumItem.code(ListeningMode.MODE_DCP_WIDE_SCREEN, "WIDE SCREEN", 
            descr: Strings.listening_mode_wide_screen),
        EnumItem.code(ListeningMode.MODE_DCP_SUPER_STADIUM, "SUPER STADIUM", 
            descr: Strings.listening_mode_super_stadium),
        EnumItem.code(ListeningMode.MODE_DCP_ROCK_ARENA, "ROCK ARENA", 
            descr: Strings.listening_mode_rock_arena),
        EnumItem.code(ListeningMode.MODE_DCP_JAZZ_CLUB, "JAZZ CLUB", 
            descr: Strings.listening_mode_jazz_club),
        EnumItem.code(ListeningMode.MODE_DCP_CLASSIC_CONCERT, "CLASSIC CONCERT", 
            descr: Strings.listening_mode_classic_concert),
        EnumItem.code(ListeningMode.MODE_DCP_MONO_MOVIE, "MONO MOVIE", 
            descr: Strings.listening_mode_mono_movie),
        EnumItem.code(ListeningMode.MODE_DCP_MATRIX, "MATRIX", 
            descr: Strings.listening_mode_matrix),
        EnumItem.code(ListeningMode.MODE_DCP_VIDEO_GAME, "VIDEO GAME", 
            descr: Strings.listening_mode_video_game),
        EnumItem.code(ListeningMode.MODE_DCP_VIRTUAL, "VIRTUAL", 
            descr: Strings.listening_mode_vitrual),

        // Control
        EnumItem.code(ListeningMode.UP, "UP", dcpCode: "RIGHT",
            descrList: Strings.l_listening_mode_up,
            icon: Drawables.cmd_right),
        EnumItem.code(ListeningMode.DOWN, "DOWN", dcpCode: "LEFT",
            descrList: Strings.l_listening_mode_down,
            icon: Drawables.cmd_left),
        EnumItem.code(ListeningMode.MUSIC, "MUSIC",
            descr: Strings.listening_mode_music),
        EnumItem.code(ListeningMode.MOVIE, "MOVIE",
            descr: Strings.listening_mode_movie),
        EnumItem.code(ListeningMode.GAME, "GAME",
            descr: Strings.listening_mode_game),
        EnumItem.code(ListeningMode.STEREO, "STEREO",
            descr: Strings.listening_mode_stereo),
        EnumItem.code(ListeningMode.THX, "THX",
            descr: Strings.listening_mode_thx),
    ]);

    ListeningModeMsg(EISCPMessage raw) : super(CODE, raw, ValueEnum);

    ListeningModeMsg.output(ListeningMode v) : super.output(CODE, v, ValueEnum);

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }

    static bool isMode(ListeningMode item)
    => Convert.enumToString(item).startsWith("MODE_");

    /*
     * Denon control protocol
     */
    static const String _DCP_COMMAND = "MS";

    static List<String> getAcceptedDcpCodes()
    => [ _DCP_COMMAND ];

    static ListeningModeMsg? processDcpMessage(String dcpMsg)
    {
        final EnumItem<ListeningMode>? s = ValueEnum.valueByDcpCommand(_DCP_COMMAND, dcpMsg);
        return s != null ? ListeningModeMsg.output(s.key) : null;
    }

    @override
    String? buildDcpMsg(bool isQuery)
    => buildDcpRequest(isQuery, _DCP_COMMAND);
}
