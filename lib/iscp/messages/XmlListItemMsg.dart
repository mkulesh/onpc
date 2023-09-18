/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2023 by Mikhail Kulesh
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
    // Integra
    UNKNOWN,
    USB,
    FOLDER,
    MUSIC,
    SEARCH,
    PLAY,
    // Denon
    FOLDER_PLAY,
    HEOS_SERVER
}

class XmlListItemMsg extends ISCPMessage
{
    static const String CODE = "NLA"; // Note: The same code as for XmlListInfoMsg

    static const ExtEnum<ListItemIcon> ListItemIconEnum = ExtEnum<ListItemIcon>([
        // Integra
        EnumItem.code(ListItemIcon.UNKNOWN, "--", icon: Drawables.media_item_unknown, defValue: true),
        EnumItem.code(ListItemIcon.USB, "31", icon: Drawables.media_item_usb),
        EnumItem.code(ListItemIcon.FOLDER, "29", icon: Drawables.media_item_folder),
        EnumItem.code(ListItemIcon.MUSIC, "2d", icon: Drawables.media_item_music),
        EnumItem.code(ListItemIcon.SEARCH, "2F", icon: Drawables.media_item_search),
        EnumItem.code(ListItemIcon.PLAY, "36", icon: Drawables.media_item_play),
        // Denon
        EnumItem.code(ListItemIcon.FOLDER_PLAY, "HS01", icon: Drawables.media_item_folder_play),
        EnumItem.code(ListItemIcon.HEOS_SERVER, "HS02", icon: Drawables.media_item_media_server)
    ]);

    late String _title, _iconType, _iconId;
    late EnumItem<ListItemIcon> _icon;
    late bool _selectable;
    ISCPMessage? _cmdMessage;

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
        final String iconType, final ListItemIcon icon, final bool selectable, final ISCPMessage cmdMessage) :
            super.outputId(id, CODE, _getParameterAsString(id, numberOfLayers))
    {
        _title = title;
        _iconType = iconType;
        _icon = ListItemIconEnum.valueByKey(icon);
        _iconId = this._icon.getCode;
        _selectable = selectable;
        _cmdMessage = cmdMessage;
    }

    XmlListItemMsg.rename(final XmlListItemMsg src, final String newTitle) :
            super.outputId(src.getMessageId, src.getCode, src.getData)
    {
        _title = newTitle;
        _iconType = src._iconType;
        _icon = src._icon;
        _iconId = src._iconId;
        _selectable = src._selectable;
        _cmdMessage = src._cmdMessage;
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

    void setIconType(String iconType)
    {
        _iconType = iconType;
    }

    EnumItem<ListItemIcon> get getIcon
    => _icon;

    void setIcon(ListItemIcon icon)
    {
        _icon = ListItemIconEnum.valueByKey(icon);
    }

    bool isSong()
    => _icon.key == ListItemIcon.PLAY || _icon.key == ListItemIcon.MUSIC;

    ISCPMessage? get getCmdMessage
    => _cmdMessage;

    void setCmdMessage(ISCPMessage cmdMessage)
    {
        _cmdMessage = cmdMessage;
    }

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
            + "; CMD=" + (_cmdMessage == null ? "N/A" : _cmdMessage!.toString())
            + "]";

    @override
    EISCPMessage getCmdMsg()
    {
        return _cmdMessage == null ? super.getCmdMsg() : _cmdMessage!.getCmdMsg();
    }
}
