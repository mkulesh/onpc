/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2025 by Mikhail Kulesh
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

import "../../config/CfgAudioControl.dart";
import "../../utils/Logging.dart";
import "../ConnectionIf.dart";
import "../messages/AllChannelEqualizerMsg.dart";
import "../messages/AllChannelLevelMsg.dart";
import "../messages/AllChannelMsg.dart";
import "../messages/AudioBalanceMsg.dart";
import "../messages/AudioMutingMsg.dart";
import "../messages/CenterLevelCommandMsg.dart";
import "../messages/DcpAllZoneStereoMsg.dart";
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
    DEVICE_BTN_AROUND_SLIDER,
    DEVICE_BTN_ABOVE_SLIDER,
    RI_AMP,
    NONE
}

class SoundControlState
{
    static const double DEF_VOL_MAX = 82.0;
    static const bool EQUALIZER_ALWAYS_AVAILABLE = false;
    static const bool CHANNEL_LEVEL_ALWAYS_AVAILABLE = false;

    // Audio muting
    late EnumItem<AudioMuting> _audioMuting;

    EnumItem<AudioMuting> get audioMuting
    => _audioMuting;

    // Master volume
    late int _volumeLevel;

    int get volumeLevel
    => _volumeLevel;

    // Tone
    late int _bassLevel;

    int get bassLevel
    => _bassLevel;

    late int _trebleLevel;

    int get trebleLevel
    => _trebleLevel;

    late EnumItem<DirectCommand> _toneDirect;

    EnumItem<DirectCommand> get toneDirect
    => _toneDirect;

    // Levels
    late int _subwooferLevel;

    int get subwooferLevel
    => _subwooferLevel;

    late int _subwooferCmdLength;

    int get subwooferCmdLength
    => _subwooferCmdLength;

    late int _centerLevel;

    int get centerLevel
    => _centerLevel;

    late int _centerCmdLength;

    int get centerCmdLength
    => _centerCmdLength;

    // Listening mode
    late EnumItem<ListeningMode> _listeningMode = ListeningModeMsg.ValueEnum.defValue;

    EnumItem<ListeningMode> get listeningMode
    => _listeningMode;

    // All Channel EQ
    final List<int> _equalizerValues = [
        AllChannelMsg.NO_LEVEL,
        AllChannelMsg.NO_LEVEL,
        AllChannelMsg.NO_LEVEL,
        AllChannelMsg.NO_LEVEL,
        AllChannelMsg.NO_LEVEL,
        AllChannelMsg.NO_LEVEL,
        AllChannelMsg.NO_LEVEL,
        AllChannelMsg.NO_LEVEL,
        AllChannelMsg.NO_LEVEL
    ];

    List<int> get equalizerValues
    => _equalizerValues;

    // Channel levels
    final List<int> _channelLevelValues = [
        AllChannelMsg.NO_LEVEL, // Front L
        AllChannelMsg.NO_LEVEL, // Front R
        AllChannelMsg.NO_LEVEL, // Center
        AllChannelMsg.NO_LEVEL, // Surr. L
        AllChannelMsg.NO_LEVEL, // Surr. R
        AllChannelMsg.NO_LEVEL, // Surr. Back L
        AllChannelMsg.NO_LEVEL, // Surr. Back R
        AllChannelMsg.NO_LEVEL, // Subwoofer 1
        AllChannelMsg.NO_LEVEL, // Height 1 L
        AllChannelMsg.NO_LEVEL, // Height 1 R
        AllChannelMsg.NO_LEVEL, // Height 2 L
        AllChannelMsg.NO_LEVEL, // Height 2 R
        AllChannelMsg.NO_LEVEL, // Subwoofer 2
    ];

    List<int> get channelLevelValues
    => _channelLevelValues;

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

    // Audio balance
    late int _balance;

    int get balance
    => _balance;

    // Data processing
    SoundControlState()
    {
        clear();
    }

    List<String> getQueriesIscp(int zone, final ReceiverInformation ri)
    {
        Logging.info(this, "Requesting ISCP data for zone " + zone.toString() + "...");
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

        if (ri.model != "TX-NR646")
        {
            // #216 TX-NR646: listening mode information is sometime missing
            // It seems to be AllChannelEq requests stops the receiver to answer ListeningMode request
            cmd.add(AllChannelEqualizerMsg.CODE);
        }

        if (ri.isPioneer)
        {
            cmd.add(AllChannelLevelMsg.CODE);
        }

        return cmd;
    }

    List<String> getQueriesDcp(int zone, final ReceiverInformation ri)
    {
        Logging.info(this, "Requesting DCP data for zone " + zone.toString() + "...");
        final List<String> cmd = [
            AudioMutingMsg.ZONE_COMMANDS[zone],
            MasterVolumeMsg.ZONE_COMMANDS[zone],
            ListeningModeMsg.CODE,
            AudioBalanceMsg.CODE,
            AllChannelLevelMsg.CODE
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
        _balance = AudioBalanceMsg.NO_LEVEL;
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
        if (msg.isTonJoined)
        {
            _bassLevel = msg.getBassLevel;
            _trebleLevel = msg.getTrebleLevel;
        }
        else
        {
            if (msg.getBassLevel != ToneCommandMsg.NO_LEVEL)
            {
                _bassLevel = msg.getBassLevel;
            }
            if (msg.getTrebleLevel != ToneCommandMsg.NO_LEVEL)
            {
                _trebleLevel = msg.getTrebleLevel;
            }
        }
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

    bool processAudioBalance(AudioBalanceMsg msg)
    {
        final bool changed = _balance != msg.getValue;
        _balance = msg.getValue;
        return changed;
    }

    bool processAllChannelEqualizer(AllChannelEqualizerMsg msg)
    {
        bool changed = false;
        for (int i = 0; i < min(_equalizerValues.length, AllChannelEqualizerMsg.CHANNELS.length); i++)
        {
            if (_equalizerValues[i] != msg.values[i])
            {
                changed = true;
                _equalizerValues[i] = msg.values[i];
            }
        }
        return changed;
    }

    bool processAllChannelLevel(AllChannelLevelMsg msg)
    {
        bool changed = false;
        if (msg.valueIdx < 0)
        {
            for (int i = 0; i < min(_channelLevelValues.length, AllChannelLevelMsg.CHANNELS.length); i++)
            {
                if (_channelLevelValues[i] != msg.values[i])
                {
                    changed = true;
                    _channelLevelValues[i] = msg.values[i];
                }
            }
        }
        else if (msg.valueIdx < _channelLevelValues.length)
        {
            changed = _channelLevelValues[msg.valueIdx] != msg.values[msg.valueIdx];
            _channelLevelValues[msg.valueIdx] = msg.values[msg.valueIdx];
        }
        return changed;
    }

    static String getVolumeLevelStr(int volumeLevel, Zone? zone)
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

    static String getRelativeLevelStr(int volumeLevel, Zone? zone, final CfgAudioControl audioControl)
    {
        final double zeroLevel = (audioControl.zeroLevel != null) ? audioControl.zeroLevel! :
            ((zone != null && zone.zeroDbLevelOrVolMax() > 0) ? zone.zeroDbLevelOrVolMax() : DEF_VOL_MAX);
        final bool doubleStep = zone != null && zone.getVolumeStep == 0;
        final double val = doubleStep ? (volumeLevel / 2.0 - zeroLevel) : (volumeLevel - zeroLevel);
        //Logging.info(audioControl, "relative level: zeroLevel=" + zeroLevel.toString()
        //    + ", volumeLevel=" + volumeLevel.toString()
        //    + ", doubleStep=" + doubleStep.toString()
        //    + ", val=" + val.toString()
        //);
        return sprintf("%1.1f dB", [val]);
    }

    bool get isDirectListeningMode
    => [
            ListeningMode.MODE_01,
            ListeningMode.MODE_11,
            ListeningMode.MODE_DCP_DIRECT,
            ListeningMode.MODE_DCP_PURE_DIRECT
        ].contains(_listeningMode.key);

    static SoundControlType soundControlType(final CfgAudioControl audioControl, int zone)
    {
        switch (audioControl.soundControl)
        {
            case "auto":
                return (audioControl.zoneVolumeMax(zone) == 0) ? SoundControlType.RI_AMP : SoundControlType.DEVICE_SLIDER;
            case "device":
                return SoundControlType.DEVICE_BUTTONS;
            case "device-slider":
                return SoundControlType.DEVICE_SLIDER;
            case "device-btn-slider":
                return SoundControlType.DEVICE_BTN_AROUND_SLIDER;
            case "device-btn-above-slider":
                return SoundControlType.DEVICE_BTN_ABOVE_SLIDER;
            case "external-amplifier":
                return SoundControlType.RI_AMP;
            default:
                return SoundControlType.NONE;
        }
    }

    int getVolumeMax(final Zone? zoneInfo)
    {
        final int scale = (zoneInfo != null && zoneInfo.getVolumeStep == 0) ? 2 : 1;
        return (zoneInfo != null && zoneInfo.getVolMax > 0) ?
            scale * zoneInfo.getVolMax :
            max(volumeLevel, scale * MasterVolumeMsg.MAX_VOLUME_1_STEP);
    }

    bool get isEqualizerAvailable
    => EQUALIZER_ALWAYS_AVAILABLE || _equalizerValues.every((e) => e != AllChannelMsg.NO_LEVEL);

    bool isChannelLevelAvailable(ProtoType protoType)
    {
        if (protoType == ProtoType.ISCP)
        {
            return CHANNEL_LEVEL_ALWAYS_AVAILABLE || _channelLevelValues.every((e) => e != AllChannelMsg.NO_LEVEL);
        }
        return CHANNEL_LEVEL_ALWAYS_AVAILABLE || _channelLevelValues.any((e) => e != AllChannelMsg.NO_LEVEL);
    }

    DcpAllZoneStereoMsg? toggleAllZoneStereo(EnumItem<ListeningMode>? m)
    {
        if (m != null)
        {
            if (_listeningMode.key == ListeningMode.MODE_DCP_ALL_ZONE_STEREO &&
                m.key != ListeningMode.MODE_DCP_ALL_ZONE_STEREO)
            {
                Logging.info(this, "Switch OFF all zone stereo");
                return DcpAllZoneStereoMsg.output(DcpAllZoneStereo.OFF);
            }
            else if (_listeningMode.key != ListeningMode.MODE_DCP_ALL_ZONE_STEREO &&
                m.key == ListeningMode.MODE_DCP_ALL_ZONE_STEREO)
            {
                Logging.info(this, "Switch ON all zone stereo");
                return DcpAllZoneStereoMsg.output(DcpAllZoneStereo.ON);
            }
        }
        return null;
    }
}