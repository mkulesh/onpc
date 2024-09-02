/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2024 by Mikhail Kulesh
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

import java.util.ArrayList;

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
        case PlayStatusMsg.CD_CODE:
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
        case ToneCommandMsg.CODE:
        case ToneCommandMsg.ZONE2_CODE:
        case ToneCommandMsg.ZONE3_CODE:
            return new ToneCommandMsg(raw);
        case SubwooferLevelCommandMsg.CODE:
            return new SubwooferLevelCommandMsg(raw);
        case CenterLevelCommandMsg.CODE:
            return new CenterLevelCommandMsg(raw);
        case PresetCommandMsg.CODE:
        case PresetCommandMsg.ZONE2_CODE:
        case PresetCommandMsg.ZONE3_CODE:
        case PresetCommandMsg.ZONE4_CODE:
            return new PresetCommandMsg(raw);
        case PresetMemoryMsg.CODE:
            return new PresetMemoryMsg(raw);
        case RadioStationNameMsg.CODE:
            return new RadioStationNameMsg(raw);
        case TuningCommandMsg.CODE:
        case TuningCommandMsg.ZONE2_CODE:
        case TuningCommandMsg.ZONE3_CODE:
        case TuningCommandMsg.ZONE4_CODE:
            return new TuningCommandMsg(raw);
        case RDSInformationMsg.CODE:
            return new RDSInformationMsg(raw);
        case MusicOptimizerMsg.CODE:
            return new MusicOptimizerMsg(raw);
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
        case DirectCommandMsg.CODE:
            return new DirectCommandMsg(raw);
        case PhaseMatchingBassMsg.CODE:
            return new PhaseMatchingBassMsg(raw);
        case SleepSetCommandMsg.CODE:
            return new SleepSetCommandMsg(raw);
        case SpeakerACommandMsg.CODE:
        case SpeakerACommandMsg.ZONE2_CODE:
            return new SpeakerACommandMsg(raw);
        case SpeakerBCommandMsg.CODE:
        case SpeakerBCommandMsg.ZONE2_CODE:
            return new SpeakerBCommandMsg(raw);
        case LateNightCommandMsg.CODE:
            return new LateNightCommandMsg(raw);
        case NetworkStandByMsg.CODE:
            return new NetworkStandByMsg(raw);
        case PrivacyPolicyStatusMsg.CODE:
            return new PrivacyPolicyStatusMsg(raw);
        case CdPlayerOperationCommandMsg.CODE:
            return new CdPlayerOperationCommandMsg(raw);
        case MultiroomDeviceInformationMsg.CODE:
            return new MultiroomDeviceInformationMsg(raw);
        case MultiroomChannelSettingMsg.CODE:
            return new MultiroomChannelSettingMsg(raw);
        case AudioInformationMsg.CODE:
            return new AudioInformationMsg(raw);
        case VideoInformationMsg.CODE:
            return new VideoInformationMsg(raw);
        default:
            throw new Exception("No factory method for message " + raw.getCode());
        }
    }

    public static ArrayList<String[]> getAllZonedMessages()
    {
        final ArrayList<String[]> retValue = new ArrayList<>();
        retValue.add(PowerStatusMsg.ZONE_COMMANDS);
        retValue.add(SpeakerACommandMsg.ZONE_COMMANDS);
        retValue.add(SpeakerBCommandMsg.ZONE_COMMANDS);
        retValue.add(InputSelectorMsg.ZONE_COMMANDS);
        retValue.add(AudioMutingMsg.ZONE_COMMANDS);
        retValue.add(MasterVolumeMsg.ZONE_COMMANDS);
        retValue.add(ToneCommandMsg.ZONE_COMMANDS);
        retValue.add(PresetCommandMsg.ZONE_COMMANDS);
        retValue.add(TuningCommandMsg.ZONE_COMMANDS);
        return retValue;
    }
}
