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

import "../../utils/Convert.dart";
import "../../utils/Pair.dart";
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";

/*
 * FL Display Information Command
 */
class DeviceDisplayMsg extends ISCPMessage
{
    static const String CODE = "FLD";
    static const List<Pair<int, int>> _SPECIAL_SYM = [
        Pair(0x1A, 0x23F5), // right-arrow (triangle)
        Pair(0x83, 0x1D160), // music note symbol
        Pair(0x90, 0x2070) // superscript zero
    ];

    late String _value;

    DeviceDisplayMsg(EISCPMessage raw) : super(CODE, raw)
    {
        final List<int> s1 = Convert.convertRaw(getData);
        // process special symbols
        _SPECIAL_SYM.forEach((element) {
            final idx = s1.indexOf(element.item1);
            if (idx >= 0 && idx < s1.length)
            {
                s1[idx] = element.item2;
            }
        });
        _value = String.fromCharCodes(s1);
    }

    String get getValue => _value;

    @override
    String toString()
    => super.toString() + "[VALUE=\"" + _value + "\"]";

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }
}