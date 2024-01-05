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

import "package:sprintf/sprintf.dart";

import "../EISCPMessage.dart";
import "../ISCPMessage.dart";

/*
 * Denon control protocol - Search
 * Command: heos://browse/search?sid=source_id&search=search_string&scid=search_criteria&range=start#, end#
 */
class DcpSearchMsg extends ISCPMessage
{
    static const String CODE = "D09";
    static const String _HEOS_COMMAND = "browse/search";

    late String _sid;
    late String _scid;
    late String _searchStr;

    DcpSearchMsg(EISCPMessage raw) : super(CODE, raw)
    {
        final List<String> tags = getData.split(ISCPMessage.DCP_MSG_SEP);
        _sid = tags.isNotEmpty ? tags[0] : "";
        _scid = tags.length > 1 ? tags[1] : "";
        _searchStr = tags.length >= 2 ? tags[2] : "";
    }

    DcpSearchMsg.output(this._sid, this._scid, this._searchStr) :
            super.output(CODE, _getParameterAsString(_sid, _scid, _searchStr));

    static String _getParameterAsString(String sid, String scid, String searchStr)
    {
        return sid + ISCPMessage.DCP_MSG_SEP + scid + ISCPMessage.DCP_MSG_SEP + searchStr;
    }

    @override
    bool hasImpactOnMediaList()
    => false;

    @override
    String toString()
    => super.toString() + "[SID=" + _sid.toString() +
        ", SCID=" + _scid.toString() +
        ", STR=" + _searchStr +
        "]";

    /*
     * Denon control protocol
     */
    @override
    String? buildDcpMsg(bool isQuery)
    => _sid.isNotEmpty && _scid.isNotEmpty ? sprintf("heos://%s?sid=%s&search=%s&scid=%s",
            [ _HEOS_COMMAND, _sid, _searchStr, _scid]) : null;
}