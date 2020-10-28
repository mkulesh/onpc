/*
 * Enhanced Controller for Onkyo and Pioneer
 * Copyright (C) 2018-2020. Mikhail Kulesh
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
import com.mkulesh.onpc.utils.Utils;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.util.List;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import androidx.annotation.NonNull;

/*
 * NET/USB List Info(All item, need processing XML data, for Network Control Only)
 */
public class XmlListInfoMsg extends ISCPMessage
{
    public final static String CODE = "NLA";

    private final Character responseType;
    private final int sequenceNumber;
    private final Character status;

    /*
     * UI type '0' : List, '1' : Menu, '2' : Playback, '3' : Popup, '4' : Keyboard, "5" : Menu List
     */
    private enum UiType implements CharParameterIf
    {
        LIST('0'), MENU('1'), PLAYBACK('2'), POPUP('3'), KEYBOARD('4'), MENU_LIST('5');

        final Character code;

        UiType(Character code)
        {
            this.code = code;
        }

        public Character getCode()
        {
            return code;
        }
    }

    private final UiType uiType;
    private final String rawXml;

    XmlListInfoMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        // Format: "tzzzzsurr<.....>"
        responseType = data.charAt(0);
        sequenceNumber = Integer.parseInt(data.substring(1, 5), 16);
        status = data.charAt(5);
        uiType = (UiType) searchParameter(data.charAt(6), UiType.values(), UiType.LIST);
        rawXml = data.substring(9);
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + data.substring(0, 9) + "..."
                + "; RESP=" + responseType
                + "; SEQ_NR=" + sequenceNumber
                + "; STATUS=" + status
                + "; UI=" + uiType.toString() + "; "
                + (isMultiline() ? ("XML<" + rawXml.length() + "B>") : ("XML=" + rawXml))
                + "]";
    }

    public static String getListedData(int seqNumber, int layer, int startItem, int endItem)
    {
        return "L" + String.format("%04x", seqNumber) +
                String.format("%02x", layer) +
                String.format("%04x", startItem) +
                String.format("%04x", endItem);
    }

    public void parseXml(final List<XmlListItemMsg> items, final int numberOfLayers) throws Exception
    {
        items.clear();
        InputStream stream = new ByteArrayInputStream(rawXml.getBytes(UTF_8));
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

                final List<Element> itemsTop = Utils.getElements(response, "items");
                if (itemsTop.isEmpty())
                {
                    continue;
                }

                // Only process the first "items" element
                Element itemsInfo = itemsTop.get(0);
                if (itemsInfo == null || itemsInfo.getAttribute("offset") == null || itemsInfo.getAttribute("totalitems") == null)
                {
                    continue;
                }
                int offset = Integer.parseInt(itemsInfo.getAttribute("offset"));
                final List<Element> elements = Utils.getElements(itemsInfo, "item");
                int id = 0;
                for (Element element : elements)
                {
                    items.add(new XmlListItemMsg(offset + id, numberOfLayers, element));
                    id++;
                }
            }
        }
        stream.close();
    }
}
