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

import android.annotation.SuppressLint;

import com.jayway.jsonpath.JsonPath;
import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import net.minidev.json.JSONArray;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/*
 * Denon control protocol - media container
 */
public class DcpMediaContainerMsg extends ISCPMessage
{
    public final static String CODE = "D05";
    private final static String EMPTY = "";
    private final static String YES = "yes";
    private final static String PLAYQUEUE_SID = "9999";

    public final static int SO_ADD_TO_HEOS = 19;
    public final static int SO_REMOVE_FROM_HEOS = 20;
    public final static int SO_CONTAINER = 21;
    public final static int SO_ADD_AND_PLAY_ALL = 201;
    public final static int SO_ADD_ALL = 203;
    public final static int SO_REPLACE_AND_PLAY_ALL = 204;

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
    private String qid = EMPTY;

    private ListTitleInfoMsg.LayerInfo layerInfo = null;
    private final List<XmlListItemMsg> items = new ArrayList<>();
    private final List<XmlListItemMsg> options = new ArrayList<>();

    private final static String HEOS_RESP_BROWSE_SERV = "heos/browse";
    private final static String HEOS_RESP_BROWSE_CONT = "browse/browse";
    private final static String HEOS_RESP_BROWSE_QUEUE = "player/get_queue";
    public final static String HEOS_SET_SERVICE_OPTION = "browse/set_service_option";

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
        this.name = getElement(data, "$.item.name");
        this.aid = getElement(data, "$.item.aid");
        this.qid = getElement(data, "$.item.qid");
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
        this.qid = other.qid;
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

    public DcpMediaContainerMsg(@NonNull Map<String, Object> heosMsg, final String parentSid, final String parentCid)
    {
        super(0, CODE);
        this.sid = getElement(heosMsg, "sid");
        this.parentSid = parentSid;
        this.cid = getElement(heosMsg, "cid");
        this.parentCid = parentCid;
        this.mid = getElement(heosMsg, "mid");
        this.type = getElement(heosMsg, "type");
        this.container = YES.equalsIgnoreCase(getElement(heosMsg, "container"));
        this.playable = YES.equalsIgnoreCase(getElement(heosMsg, "playable"));
        this.name = getNameElement(getElement(heosMsg, "name"));
        this.artist = getNameElement(getElement(heosMsg, "artist"));
        this.album = getNameElement(getElement(heosMsg, "album"));
        this.imageUrl = getElement(heosMsg, "image_url");
    }

    public DcpMediaContainerMsg(@NonNull Map<String, Object> heosMsg, String psid)
    {
        super(0, CODE);
        this.sid = "";
        this.parentSid = psid;
        this.cid = "";
        this.parentCid = "";
        this.mid = getElement(heosMsg, "mid");
        this.type = "song";
        this.container = false;
        this.playable = true;
        this.artist = getElement(heosMsg, "artist");
        this.name = this.artist + " - " + getElement(heosMsg, "song");
        this.album = getElement(heosMsg, "album");
        this.imageUrl = getElement(heosMsg, "image_url");
        this.qid = getElement(heosMsg, "qid");
    }

    public boolean keyEqual(@NonNull DcpMediaContainerMsg msg)
    {
        return sid.equals(msg.sid) && cid.equals(msg.cid);
    }

    public String getSid()
    {
        return sid;
    }

    public String getCid()
    {
        return cid;
    }

    public String getMid()
    {
        return mid;
    }

    public boolean isContainer()
    {
        return container;
    }

    public boolean isPlayable()
    {
        return playable;
    }

    public String getType()
    {
        return type;
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

    public boolean isSong()
    {
        return "song".equals(type);
    }

    public List<XmlListItemMsg> getOptions()
    {
        return options;
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
                + (qid.isEmpty() ? EMPTY : "; QID=" + qid)
                + (name.isEmpty() ? EMPTY : "; NAME=" + name)
                + (artist.isEmpty() ? EMPTY : "; ARTIST=" + artist)
                + (album.isEmpty() ? EMPTY : "; ALBUM=" + album)
                + (imageUrl.isEmpty() ? EMPTY : "; IMG=" + imageUrl)
                + (layerInfo == null ? EMPTY : "; LAYER=" + layerInfo)
                + (items.isEmpty() ? EMPTY : "; ITEMS=" + items.size())
                + (options.isEmpty() ? EMPTY : "; OPTIONS=" + options.size())
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
        addJsonParameter(sb, "container", container ? "yes" : "no", true);
        addJsonParameter(sb, "playable", playable ? "yes" : "no", true);
        addJsonParameter(sb, "name", name, true);
        addJsonParameter(sb, "start", String.valueOf(start), true);
        addJsonParameter(sb, "aid", aid, true);
        addJsonParameter(sb, "qid", qid, false);
        sb.append("}}");
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
            readMediaItems(parentMsg, heosMsg);
            try
            {
                // options are optional
                readOptions(parentMsg, heosMsg);
            }
            catch (Exception ex)
            {
                // nothing to do
            }
            return parentMsg;
        }

        if (HEOS_RESP_BROWSE_QUEUE.equals(command))
        {
            if (tokens.get("sid") == null)
            {
                tokens.put("sid", PLAYQUEUE_SID);
            }
            final DcpMediaContainerMsg parentMsg = new DcpMediaContainerMsg(tokens);
            readPlayQueueItems(parentMsg, heosMsg);
            return parentMsg;
        }

        return null;
    }

    private static void readMediaItems(DcpMediaContainerMsg parentMsg, String heosMsg)
    {
        final JSONArray payload = JsonPath.parse(heosMsg).read("$.payload");
        for (int i = 0; i < payload.size(); i++)
        {
            @SuppressWarnings("unchecked")
            final DcpMediaContainerMsg itemMsg = new DcpMediaContainerMsg(
                    (LinkedHashMap<String, Object>) payload.get(i),
                    parentMsg.sid, parentMsg.cid);
            if (itemMsg.isSong())
            {
                itemMsg.setAid("1");
            }
            final XmlListItemMsg xmlItem = new XmlListItemMsg(
                    i + parentMsg.start,
                    parentMsg.layerInfo == ListTitleInfoMsg.LayerInfo.SERVICE_TOP ? 0 : 1,
                    itemMsg.name,
                    XmlListItemMsg.Icon.UNKNOWN,
                    true, itemMsg);
            if (itemMsg.container)
            {
                xmlItem.setIconType(itemMsg.name.equals("All") ? "01" :
                        itemMsg.name.equals("Browse Folders") ? "99" : "50");
                xmlItem.setIcon(itemMsg.playable ?
                        XmlListItemMsg.Icon.FOLDER_PLAY : XmlListItemMsg.Icon.FOLDER);
            }
            else
            {
                xmlItem.setIconType("75");
                xmlItem.setIcon(itemMsg.playable ?
                        XmlListItemMsg.Icon.MUSIC : XmlListItemMsg.Icon.UNKNOWN);
            }
            parentMsg.items.add(xmlItem);
        }
    }

    private static void readPlayQueueItems(DcpMediaContainerMsg parentMsg, String heosMsg)
    {
        final JSONArray payload = JsonPath.parse(heosMsg).read("$.payload");
        for (int i = 0; i < payload.size(); i++)
        {
            @SuppressWarnings("unchecked")
            final DcpMediaContainerMsg itemMsg = new DcpMediaContainerMsg(
                    (LinkedHashMap<String, Object>) payload.get(i),
                    PLAYQUEUE_SID);
            final XmlListItemMsg xmlItem = new XmlListItemMsg(
                    Integer.parseInt(itemMsg.qid),
                    0,
                    itemMsg.name,
                    XmlListItemMsg.Icon.MUSIC,
                    true, itemMsg);
            xmlItem.setIconType("75");
            parentMsg.items.add(xmlItem);
        }
    }

    private static void readOptions(final DcpMediaContainerMsg parentMsg, String heosMsg)
    {
        final List<Map<String, JSONArray>> options = JsonPath.parse(heosMsg).read("$.options[*]");
        final JSONArray browse = options.isEmpty() ? null : options.get(0).get("browse");
        if (browse == null)
        {
            return;
        }
        for (int i = 0; i < browse.size(); i++)
        {
            @SuppressWarnings("unchecked")
            final LinkedHashMap<String, Object> item = (LinkedHashMap<String, Object>) browse.get(i);
            final int id = Integer.parseInt(getElement(item, "id"));
            final String name = getElement(item, "name");
            if (id == SO_CONTAINER)
            {
                parentMsg.options.add(new XmlListItemMsg(SO_ADD_ALL, 0, name,
                        XmlListItemMsg.Icon.FOLDER_PLAY, true, null));
                parentMsg.options.add(new XmlListItemMsg(SO_ADD_AND_PLAY_ALL, 0, name,
                        XmlListItemMsg.Icon.FOLDER_PLAY, true, null));
                parentMsg.options.add(new XmlListItemMsg(SO_REPLACE_AND_PLAY_ALL, 0, name,
                        XmlListItemMsg.Icon.FOLDER_PLAY, true, null));
            }
            else
            {
                parentMsg.options.add(new XmlListItemMsg(id, 0, name,
                        XmlListItemMsg.Icon.UNKNOWN, true, null));
            }
        }
    }

    @SuppressLint("DefaultLocale")
    @Nullable
    @Override
    public String buildDcpMsg(boolean isQuery)
    {
        if (aid.startsWith(HEOS_SET_SERVICE_OPTION))
        {
            switch (start)
            {
            case SO_ADD_TO_HEOS: // Add station to HEOS Favorites
                return String.format("heos://browse/set_service_option?sid=%s&option=19&mid=%s&name=%s",
                        parentSid, mid, name);
            case SO_REMOVE_FROM_HEOS: // Remove from HEOS Favorites
                return String.format("heos://browse/set_service_option?option=20&mid=%s",
                        mid);
            case SO_ADD_AND_PLAY_ALL: // Add and play
                return String.format("heos://browse/add_to_queue?pid=%s&sid=%s&cid=%s&aid=1",
                        DCP_HEOS_PID, parentSid, parentCid);
            case SO_ADD_ALL: // Add
                return String.format("heos://browse/add_to_queue?pid=%s&sid=%s&cid=%s&aid=3",
                        DCP_HEOS_PID, parentSid, parentCid);
            case SO_REPLACE_AND_PLAY_ALL: // Replace and play
                return String.format("heos://browse/add_to_queue?pid=%s&sid=%s&cid=%s&aid=4",
                        DCP_HEOS_PID, parentSid, parentCid);
            }
        }
        else if (container)
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
                if (PLAYQUEUE_SID.equals(sid))
                {
                    return String.format("heos://player/get_queue?pid=%s&range=%d,9999",
                            DCP_HEOS_PID, start);
                }
                else
                {
                    return String.format("heos://browse/browse?sid=%s", sid);
                }
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
                if (isSong() && !parentSid.isEmpty() && !parentCid.isEmpty())
                {
                    return String.format("heos://browse/add_to_queue?pid=%s&sid=%s&cid=%s&mid=%s&aid=%s",
                            DCP_HEOS_PID, parentSid, parentCid, mid, aid);
                }
            }
            if (playable && PLAYQUEUE_SID.equals(parentSid) && !qid.isEmpty())
            {
                return String.format("heos://player/play_queue?pid=%s&qid=%s", DCP_HEOS_PID, qid);
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
    private static String getElement(Map<String, Object> payload, String name)
    {
        final Object obj = payload.get(name);
        if (obj != null)
        {
            if (obj instanceof Integer)
            {
                return Integer.toString((Integer) obj);
            }
            if (obj instanceof String)
            {
                return (String) obj;
            }
            Logging.info(payload, "DCP HEOS error: Cannot read element " + name + ": object type unknown: " + obj);
        }
        return EMPTY;
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
            Logging.info(heosMsg, "DCP HEOS error: Cannot read path " + path + ": object type unknown: " + obj);
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
