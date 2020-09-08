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

import "../../constants/Drawables.dart";
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";
import "EnumParameterMsg.dart";

enum ListItemIcon
{
    UNKNOWN,
    USB,
    FOLDER,
    MUSIC,
    SEARCH,
    PLAY
}

class XmlListItemMsg extends ISCPMessage
{
    static const String CODE = "NLA"; // Note: The same code as for XmlListInfoMsg

    static const ExtEnum<ListItemIcon> ListItemIconEnum = ExtEnum<ListItemIcon>([
        EnumItem.code(ListItemIcon.UNKNOWN, "--", icon: Drawables.media_item_unknown, defValue: true),
        EnumItem.code(ListItemIcon.USB, "31", icon: Drawables.media_item_usb),
        EnumItem.code(ListItemIcon.FOLDER, "29", icon: Drawables.media_item_folder),
        EnumItem.code(ListItemIcon.MUSIC, "2d", icon: Drawables.media_item_music),
        EnumItem.code(ListItemIcon.SEARCH, "2F", icon: Drawables.media_item_search),
        EnumItem.code(ListItemIcon.PLAY, "36", icon: Drawables.media_item_play)
    ]);

    String _title, _iconType, _iconId;
    EnumItem<ListItemIcon> _icon;
    bool _selectable;
    EISCPMessage _cmdMessage;

    XmlListItemMsg.output(final int id, final int numberOfLayers, final xml.XmlElement src) :
            super.outputId(id, CODE, _getParameterAsString(id, numberOfLayers))
    {
        _title = ISCPMessage.nonNullString(src.getAttribute("title"));
        _iconType = ISCPMessage.nonNullString(src.getAttribute("icontype"));
        _iconId = ISCPMessage.nonNullString(src.getAttribute("iconid"));
        _icon = ListItemIconEnum.valueByCode(_iconId);
        _selectable = ISCPMessage.nonNullInteger(src.getAttribute("selectable"), 10, 0) == 1;
        _cmdMessage = null;
    }

    XmlListItemMsg.details(final int id, final int numberOfLayers, final String title,
        final String iconType, final ListItemIcon icon, final bool selectable, final EISCPMessage cmdMessage) :
            super.outputId(id, CODE, _getParameterAsString(id, numberOfLayers))
    {
        _title = title;
        _iconType = iconType;
        _icon = ListItemIconEnum.valueByKey(icon);
        _iconId = this._icon.getCode;
        _selectable = selectable;
        _cmdMessage = cmdMessage;
    }

    static String _getParameterAsString(final int id, final int numberOfLayers)
    {
        return "I" +
            numberOfLayers.toRadixString(16).padLeft(2, '0') +
            id.toRadixString(16).padLeft(4, '0') + "----";
    }

    String get getTitle
    => _title;

    String get iconType
    => _iconType;

    EnumItem<ListItemIcon> get getIcon
    => _icon;

    bool get isSelectable
    => _selectable;

    @override
    String toString()
    => "ITEM[" + _title
            + "; ID=" + getMessageId.toString()
            + "; ICON_TYPE=" + _iconType
            + "; ICON_ID=" + _iconId
            + "; ICON=" + _icon.toString()
            + "; SELECTABLE=" + _selectable.toString()
            + "; CMD=" + (_cmdMessage == null ? "N/A" : _cmdMessage.toString())
            + "]";

    EISCPMessage getCmdMsg()
    {
        return _cmdMessage == null ? super.getCmdMsg() : _cmdMessage;
    }
}
