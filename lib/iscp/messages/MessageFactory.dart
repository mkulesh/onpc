/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2022 by Mikhail Kulesh
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
// @dart=2.9
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";
import "AlbumNameMsg.dart";
import "AllChannelEqMsg.dart";
import "ArtistNameMsg.dart";
import "AudioInformationMsg.dart";
import "AudioMutingMsg.dart";
import "AutoPowerMsg.dart";
import "CenterLevelCommandMsg.dart";
import "CustomPopupMsg.dart";
import "DabStationNameMsg.dart";
import "DeviceNameMsg.dart";
import "DigitalFilterMsg.dart";
import "DimmerLevelMsg.dart";
import "DirectCommandMsg.dart";
import "DisplayModeMsg.dart";
import "FileFormatMsg.dart";
import "FirmwareUpdateMsg.dart";
import "FriendlyNameMsg.dart";
import "GoogleCastAnalyticsMsg.dart";
import "GoogleCastVersionMsg.dart";
import "HdmiCecMsg.dart";
import "InputSelectorMsg.dart";
import "JacketArtMsg.dart";
import "LateNightCommandMsg.dart";
import "ListInfoMsg.dart";
import "ListItemInfoMsg.dart";
import "ListTitleInfoMsg.dart";
import "ListeningModeMsg.dart";
import "MasterVolumeMsg.dart";
import "MenuStatusMsg.dart";
import "MultiroomChannelSettingMsg.dart";
import "MultiroomDeviceInformationMsg.dart";
import "MusicOptimizerMsg.dart";
import "PhaseMatchingBassMsg.dart";
import "PlayStatusMsg.dart";
import "PowerStatusMsg.dart";
import "PresetCommandMsg.dart";
import "PresetMemoryMsg.dart";
import "PrivacyPolicyStatusMsg.dart";
import "ReceiverInformationMsg.dart";
import "SleepSetCommandMsg.dart";
import "SpeakerACommandMsg.dart";
import "SpeakerBCommandMsg.dart";
import "SubwooferLevelCommandMsg.dart";
import "TimeInfoMsg.dart";
import "TitleNameMsg.dart";
import "ToneCommandMsg.dart";
import "TrackInfoMsg.dart";
import "TuningCommandMsg.dart";
import "VideoInformationMsg.dart";
import "XmlListInfoMsg.dart";

class MessageFactory
{
    static ISCPMessage create(EISCPMessage raw)
    {
        switch (raw.getCode)
        {
        // Receiver info
            case ReceiverInformationMsg.CODE:
                return ReceiverInformationMsg(raw);
            case FriendlyNameMsg.CODE:
                return FriendlyNameMsg(raw);
            case DeviceNameMsg.CODE:
                return DeviceNameMsg(raw);
            case PowerStatusMsg.CODE:
            case PowerStatusMsg.ZONE2_CODE:
            case PowerStatusMsg.ZONE3_CODE:
            case PowerStatusMsg.ZONE4_CODE:
                return PowerStatusMsg(raw);
            case FirmwareUpdateMsg.CODE:
                return FirmwareUpdateMsg(raw);
            case GoogleCastVersionMsg.CODE:
                return GoogleCastVersionMsg(raw);

        // Settings
            case DimmerLevelMsg.CODE:
                return DimmerLevelMsg(raw);
            case DigitalFilterMsg.CODE:
                return DigitalFilterMsg(raw);
            case MusicOptimizerMsg.CODE:
                return MusicOptimizerMsg(raw);
            case AutoPowerMsg.CODE:
                return AutoPowerMsg(raw);
            case HdmiCecMsg.CODE:
                return HdmiCecMsg(raw);
            case PhaseMatchingBassMsg.CODE:
                return PhaseMatchingBassMsg(raw);
            case SleepSetCommandMsg.CODE:
                return SleepSetCommandMsg(raw);
            case SpeakerACommandMsg.CODE:
            case SpeakerACommandMsg.ZONE2_CODE:
                return SpeakerACommandMsg(raw);
            case SpeakerBCommandMsg.CODE:
            case SpeakerBCommandMsg.ZONE2_CODE:
                return SpeakerBCommandMsg(raw);
            case GoogleCastAnalyticsMsg.CODE:
                return GoogleCastAnalyticsMsg(raw);
            case LateNightCommandMsg.CODE:
                return LateNightCommandMsg(raw);

        // Track info
            case AlbumNameMsg.CODE:
                return AlbumNameMsg(raw);
            case ArtistNameMsg.CODE:
                return ArtistNameMsg(raw);
            case TitleNameMsg.CODE:
                return TitleNameMsg(raw);
            case FileFormatMsg.CODE:
                return FileFormatMsg(raw);
            case TimeInfoMsg.CODE:
                return TimeInfoMsg(raw);
            case TrackInfoMsg.CODE:
                return TrackInfoMsg(raw);
            case DisplayModeMsg.CODE:
                return DisplayModeMsg(raw);
            case JacketArtMsg.CODE:
                return JacketArtMsg(raw);
            case AudioInformationMsg.CODE:
                return AudioInformationMsg(raw);
            case VideoInformationMsg.CODE:
                return VideoInformationMsg(raw);

        // Play status
            case InputSelectorMsg.CODE:
            case InputSelectorMsg.ZONE2_CODE:
            case InputSelectorMsg.ZONE3_CODE:
            case InputSelectorMsg.ZONE4_CODE:
                return InputSelectorMsg(raw);
            case PlayStatusMsg.CODE:
            case PlayStatusMsg.CD_CODE:
                return PlayStatusMsg(raw);
            case ListInfoMsg.CODE:
                return ListInfoMsg(raw);
            case ListItemInfoMsg.CODE:
                return ListItemInfoMsg(raw);
            case ListTitleInfoMsg.CODE:
                return ListTitleInfoMsg(raw);
            case MenuStatusMsg.CODE:
                return MenuStatusMsg(raw);
            case XmlListInfoMsg.CODE:
                return XmlListInfoMsg(raw);

        // Sound
            case AudioMutingMsg.CODE:
            case AudioMutingMsg.ZONE2_CODE:
            case AudioMutingMsg.ZONE3_CODE:
            case AudioMutingMsg.ZONE4_CODE:
                return AudioMutingMsg(raw);
            case MasterVolumeMsg.CODE:
            case MasterVolumeMsg.ZONE2_CODE:
            case MasterVolumeMsg.ZONE3_CODE:
            case MasterVolumeMsg.ZONE4_CODE:
                return MasterVolumeMsg(raw);
            case ToneCommandMsg.CODE:
            case ToneCommandMsg.ZONE2_CODE:
            case ToneCommandMsg.ZONE3_CODE:
                return ToneCommandMsg(raw);
            case DirectCommandMsg.CODE:
                return DirectCommandMsg(raw);
            case SubwooferLevelCommandMsg.CODE:
                return SubwooferLevelCommandMsg(raw);
            case CenterLevelCommandMsg.CODE:
                return CenterLevelCommandMsg(raw);
            case ListeningModeMsg.CODE:
                return ListeningModeMsg(raw);
            case AllChannelEqMsg.CODE:
                return AllChannelEqMsg(raw);

        // Radio
            case PresetCommandMsg.CODE:
            case PresetCommandMsg.ZONE2_CODE:
            case PresetCommandMsg.ZONE3_CODE:
            case PresetCommandMsg.ZONE4_CODE:
                return PresetCommandMsg(raw);
            case TuningCommandMsg.CODE:
            case TuningCommandMsg.ZONE2_CODE:
            case TuningCommandMsg.ZONE3_CODE:
            case TuningCommandMsg.ZONE4_CODE:
                return TuningCommandMsg(raw);
            case PresetMemoryMsg.CODE:
                return PresetMemoryMsg(raw);
            case DabStationNameMsg.CODE:
                return DabStationNameMsg(raw);

        // Popups
            case CustomPopupMsg.CODE:
                return CustomPopupMsg(raw);

        // Multiroom
            case MultiroomDeviceInformationMsg.CODE:
                return MultiroomDeviceInformationMsg(raw);
            case MultiroomChannelSettingMsg.CODE:
                return MultiroomChannelSettingMsg(raw);

        // Privacy
            case PrivacyPolicyStatusMsg.CODE:
                return PrivacyPolicyStatusMsg(raw);

            default:
                throw Exception("No factory method for message " + raw.getCode);
        }
    }
}