/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2025 by Mikhail Kulesh
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

class AllChannelMsg extends ISCPMessage
{
    static const int NO_LEVEL = 0xFF;
    final List<int> _values = [];

    AllChannelMsg(String code, int valNum, EISCPMessage raw) : super(code, raw)
    {
        for (int i = 0; i < valNum; i++)
        {
            final int k = i * 3;
            final int val = k + 2 < getData.length ?
                ISCPMessage.nonNullInteger(getData.substring(k, k + 3), 16, NO_LEVEL) : NO_LEVEL;
            _values.add(val);
        }
    }

    AllChannelMsg.output(String code, int valNum, final List<int> allValues, final int channel, final int level) :
            super.output(code, _getParameterAsString(valNum, allValues, channel, level))
    {
        for (int i = 0; i < valNum; i++)
        {
            final int val = i < allValues.length ? (i == channel ? level : allValues[i]) : 0;
            _values.add(val);
        }
    }

    static String _getParameterAsString(int valNum, final List<int> allValues, final int channel, final int level)
    {
        String s = "";
        for (int i = 0; i < valNum; i++)
        {
            final int val = i < allValues.length ? (i == channel ? level : allValues[i]) : 0;
            s += _getLevelAsString(val);
        }
        return s;
    }

    static String _getLevelAsString(int level)
    {
        if (level == 0)
        {
            return "000";
        }
        else
        {
            final String s = level < 0 ? "-" : "+";
            final String format = level.abs().toRadixString(16).padLeft(2, '0');
            return s + format.toUpperCase();
        }
    }

    List<int> get values
    => _values;

    @override
    String toString()
    => super.toString() + "[VALUES=" + _values.toString() + "]";

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }
}
