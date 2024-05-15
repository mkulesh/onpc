/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2024 by Mikhail Kulesh
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
import "EnumParameterMsg.dart";
import "ServiceType.dart";

/*
 * Denon control protocol - media item
 * Get Now Playing Media Command: heos://player/get_now_playing_media?pid=player_id
 */
class DcpMediaItemMsg extends ISCPMessage
{
    static const String CODE = "D06";
    static const int INVALID_TRACK = -1;

    final int _sid;

    final int _qid;

    DcpMediaItemMsg(EISCPMessage raw) :
            _sid = INVALID_TRACK, _qid = INVALID_TRACK, super(CODE, raw);

    DcpMediaItemMsg._dcp(final String mid, final int sid, final int qid) :
            _sid = sid, _qid = qid, super.output(CODE, mid);

    EnumItem<ServiceType> getServiceType()
    {
        final EnumItem<ServiceType>? st = Services.ServiceTypeEnum.valueByDcpCode("HS" + _sid.toString());
        return (st == null) ? Services.ServiceTypeEnum.defValue : st;
    }

    int get qid => _qid;

    @override
    String toString()
    => super.toString() + "[SID=" + _sid.toString() + ", QID=" + _qid.toString() + "]";

    /*
     * Denon control protocol
     */
    static const String _HEOS_COMMAND = "player/get_now_playing_media";

    static DcpMediaItemMsg? processHeosMessage(DcpHeosMessage jsonMsg)
    {
        if (_HEOS_COMMAND == jsonMsg.command)
        {
            final String? type = jsonMsg.getString("payload.type");
            if (type == null)
            {
                return null;
            }
            final String? mid = ("station" == type) ?
                jsonMsg.getString("payload.album_id") : jsonMsg.getString("payload.mid");
            if (mid == null)
            {
                return null;
            }
            final int? sid = jsonMsg.getInt("payload.sid");
            final int? qid = ("station" == type) ?
                INVALID_TRACK : jsonMsg.getInt("payload.qid");
            return sid != null ? DcpMediaItemMsg._dcp(mid, sid, qid != null ? qid : INVALID_TRACK) : null;
        }
        return null;
    }

    @override
    String? buildDcpMsg(bool isQuery)
    => isQuery ? "heos://" + _HEOS_COMMAND + "?pid=" + ISCPMessage.DCP_HEOS_PID : null;
}