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
import "dart:math";

import "../ISCPMessage.dart";

enum TimeFormat
{
    MM60_SS,    /* MM60 here minutes between 0 and 59 */
    MM99_SS,    /* MM99 here minutes between 0 and 99, like for CR-N765 */
    HH_MM_SS
}

/*
 * NET/USB Time Seek
 */
class TimeSeekMsg extends ISCPMessage
{
    static const String CODE = "NTS";

    TimeFormat _timeFormat;

    TimeSeekMsg.output(final String model, final int hours, final int minutes, final int seconds)
        : super.output(CODE, _getParameterAsString(_getTimeFormat(model, hours), hours, minutes, seconds))
    {
        this._timeFormat = _getTimeFormat(model, hours);
    }

    @override
    String toString()
    => super.toString() + "[FORMAT=" + _timeFormat.toString() + "]";

    static TimeFormat _getTimeFormat(final String model, final int hours)
    {
        switch (model)
        {
            case "CR-N765":
                return TimeFormat.MM99_SS;
            case "NT-503":
                return hours > 0 ? TimeFormat.HH_MM_SS : TimeFormat.MM60_SS;
            default:
                return TimeFormat.HH_MM_SS;
        }
    }

    static String _getParameterAsString(final TimeFormat timeFormat,
        final int hours, final int minutes, final int seconds)
    {
        final int MM99_MAX_MIN = 99;
        switch (timeFormat)
        {
            case TimeFormat.MM60_SS:
                return minutes.toString().padLeft(2, '0') +
                    ":" + seconds.toString().padLeft(2, '0');
            case TimeFormat.MM99_SS:
                return min(MM99_MAX_MIN, 60 * hours + minutes).toString().padLeft(2, '0') +
                    ":" + seconds.toString().padLeft(2, '0');
            case TimeFormat.HH_MM_SS:
            /* it is also default case*/
            default:
                return hours.toString().padLeft(2, '0') +
                    ":" + minutes.toString().padLeft(2, '0') +
                    ":" + seconds.toString().padLeft(2, '0');
        }
    }

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }
}
