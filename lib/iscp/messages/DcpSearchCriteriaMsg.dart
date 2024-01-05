/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2023 by Mikhail Kulesh
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

import "package:json_path/json_path.dart";

import "../../utils/Pair.dart";
import "../DcpHeosMessage.dart";
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";

/*
 * Denon control protocol - Get Source Search Criteria
 * Command: heos://browse/get_search_criteria?sid=source_id
Response:
{
"heos": {
    "command": "browse/ get_search_criteria ",
    "result": "success",
    "message": "sid='source_id "
},
"payload": [
    {
        "name": "Artist",
        "scid": "'search_criteria_id'",
        "wildcard": "yes_or_no",
    },
    {
        "name": "Album",
        "scid": "'search_criteria_id'",
        "wildcard": "yes_or_no",
    },
    ...
    ]
}
 */
class DcpSearchCriteriaMsg extends ISCPMessage
{
    static const String CODE = "D08";
    static const String _HEOS_COMMAND = "browse/get_search_criteria";

    late String _sid;

    String get sid => _sid;

    final List<Pair<String, int>> _criteria = [];

    List<Pair<String, int>> get criteria => _criteria;

    DcpSearchCriteriaMsg(EISCPMessage raw) : super(CODE, raw)
    {
        _sid = getData;
    }

    DcpSearchCriteriaMsg.output(this._sid) : super.output(CODE, _sid);

    DcpSearchCriteriaMsg._dcp(this._sid, List<Pair<String, int>> cr) : super.output(CODE, _sid)
    {
        _criteria.addAll(cr);
    }

    @override
    bool hasImpactOnMediaList()
    => false;

    @override
    String toString()
    {
        return "DCP search criteria for SID=" + _sid + ": " + _criteria.toString();
    }

    /*
     * Denon control protocol
     */
    static DcpSearchCriteriaMsg? processHeosMessage(DcpHeosMessage jsonMsg)
    {
        if (jsonMsg.command == _HEOS_COMMAND && jsonMsg.message["sid"] != null)
        {
            final String? sid = jsonMsg.message["sid"];
            if (sid == null || sid.isEmpty)
            {
                return null;
            }
            final Iterable<JsonPathMatch> payload = jsonMsg.getArray("payload[*]");
            final List<Pair<String, int>> cr = [];
            for (int i = 0; i < payload.length; i++)
            {
                final Map<String, dynamic> map = payload.elementAt(i).value as Map<String, dynamic>;
                if (map["name"] != null && map["scid"] != null)
                {
                    cr.add(Pair(map["name"], map["scid"]));
                }
            }
            return DcpSearchCriteriaMsg._dcp(sid, cr);
        }
        return null;
    }

    @override
    String? buildDcpMsg(bool isQuery)
    => "heos://" + _HEOS_COMMAND + "?sid=" + _sid;
}