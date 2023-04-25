/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2022 by Mikhail Kulesh
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
import com.mkulesh.onpc.utils.Utils;

import org.w3c.dom.Element;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;

public class XmlListItemMsg extends ISCPMessage
{
    public enum Icon implements StringParameterIf
    {
        UNKNOWN("--", R.drawable.media_item_unknown),
        USB("31", R.drawable.media_item_usb),
        FOLDER("29", R.drawable.media_item_folder),
        MUSIC("2d", R.drawable.media_item_music),
        SEARCH("2F", R.drawable.media_item_search),
        PLAY("36", R.drawable.media_item_play),
        FOLDER_PLAY("HS01", R.drawable.media_item_folder_play),
        HEOS_SERVER("HS02", R.drawable.media_item_media_server);
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
    private Icon icon;
    private final boolean selectable;
    private final ISCPMessage cmdMessage;

    XmlListItemMsg(final int id, final int numberOfLayers, final Element src)
    {
        super(id, null);
        this.numberOfLayers = numberOfLayers;
        title = src.getAttribute("title") == null ? "" : src.getAttribute("title");
        iconType = src.getAttribute("icontype") == null ? "" : src.getAttribute("icontype");
        iconId = src.getAttribute("iconid") == null ? Icon.UNKNOWN.getCode() : src.getAttribute("iconid");
        icon = (Icon) searchParameter(iconId, Icon.values(), Icon.UNKNOWN);
        selectable = Utils.ensureAttribute(src, "selectable", "1");
        cmdMessage = null;
    }

    public XmlListItemMsg(final int id, final int numberOfLayers, final String title,
                          final Icon icon, final boolean selectable, final ISCPMessage cmdMessage)
    {
        super(id, null);
        this.numberOfLayers = numberOfLayers;
        this.title = title;
        iconType = "";
        iconId = icon.getCode();
        this.icon = icon;
        this.selectable = selectable;
        this.cmdMessage = cmdMessage;
    }

    private int getNumberOfLayers()
    {
        return numberOfLayers;
    }

    public Icon getIcon()
    {
        return icon;
    }

    public void setIcon(Icon icon)
    {
        this.icon = icon;
    }

    public String getTitle()
    {
        return title;
    }

    @SuppressWarnings("BooleanMethodIsAlwaysInverted")
    public boolean isSelectable()
    {
        return selectable;
    }

    @NonNull
    @Override
    public String toString()
    {
        return "ITEM[" + messageId + ": " + title
                + "; ICON_TYPE=" + iconType
                + "; ICON_ID=" + iconId
                + "; ICON=" + icon.toString()
                + "; SELECTABLE=" + selectable
                + "; CMD=" + cmdMessage
                + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        if (cmdMessage != null)
        {
            return cmdMessage.getCmdMsg();
        }
        else
        {
            final String param = "I" + String.format("%02x", getNumberOfLayers()) +
                    String.format("%04x", getMessageId()) + "----";
            return new EISCPMessage("NLA", param);
        }
    }

    public ISCPMessage getCmdMessage()
    {
        return cmdMessage;
    }
}
