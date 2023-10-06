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

import 'package:sprintf/sprintf.dart';

import "../DcpHeosMessage.dart";
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";

/*
 * NET/USB Time Info
 */
class TimeInfoMsg extends ISCPMessage
{
    static const String CODE = "NTM";
    static const String INVALID_TIME = "--:--:--";

    /*
     * (Elapsed time/Track Time Max 99:59:59. If time is unknown, this response is --:--)
     */
    late String _currentTime, _maxTime;

    TimeInfoMsg(EISCPMessage raw) : super(CODE, raw)
    {
        final List<String> pars = getData.split(ISCPMessage.PAR_SEP);
        if (pars.length != 2)
        {
            throw Exception("Can not find parameter split character in message " + raw.toString());
        }
        _currentTime = ISCPMessage.nonNullString(pars[0]);
        _maxTime = ISCPMessage.nonNullString(pars[1]);
    }

    TimeInfoMsg._dcp(String currentTime, String maxTime) : super.output(CODE, "")
    {
        _currentTime = currentTime;
        _maxTime = maxTime;
    }

    String get getCurrentTime
    => _currentTime.isEmpty ? INVALID_TIME : _currentTime;

    String get getMaxTime
    => _maxTime.isEmpty ? INVALID_TIME : _maxTime;

    @override
    String toString()
    => super.toString() + "[CURR=" + getCurrentTime + "; MAX=" + getMaxTime + "]";

    /*
     * Denon control protocol
     * - Player Now Playing Progress
     * {
     * "heos": {
     *     "command": " event/player_now_playing_progress",
     *     "message": "pid=player_id&cur_pos=position_ms&duration=duration_ms"
     *     }
     * }
     */
    static const String _HEOS_COMMAND = "event/player_now_playing_progress";

    static TimeInfoMsg? processHeosMessage(DcpHeosMessage jsonMsg)
    {
        if (_HEOS_COMMAND == jsonMsg.command)
        {
            final String? curPosStr = jsonMsg.message["cur_pos"];
            final String? durationStr = jsonMsg.message["duration"];
            if (curPosStr != null && durationStr != null)
            {
                final int? curPos = int.tryParse(curPosStr);
                final int? duration = int.tryParse(durationStr);
                if (curPos != null && duration != null)
                {
                    return TimeInfoMsg._dcp(_millisToTime(curPos),
                        duration == 0 ? INVALID_TIME : _millisToTime(duration));
                }
            }
        }
        return null;
    }

    static String _millisToTime(int millis)
    {
        final int inpSec = (millis / 1000).floor();
        final int hours = (inpSec / 3600).floor();
        final int minutes = ((inpSec - hours * 3600) / 60).floor();
        final int seconds = inpSec - hours * 3600 - minutes * 60;
        return sprintf("%02d:%02d:%02d", [ hours, minutes, seconds ]);
    }
}
