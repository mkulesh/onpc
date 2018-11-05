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

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.io.StringWriter;
import java.nio.charset.Charset;
import java.util.List;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

/*
 * NET Custom Popup Message (for Network Control Only)
 */
public class CustomPopupMsg extends ISCPMessage
{
    public final static String CODE = "NCP";

    private final String rawXml;
    private Document doc = null;
    private String response = null;

    CustomPopupMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        rawXml = data.substring(1);
    }

    public String getResponse()
    {
        return response;
    }

    @Override
    public String toString()
    {
        return CODE + "[" + data + "]";
    }

    public boolean parseXml() throws Exception
    {
        boolean retValue = false;
        InputStream stream = new ByteArrayInputStream(rawXml.getBytes(Charset.forName("UTF-8")));
        final DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        final DocumentBuilder builder = factory.newDocumentBuilder();
        doc = builder.parse(stream);
        final Element popup = getPopup();
        if (popup != null)
        {
            Logging.info(this, "received popup: " + popup.getAttribute("title"));
            retValue = true;
        }
        stream.close();
        return retValue;
    }

    private Element getPopup()
    {
        for (Node object = doc.getDocumentElement(); object != null; object = object.getNextSibling())
        {
            if (object instanceof Element)
            {
                final Element popup = (Element) object;
                if (popup.getTagName().equals("popup"))
                {
                    return popup;
                }
            }
        }
        return null;
    }

    public void generateAutoResponse(final int btnCount, final String btnName, final boolean value) throws Exception
    {
        response = null;
        final Element popup = getPopup();
        if (popup == null)
        {
            throw new Exception("popup element not found");
        }

        final List<Element> buttonGroup = Utils.getElements(popup, "buttongroup");
        if (buttonGroup.isEmpty())
        {
            throw new Exception("buttongroup element not found");
        }

        for (Element e : buttonGroup)
        {
            final int numberOfButtons = Integer.parseInt(e.getAttribute("total"));
            if (numberOfButtons != btnCount)
            {
                continue;
            }
            final List<Element> buttons = Utils.getElements(e, "button");
            if (buttons.isEmpty())
            {
                throw new Exception("empty buttons list");
            }
            for (Element b : buttons)
            {
                if (b.getAttribute("text").equals(btnName))
                {
                    b.setAttribute("selected", String.valueOf(value));
                    response = generateResponse();
                    return;
                }
            }
        }
        throw new Exception("button " + btnName + " not found");
    }

    private String generateResponse() throws Exception
    {
        DOMSource domSource = new DOMSource(doc);
        StringWriter writer = new StringWriter();
        StreamResult result = new StreamResult(writer);
        TransformerFactory tf = TransformerFactory.newInstance();
        Transformer transformer = tf.newTransformer();
        transformer.transform(domSource, result);
        return writer.toString();
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        final String par = "3010" + response;
        return new EISCPMessage('1', CODE, par);
    }
}
