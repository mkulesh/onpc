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

import "../ISCPMessage.dart";

/*
 * NET/USB Time Seek
 */
class TimeSeekMsg extends ISCPMessage
{
    static const String CODE = "NTS";

    TimeSeekMsg.output(final bool sendHours, final int hours, final int minutes, final int seconds) :
            super.output(CODE, _getParameterAsString(sendHours, hours, minutes, seconds));

    static String _getParameterAsString(final bool sendHours, final int hours, final int minutes, final int seconds)
    {
        if (sendHours)
        {
            return hours.toString().padLeft(2, '0')
                + ":" + minutes.toString().padLeft(2, '0')
                + ":" + seconds.toString().padLeft(2, '0');
        }
        else
        {
            return minutes.toString().padLeft(2, '0')
                + ":" + seconds.toString().padLeft(2, '0');
        }
    }

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }
}
