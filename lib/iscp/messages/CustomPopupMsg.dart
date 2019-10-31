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

enum PopupUiType
{
    XML,
    LIST,
    MENU,
    PLAYBACK,
    POPUP,
    KEYBOARD,
    MENU_LIST
}

/*
 * NET Custom Popup Message (for Network Control Only)
 */
class CustomPopupMsg extends ISCPMessage
{
    static const String CODE = "NCP";

    static const ExtEnum<PopupUiType> PopupUiTypeEnum = ExtEnum<PopupUiType>([
        EnumItem.char(PopupUiType.XML, 'X', defValue: true),
        EnumItem.char(PopupUiType.LIST, '0'),
        EnumItem.char(PopupUiType.MENU, '1'),
        EnumItem.char(PopupUiType.PLAYBACK, '2'),
        EnumItem.char(PopupUiType.POPUP, '3'),
        EnumItem.char(PopupUiType.KEYBOARD, '4'),
        EnumItem.char(PopupUiType.MENU_LIST, '5')
    ]);

    PopupUiType _uiType;

    xml.XmlDocument _popupDocument;

    xml.XmlDocument get popupDocument
    => _popupDocument;

    CustomPopupMsg(EISCPMessage raw) : super(CODE, raw)
    {
        _uiType = PopupUiTypeEnum.valueByCode(getData.substring(0, 1)).key;
        _popupDocument = xml.parse(getData.substring(1));
    }

    CustomPopupMsg.output(final PopupUiType uiType, final xml.XmlDocument popupDocument) :
            super.output(CODE, _getParameterAsString(uiType, popupDocument.toXmlString()))
    {
        _uiType = uiType;
        _popupDocument = popupDocument;
    }

    static String _getParameterAsString(PopupUiType uiType, String xml)
    {
        return PopupUiTypeEnum.valueByKey(uiType).getCode + "000" + xml;
    }

    @override
    String toString()
    => super.toString() + "[" + "; UI=" + _uiType.toString() + "]";
}
