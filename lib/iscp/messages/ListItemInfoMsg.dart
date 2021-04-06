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
 * NET/USB List Info (Update item, need processing XML getData, for Network Control Only)
 */
class ListItemInfoMsg extends ISCPMessage
{
    static const String CODE = "NLU";

    int _index, _number;

    ListItemInfoMsg(EISCPMessage raw) : super(CODE, raw)
    {
        _index = ISCPMessage.nonNullInteger(getData.substring(0, 4), 16, 0);
        _number = ISCPMessage.nonNullInteger(getData.substring(4, 8), 16, 0);
    }

    @override
    String toString()
    => super.toString() + "[INDEX=" + _index.toString() + "; NUMBER=" + _number.toString() + "]";
}
