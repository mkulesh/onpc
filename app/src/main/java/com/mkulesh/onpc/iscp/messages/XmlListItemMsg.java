package com.mkulesh.onpc.iscp.messages;

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
        PLAY("36", R.drawable.media_item_play);
        final String code;
        final int imageId;

        Icon(String code, int imageId)
        {
            this.code = code;
            this.imageId = imageId;
        }

        public String getCode()
        {
            return code;
        }

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
