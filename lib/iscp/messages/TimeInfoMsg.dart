/*
 * Copyright (C) 2019. Mikhail Kulesh
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
    String _currentTime, _maxTime;

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

    String get getCurrentTime
    => _currentTime.isEmpty ? INVALID_TIME : _currentTime;

    String get getMaxTime
    => _maxTime.isEmpty ? INVALID_TIME : _maxTime;

    @override
    String toString()
    => super.toString() + "[CURR=" + getCurrentTime + "; MAX=" + getMaxTime + "]";
}
