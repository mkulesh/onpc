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
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";
import "EnumParameterMsg.dart";

enum PlayStatus
{
    STOP,
    PLAY,
    PAUSE,
    FF,
    FR,
    EOF
}

enum RepeatStatus
{
    OFF,
    ALL,
    FOLDER,
    REPEAT_1,
    DISABLE
}

enum ShuffleStatus
{
    OFF,
    ALL,
    ALBUM,
    FOLDER,
    DISABLE
}

/*
 * NET/USB/CD Play Status (3 letters)
 */
class PlayStatusMsg extends ISCPMessage
{
    static const String CODE = "NST";
    static const String CD_CODE = "CST";

    /*
     * Play Status: "S": STOP, "P": Play, "p": Pause, "F": FF, "R": FR, "E": EOF
     */
    static const ExtEnum<PlayStatus> PlayStatusEnum = ExtEnum<PlayStatus>([
        EnumItem.char(PlayStatus.STOP, 'S'),
        EnumItem.char(PlayStatus.PLAY, 'P'),
        EnumItem.char(PlayStatus.PAUSE, 'p'),
        EnumItem.char(PlayStatus.FF, 'F'),
        EnumItem.char(PlayStatus.FR, 'R'),
        EnumItem.char(PlayStatus.EOF, 'E', defValue: true)
    ]);

    EnumItem<PlayStatus> _playStatus;

    /*
     * Repeat Status: '-': Off, 'R': All, 'F': Folder, '1': Repeat 1, 'x': disable
     */
    static const ExtEnum<RepeatStatus> RepeatStatusEnum = ExtEnum<RepeatStatus>([
        EnumItem.char(RepeatStatus.OFF, '-', icon: Drawables.repeat_off),
        EnumItem.char(RepeatStatus.ALL, 'R', icon: Drawables.repeat_all),
        EnumItem.char(RepeatStatus.FOLDER, 'F', icon: Drawables.repeat_folder),
        EnumItem.char(RepeatStatus.REPEAT_1, '1', icon: Drawables.repeat_once),
        EnumItem.char(RepeatStatus.DISABLE, 'x', icon: Drawables.repeat_off, defValue: true)
    ]);

    EnumItem<RepeatStatus> _repeatStatus;

    /*
     * Shuffle Status: '-': Off, 'S': All , 'A': Album, 'F': Folder, 'x': disable
     */
    static const ExtEnum<ShuffleStatus> ShuffleStatusEnum = ExtEnum<ShuffleStatus>([
        EnumItem.char(ShuffleStatus.OFF, '-'),
        EnumItem.char(ShuffleStatus.ALL, 'S'),
        EnumItem.char(ShuffleStatus.ALBUM, 'A'),
        EnumItem.char(ShuffleStatus.FOLDER, 'F'),
        EnumItem.char(ShuffleStatus.DISABLE, 'x', defValue: true)
    ]);

    EnumItem<ShuffleStatus> _shuffleStatus;

    PlayStatusMsg(EISCPMessage raw) : super(CODE, raw)
    {
        if (getData.isNotEmpty)
        {
            _playStatus = PlayStatusEnum.valueByCode(getData.substring(0, 1));
        }
        if (getData.length > 1)
        {
            _repeatStatus = RepeatStatusEnum.valueByCode(getData.substring(1, 2));
        }
        if (getData.length > 2)
        {
            _shuffleStatus = ShuffleStatusEnum.valueByCode(getData.substring(2, 3));
        }
    }

    EnumItem<PlayStatus> get getPlayStatus
    => _playStatus;

    EnumItem<RepeatStatus> get getRepeatStatus
    => _repeatStatus;

    EnumItem<ShuffleStatus> get getShuffleStatus
    => _shuffleStatus;

    @override
    String toString()
    => super.toString()
            + "[PLAY=" + _playStatus.toString()
            + "; REPEAT=" + _repeatStatus.toString()
            + "; SHUFFLE=" + _shuffleStatus.toString()
            + "]";
}
