/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2025 by Mikhail Kulesh
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

import "../DcpHeosMessage.dart";
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";

/*
 * Denon control protocol:
 * - Save Queue as Playlist
 *   Command: heos://player/save_queue?pid=player_id&name=playlist_name
 * - Rename HEOS Playlist
 *   Command: heos://browse/rename_playlist?sid=source_id&cid=container_id&name=playlist_name
 * - Delete HEOS Playlist
 *   Command: heos://browse/delete_playlist?sid=source_id&cid=contaiiner_id
 */
class DcpPlaylistCmdMsg extends ISCPMessage
{
    static const String CODE = "D11";

    DcpPlaylistCmdMsg(EISCPMessage raw) : super(CODE, raw);

    DcpPlaylistCmdMsg._dcp(final String data) : super.output(CODE, data);

    DcpPlaylistCmdMsg.create(final String name) :
        super.output(CODE, _buildCreateCmd(name));

    DcpPlaylistCmdMsg.rename(final String sid, final String cid, final String name) :
        super.output(CODE, _buildRenameCmd(sid, cid, name));

    DcpPlaylistCmdMsg.delete(final String sid, final String cid) :
        super.output(CODE, _buildDeleteCmd(sid, cid));

    static String _buildCreateCmd(String name)
    => sprintf("heos://player/save_queue?pid=%s&name=%s", [ISCPMessage.DCP_HEOS_PID, name]);

    static String _buildRenameCmd(String sid, String cid, String name)
    => sprintf("heos://browse/rename_playlist?sid=%s&cid=%s&name=%s", [sid, cid, name]);

    static String _buildDeleteCmd(String sid, String cid)
    => sprintf("heos://browse/delete_playlist?sid=%s&cid=%s", [sid, cid]);

    static const String HEOS_CREATE_EVENT = "player/save_queue";
    static const String HEOS_RENAME_EVENT = "browse/rename_playlist";
    static const String HEOS_DELETE_EVENT = "browse/delete_playlist";

    static List<String> getAcceptedDcpCodes()
    => [];

    static DcpPlaylistCmdMsg? processHeosMessage(DcpHeosMessage jsonMsg)
    {
        final bool isCmd = [HEOS_CREATE_EVENT, HEOS_RENAME_EVENT, HEOS_DELETE_EVENT].contains(jsonMsg.command);
        return isCmd ? DcpPlaylistCmdMsg._dcp(jsonMsg.command) : null;
    }

    @override
    String? buildDcpMsg(bool isQuery)
    => getData;
}
