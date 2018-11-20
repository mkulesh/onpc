/*
 * Copyright (C) 2018. Mikhail Kulesh
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

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

/*
 * Gets the Receiver Information Status
 */
public class ReceiverInformationMsg extends ISCPMessage
{
    public final static String CODE = "NRI";

    public static class Selector
    {
        final String id;
        final String name;
        final String iconId;
        final boolean addToQueue;

        Selector(Element e)
        {
            id = e.getAttribute("id").toUpperCase();
            name = e.getAttribute("name");
            iconId = e.getAttribute("iconid");
            addToQueue = e.hasAttribute("addqueue") && (Integer.parseInt(e.getAttribute("addqueue")) == 1);
        }

        public Selector(final String id, final String name, final String iconId, final boolean addToQueue)
        {
            this.id = id;
            this.name = name;
            this.iconId = iconId;
            this.addToQueue = addToQueue;
        }

        public String getId()
        {
            return id;
        }

        public boolean isAddToQueue()
        {
            return addToQueue;
        }

        @Override
        public String toString()
        {
            return id + "(" + name + "): icon=" + iconId + ", addToQueue=" + addToQueue;
        }
    }


    private String deviceId;
    private final HashMap<String, String> deviceProperties = new HashMap<>();
    private Bitmap deviceCover;
    private final List<Selector> deviceSelectors = new ArrayList<>();
    private final Set<String> controlList = new HashSet<>();

    ReceiverInformationMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        deviceId = "";
        deviceCover = null;
    }

    public Map<String, String> getDeviceProperties()
    {
        return deviceProperties;
    }

    public Set<String> getControlList()
    {
        return controlList;
    }

    public Bitmap getDeviceCover()
    {
        return deviceCover;
    }

    public List<Selector> getDeviceSelectors()
    {
        return deviceSelectors;
    }

    @Override
    public String toString()
    {
        return CODE + "[XML<" + Integer.toString(data.length()) + ">]";
    }

    public void parseXml() throws Exception
    {
        deviceProperties.clear();
        deviceSelectors.clear();
        InputStream stream = new ByteArrayInputStream(data.getBytes(UTF_8));
        final DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        final DocumentBuilder builder = factory.newDocumentBuilder();
        final Document doc = builder.parse(stream);
        for (Node object = doc.getDocumentElement(); object != null; object = object.getNextSibling())
        {
            if (object instanceof Element)
            {
                final Element response = (Element) object;
                if (!response.getTagName().equals("response") || !Utils.ensureAttribute(response, "status", "ok"))
                {
                    continue;
                }

                final List<Element> device = Utils.getElements(response, "device");
                if (device.isEmpty())
                {
                    continue;
                }

                // Only process the first "items" element
                Element deviceInfo = device.get(0);
                if (deviceInfo == null)
                {
                    continue;
                }

                deviceId = deviceInfo.getAttribute("id");
                Logging.info(this, "    deviceId=" + deviceId);

                for (Node prop = deviceInfo.getFirstChild(); prop != null; prop = prop.getNextSibling())
                {
                    if (prop instanceof Element)
                    {
                        final Element en = (Element) prop;
                        if (en.getChildNodes().getLength() == 1)
                        {
                            deviceProperties.put(en.getTagName(), en.getChildNodes().item(0).getNodeValue());
                        }
                        else if ("selectorlist".equals(en.getTagName()))
                        {
                            final List<Element> elSelectors = Utils.getElements(en, "selector");
                            for (Element element : elSelectors)
                            {
                                deviceSelectors.add(new Selector(element));
                            }
                        }
                        else if ("controllist".equals(en.getTagName()))
                        {
                            final List<Element> elControls = Utils.getElements(en, "control");
                            for (Element element : elControls)
                            {
                                final String id = element.getAttribute("id");
                                final String value = element.getAttribute("value");
                                if (id != null && value != null && Integer.parseInt(value) == 1)
                                {
                                    controlList.add(id);
                                }
                            }
                        }
                    }
                }
            }
        }

        for (Map.Entry<String, String> p : deviceProperties.entrySet())
        {
            Logging.info(this, "    Property: " + p.getKey() + "=" + p.getValue());
        }
        for (Selector s : deviceSelectors)
        {
            Logging.info(this, "    Selector: " + s.toString());
        }
        for (String s : controlList)
        {
            Logging.info(this, "    Control: " + s);
        }

        if (deviceProperties.containsKey("modeliconurl"))
        {
            final URL url = new URL(deviceProperties.get("modeliconurl"));
            Logging.info(this, "loading image from URL: " + url.toString());
            byte[] bytes = Utils.streamToByteArray(url.openConnection().getInputStream());
            deviceCover = BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
            if (deviceCover == null)
            {
                Logging.info(this, "can not decode image");
            }
        }
        stream.close();
    }
}
