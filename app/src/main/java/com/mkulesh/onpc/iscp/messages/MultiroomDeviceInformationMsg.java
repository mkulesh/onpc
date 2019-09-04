package com.mkulesh.onpc.iscp.messages;

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

    enum ChannelType
    {
        ST, FL, FR, NONE
    }

    enum RoleType
    {
        SRC, DST, NONE
    }

    public static class Zone
    {
        final String id;
        final String groupid;
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
            id = e.getAttribute("id").toUpperCase();
            groupid = e.hasAttribute("groupid") ? e.getAttribute("groupid") : "";
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
    }

    private final HashMap<String, String> properties = new HashMap<>();
    private final List<MultiroomDeviceInformationMsg.Zone> zones = new ArrayList<>();

    public MultiroomDeviceInformationMsg(EISCPMessage raw) throws Exception
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
}
