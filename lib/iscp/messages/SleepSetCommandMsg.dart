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
// @dart=2.9
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";

/*
 * Sleep Set Command
 */
class SleepSetCommandMsg extends ISCPMessage
{
    static const String CODE = "SLP";

    static const int NOT_APPLICABLE = 0xFF;
    static const int SLEEP_OFF = 0x00;
    int _sleepTime;

    SleepSetCommandMsg(EISCPMessage raw) : super(CODE, raw)
    {
        _sleepTime = "OFF" == getData ? SLEEP_OFF : ISCPMessage.nonNullInteger(getData, 16, NOT_APPLICABLE);
    }

    SleepSetCommandMsg.output(int sleepTime) : super.output(CODE, _getParameterAsString(sleepTime))
    {
        this._sleepTime = sleepTime;
    }

    static String _getParameterAsString(int sleepTime)
    {
        return sleepTime == SLEEP_OFF ? "OFF" : sleepTime.toRadixString(16).padLeft(2, '0');
    }

    int get sleepTime
    => _sleepTime;

    @override
    String toString()
    => super.toString() + "[SLEEP_TIME=" + _sleepTime.toString() + "]";

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }

    static int toggle(int sleepTime)
    {
        final int res = 15 * ((sleepTime.toDouble() / 15.0).floor() + 1);
        return res > 90 ? 0 : res;
    }
}
