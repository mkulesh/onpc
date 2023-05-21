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
import "package:shared_preferences/shared_preferences.dart";

import "../Platform.dart";
import "../constants/Strings.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/EnumParameterMsg.dart";
import "../iscp/messages/ListeningModeMsg.dart";
import "../utils/Pair.dart";
import "CfgModule.dart";
import "CheckableItem.dart";

class CfgAudioControl extends CfgModule
{
    // Sound control
    static const Pair<String, String> SOUND_CONTROL = Pair<String, String>("sound_control", Strings.pref_sound_control_default);
    String _soundControl;

    String get soundControl
    => _soundControl;

    set soundControl(String value)
    {
        _soundControl = value;
        saveStringParameter(SOUND_CONTROL, value);
    }

    // Force audio control
    static const Pair<String, bool> FORCE_AUDIO_CONTROL = Pair<String, bool>("force_audio_control", false);
    bool _forceAudioControl;

    bool get isForceAudioControl
    => _forceAudioControl;

    // Selected listening modes
    static const String SELECTED_LISTENING_MODES = "selected_listening_modes";

    // Master volume maximum
    static const Pair<String, int> MASTER_VOLUME_MAX = Pair<String, int>("master_volume_max", 9999);
    int _masterVolumeMax;

    int get masterVolumeMax
    => _masterVolumeMax;

    set masterVolumeMax(int value)
    {
        _masterVolumeMax = value;
        saveIntegerParameter(getModelDependentInt(MASTER_VOLUME_MAX), value);
    }

    // Default modes
    static const List<ListeningMode> DEFAULT_LISTENING_MODES = [
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

    // Master volume hardware keys
    static const Pair<String, bool> VOLUME_KEYS = Pair<String, bool>("volume_keys", true); // For Android only
    bool _volumeKeys;

    bool get volumeKeys
    => _volumeKeys;

    // methods
    CfgAudioControl(final SharedPreferences preferences) : super(preferences);

    @override
    void read()
    {
        _soundControl = getString(SOUND_CONTROL, doLog: true);
        _forceAudioControl = getBool(FORCE_AUDIO_CONTROL, doLog: true);
        _volumeKeys = Platform.isAndroid ? getBool(VOLUME_KEYS, doLog: true) : false;
    }

    @override
    void setReceiverInformation(StateManager stateManager)
    {
        _masterVolumeMax = getInt(getModelDependentInt(MASTER_VOLUME_MAX), doLog: true);
    }

    List<EnumItem<ListeningMode>> getSortedListeningModes(bool allItems, EnumItem<ListeningMode> activeItem)
    {
        final List<EnumItem<ListeningMode>> result = [];
        final List<String> defItems = [];

        DEFAULT_LISTENING_MODES.forEach((m)
        => defItems.add(ListeningModeMsg.ValueEnum.valueByKey(m).getCode));

        final String par = getModelDependentParameter(SELECTED_LISTENING_MODES);
        for (CheckableItem sp in CheckableItem.readFromPreference(this, par, defItems))
        {
            final bool visible = allItems || sp.checked ||
                (activeItem.key != ListeningMode.NONE && activeItem.getCode == sp.code);
            ListeningModeMsg.ValueEnum.values.forEach((m)
            {
                if (visible && m.key != ListeningMode.NONE && m.getCode == sp.code)
                {
                    result.add(m);
                }
            });
        }
        return result;
    }
}