/*
 * Copyright (C) 2019. Mikhail Kulesh
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

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import androidx.annotation.NonNull;
import androidx.annotation.StringRes;

/*
 * Multiroom Device Information Command: gets the Multiroom Device Information as an XML message:
 * <mdi>
 *   <deviceid>111111111111</deviceid>
 *   <currentversion>100</currentversion>
 *   <zonelist>
 *　  <zone id="1" groupid="3" ch="ST" role="src" roomname="" groupname="" powerstate="1" iconid="1" color="1" delay="1000"/>
 *    <zone id="2" groupid="3" ch="ST" role="dst" roomname="" groupname="" powerstate="1" iconid="1" color="1" delay="1000"/>
 *    <zone id="3" groupid="1" ch="ST" role="none" roomname="" groupname="" powerstate="1" iconid="1" color="1" delay="1000"/>
 *   </zonelist>
 *  </mdi>
 */
public class MultiroomDeviceInformationMsg extends ISCPMessage
{
    public final static String CODE = "MDI";
    public final static int NO_GROUP = 0;

    public enum ChannelType
    {
        ST, FL, FR, NONE
    }

    public enum RoleType implements StringParameterIf
    {
        SRC("SRC", R.string.multiroom_master),
        DST("DST", R.string.multiroom_slave),
        NONE("NONE", R.string.multiroom_none);

        final String code;

        @StringRes
        final int descriptionId;

        RoleType(final String code, @StringRes final int descriptionId)
        {
            this.code = code;
            this.descriptionId = descriptionId;
        }

        public String getCode()
        {
            return code;
        }

        @StringRes
        public int getDescriptionId()
        {
            return descriptionId;
        }
    }

    public static class Zone
    {
        final int id;
        final int groupid;
        final ChannelType ch;
        final RoleType role;
        final String roomname;
        final String groupname;
        final int powerstate;
        final int iconid;
        final int color;
        final int delay;

        Zone(Element e)
        {
            id = Integer.parseInt(e.getAttribute("id"));
            groupid = e.hasAttribute("groupid") ? Integer.parseInt(e.getAttribute("groupid")) : NO_GROUP;
            ch = e.hasAttribute("ch") ? ChannelType.valueOf(e.getAttribute("ch").toUpperCase()) : ChannelType.NONE;
            role = e.hasAttribute("role") ? RoleType.valueOf(e.getAttribute("role").toUpperCase()) : RoleType.NONE;
            roomname = e.hasAttribute("roomname") ? e.getAttribute("roomname") : "";
            groupname = e.hasAttribute("groupname") ? e.getAttribute("groupname") : "";
            powerstate = e.hasAttribute("powerstate") ? Integer.parseInt(e.getAttribute("powerstate")) : -1;
            iconid = e.hasAttribute("iconid") ? Integer.parseInt(e.getAttribute("iconid")) : -1;
            color = e.hasAttribute("color") ? Integer.parseInt(e.getAttribute("color")) : -1;
            delay = e.hasAttribute("delay") ? Integer.parseInt(e.getAttribute("delay")) : -1;
        }

        @NonNull
        @Override
        public String toString()
        {
            return id + ": groupid=" + groupid
                    + ", ch=" + ch.toString()
                    + ", role=" + role.toString()
                    + ", roomname=" + roomname
                    + ", groupname=" + groupname
                    + ", powerstate=" + powerstate
                    + ", iconid=" + iconid
                    + ", color=" + color
                    + ", delay=" + delay;
        }

        public int getId()
        {
            return id;
        }

        public int getGroupid()
        {
            return groupid;
        }
    }

    private final HashMap<String, String> properties = new HashMap<>();
    private final List<MultiroomDeviceInformationMsg.Zone> zones = new ArrayList<>();

    MultiroomDeviceInformationMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "["
                + (isMultiline() ? ("XML<" + data.length() + "B>") : ("XML=" + data))
                + "]";
    }

    public void parseXml(boolean showInfo) throws Exception
    {
        properties.clear();
        zones.clear();

        InputStream stream = new ByteArrayInputStream(data.getBytes(UTF_8));
        final DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        final DocumentBuilder builder = factory.newDocumentBuilder();
        final Document doc = builder.parse(stream);

        final Element mdi = Utils.getElement(doc, "mdi");
        if (mdi == null)
        {
            throw new Exception("mdi element not found");
        }

        for (Node prop = mdi.getFirstChild(); prop != null; prop = prop.getNextSibling())
        {
            if (prop instanceof Element)
            {
                final Element en = (Element) prop;
                if ("zonelist".equals(en.getTagName()))
                {
                    final List<Element> elZone = Utils.getElements(en, "zone");
                    for (Element element : elZone)
                    {
                        final String id = element.getAttribute("id");
                        if (id != null)
                        {
                            zones.add(new MultiroomDeviceInformationMsg.Zone(element));
                        }
                    }
                }
                else if (en.getChildNodes().getLength() == 1)
                {
                    properties.put(en.getTagName(), en.getChildNodes().item(0).getNodeValue());
                }
            }
        }

        if (showInfo)
        {
            for (Map.Entry<String, String> p : properties.entrySet())
            {
                Logging.info(this, "    Property: " + p.getKey() + "=" + p.getValue());
            }
            for (MultiroomDeviceInformationMsg.Zone s : zones)
            {
                Logging.info(this, "    Zone " + s.toString());
            }
        }
    }

    @NonNull
    public String getProperty(final String name)
    {
        String prop = properties.get(name);
        return prop == null ? "" : prop;
    }

    @NonNull
    public List<Zone> getZones()
    {
        return zones;
    }

    @NonNull
    public RoleType getRole(int zone)
    {
        for (MultiroomDeviceInformationMsg.Zone z : zones)
        {
            if (z.getId() == zone)
            {
                return z.role;
            }
        }
        return RoleType.NONE;
    }

    @NonNull
    public ChannelType getChannelType(int zone)
    {
        for (MultiroomDeviceInformationMsg.Zone z : zones)
        {
            if (z.getId() == zone)
            {
                return z.ch;
            }
        }
        return ChannelType.NONE;
    }

    public int getGroupId(int zone)
    {
        for (MultiroomDeviceInformationMsg.Zone z : zones)
        {
            if (z.getId() == zone)
            {
                return z.groupid;
            }
        }
        return NO_GROUP;
    }
}
