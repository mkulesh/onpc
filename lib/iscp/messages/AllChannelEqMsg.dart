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

import 'dart:math';

import "../EISCPMessage.dart";
import "../ISCPMessage.dart";

/*
 * sets All Channel EQ for Temporary Value
 * xxx=-18(-12.0dB)~000(0.0dB)~+18(+12.0dB)
 *
 * aaa:63Hz
 * bbb:125Hz
 * ccc:250Hz
 * ddd:500Hz
 * eee:1kHz
 * fff:2kHz
 * ggg:4kHz
 * hhh:8kHz
 * iii:16kHz
 *
 * Example: ACE[000000000000000000000000000]
 */
class AllChannelEqMsg extends ISCPMessage
{
    static const String CODE = "ACE";
    static const int CHANNELS = 9;
    static const int VALUES = 48; // [-0x18, ... 0, ... 0x18]
    static const int NO_LEVEL = 0xFF;
    static const List<String> FREQUENCIES = ['63', '125', '250', '500', '1k', '2k', '4k', '8k', '16k'];

    final List<int> _eqValues = [NO_LEVEL, NO_LEVEL, NO_LEVEL, NO_LEVEL, NO_LEVEL, NO_LEVEL, NO_LEVEL, NO_LEVEL, NO_LEVEL];

    AllChannelEqMsg(EISCPMessage raw) : super(CODE, raw)
    {
        for (int i = 0; i < CHANNELS; i++)
        {
            final int k = i * 3;
            if (k + 2 < getData.length)
            {
                _eqValues[i] = ISCPMessage.nonNullInteger(getData.substring(k, k + 3), 16, NO_LEVEL);
            }
        }
    }

    AllChannelEqMsg.output(final List<int> allValues, final int channel, final int level) :
            super.output(CODE, _getParameterAsString(allValues, channel, level))
    {
        for (int i = 0; i < min(CHANNELS, allValues.length); i++)
        {
            _eqValues[i] = (i == channel) ? level : allValues[i];
        }
    }

    static String _getParameterAsString(final List<int> allValues, final int channel, final int level)
    {
        String s = "";
        for (int i = 0; i < min(CHANNELS, allValues.length); i++)
        {
            s += _getLevelAsString((i == channel) ? level : allValues[i]);
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

    List<int> get eqValues
    => _eqValues;

    @override
    String toString()
    => super.toString() + "[VALUES=" + _eqValues.toString() + "]";

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }
}
