/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2024 by Mikhail Kulesh
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

import "../DcpHeosMessage.dart";
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";

/*
 * NET/USB Track Info
 */
class TrackInfoMsg extends ISCPMessage
{
    static const String CODE = "NTR";
    static const int INVALID_TRACK = -1;

    /*
     * (Current Track/Total Track Max 9999. If Track is unknown, this response is ----)
     */
    late int _currentTrack, _maxTrack;

    TrackInfoMsg(EISCPMessage raw) : super(CODE, raw)
    {
        final List<String> pars = getData.split(ISCPMessage.PAR_SEP);
        if (pars.length != 2)
        {
            throw Exception("Can not find parameter split character in message " + raw.toString());
        }
        _currentTrack = ISCPMessage.nonNullInteger(pars[0], 10, INVALID_TRACK);
        _maxTrack = ISCPMessage.nonNullInteger(pars[1], 10, INVALID_TRACK);
    }

    TrackInfoMsg.output(int currentTrack, int maxTrack) :
            super.output(CODE, currentTrack.toString() + ISCPMessage.PAR_SEP + maxTrack.toString())
    {
        _currentTrack = currentTrack;
        _maxTrack = maxTrack;
    }

    int get getCurrentTrack
    => _currentTrack;

    int get getMaxTrack
    => _maxTrack;

    @override
    String toString()
    => super.toString() + "[CURR=" + _currentTrack.toString() + "; MAX=" + _maxTrack.toString() + "]";

    /*
     * Denon control protocol
     * Request queue length: heos://player/get_queue?pid=PID&range=X,Y
     * Response: {"heos": {"command": "player/get_queue", "result": "success", "message": "pid=PID&range=X,Y&returned=17&count=17"}, "payload": []}
     */
    static const String _HEOS_COMMAND = "player/get_queue";

    static TrackInfoMsg? processHeosMessage(final DcpHeosMessage jsonMsg)
    {
        if (_HEOS_COMMAND == jsonMsg.command)
        {
            final int? count = int.tryParse(jsonMsg.getMsgTag("count"));
            if (count != null && count == 0)
            {
                return TrackInfoMsg.output(INVALID_TRACK, INVALID_TRACK);
            }
            final List<String> rangeStr = jsonMsg.getMsgTag("range").split(",");
            if (rangeStr.length == 2 && rangeStr.first == rangeStr.last)
            {
                // process get_queue response with equal start and end items
                final int? current = int.tryParse(rangeStr.first);
                if (current != null && count != null)
                {
                    return TrackInfoMsg.output(current, count);
                }
            }
        }
        return null;
    }

    @override
    String? buildDcpMsg(bool isQuery)
    => "heos://" + _HEOS_COMMAND + "?pid=" + ISCPMessage.DCP_HEOS_PID +
        "&range=" + _currentTrack.toString() + "," + _currentTrack.toString();
}
