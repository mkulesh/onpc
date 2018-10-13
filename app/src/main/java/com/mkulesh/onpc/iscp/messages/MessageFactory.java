package com.mkulesh.onpc.iscp.messages;

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

/**
 * A static helper class used to create messages
 */
public class MessageFactory
{
    public static ISCPMessage create(EISCPMessage raw) throws Exception
    {
        switch (raw.getCode().toUpperCase())
        {
        case PowerStatusMsg.CODE:
            return new PowerStatusMsg(raw);
        case ReceiverInformationMsg.CODE:
            return new ReceiverInformationMsg(raw);
        case DeviceNameMsg.CODE:
            return new DeviceNameMsg(raw);
        case InputSelectorMsg.CODE:
            return new InputSelectorMsg(raw);
        case TimeInfoMsg.CODE:
            return new TimeInfoMsg(raw);
        case JacketArtMsg.CODE:
            return new JacketArtMsg(raw);
        case TitleNameMsg.CODE:
            return new TitleNameMsg(raw);
        case AlbumNameMsg.CODE:
            return new AlbumNameMsg(raw);
        case ArtistNameMsg.CODE:
            return new ArtistNameMsg(raw);
        case FileFormatMsg.CODE:
            return new FileFormatMsg(raw);
        case TrackInfoMsg.CODE:
            return new TrackInfoMsg(raw);
        case PlayStatusMsg.CODE:
            return new PlayStatusMsg(raw);
        case ListTitleInfoMsg.CODE:
            return new ListTitleInfoMsg(raw);
        case ListInfoMsg.CODE:
            return new ListInfoMsg(raw);
        case ListItemInfoMsg.CODE:
            return new ListItemInfoMsg(raw);
        case MenuStatusMsg.CODE:
            return new MenuStatusMsg(raw);
        case XmlListInfoMsg.CODE:
            return new XmlListInfoMsg(raw);
        default:
            throw new Exception("No factory method for message " + raw.getCode());
        }
    }
}
