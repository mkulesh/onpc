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

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/*
 * Denon control protocol - Search
 * Command: heos://browse/search?sid=source_id&search=search_string&scid=search_criteria&range=start#, end#
 */
public class DcpSearchMsg extends ISCPMessage
{
    public final static String CODE = "D09";
    private final static String HEOS_COMMAND = "browse/search";

    private final String sid;
    private final String scid;
    private final String searchStr;

    DcpSearchMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        final String[] tags = data.split(ISCPMessage.DCP_MSG_SEP);
        sid = tags.length > 0 ? tags[0] : "";
        scid = tags.length > 1 ? tags[1] : "";
        searchStr = tags.length >= 2 ? tags[2] : "";
    }

    public DcpSearchMsg(String sid, String scid, String searchStr)
    {
        super(0, null);
        this.sid = sid;
        this.scid = scid;
        this.searchStr = searchStr;
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[SID=" + sid + ", SCID=" + scid + ", STR=" + searchStr + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        final String param = sid + ISCPMessage.DCP_MSG_SEP + scid + ISCPMessage.DCP_MSG_SEP + searchStr;
        return new EISCPMessage(CODE, param);
    }

    @Override
    public boolean hasImpactOnMediaList()
    {
        return false;
    }

    @Nullable
    @Override
    public String buildDcpMsg(boolean isQuery)
    {
        return !sid.isEmpty() && !scid.isEmpty() ? String.format("heos://%s?sid=%s&search=%s&scid=%s",
                HEOS_COMMAND, sid, searchStr, scid) : null;
    }
}