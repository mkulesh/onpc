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

import "../EISCPMessage.dart";
import "../ISCPMessage.dart";

/*
 * Friendly Name Setting Command
 */
class FriendlyNameMsg extends ISCPMessage
{
    static const String CODE = "NFN";

    String _friendlyName;

    FriendlyNameMsg(EISCPMessage raw) : super(CODE, raw)
    {
        String str = "";
        if (getData != null && getData != ".")
        {
            str = getData.startsWith(".") ? getData.substring(1) : getData;
        }
        _friendlyName = str.trim();
    }

    FriendlyNameMsg.output(String name) : super.output(CODE, name.isEmpty ? " " : name)
    {
        _friendlyName = getData;
    }

    String get getFriendlyName
    => _friendlyName;

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }
}
