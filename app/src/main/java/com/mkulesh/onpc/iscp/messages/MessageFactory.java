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
        case PowerStatusMsg.ZONE2_CODE:
        case PowerStatusMsg.ZONE3_CODE:
        case PowerStatusMsg.ZONE4_CODE:
            return new PowerStatusMsg(raw);
        case FirmwareUpdateMsg.CODE:
            return new FirmwareUpdateMsg(raw);
        case ReceiverInformationMsg.CODE:
            return new ReceiverInformationMsg(raw);
        case FriendlyNameMsg.CODE:
            return new FriendlyNameMsg(raw);
        case DeviceNameMsg.CODE:
            return new DeviceNameMsg(raw);
        case InputSelectorMsg.CODE:
        case InputSelectorMsg.ZONE2_CODE:
        case InputSelectorMsg.ZONE3_CODE:
        case InputSelectorMsg.ZONE4_CODE:
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
        case DisplayModeMsg.CODE:
            return new DisplayModeMsg(raw);
        case DimmerLevelMsg.CODE:
            return new DimmerLevelMsg(raw);
        case DigitalFilterMsg.CODE:
            return new DigitalFilterMsg(raw);
        case AudioMutingMsg.CODE:
        case AudioMutingMsg.ZONE2_CODE:
        case AudioMutingMsg.ZONE3_CODE:
        case AudioMutingMsg.ZONE4_CODE:
            return new AudioMutingMsg(raw);
        case MasterVolumeMsg.CODE:
        case MasterVolumeMsg.ZONE2_CODE:
        case MasterVolumeMsg.ZONE3_CODE:
        case MasterVolumeMsg.ZONE4_CODE:
            return new MasterVolumeMsg(raw);
        case AutoPowerMsg.CODE:
            return new AutoPowerMsg(raw);
        case CustomPopupMsg.CODE:
            return new CustomPopupMsg(raw);
        case GoogleCastVersionMsg.CODE:
            return new GoogleCastVersionMsg(raw);
        case GoogleCastAnalyticsMsg.CODE:
            return new GoogleCastAnalyticsMsg(raw);
        case ListeningModeMsg.CODE:
            return new ListeningModeMsg(raw);
        case HdmiCecMsg.CODE:
            return new HdmiCecMsg(raw);
        case SpeakerACommandMsg.CODE:
        case SpeakerACommandMsg.ZONE2_CODE:
            return new SpeakerACommandMsg(raw);
        case SpeakerBCommandMsg.CODE:
        case SpeakerBCommandMsg.ZONE2_CODE:
            return new SpeakerBCommandMsg(raw);
        case PrivacyPolicyStatusMsg.CODE:
            return new PrivacyPolicyStatusMsg(raw);
        case CdPlayerOperationCommandMsg.CODE:
            return new CdPlayerOperationCommandMsg(raw);
        default:
            throw new Exception("No factory method for message " + raw.getCode());
        }
    }
}
