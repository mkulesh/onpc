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

import "../EISCPMessage.dart";
import "../ISCPMessage.dart";

/*
 * NET/USB File Info (variable-length, 64 ASCII letters max)
 */
class FileFormatMsg extends ISCPMessage
{
    static const String CODE = "NFI";

    String _format, _sampleFrequency, _bitRate;

    FileFormatMsg(EISCPMessage raw) : super(CODE, raw)
    {
        final List<String> pars = getData.split(ISCPMessage.PAR_SEP);
        _format = pars.isNotEmpty ? ISCPMessage.nonNullString(pars[0]) : "";
        _sampleFrequency = pars.length > 1 ? ISCPMessage.nonNullString(pars[1]) : "";
        _bitRate = pars.length > 2 ? ISCPMessage.nonNullString(pars[2]) : "";
    }

    String getFullFormat()
    {
        String str = _format;
        if (str.isNotEmpty && _sampleFrequency.isNotEmpty)
        {
            str += "/";
        }
        str += _sampleFrequency;
        if (str.isNotEmpty && _bitRate.isNotEmpty)
        {
            str += "/";
        }
        str += _bitRate;
        return str;
    }

    @override
    String toString()
    => super.toString() + "[FORMAT=" + _format + "; FREQUENCY=" + _sampleFrequency + "; BITRATE=" + _bitRate + "]";
}
