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

import "package:xml/xml.dart" as xml;

import "../EISCPMessage.dart";
import "../ISCPMessage.dart";
import "EnumParameterMsg.dart";
import "XmlListItemMsg.dart";

enum XmlUiType
{
    LIST,
    MENU,
    PLAYBACK,
    POPUP,
    KEYBOARD,
    MENU_LIST,
    NONE
}

/*
 * NET/USB List Info(All item, need processing XML data, for Network Control Only)
 */
class XmlListInfoMsg extends ISCPMessage
{
    static const String CODE = "NLA";

    String _responseType;
    int _sequenceNumber;
    String _status;

    /*
     * UI type '0' : List, '1' : Menu, '2' : Playback, '3' : Popup, '4' : Keyboard, "5" : Menu List
     */
    static const ExtEnum<XmlUiType> XmlUiTypeEnum = ExtEnum<XmlUiType>([
        EnumItem.char(XmlUiType.LIST, '0'),
        EnumItem.char(XmlUiType.MENU, '1'),
        EnumItem.char(XmlUiType.PLAYBACK, '2'),
        EnumItem.char(XmlUiType.POPUP, '3'),
        EnumItem.char(XmlUiType.KEYBOARD, '4'),
        EnumItem.char(XmlUiType.MENU_LIST, '5'),
        EnumItem.char(XmlUiType.NONE, '-', defValue: true)
    ]);

    XmlUiType _uiType;

    XmlListInfoMsg(EISCPMessage raw) : super(CODE, raw)
    {
        // Format: "tzzzzsurr<.....>"
        _responseType = getData.substring(0, 1);
        _sequenceNumber = ISCPMessage.nonNullInteger(getData.substring(1, 5), 16, 0);
        _status = getData.substring(5, 6);
        _uiType = XmlUiTypeEnum.valueByCode(getData.substring(6, 7)).key;
    }

    XmlListInfoMsg.output(int seqNumber, int layer, int startItem, int endItem) :
            super.output(CODE, _getParameterAsString(seqNumber, layer, startItem, endItem))
    {
        // Format: "tzzzzsurr<.....>"
        _responseType = 'x';
        _sequenceNumber = seqNumber;
        _status = 'x';
        _uiType = XmlUiType.NONE;
    }

    static String _getParameterAsString(int seqNumber, int layer, int startItem, int endItem)
    {
        return "L" + seqNumber.toRadixString(16).padLeft(4, '0') +
            layer.toRadixString(16).padLeft(2, '0') +
            startItem.toRadixString(16).padLeft(4, '0') +
            endItem.toRadixString(16).padLeft(4, '0');
    }

    @override
    String toString()
    => super.toString() + "["
            + "; RESP=" + _responseType
            + "; SEQ_NR=" + _sequenceNumber.toString()
            + "; STATUS=" + _status
            + "; UI=" + _uiType.toString() + "]";

    void parseXml(final List<ISCPMessage> items, final int numberOfLayers)
    {
        final xml.XmlDocument document = xml.XmlDocument.parse(getData.substring(9));
        final Iterable<xml.XmlElement> itemsElements = document.findAllElements("items");
        if (itemsElements.isEmpty)
        {
            return;
        }
        final xml.XmlElement header = itemsElements.first;
        final int offset = ISCPMessage.nonNullInteger(header.getAttribute("offset"), 10, -1);
        final int totalitems = ISCPMessage.nonNullInteger(header.getAttribute("totalitems"), 10, -1);
        if (offset >= 0 && totalitems >= 0)
        {
            int id = 0;
            document.findAllElements("item").forEach((element)
            {
                items.add(XmlListItemMsg.output(offset + id, numberOfLayers, element));
                id++;
            });
        }
    }
}
