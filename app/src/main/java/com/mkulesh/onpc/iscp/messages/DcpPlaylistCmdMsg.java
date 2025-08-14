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

package com.mkulesh.onpc.iscp.messages;

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/*
 * Denon control protocol:
 * - Save Queue as Playlist
 *   Command: heos://player/save_queue?pid=player_id&name=playlist_name
 * - Rename HEOS Playlist
 *   Command: heos://browse/rename_playlist?sid=source_id&cid=container_id&name=playlist_name
 * - Delete HEOS Playlist
 *   Command: heos://browse/delete_playlist?sid=source_id&cid=contaiiner_id
 */
public class DcpPlaylistCmdMsg extends ISCPMessage
{
    public final static String CODE = "D11";
    public final static String HEOS_CREATE_EVENT = "player/save_queue";
    public final static String HEOS_RENAME_EVENT = "browse/rename_playlist";
    public final static String HEOS_DELETE_EVENT = "browse/delete_playlist";

    DcpPlaylistCmdMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
    }

    DcpPlaylistCmdMsg(final String data)
    {
        super(0, data);
    }

    public DcpPlaylistCmdMsg(final String event, final String sid, final String cid, final String name)
    {
        super(0, _buildCmd(event, sid, cid, name));
    }

    static String _buildCmd(final String event, String sid, String cid, String name)
    {
        switch (event)
        {
        case HEOS_CREATE_EVENT:
            return String.format("heos://player/save_queue?pid=%s&name=%s", ISCPMessage.DCP_HEOS_PID, name);
        case HEOS_RENAME_EVENT:
            return String.format("heos://browse/rename_playlist?sid=%s&cid=%s&name=%s", sid, cid, name);
        case HEOS_DELETE_EVENT:
            return String.format("heos://browse/delete_playlist?sid=%s&cid=%s", sid, cid);
        default:
            return "";
        }
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + getData() + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return new EISCPMessage(CODE, getData());
    }

    @Override
    public boolean hasImpactOnMediaList()
    {
        return false;
    }

    @Nullable
    public static DcpPlaylistCmdMsg processHeosMessage(@NonNull final String command)
    {
        final boolean isCmd = HEOS_CREATE_EVENT.equals(command)
                || HEOS_RENAME_EVENT.equals(command)
                || HEOS_DELETE_EVENT.equals(command);
        return isCmd ? new DcpPlaylistCmdMsg(command) : null;
    }

    @Nullable
    @Override
    public String buildDcpMsg(boolean isQuery)
    {
        return getData();
    }
}
