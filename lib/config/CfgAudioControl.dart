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

import "package:shared_preferences/shared_preferences.dart";

import "../constants/Strings.dart";
import "../iscp/ConnectionIf.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/EnumParameterMsg.dart";
import "../iscp/messages/ListeningModeMsg.dart";
import "../utils/Convert.dart";
import "../utils/Pair.dart";
import "../utils/Platform.dart";
import "CfgModule.dart";
import "CheckableItem.dart";

enum VolumeUnit
{
    ABSOLUTE,
    RELATIVE
}

class CfgAudioControl extends CfgModule
{
    // Sound control
    static const Pair<String, String> SOUND_CONTROL = Pair<String, String>("sound_control", Strings.pref_sound_control_default);
    String _soundControl = SOUND_CONTROL.item2;

    String get soundControl
    => _soundControl;

    set soundControl(String value)
    {
        _soundControl = value;
        saveStringParameter(SOUND_CONTROL, value);
    }

    // Force audio control
    static const Pair<String, bool> FORCE_AUDIO_CONTROL = Pair<String, bool>("force_audio_control", false);
    bool _forceAudioControl = FORCE_AUDIO_CONTROL.item2;

    bool get isForceAudioControl
    => _forceAudioControl;

    // Volume unit
    static const Pair<String, String> VOLUME_UNIT = Pair<String, String>("volume_unit", "ABSOLUTE");
    VolumeUnit _volumeUnit = VolumeUnit.ABSOLUTE;

    VolumeUnit get volumeUnit
    => _volumeUnit;

    static const Pair<String, String> ZERO_LEVEL = Pair<String, String>("zero_level", "");
    double? _zeroLevel;

    double? get zeroLevel
    => _zeroLevel;

    // Selected listening modes
    static const String _SELECTED_LISTENING_MODES = "selected_listening_modes";

    // Master volume maximum
    static const Pair<String, int> MASTER_VOLUME_MAX = Pair<String, int>("master_volume_max", 9999);
    int _masterVolumeMax = MASTER_VOLUME_MAX.item2;

    int get masterVolumeMax
    => _masterVolumeMax;

    set masterVolumeMax(int value)
    {
        _masterVolumeMax = value;
        saveIntegerParameter(getModelDependentInt(MASTER_VOLUME_MAX), value);
    }

    // Integra modes
    static const List<ListeningMode> _ISCP_LISTENING_MODES = [
        ListeningMode.MODE_0F, // MONO
        ListeningMode.MODE_00, // STEREO
        ListeningMode.MODE_01, // DIRECT
        ListeningMode.MODE_09, // UNPLUGGED
        ListeningMode.MODE_08, // ORCHESTRA
        ListeningMode.MODE_0A, // STUDIO-MIX
        ListeningMode.MODE_11, // PURE AUDIO
        ListeningMode.MODE_13, // FULL MONO
        ListeningMode.MODE_0C, // ALL CH STEREO
        ListeningMode.MODE_0B, // TV Logic
        ListeningMode.MODE_0D, // Theater-Dimensional
        ListeningMode.MODE_40, // DOLBY DIGITAL
        ListeningMode.MODE_80, // DOLBY SURROUND
        ListeningMode.MODE_84, // Dolby THX Cinema
        ListeningMode.MODE_8B, // Dolby THX Music
        ListeningMode.MODE_89, // Dolby THX Games
        ListeningMode.MODE_82, // DTS NEURAL:X
        ListeningMode.MODE_17, // DTS Virtual:X
        ListeningMode.MODE_03, // Game-RPG
        ListeningMode.MODE_05, // Game-Action
        ListeningMode.MODE_06, // Game-Rock
        ListeningMode.MODE_0E  // Game-Sports
    ];

    // Denon modes
    static const List<ListeningMode> _DCP_LISTENING_MODES = [
        ListeningMode.MODE_DCP_DIRECT,
        ListeningMode.MODE_DCP_PURE_DIRECT,
        ListeningMode.MODE_DCP_STEREO,
        ListeningMode.MODE_DCP_ALL_ZONE_STEREO,
        ListeningMode.MODE_DCP_AUTO,
        ListeningMode.MODE_DCP_DOLBY_DIGITAL,
        ListeningMode.MODE_DCP_DTS_SURROUND,
        ListeningMode.MODE_DCP_AURO3D,
        ListeningMode.MODE_DCP_AURO2DSURR,
        ListeningMode.MODE_DCP_MCH_STEREO,
        ListeningMode.MODE_DCP_WIDE_SCREEN,
        ListeningMode.MODE_DCP_SUPER_STADIUM,
        ListeningMode.MODE_DCP_ROCK_ARENA,
        ListeningMode.MODE_DCP_JAZZ_CLUB,
        ListeningMode.MODE_DCP_CLASSIC_CONCERT,
        ListeningMode.MODE_DCP_MONO_MOVIE,
        ListeningMode.MODE_DCP_MATRIX,
        ListeningMode.MODE_DCP_VIDEO_GAME,
        ListeningMode.MODE_DCP_VIRTUAL
    ];

    // Master volume hardware keys
    static const Pair<String, bool> VOLUME_KEYS = Pair<String, bool>("volume_keys", true); // For Android only
    bool _volumeKeys = VOLUME_KEYS.item2;

    bool get volumeKeys
    => _volumeKeys;

    // Zone maximum volume (used to detect external amplifier)
    static const Pair<String, String> ZONE_VOLUME_MAX = Pair<String, String>("zone_volume_max", "");
    final List<int> _zoneVolumeMax = [];

    int zoneVolumeMax(int zone)
    => zone < _zoneVolumeMax.length? _zoneVolumeMax[zone] : 0;

    // methods
    CfgAudioControl(final SharedPreferences preferences) : super(preferences);

    @override
    void read()
    {
        _soundControl = getString(SOUND_CONTROL, doLog: true);
        _forceAudioControl = getBool(FORCE_AUDIO_CONTROL, doLog: true);
        final _volumeUnitStr = getString(VOLUME_UNIT, doLog: true).toUpperCase();
        _volumeUnit = VolumeUnit.values.firstWhere(
                (p) => Convert.enumToString(p).toUpperCase() == _volumeUnitStr,
                orElse: () => VolumeUnit.ABSOLUTE);
        _zeroLevel = double.tryParse(getString(ZERO_LEVEL, doLog: true));
        _volumeKeys = Platform.isAndroid ? getBool(VOLUME_KEYS, doLog: true) : false;
        _zoneVolumeMax.clear();
        getString(ZONE_VOLUME_MAX, doLog: true).split(",").forEach((str) => _zoneVolumeMax.add(int.tryParse(str) ?? 0));
    }

    @override
    void setReceiverInformation(StateManager stateManager)
    {
        _masterVolumeMax = getInt(getModelDependentInt(MASTER_VOLUME_MAX), doLog: true);
        _zoneVolumeMax.clear();
        String volumeZoneMaxStr = "";
        stateManager.state.receiverInformation.zones.forEach((z)
        {
            _zoneVolumeMax.add(z.getVolMax);
            volumeZoneMaxStr += ("," + z.getVolMax.toString());
        });
        saveStringParameter(ZONE_VOLUME_MAX, volumeZoneMaxStr.startsWith(",") ? volumeZoneMaxStr.substring(1) : volumeZoneMaxStr);
    }

    void setVolumeUnit(VolumeUnit volumeUnit, double? zeroValue)
    {
        _volumeUnit = volumeUnit;
        saveStringParameter(VOLUME_UNIT, Convert.enumToString(_volumeUnit), prefix: "  ");
        _zeroLevel = zeroValue;
        saveStringParameter(ZERO_LEVEL, _zeroLevel == null ? "" : _zeroLevel.toString(), prefix: "  ");
    }
    
    List<EnumItem<ListeningMode>> getSortedListeningModes(
        bool allItems, EnumItem<ListeningMode> activeItem, ProtoType protoType)
    {
        final List<EnumItem<ListeningMode>> result = [];
        final List<String> defItems = [];

        getListeningModes(protoType).forEach((m)
        => defItems.add(ListeningModeMsg.ValueEnum.valueByKey(m).getCode));

        final String par = getModelDependentParameter(getSelectedListeningModePar(protoType));
        for (CheckableItem sp in CheckableItem.readFromPreference(this, par, defItems))
        {
            final bool visible = allItems || sp.checked ||
                (activeItem.key != ListeningMode.NONE && activeItem.getCode == sp.code);
            ListeningModeMsg.ValueEnum.values.forEach((m)
            {
                if (visible && ListeningModeMsg.isMode(m.key) && m.key != ListeningMode.NONE && m.getCode == sp.code)
                {
                    result.add(m);
                }
            });
        }
        return result;
    }

    static List<ListeningMode> getListeningModes(ProtoType protoType)
    => (protoType == ProtoType.ISCP) ? _ISCP_LISTENING_MODES : _DCP_LISTENING_MODES;

    static String getSelectedListeningModePar(ProtoType protoType)
    {
        String par = _SELECTED_LISTENING_MODES;
        if (protoType == ProtoType.DCP)
        {
            par += "_DCP";
        }
        return par;
    }
}