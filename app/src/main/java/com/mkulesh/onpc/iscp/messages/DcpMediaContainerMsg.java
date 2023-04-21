/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2022 by Mikhail Kulesh
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

import android.annotation.SuppressLint;

import com.jayway.jsonpath.JsonPath;
import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public class DcpMediaContainerMsg extends ISCPMessage
{
    public final static String CODE = "D05";
    private final static String EMPTY = "";
    private final static String YES = "yes";

    private final String sid;
    private final String parentSid;
    private final String cid;
    private final String parentCid;
    private String mid = EMPTY;
    private String type = EMPTY;
    private final boolean container;
    private boolean playable = false;
    private String name = EMPTY;
    private String artist = EMPTY;
    private String album = EMPTY;
    private String imageUrl = EMPTY;
    private int start = 0;
    private int count = 0;
    private String aid = EMPTY;

    private ListTitleInfoMsg.LayerInfo layerInfo = null;
    private final List<XmlListItemMsg> items = new ArrayList<>();

    private final static String HEOS_RESP_BROWSE_SERV = "heos/browse";
    private final static String HEOS_RESP_BROWSE_CONT = "browse/browse";

    DcpMediaContainerMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        this.sid = getElement(data, "$.item.sid");
        this.parentSid = getElement(data, "$.item.parentSid");
        this.cid = getElement(data, "$.item.cid");
        this.parentCid = getElement(data, "$.item.parentCid");
        this.mid = getElement(data, "$.item.mid");
        this.type = getElement(data, "$.item.type");
        final String startStr = getElement(data, "$.item.start");
        if (!startStr.isEmpty() && Utils.isInteger(startStr))
        {
            this.start = Integer.parseInt(startStr);
        }
        this.container = YES.equalsIgnoreCase(getElement(data, "$.item.container"));
        this.playable = YES.equalsIgnoreCase(getElement(data, "$.item.playable"));
        this.aid = getElement(data, "$.item.aid");
    }

    public DcpMediaContainerMsg(final DcpMediaContainerMsg other)
    {
        super(0, CODE);
        this.sid = other.sid;
        this.parentSid = other.parentSid;
        this.cid = other.cid;
        this.parentCid = other.parentCid;
        this.mid = other.mid;
        this.type = other.type;
        this.container = other.container;
        this.playable = other.playable;
        this.name = other.name;
        this.artist = other.artist;
        this.album = other.album;
        this.imageUrl = other.imageUrl;
        this.start = other.start;
        this.count = other.count;
        this.aid = other.aid;
        this.layerInfo = other.layerInfo;
        // Do not copy items
    }

    DcpMediaContainerMsg(Map<String, String> tokens)
    {
        super(0, CODE);
        this.sid = nonNull(tokens.get("sid"));
        this.parentSid = this.sid;
        this.cid = nonNull(tokens.get("cid"));
        this.parentCid = this.cid;
        this.container = !cid.isEmpty();
        final String[] rangeStr = nonNull(tokens.get("range")).split(",");
        if (rangeStr.length == 2 && Utils.isInteger(rangeStr[0]))
        {
            this.start = Integer.parseInt(rangeStr[0]);
        }
        final String countStr = nonNull(tokens.get("count"));
        if (!countStr.isEmpty() && Utils.isInteger(countStr))
        {
            this.count = Integer.parseInt(countStr);
        }
        this.layerInfo = cid.isEmpty() ?
                ListTitleInfoMsg.LayerInfo.SERVICE_TOP : ListTitleInfoMsg.LayerInfo.UNDER_2ND_LAYER;
    }

    public DcpMediaContainerMsg(@NonNull String heosMsg, int i, final String parentSid, final String parentCid)
    {
        super(0, CODE);
        this.sid = getElement(heosMsg, "$.payload[" + i +"].sid");
        this.parentSid = parentSid;
        this.cid = getElement(heosMsg, "$.payload[" + i +"].cid");
        this.parentCid = parentCid;
        this.mid = getElement(heosMsg, "$.payload[" + i +"].mid");
        this.type = getElement(heosMsg, "$.payload[" + i +"].type");
        this.container = YES.equalsIgnoreCase(getElement(heosMsg, "$.payload[" + i +"].container"));
        this.playable = YES.equalsIgnoreCase(getElement(heosMsg, "$.payload[" + i +"].playable"));
        this.name = getNameElement(getElement(heosMsg, "$.payload[" + i +"].name"));
        this.artist = getNameElement(getElement(heosMsg, "$.payload[" + i +"].artist"));
        this.album = getNameElement(getElement(heosMsg, "$.payload[" + i +"].album"));
        this.imageUrl = getElement(heosMsg, "$.payload[" + i +"].image_url");
    }

    public boolean keyEqual(@NonNull DcpMediaContainerMsg msg)
    {
        return sid.equals(msg.sid) && cid.equals(msg.cid);
    }

    public String getCid()
    {
        return cid;
    }

    public boolean isContainer()
    {
        return container;
    }

    public boolean isPlayable()
    {
        return playable;
    }

    public int getStart()
    {
        return start;
    }

    public void setStart(int start)
    {
        this.start = start;
    }

    public int getCount()
    {
        return count;
    }

    public void setAid(String aid)
    {
        this.aid = aid;
    }

    public ListTitleInfoMsg.LayerInfo getLayerInfo()
    {
        return layerInfo;
    }

    public List<XmlListItemMsg> getItems()
    {
        return items;
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[SID=" + sid
                + "; PSID=" + parentSid
                + "; CID=" + cid
                + "; PCID=" + parentCid
                + "; MID=" + mid
                + "; TYPE=" + type
                + "; CONT=" + container
                + "; PLAY=" + playable
                + "; START=" + start
                + "; COUNT=" + count
                + (aid.isEmpty() ? EMPTY : "; AID=" + aid)
                + (name.isEmpty() ? EMPTY : "; NAME=" + name)
                + (artist.isEmpty() ? EMPTY : "; ARTIST=" + artist)
                + (album.isEmpty() ? EMPTY : "; ALBUM=" + album)
                + (imageUrl.isEmpty() ? EMPTY : "; IMG=" + imageUrl)
                + (items.isEmpty() ? EMPTY : "; ITEMS=" + items.size())
                + (layerInfo == null ? EMPTY : "; LAYER=" + layerInfo)
                + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        final StringBuilder sb = new StringBuilder("{\"item\":{");
        addJsonParameter(sb, "sid", sid, true);
        addJsonParameter(sb, "parentSid", parentSid, true);
        addJsonParameter(sb, "cid", cid, true);
        addJsonParameter(sb, "parentCid", parentCid, true);
        addJsonParameter(sb, "mid", mid, true);
        addJsonParameter(sb, "type", type, true);
        addJsonParameter(sb, "container", container ? "yes": "no", true);
        addJsonParameter(sb, "playable", playable  ? "yes" : "no", true);
        addJsonParameter(sb, "start", String.valueOf(start), true);
        addJsonParameter(sb, "aid", aid, false);
        sb.append("}}");
        Logging.info(this, sb.toString());
        return new EISCPMessage(CODE, sb.toString());
    }

    private void addJsonParameter(@NonNull final StringBuilder sb,
                                  @NonNull final String name, @NonNull final String value, boolean intermediate)
    {
        sb.append("\"").append(name).append("\": \"").append(value).append("\"");
        if (intermediate)
        {
            sb.append(", ");
        }
    }

    @Nullable
    public static DcpMediaContainerMsg processHeosMessage(@NonNull final String command,
        @NonNull final String heosMsg, @NonNull final Map<String, String> tokens)
    {
        if (HEOS_RESP_BROWSE_SERV.equals(command) || HEOS_RESP_BROWSE_CONT.equals(command))
        {
            final DcpMediaContainerMsg parentMsg = new DcpMediaContainerMsg(tokens);
            final List<String> names = JsonPath.read(heosMsg, "$.payload[*].name");
            for (int i = 0; i < names.size(); i++)
            {
                final DcpMediaContainerMsg itemMsg =
                        new DcpMediaContainerMsg(heosMsg, i, parentMsg.sid, parentMsg.cid);
                final XmlListItemMsg.Icon icon = itemMsg.playable && itemMsg.container ?
                        XmlListItemMsg.Icon.FOLDER_PLAY :
                        itemMsg.playable ? XmlListItemMsg.Icon.MUSIC : XmlListItemMsg.Icon.FOLDER;
                final XmlListItemMsg xmlItem = new XmlListItemMsg(
                        i,
                        parentMsg.layerInfo == ListTitleInfoMsg.LayerInfo.SERVICE_TOP ? 0 : 1,
                        itemMsg.name,
                        icon,
                        true, itemMsg);
                parentMsg.items.add(xmlItem);
            }
            return parentMsg;
        }
        return null;
    }

    @SuppressLint("DefaultLocale")
    @Nullable
    @Override
    public String buildDcpMsg(boolean isQuery)
    {
        if (container)
        {
            if (playable && !parentSid.isEmpty() && !parentCid.isEmpty() && !aid.isEmpty())
            {
                return String.format("heos://browse/add_to_queue?pid=%s&sid=%s&cid=%s&aid=%s",
                        DCP_HEOS_PID, parentSid, cid, aid);
            }
            if (!parentSid.isEmpty() && !cid.isEmpty())
            {
                return String.format("heos://browse/browse?sid=%s&cid=%s&range=%d,9999",
                        parentSid, cid, start);
            }
        }
        else
        {
            if (!playable && !sid.isEmpty())
            {
                return String.format("heos://browse/browse?sid=%s", sid);
            }
            if (playable && !mid.isEmpty())
            {
                if ("station".equals(type) && !parentSid.isEmpty())
                {
                    if (!parentCid.isEmpty())
                    {
                        return String.format("heos://browse/play_stream?pid=%s&sid=%s&cid=%s&mid=%s",
                                DCP_HEOS_PID, parentSid, parentCid, mid);
                    }
                    else
                    {
                        return String.format("heos://browse/play_stream?pid=%s&sid=%s&mid=%s",
                                DCP_HEOS_PID, parentSid, mid);
                    }
                }
                if ("song".equals(type) && !parentSid.isEmpty() && !parentCid.isEmpty())
                {
                    return String.format("heos://browse/add_to_queue?pid=%s&sid=%s&cid=%s&mid=%s&aid=4",
                            DCP_HEOS_PID, parentSid, parentCid, mid);
                }
            }
        }
        return null;
    }
    @NonNull
    private static String nonNull(@Nullable final String inp)
    {
        return inp == null ? EMPTY : inp;
    }

    @NonNull
    private static String getElement(@NonNull final String heosMsg, @NonNull final String path)
    {
        try
        {
            final Object obj = JsonPath.read(heosMsg, path);
            if (obj instanceof Integer)
            {
                return Integer.toString((Integer) obj);
            }
            if (obj instanceof String)
            {
                return (String) obj;
            }
            Logging.info(heosMsg, "Cannot read path " + path + ": object type unknown" + obj);
            return EMPTY;
        }
        catch (Exception ex)
        {
            return EMPTY;
        }
    }

    @NonNull
    private static String getNameElement(@NonNull final String name)
    {
        return name.replace("%26", "&")
                .replace("%3D", "=")
                .replace("%25", "%");
    }
}
