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

package com.mkulesh.onpc.iscp.messages;

import com.jayway.jsonpath.JsonPath;
import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

import java.util.ArrayList;
import java.util.Collections;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/*
 * Friendly Name Setting Command
 */
public class FriendlyNameMsg extends ISCPMessage
{
    public final static String CODE = "NFN";

    private final String friendlyName;

    FriendlyNameMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        String str = "";
        if (data != null && !data.equals("."))
        {
            str = data.startsWith(".") ? data.substring(1) : data;
        }
        friendlyName = str.trim();
    }

    public FriendlyNameMsg(String name)
    {
        super(0, null);
        this.friendlyName = name;
    }

    public String getFriendlyName()
    {
        return friendlyName;
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + friendlyName + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return new EISCPMessage(CODE,
                friendlyName.isEmpty() ? " " : friendlyName);
    }

    @Override
    public boolean hasImpactOnMediaList()
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
    private final static String HEOS_COMMAND = "player/get_player_info";
    private final static String DCP_COMMAND = "NSFRN";

    @NonNull
    public static ArrayList<String> getAcceptedDcpCodes()
    {
        return new ArrayList<>(Collections.singletonList(DCP_COMMAND));
    }

    @Nullable
    public static FriendlyNameMsg processDcpMessage(@NonNull String dcpMsg)
    {
        return dcpMsg.startsWith(DCP_COMMAND) ?
                new FriendlyNameMsg(dcpMsg.substring(DCP_COMMAND.length()).trim()) : null;
    }

    @Nullable
    public static FriendlyNameMsg processHeosMessage(@NonNull final String command, @NonNull final String heosMsg)
    {
        if (HEOS_COMMAND.equals(command))
        {
            final String name = JsonPath.read(heosMsg, "$.payload.name");
            return name != null ? new FriendlyNameMsg(name) : null;
        }
        return null;
    }

    @Nullable
    @Override
    public String buildDcpMsg(boolean isQuery)
    {
        return isQuery ? "heos://" + HEOS_COMMAND + "?pid=" + ISCPMessage.DCP_HEOS_PID : (DCP_COMMAND + " " + friendlyName);
    }
}
