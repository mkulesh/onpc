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

import 'package:sprintf/sprintf.dart';

import "../../utils/Logging.dart";
import "../messages/AudioMutingMsg.dart";
import "../messages/CenterLevelCommandMsg.dart";
import "../messages/EnumParameterMsg.dart";
import "../messages/ListeningModeMsg.dart";
import "../messages/MasterVolumeMsg.dart";
import "../messages/ReceiverInformationMsg.dart";
import "../messages/SubwooferLevelCommandMsg.dart";
import "../messages/ToneCommandMsg.dart";

enum SoundControlType
{
    DEVICE,
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

    // Levels
    int _subwooferLevel;

    int get subwooferLevel
    => _subwooferLevel;

    int _centerLevel;

    int get centerLevel
    => _centerLevel;

    // Listening mode
    EnumItem<ListeningMode> _listeningMode;

    EnumItem<ListeningMode> get listeningMode
    => _listeningMode;

    SoundControlState()
    {
        clear();
    }

    List<String> getQueries(int zone)
    {
        Logging.info(this, "Requesting data for zone " + zone.toString() + "...");
        final List<String> cmd = [
            AudioMutingMsg.ZONE_COMMANDS[zone],
            MasterVolumeMsg.ZONE_COMMANDS[zone],
            SubwooferLevelCommandMsg.CODE,
            CenterLevelCommandMsg.CODE,
            ListeningModeMsg.CODE
        ];

        if (zone < ToneCommandMsg.ZONE_COMMANDS.length)
        {
            cmd.add(ToneCommandMsg.ZONE_COMMANDS[zone]);
        }
        return cmd;
    }

    clear()
    {
        _audioMuting = AudioMutingMsg.ValueEnum.defValue;
        _volumeLevel = MasterVolumeMsg.NO_LEVEL;
        _bassLevel = ToneCommandMsg.NO_LEVEL;
        _trebleLevel = ToneCommandMsg.NO_LEVEL;
        _subwooferLevel = SubwooferLevelCommandMsg.NO_LEVEL;
        _centerLevel = CenterLevelCommandMsg.NO_LEVEL;
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
        _volumeLevel = msg.getVolumeLevel;
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

    bool processSubwooferLevelCommand(SubwooferLevelCommandMsg msg)
    {
        final bool changed = _subwooferLevel != msg.getLevel;
        _subwooferLevel = msg.getLevel;
        return changed;
    }

    bool processCenterLevelCommand(CenterLevelCommandMsg msg)
    {
        final bool changed = _centerLevel != msg.getLevel;
        _centerLevel = msg.getLevel;
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
                return (zone != null && zone.getVolMax == 0) ? SoundControlType.RI_AMP : SoundControlType.DEVICE;
            case "device":
                return SoundControlType.DEVICE;
            case "external-amplifier":
                return SoundControlType.RI_AMP;
            default:
                return SoundControlType.NONE;
        }
    }
}