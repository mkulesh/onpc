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
import "dart:ui";

import "../iscp/ConnectionIf.dart";
import "../iscp/ISCPMessage.dart";

class Convert
{
    static String enumToString<T> (T val)
    => val.toString().split('.').last;

    static String ipToString(String host, String port)
    => host + ":" + port;

    static ProtoType stringToProtoType(String protoType)
    => ProtoType.values.firstWhere(
        (p) => Convert.enumToString(p).toUpperCase() == protoType.toUpperCase(),
        orElse: () => ProtoType.ISCP);

    static ColorFilter toColorFilter(final Color c)
    => ColorFilter.mode(c, BlendMode.srcIn);

    static List<int> convertRaw(String str)
    {
        final int size = (str.length / 2).floor();
        final List<int> bytes = List.generate(size, (i)
        {
            final int j1 = 2 * i;
            final int j2 = 2 * i + 1;
            return (j1 < str.length && j2 < str.length) ? ISCPMessage.nonNullInteger(str.substring(j1, j2 + 1), 16, 0) : 0;
        });
        return bytes;
    }

    static String decodeUtf8(final List<int> buffer)
    => utf8.decode(buffer, allowMalformed: true);
}