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

import "dart:math";

import "package:sprintf/sprintf.dart";

import "../../utils/Logging.dart";
import "../messages/AudioMutingMsg.dart";
import "../messages/CenterLevelCommandMsg.dart";
import "../messages/DirectCommandMsg.dart";
import "../messages/EnumParameterMsg.dart";
import "../messages/ListeningModeMsg.dart";
import "../messages/MasterVolumeMsg.dart";
import "../messages/ReceiverInformationMsg.dart";
import "../messages/SubwooferLevelCommandMsg.dart";
import "../messages/ToneCommandMsg.dart";
import "ReceiverInformation.dart";

enum SoundControlType
{
    DEVICE_BUTTONS,
    DEVICE_SLIDER,
    DEVICE_BTN_SLIDER,
    RI_AMP,
    NONE
}

class SoundControlState
{
    // Audio muting
    EnumItem<AudioMuting> _audioMuting;

    EnumItem<AudioMuting> get audioMuting
    => _audioMuting;

    // Master volume
    int _volumeLevel;

    int get volumeLevel
    => _volumeLevel;

    // Tone
    int _bassLevel;

    int get bassLevel
    => _bassLevel;

    int _trebleLevel;

    int get trebleLevel
    => _trebleLevel;

    EnumItem<DirectCommand> _toneDirect;

    EnumItem<DirectCommand> get toneDirect
    => _toneDirect;

    // Levels
    int _subwooferLevel;

    int get subwooferLevel
    => _subwooferLevel;

    int _subwooferCmdLength;

    int get subwooferCmdLength
    => _subwooferCmdLength;

    int _centerLevel;

    int get centerLevel
    => _centerLevel;

    int _centerCmdLength;

    int get centerCmdLength
    => _centerCmdLength;

    // Listening mode
    EnumItem<ListeningMode> _listeningMode;

    EnumItem<ListeningMode> get listeningMode
    => _listeningMode;

    // Force audio control
    bool _forceAudioControl = false;

    set forceAudioControl(bool value)
    {
        _forceAudioControl = value;
        if (value)
        {
            _volumeLevel = _volumeLevel == MasterVolumeMsg.NO_LEVEL ? 0 : _volumeLevel;
            _bassLevel = _bassLevel == ToneCommandMsg.NO_LEVEL ? 0 : _bassLevel;
            _trebleLevel = _trebleLevel == ToneCommandMsg.NO_LEVEL ? 0 : _trebleLevel;
        }
    }

    SoundControlState()
    {
        clear();
    }

    List<String> getQueries(int zone, final ReceiverInformation ri)
    {
        Logging.info(this, "Requesting data for zone " + zone.toString() + "...");
        final List<String> cmd = [
            AudioMutingMsg.ZONE_COMMANDS[zone],
            MasterVolumeMsg.ZONE_COMMANDS[zone],
            SubwooferLevelCommandMsg.CODE,
            CenterLevelCommandMsg.CODE,
            ListeningModeMsg.CODE,
            DirectCommandMsg.CODE
        ];

        if (zone < ToneCommandMsg.ZONE_COMMANDS.length)
        {
            cmd.add(ToneCommandMsg.ZONE_COMMANDS[zone]);
        }

        return cmd;
    }

    void clear()
    {
        _audioMuting = AudioMutingMsg.ValueEnum.defValue;
        _volumeLevel = _forceAudioControl ? 0 : MasterVolumeMsg.NO_LEVEL;
        _bassLevel = _forceAudioControl ? 0 : ToneCommandMsg.NO_LEVEL;
        _trebleLevel = _forceAudioControl ? 0 : ToneCommandMsg.NO_LEVEL;
        _toneDirect = DirectCommandMsg.ValueEnum.defValue;
        _subwooferLevel = SubwooferLevelCommandMsg.NO_LEVEL;
        _subwooferCmdLength = SubwooferLevelCommandMsg.NO_LEVEL;
        _centerLevel = CenterLevelCommandMsg.NO_LEVEL;
        _centerCmdLength = CenterLevelCommandMsg.NO_LEVEL;
        _listeningMode = ListeningModeMsg.ValueEnum.defValue;
    }

    bool processAudioMuting(AudioMutingMsg msg)
    {
        final bool changed = _audioMuting.key != msg.getValue.key;
        _audioMuting = msg.getValue;
        return changed;
    }

    bool processMasterVolume(MasterVolumeMsg msg)
    {
        final bool changed = _volumeLevel != msg.getVolumeLevel;
        if (msg.getVolumeLevel != MasterVolumeMsg.NO_LEVEL)
        {
            // Do not overwrite a valid value with an invalid value
            _volumeLevel = msg.getVolumeLevel;
        }
        return changed;
    }

    bool processToneCommand(ToneCommandMsg msg)
    {
        final bool changed =
            (msg.getBassLevel != ToneCommandMsg.NO_LEVEL && _bassLevel != msg.getBassLevel) ||
                (msg.getTrebleLevel != ToneCommandMsg.NO_LEVEL && _trebleLevel != msg.getTrebleLevel);
        _bassLevel = msg.getBassLevel;
        _trebleLevel = msg.getTrebleLevel;
        return changed;
    }

    bool processDirectCommand(DirectCommandMsg msg)
    {
        final bool changed = _toneDirect.key != msg.getValue.key;
        _toneDirect = msg.getValue;
        return changed;
    }

    bool processSubwooferLevelCommand(SubwooferLevelCommandMsg msg)
    {
        final bool changed = _subwooferLevel != msg.getLevel;
        if (msg.getLevel != SubwooferLevelCommandMsg.NO_LEVEL)
        {
            // Do not overwrite a valid value with an invalid value
            _subwooferLevel = msg.getLevel;
            _subwooferCmdLength = msg.getCmdLength;
        }
        return changed;
    }

    bool processCenterLevelCommand(CenterLevelCommandMsg msg)
    {
        final bool changed = _centerLevel != msg.getLevel;
        if (msg.getLevel != CenterLevelCommandMsg.NO_LEVEL)
        {
            // Do not overwrite a valid value with an invalid value
            _centerLevel = msg.getLevel;
            _centerCmdLength = msg.getCmdLength;
        }
        return changed;
    }

    bool processListeningMode(ListeningModeMsg msg)
    {
        final bool changed = _listeningMode.key != msg.getValue.key;
        _listeningMode = msg.getValue;
        return changed;
    }

    static String getVolumeLevelStr(int volumeLevel, Zone zone)
    {
        if (zone != null && zone.getVolumeStep == 0)
        {
            return sprintf("%1.1f", [volumeLevel / 2.0]);
        }
        else
        {
            return volumeLevel.toString();
        }
    }

    bool get isDirectListeningMode
    => _listeningMode != null && [ListeningMode.MODE_01, ListeningMode.MODE_11].contains(_listeningMode.key);

    SoundControlType soundControlType(final String config, Zone zone)
    {
        switch (config)
        {
            case "auto":
                return (zone != null && zone.getVolMax == 0) ? SoundControlType.RI_AMP : SoundControlType.DEVICE_SLIDER;
            case "device":
                return SoundControlType.DEVICE_BUTTONS;
            case "device-slider":
                return SoundControlType.DEVICE_SLIDER;
            case "device-btn-slider":
                return SoundControlType.DEVICE_BTN_SLIDER;
            case "external-amplifier":
                return SoundControlType.RI_AMP;
            default:
                return SoundControlType.NONE;
        }
    }

    int getVolumeMax(final Zone zoneInfo)
    {
        final int scale = (zoneInfo != null && zoneInfo.getVolumeStep == 0) ? 2 : 1;
        return (zoneInfo != null && zoneInfo.getVolMax > 0) ?
            scale * zoneInfo.getVolMax :
            max(volumeLevel, scale * MasterVolumeMsg.MAX_VOLUME_1_STEP);
    }
}