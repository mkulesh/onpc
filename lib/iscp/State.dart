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
// @dart=2.9
import 'dart:collection';

import "package:xml/xml.dart" as xml;

import "../constants/Drawables.dart";
import "../utils/Logging.dart";
import "ConnectionIf.dart";
import "ISCPMessage.dart";
import "messages/AlbumNameMsg.dart";
import "messages/AllChannelEqMsg.dart";
import "messages/ArtistNameMsg.dart";
import "messages/AudioInformationMsg.dart";
import "messages/AudioMutingMsg.dart";
import "messages/AutoPowerMsg.dart";
import "messages/CdPlayerOperationCommandMsg.dart";
import "messages/CenterLevelCommandMsg.dart";
import "messages/CustomPopupMsg.dart";
import "messages/DcpAudioRestorerMsg.dart";
import "messages/DcpEcoModeMsg.dart";
import "messages/DcpReceiverInformationMsg.dart";
import "messages/DcpTunerModeMsg.dart";
import "messages/DeviceNameMsg.dart";
import "messages/DigitalFilterMsg.dart";
import "messages/DimmerLevelMsg.dart";
import "messages/DirectCommandMsg.dart";
import "messages/FileFormatMsg.dart";
import "messages/FirmwareUpdateMsg.dart";
import "messages/FriendlyNameMsg.dart";
import "messages/GoogleCastAnalyticsMsg.dart";
import "messages/GoogleCastVersionMsg.dart";
import "messages/HdmiCecMsg.dart";
import "messages/InputSelectorMsg.dart";
import "messages/JacketArtMsg.dart";
import "messages/LateNightCommandMsg.dart";
import "messages/ListInfoMsg.dart";
import "messages/ListTitleInfoMsg.dart";
import "messages/ListeningModeMsg.dart";
import "messages/MasterVolumeMsg.dart";
import "messages/MenuStatusMsg.dart";
import "messages/MusicOptimizerMsg.dart";
import "messages/NetworkStandByMsg.dart";
import "messages/PhaseMatchingBassMsg.dart";
import "messages/PlayStatusMsg.dart";
import "messages/PowerStatusMsg.dart";
import "messages/PresetCommandMsg.dart";
import "messages/RadioStationNameMsg.dart";
import "messages/ReceiverInformationMsg.dart";
import "messages/ServiceType.dart";
import "messages/SleepSetCommandMsg.dart";
import "messages/SpeakerACommandMsg.dart";
import "messages/SpeakerBCommandMsg.dart";
import "messages/SubwooferLevelCommandMsg.dart";
import "messages/TimeInfoMsg.dart";
import "messages/TitleNameMsg.dart";
import "messages/ToneCommandMsg.dart";
import "messages/TrackInfoMsg.dart";
import "messages/TuningCommandMsg.dart";
import "messages/VideoInformationMsg.dart";
import "messages/XmlListInfoMsg.dart";
import "state/DeviceSettingsState.dart";
import "state/MediaListState.dart";
import "state/MultiroomState.dart";
import "state/PlaybackState.dart";
import "state/RadioState.dart";
import "state/ReceiverInformation.dart";
import "state/SoundControlState.dart";
import "state/TrackState.dart";

class State with ProtoTypeMix
{
    static const bool SKIP_XML_MESSAGES = false;

    // Connection state
    bool _connected = false;

    bool get isConnected
    => _connected;

    // Receiver information
    final ReceiverInformation _receiverInformation = ReceiverInformation();

    ReceiverInformation get receiverInformation
    => _receiverInformation;

    bool get isOn
    => _receiverInformation.isOn;

    // Device settings
    final DeviceSettingsState _deviceSettingsState = DeviceSettingsState();

    DeviceSettingsState get deviceSettingsState
    => _deviceSettingsState;

    // Active zone
    static const int DEFAULT_ACTIVE_ZONE = ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE;
    int _activeZone = DEFAULT_ACTIVE_ZONE;

    set activeZone(int value)
    {
        _activeZone = value;
        Logging.info(this, "set active zone: " + value.toString());
    }

    int get getActiveZone
    => _activeZone;

    Zone get getActiveZoneInfo
    => _activeZone < _receiverInformation.zones.length ? _receiverInformation.zones[_activeZone] : null;

    bool get isExtendedZone
    => _activeZone < _receiverInformation.zones.length && _activeZone != DEFAULT_ACTIVE_ZONE;

    bool get isDefaultZone
    => _activeZone == DEFAULT_ACTIVE_ZONE;

    // Track state
    final TrackState _trackState = TrackState();

    TrackState get trackState
    => _trackState;

    // Playback state
    final PlaybackState _playbackState = PlaybackState();

    PlaybackState get playbackState
    => _playbackState;

    bool get isPlaying
    => playbackState.playStatus != PlayStatus.STOP;

    // Media list
    final MediaListState _mediaListState = MediaListState();

    MediaListState get mediaListState
    => _mediaListState;

    // Sound control state
    final SoundControlState _soundControlState = SoundControlState();

    SoundControlState get soundControlState
    => _soundControlState;

    // Radio state
    final RadioState _radioState = RadioState();

    RadioState get radioState
    => _radioState;

    // Popup
    xml.XmlDocument _popupDocument;

    xml.XmlDocument get popupDocument
    => _popupDocument;

    // Multiroom
    final MultiroomState _multiroomState = MultiroomState();

    MultiroomState get multiroomState
    => _multiroomState;

    // Update logic
    String _isChange(String type, bool change)
    => change ? type : null;

    // Media list positions
    final HashMap mediaListPosition = HashMap<int, double>();

    // Media filter
    bool _mediaFilterVisible = false;

    bool get mediaFilterVisible
    => _mediaFilterVisible;

    void closeMediaFilter()
    {
        _mediaFilterVisible = false;
    }

    void toggleMediaFilter()
    {
        _mediaFilterVisible = !_mediaFilterVisible;
    }

    bool updateConnection(bool c, ProtoType p)
    {
        setProtoType(p);
        final changed = _connected != c;
        _connected = c;
        if (!isConnected)
        {
            clear();
        }
        else
        {
            _receiverInformation.createDefaultReceiverInfo(protoType);
        }
        return changed;
    }

    bool changeZone(String getId)
    {
        for (int i = 0; i < _receiverInformation.zones.length; i++)
        {
            if (_receiverInformation.zones[i].getId == getId)
            {
                Logging.info(this, "requesting new zone: " + i.toString());
                clear();
                _activeZone = i;
                return true;
            }
        }
        return false;
    }

    String update(ISCPMessage msg)
    {
        // Note: Use zone-independent message CODE here
        // instead od zone-dependent msg.getCode

        // Receiver info
        if (!SKIP_XML_MESSAGES && msg is ReceiverInformationMsg)
        {
            final String changed = _isChange(ReceiverInformationMsg.CODE,
                _receiverInformation.processReceiverInformation(msg));
            if (_mediaListState.isRadioInput)
            {
                _mediaListState.fillRadioPresets(getActiveZone, protoType, _receiverInformation.presetList);
            }
            return changed;
        }
        else if (msg is FriendlyNameMsg)
        {
            return _isChange(FriendlyNameMsg.CODE,
                _receiverInformation.processFriendlyName(msg));
        }
        else if (msg is DeviceNameMsg)
        {
            return _isChange(DeviceNameMsg.CODE,
                _receiverInformation.processDeviceName(msg));
        }
        else if (msg is PowerStatusMsg)
        {
            final String changed = _isChange(PowerStatusMsg.CODE,
                _receiverInformation.processPowerStatus(msg));
            if (changed != null && !isOn)
            {
                _mediaListState.clearItems();
                trackState.clear();
            }
            return changed;
        }
        else if (msg is FirmwareUpdateMsg)
        {
            return _isChange(FirmwareUpdateMsg.CODE,
                _receiverInformation.processFirmwareUpdate(msg));
        }
        else if (msg is GoogleCastVersionMsg)
        {
            return _isChange(GoogleCastVersionMsg.CODE,
                _receiverInformation.processGoogleCastVersion(msg));
        }

        // Device settings
        if (msg is DimmerLevelMsg)
        {
            return _isChange(DimmerLevelMsg.CODE, _deviceSettingsState.processDimmerLevel(msg));
        }
        else if (msg is DigitalFilterMsg)
        {
            return _isChange(DigitalFilterMsg.CODE, _deviceSettingsState.processDigitalFilter(msg));
        }
        else if (msg is MusicOptimizerMsg)
        {
            return _isChange(MusicOptimizerMsg.CODE, _deviceSettingsState.processMusicOptimizer(msg));
        }
        else if (msg is AutoPowerMsg)
        {
            return _isChange(AutoPowerMsg.CODE, _deviceSettingsState.processAutoPower(msg));
        }
        else if (msg is HdmiCecMsg)
        {
            return _isChange(HdmiCecMsg.CODE, _deviceSettingsState.processHdmiCec(msg));
        }
        else if (msg is PhaseMatchingBassMsg)
        {
            return _isChange(PhaseMatchingBassMsg.CODE, _deviceSettingsState.processPhaseMatchingBass(msg));
        }
        else if (msg is SleepSetCommandMsg)
        {
            return _isChange(SleepSetCommandMsg.CODE, _deviceSettingsState.processSleepSet(msg));
        }
        else if (msg is SpeakerACommandMsg)
        {
            return _isChange(SpeakerACommandMsg.CODE, _deviceSettingsState.processSpeakerACommand(msg));
        }
        else if (msg is SpeakerBCommandMsg)
        {
            return _isChange(SpeakerBCommandMsg.CODE, _deviceSettingsState.processSpeakerBCommand(msg));
        }
        else if (msg is GoogleCastAnalyticsMsg)
        {
            return _isChange(GoogleCastAnalyticsMsg.CODE, _deviceSettingsState.processGoogleCastAnalytics(msg));
        }
        else if (msg is LateNightCommandMsg)
        {
            return _isChange(LateNightCommandMsg.CODE, _deviceSettingsState.processLateNightCommand(msg));
        }
        else if (msg is NetworkStandByMsg)
        {
            return _isChange(NetworkStandByMsg.CODE, _deviceSettingsState.processNetworkStandBy(msg));
        }

        // Track info
        if (msg is AlbumNameMsg)
        {
            return _isChange(AlbumNameMsg.CODE, _trackState.processAlbumName(msg));
        }
        else if (msg is ArtistNameMsg)
        {
            return _isChange(ArtistNameMsg.CODE, _trackState.processArtistName(msg));
        }
        else if (msg is TitleNameMsg)
        {
            return _isChange(TitleNameMsg.CODE, _trackState.processTitleName(msg));
        }
        else if (msg is FileFormatMsg)
        {
            return _isChange(FileFormatMsg.CODE, _trackState.processFileFormat(msg));
        }
        else if (msg is TrackInfoMsg)
        {
            return _isChange(TrackInfoMsg.CODE, _trackState.processTrackInfo(msg));
        }
        else if (msg is TimeInfoMsg)
        {
            return _isChange(TimeInfoMsg.CODE, _trackState.processTimeInfo(msg));
        }
        else if (msg is JacketArtMsg)
        {
            return _isChange(JacketArtMsg.CODE, _trackState.processJacketArt(protoType, msg, isOn));
        }
        else if (msg is AudioInformationMsg)
        {
            return _isChange(AudioInformationMsg.CODE, _trackState.processAudioInformation(msg));
        }
        else if (msg is VideoInformationMsg)
        {
            return _isChange(VideoInformationMsg.CODE, _trackState.processVideoInformation(msg));
        }

        // Playback state
        if (msg is PlayStatusMsg)
        {
            return _isChange(PlayStatusMsg.CODE, _playbackState.processPlayStatus(msg));
        }
        else if (msg is MenuStatusMsg)
        {
            return _isChange(MenuStatusMsg.CODE, _playbackState.processMenuStatus(msg));
        }

        // Media list state
        if (msg is InputSelectorMsg)
        {
            final String changed = _isChange(InputSelectorMsg.CODE, _mediaListState.processInputSelector(msg));
            if (_mediaListState.isRadioInput)
            {
                _mediaListState.fillRadioPresets(getActiveZone, protoType, _receiverInformation.presetList);
            }
            else if (_mediaListState.isSimpleInput)
            {
                _trackState.clear();
                _playbackState.clear();
            }
            return changed;
        }
        else if (msg is ListTitleInfoMsg)
        {
            final String changed = _isChange(ListTitleInfoMsg.CODE, _mediaListState.processListTitleInfo(msg));
            if (!_mediaListState.isPopupMode)
            {
                _popupDocument = null;
            }
            return changed;
        }
        else if (!SKIP_XML_MESSAGES && msg is XmlListInfoMsg)
        {
            final String changed = _isChange(XmlListInfoMsg.CODE, _mediaListState.processXmlListInfo(msg));
            if (changed != null && _mediaListState.serviceType.key == ServiceType.PLAYQUEUE)
            {
                // Corner case; receiver does not provide track information for play queue,
                // However, we can obtain this track information from XML media items
                _trackState.processXmlListItem(_mediaListState.mediaItems);
            }
            return changed;
        }
        else if (msg is ListInfoMsg)
        {
            return _isChange(ListInfoMsg.CODE, _mediaListState.processListInfo(msg, _receiverInformation));
        }

        // Sound control
        if (msg is AudioMutingMsg)
        {
            return _isChange(AudioMutingMsg.CODE, _soundControlState.processAudioMuting(msg));
        }
        else if (msg is MasterVolumeMsg)
        {
            return _isChange(MasterVolumeMsg.CODE, _soundControlState.processMasterVolume(msg));
        }
        else if (msg is ToneCommandMsg)
        {
            return _isChange(ToneCommandMsg.CODE, _soundControlState.processToneCommand(msg));
        }
        else if (msg is DirectCommandMsg)
        {
            return _isChange(DirectCommandMsg.CODE, _soundControlState.processDirectCommand(msg));
        }
        else if (msg is SubwooferLevelCommandMsg)
        {
            return _isChange(SubwooferLevelCommandMsg.CODE, _soundControlState.processSubwooferLevelCommand(msg));
        }
        else if (msg is CenterLevelCommandMsg)
        {
            return _isChange(CenterLevelCommandMsg.CODE, _soundControlState.processCenterLevelCommand(msg));
        }
        else if (msg is ListeningModeMsg)
        {
            return _isChange(ListeningModeMsg.CODE, _soundControlState.processListeningMode(msg));
        }
        else if (msg is AllChannelEqMsg)
        {
            return _isChange(AllChannelEqMsg.CODE, _soundControlState.processAllChannelEq(msg));
        }

        // Radio
        if (msg is PresetCommandMsg)
        {
            return _isChange(PresetCommandMsg.CODE, _radioState.processPresetCommand(msg));
        }
        if (msg is TuningCommandMsg)
        {
            return _isChange(TuningCommandMsg.CODE, _radioState.processTuningCommand(msg, _mediaListState));
        }
        if (msg is RadioStationNameMsg)
        {
            return _isChange(RadioStationNameMsg.CODE, _radioState.processDabStationName(msg, _mediaListState));
        }

        // Popup
        if (msg is CustomPopupMsg)
        {
            return _isChange(CustomPopupMsg.CODE, _processCustomPopup(msg));
        }

        // Denon
        if (msg is DcpReceiverInformationMsg)
        {
            final DcpUpdateType upd = _receiverInformation.processDcpReceiverInformation(msg);
            if (upd == DcpUpdateType.NET_TOP)
            {
                Logging.info(this, "    Set network top layer");
                // TODO:
                //_mediaListState.setDcpNetTopLayer();
            }
            return _isChange(DcpReceiverInformationMsg.CODE, upd != null);
        }
        if (msg is DcpTunerModeMsg)
        {
            final String changed = _isChange(DcpTunerModeMsg.CODE, _mediaListState.processDcpTunerModeMsg(msg));
            if (_mediaListState.isRadioInput)
            {
                _mediaListState.fillRadioPresets(getActiveZone, protoType, _receiverInformation.presetList);
            }
            return changed;
        }
        if (msg is DcpEcoModeMsg)
        {
            return _isChange(DcpEcoModeMsg.CODE, _deviceSettingsState.processDcpEcoModeMsg(msg));
        }
        if (msg is DcpAudioRestorerMsg)
        {
            return _isChange(DcpAudioRestorerMsg.CODE, _deviceSettingsState.processDcpAudioRestorerMsg(msg));
        }

        return null;
    }

    Selector get getActualSelector
    => _receiverInformation.deviceSelectors.firstWhere((s) => s.getId == mediaListState.inputType.getCode, orElse: () => null);

    bool get isCdInput
    => (mediaListState.inputType.key == InputSelector.CD) &&
            (_receiverInformation.isControlExists(CdPlayerOperationCommandMsg.CONTROL_CD_INT1) ||
                _receiverInformation.isControlExists(CdPlayerOperationCommandMsg.CONTROL_CD_INT2));

    NetworkService get getNetworkService
    => (_mediaListState.serviceType != null) ? _receiverInformation.getNetworkService(_mediaListState.serviceType.getCode) : null;

    bool _processCustomPopup(CustomPopupMsg msg)
    {
        if (msg.popupDocument.findElements("popup").isNotEmpty &&
            msg.popupDocument.findElements("popup").first != null)
        {
            _popupDocument = msg.popupDocument;
        }
        else
        {
            Logging.info(this, "received a popup with empty content. Ignored.");
        }
        return _popupDocument != null;
    }

    bool isSimplePopupMessage()
    => _popupDocument != null &&
       _popupDocument.findElements("popup").length == 1 &&
       _popupDocument.findAllElements("textboxgroup").isEmpty &&
       _popupDocument.findAllElements("buttongroup").isEmpty &&
       _popupDocument.findAllElements("label").isNotEmpty;

    String retrieveSimplePopupMessage()
    {
        if (isSimplePopupMessage())
        {
            final xml.XmlElement popupElement = _popupDocument.findElements("popup").first;
            String retValue = popupElement.getAttribute("title") + ": ";
            popupElement.findElements("label").forEach((label)
            {
                label.findElements("line").forEach((line) => retValue += line.getAttribute("text"));
            });
            _popupDocument = null;
            return retValue;
        }
        return null;
    }

    String getServiceIcon()
    {
        String serviceIcon = isPlaying? playbackState.serviceIcon.icon : mediaListState.serviceType.icon;
        if (serviceIcon == null)
        {
            serviceIcon = mediaListState.inputType.icon;
            if (mediaListState.inputType.key == InputSelector.DCP_TUNER &&
                mediaListState.dcpTunerMode.key != DcpTunerMode.NONE)
            {
                // Special icon for Denon tuner input
                serviceIcon = mediaListState.dcpTunerMode.icon;
            }
        }
        if (serviceIcon == null)
        {
            serviceIcon = Drawables.media_item_unknown;
        }
        return serviceIcon;
    }

    void clear()
    {
        _receiverInformation.clear();
        _deviceSettingsState.clear();
        _trackState.clear();
        _playbackState.clear();
        _mediaListState.clear();
        _soundControlState.clear();
        _radioState.clear();
        _popupDocument = null;
        mediaListPosition.clear();
    }

    bool get isShortcutPossible
    {
        final bool isMediaList = mediaListState.numberOfLayers > 0 && mediaListState.titleBar.isNotEmpty && mediaListState.serviceType != null;
        return !SKIP_XML_MESSAGES && (isMediaList || mediaListState.isSimpleInput);
    }

}
