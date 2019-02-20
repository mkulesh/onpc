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

import android.support.annotation.DrawableRes;
import android.support.annotation.NonNull;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.utils.Utils;

import org.w3c.dom.Element;

public class XmlListItemMsg extends ISCPMessage
{
    public enum Icon implements StringParameterIf
    {
        UNKNOWN("--", R.drawable.media_item_unknown),
        USB("31", R.drawable.media_item_usb),
        FOLDER("29", R.drawable.media_item_folder),
        MUSIC("2d", R.drawable.media_item_music),
        SEARCH("2F", R.drawable.media_item_search),
        PLAY("36", R.drawable.media_item_play);
        final String code;

        @DrawableRes
        final int imageId;

        Icon(String code, @DrawableRes int imageId)
        {
            this.code = code;
            this.imageId = imageId;
        }

        public String getCode()
        {
            return code;
        }

        @DrawableRes
        public int getImageId()
        {
            return imageId;
        }
    }

    private final int numberOfLayers;
    private final String title;
    private final String iconType;
    private final String iconId;
    private final Icon icon;
    private final boolean selectable;

    XmlListItemMsg(final int id, final int numberOfLayers, final Element src)
    {
        super(id, null);
        this.numberOfLayers = numberOfLayers;
        title = src.getAttribute("title") == null ? "" : src.getAttribute("title");
        iconType = src.getAttribute("icontype") == null ? "" : src.getAttribute("icontype");
        iconId = src.getAttribute("iconid") == null ? Icon.UNKNOWN.getCode() : src.getAttribute("iconid");
        icon = (Icon) searchParameter(iconId, Icon.values(), Icon.UNKNOWN);
        selectable = Utils.ensureAttribute(src, "selectable", "1");
    }

    public XmlListItemMsg(final int id, final int numberOfLayers, final String title,
                          final Icon icon, final boolean selectable)
    {
        super(id, null);
        this.numberOfLayers = numberOfLayers;
        this.title = title;
        iconType = "";
        iconId = icon.getCode();
        this.icon = icon;
        this.selectable = selectable;
    }

    public XmlListItemMsg(XmlListItemMsg other)
    {
        super(other);
        numberOfLayers = other.numberOfLayers;
        title = other.title;
        iconType = other.iconType;
        iconId = other.iconId;
        icon = other.icon;
        selectable = other.selectable;
    }

    private int getNumberOfLayers()
    {
        return numberOfLayers;
    }

    public Icon getIcon()
    {
        return icon;
    }

    public String getTitle()
    {
        return title;
    }

    public boolean isSelectable()
    {
        return selectable;
    }

    @NonNull
    @Override
    public String toString()
    {
        return "ITEM[" + Integer.toString(messageId) + ": " + title
                + "; ICON_TYPE=" + iconType
                + "; ICON_ID=" + iconId
                + "; ICON=" + icon.toString()
                + "; SELECTABLE=" + selectable
                + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        final String param = "I" + String.format("%02x", getNumberOfLayers()) +
                String.format("%04x", getMessageId()) + "----";
        return new EISCPMessage('1', "NLA", param);
    }
}
