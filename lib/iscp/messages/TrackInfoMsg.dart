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
    int _currentTrack, _maxTrack;

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

    int get getCurrentTrack
    => _currentTrack;

    int get getMaxTrack
    => _maxTrack;

    @override
    String toString()
    => super.toString() + "[CURR=" + _currentTrack.toString() + "; MAX=" + _maxTrack.toString() + "]";
}
