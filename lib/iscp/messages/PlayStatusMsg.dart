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
import "../DcpHeosMessage.dart";
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

enum PlayStatusUpd
{
    ALL,
    PLAY_STATE,
    PLAY_MODE,
    REPEAT,
    SHUFFLE
}

/*
 * NET/USB/CD Play Status (3 letters)
 */
class PlayStatusMsg extends ISCPMessage
{
    static const String CODE = "NST";
    static const String CD_CODE = "CST";

    final PlayStatusUpd _updateType;

    PlayStatusUpd get updateType => _updateType;

    /*
     * Play Status: "S": STOP, "P": Play, "p": Pause, "F": FF, "R": FR, "E": EOF
     */
    static const ExtEnum<PlayStatus> PlayStatusEnum = ExtEnum<PlayStatus>([
        EnumItem.char(PlayStatus.STOP, 'S', dcpCode: "STOP"),
        EnumItem.char(PlayStatus.PLAY, 'P', dcpCode: "PLAY"),
        EnumItem.char(PlayStatus.PAUSE, 'p', dcpCode: "PAUSE"),
        EnumItem.char(PlayStatus.FF, 'F'),
        EnumItem.char(PlayStatus.FR, 'R'),
        EnumItem.char(PlayStatus.EOF, 'E', defValue: true)
    ]);

    EnumItem<PlayStatus> _playStatus = PlayStatusEnum.defValue;

    /*
     * Repeat Status: '-': Off, 'R': All, 'F': Folder, '1': Repeat 1, 'x': disable
     */
    static const ExtEnum<RepeatStatus> RepeatStatusEnum = ExtEnum<RepeatStatus>([
        EnumItem.char(RepeatStatus.OFF, '-', dcpCode: "OFF", icon: Drawables.repeat_off),
        EnumItem.char(RepeatStatus.ALL, 'R', dcpCode: "ON_ALL", icon: Drawables.repeat_all),
        EnumItem.char(RepeatStatus.FOLDER, 'F', dcpCode: "NONE", icon: Drawables.repeat_folder),
        EnumItem.char(RepeatStatus.REPEAT_1, '1', dcpCode: "ON_ONE", icon: Drawables.repeat_once),
        EnumItem.char(RepeatStatus.DISABLE, 'x', dcpCode: "NONE", icon: Drawables.repeat_off, defValue: true)
    ]);

    EnumItem<RepeatStatus> _repeatStatus = RepeatStatusEnum.defValue;

    /*
     * Shuffle Status: '-': Off, 'S': All , 'A': Album, 'F': Folder, 'x': disable
     */
    static const ExtEnum<ShuffleStatus> ShuffleStatusEnum = ExtEnum<ShuffleStatus>([
        EnumItem.char(ShuffleStatus.OFF, '-', dcpCode: "OFF"),
        EnumItem.char(ShuffleStatus.ALL, 'S', dcpCode: "ON"),
        EnumItem.char(ShuffleStatus.ALBUM, 'A', dcpCode: "NONE"),
        EnumItem.char(ShuffleStatus.FOLDER, 'F', dcpCode: "NONE"),
        EnumItem.char(ShuffleStatus.DISABLE, 'x', dcpCode: "NONE", defValue: true)
    ]);

    EnumItem<ShuffleStatus> _shuffleStatus = ShuffleStatusEnum.defValue;

    PlayStatusMsg(EISCPMessage raw) :
            _updateType = PlayStatusUpd.ALL, super(CODE, raw)
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

    PlayStatusMsg._dcpPlayStatus(EnumItem<PlayStatus> playStatus) :
            _updateType = PlayStatusUpd.PLAY_STATE, super.output(CODE, "")
    {
        _playStatus = playStatus;
    }

    PlayStatusMsg._dcpPlayMode(EnumItem<RepeatStatus> repeatStatus, EnumItem<ShuffleStatus> shuffleStatus) :
            _updateType = PlayStatusUpd.PLAY_MODE, super.output(CODE, "")
    {
        _repeatStatus = repeatStatus;
        _shuffleStatus = shuffleStatus;
    }

    PlayStatusMsg._dcpRepeat(EnumItem<RepeatStatus> repeatStatus) :
            _updateType = PlayStatusUpd.REPEAT, super.output(CODE, "")
    {
        _repeatStatus = repeatStatus;
    }

    PlayStatusMsg._dcpShuffle(EnumItem<ShuffleStatus> shuffleStatus) :
            _updateType = PlayStatusUpd.SHUFFLE, super.output(CODE, "")
    {
        _shuffleStatus = shuffleStatus;
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

    /*
     * Denon control protocol
     * - Player State Changed
     * {
     * "heos": {
     *     "command": "event/player_state_changed",
     *     "message": "pid='player_id'&state='play_state'"
     *     }
     * }
     * - Get Play State: heos://player/get_play_state?pid=player_id
     * {
     * "heos": {
     *     "command": "player/get_play_state",
     *     "result": "success",
     *     "message": "pid='player_id'&state='play_state'"
     *     }
     * }
     * - Get Play Mode: heos://player/get_play_mode?pid=player_id
     * - Player Repeat Mode Changed
     * {
     * "heos": {
     *     "command": "event/repeat_mode_changed",
     *     "message": "pid=’player_id’&repeat='on_all_or_on_one_or_off'”
     *     }
     * }
     * -  Player Shuffle Mode Changed
     * {
     *     "heos": {
     *     "command": "event/shuffle_mode_changed",
     *     "message": "pid=’player_id’&shuffle='on_or_off'”
     *     }
     * }
     */
    static const String _HEOS_EVENT_STATE = "event/player_state_changed";
    static const String _HEOS_EVENT_REPEAT = "event/repeat_mode_changed";
    static const String _HEOS_EVENT_SHUFFLE = "event/shuffle_mode_changed";
    static const String _HEOS_COMMAND_STATE = "player/get_play_state";
    static const String _HEOS_COMMAND_MODE = "player/get_play_mode";

    static PlayStatusMsg? processHeosMessage(DcpHeosMessage jsonMsg)
    {
        if (_HEOS_EVENT_STATE == jsonMsg.command ||
            _HEOS_EVENT_REPEAT == jsonMsg.command ||
            _HEOS_EVENT_SHUFFLE == jsonMsg.command ||
            _HEOS_COMMAND_STATE == jsonMsg.command ||
            _HEOS_COMMAND_MODE == jsonMsg.command)
        {
            if (_HEOS_EVENT_STATE == jsonMsg.command || _HEOS_COMMAND_STATE == jsonMsg.command)
            {
                final EnumItem<PlayStatus>? s = PlayStatusEnum.valueByDcpCode(jsonMsg.getMsgTag("state").toUpperCase());
                if (s != null)
                {
                    return PlayStatusMsg._dcpPlayStatus(s);
                }
            }
            if (_HEOS_COMMAND_MODE == jsonMsg.command)
            {
                final EnumItem<RepeatStatus>? r = RepeatStatusEnum.valueByDcpCode(jsonMsg.getMsgTag("repeat").toUpperCase());
                final EnumItem<ShuffleStatus>? s = ShuffleStatusEnum.valueByDcpCode(jsonMsg.getMsgTag("shuffle").toUpperCase());
                if (r != null && s != null)
                {
                    return PlayStatusMsg._dcpPlayMode(r, s);
                }
            }
            if (_HEOS_EVENT_REPEAT == jsonMsg.command)
            {
                final EnumItem<RepeatStatus>? r = RepeatStatusEnum.valueByDcpCode(jsonMsg.getMsgTag("repeat").toUpperCase());
                if (r != null)
                {
                    return PlayStatusMsg._dcpRepeat(r);
                }
            }
            if (_HEOS_EVENT_SHUFFLE == jsonMsg.command)
            {
                final EnumItem<ShuffleStatus>? s = ShuffleStatusEnum.valueByDcpCode(jsonMsg.getMsgTag("shuffle").toUpperCase());
                if (s != null)
                {
                    return PlayStatusMsg._dcpShuffle(s);
                }
            }
        }
        return null;
    }

    @override
    String? buildDcpMsg(bool isQuery)
    {
        if (isQuery)
        {
            return "heos://" + _HEOS_COMMAND_STATE + "?pid=" + ISCPMessage.DCP_HEOS_PID +
                ISCPMessage.DCP_MSG_SEP +
                "heos://" + _HEOS_COMMAND_MODE + "?pid=" + ISCPMessage.DCP_HEOS_PID;
        }
        return null;
    }
}
