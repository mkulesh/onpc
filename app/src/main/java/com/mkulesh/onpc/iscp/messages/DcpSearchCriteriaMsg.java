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
import com.mkulesh.onpc.utils.Logging;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.util.Pair;

/*
 * Denon control protocol - Get Source Search Criteria
 * Command: heos://browse/get_searchcriteria?sid=source_id
Response:
{
"heos": {
    "command": "browse/ get_searchcriteria ",
    "result": "success",
    "message": "sid='source_id "
},
"payload": [
    {
        "name": "Artist",
        "scid": "'searchcriteria_id'",
        "wildcard": "yes_or_no",
    },
    {
        "name": "Album",
        "scid": "'searchcriteria_id'",
        "wildcard": "yes_or_no",
    },
    ...
    ]
}
 */
public class DcpSearchCriteriaMsg extends ISCPMessage
{
    public final static String CODE = "D08";
    private final static String HEOS_COMMAND = "browse/get_search_criteria";

    private final String sid;
    private final List<Pair<String, Integer>> criteria = new ArrayList<>();

    DcpSearchCriteriaMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        sid = getData();
    }

    public DcpSearchCriteriaMsg(final String sid)
    {
        super(0, sid);
        this.sid = sid;
    }

    DcpSearchCriteriaMsg(final String sid, List<Pair<String, Integer>> cr)
    {
        super(0, sid);
        this.sid = sid;
        criteria.addAll(cr);
    }

    public String getSid()
    {
        return sid;
    }

    public List<Pair<String, Integer>> getCriteria()
    {
        return criteria;
    }

    @NonNull
    @Override
    public String toString()
    {
        return "DCP search criteria for SID=" + sid + ": " + criteria.toString();
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return new EISCPMessage(CODE, sid);
    }

    @Override
    public boolean hasImpactOnMediaList()
    {
        return false;
    }

    @Nullable
    public static DcpSearchCriteriaMsg processHeosMessage(@NonNull final String command, @NonNull final String heosMsg, @NonNull final Map<String, String> tokens)
    {
        if (HEOS_COMMAND.equals(command))
        {
            final String sid = tokens.get("sid");
            if (sid == null || sid.isEmpty())
            {
                return null;
            }

            final List<String> names = JsonPath.read(heosMsg, "$.payload[*].name");
            final List<Integer> csids = JsonPath.read(heosMsg, "$.payload[*].scid");
            if (names.size() != csids.size())
            {
                Logging.info(DcpReceiverInformationMsg.class, "Inconsistent size of names and csids");
                return null;
            }

            final List<Pair<String, Integer>> cr = new ArrayList<>();
            for (int i = 0; i < names.size(); i++)
            {
                if (names.get(i) != null && csids.get(i) != null)
                {
                    cr.add(new Pair<>(names.get(i), csids.get(i)));
                }
            }

            return new DcpSearchCriteriaMsg(sid, cr);
        }
        return null;
    }

    @Nullable
    @Override
    public String buildDcpMsg(boolean isQuery)
    {
        return "heos://" + HEOS_COMMAND + "?sid=" + sid;
    }
}