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

import "dart:convert";

import "../../utils/Convert.dart";
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";

/*
 * FL Display Information Command
 */
class DeviceDisplayMsg extends ISCPMessage
{
    static const String CODE = "FLD";

    late String _value;

    DeviceDisplayMsg(EISCPMessage raw) : super(CODE, raw)
    {
        final List<int> s1 = Convert.convertRaw(getData);
        _value = utf8.decode(s1, allowMalformed: true);
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