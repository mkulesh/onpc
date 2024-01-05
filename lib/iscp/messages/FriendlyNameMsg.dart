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

import "../DcpHeosMessage.dart";
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";

/*
 * Friendly Name Setting Command
 */
class FriendlyNameMsg extends ISCPMessage
{
    static const String CODE = "NFN";

    late String _friendlyName;

    FriendlyNameMsg(EISCPMessage raw) : super(CODE, raw)
    {
        String str = "";
        if (getData != ".")
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

    /*
     * Denon control protocol
     * Command: heos://player/get_player_info?pid=player_id
     * Response: {"heos": {"command": "player/get_player_info", "result": "success", "message": "pid=-2078441090"},
     *            "payload": {"name": "Denon Player", "pid": -2078441090, ...}}
     * Change: NSFRN
     */
    static const String _HEOS_COMMAND = "player/get_player_info";
    static const String _DCP_COMMAND = "NSFRN";

    static List<String> getAcceptedDcpCodes()
    => [ _DCP_COMMAND ];

    static FriendlyNameMsg? processDcpMessage(String dcpMsg)
    {
        if (dcpMsg.startsWith(_DCP_COMMAND))
        {
            return FriendlyNameMsg.output(dcpMsg.substring(_DCP_COMMAND.length).trim());
        }
        return null;
    }

    static FriendlyNameMsg? processHeosMessage(DcpHeosMessage jsonMsg)
    {
        final String? name = jsonMsg.getCmdProperty(_HEOS_COMMAND, "payload.name");
        return name != null ? FriendlyNameMsg.output(name) : null;
    }

    @override
    String? buildDcpMsg(bool isQuery)
    => isQuery ? "heos://" + _HEOS_COMMAND + "?pid=" + ISCPMessage.DCP_HEOS_PID : (_DCP_COMMAND + " " + _friendlyName);
}
