/*
 * Copyright (C) 2020. Mikhail Kulesh
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

import "package:onpc/iscp/messages/EnumParameterMsg.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../constants/Strings.dart";
import "../iscp/messages/ListeningModeMsg.dart";
import "../iscp/StateManager.dart";
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
        ListeningMode.MODE_00, // STEREO
        ListeningMode.MODE_01, // DIRECT
        ListeningMode.MODE_09, // UNPLUGGED
        ListeningMode.MODE_08, // ORCHESTRA
        ListeningMode.MODE_0A, // STUDIO-MIX
        ListeningMode.MODE_11, // PURE AUDIO
        ListeningMode.MODE_0C, // ALL CH STEREO
        ListeningMode.MODE_40, // DOLBY DIGITAL
        ListeningMode.MODE_80, // DOLBY SURROUND
        ListeningMode.MODE_82  // DTS NEURAL:X
    ];

    // methods
    CfgAudioControl(final SharedPreferences preferences) : super(preferences);

    void read()
    {
        _soundControl = getString(SOUND_CONTROL, doLog: true);
        _forceAudioControl = getBool(FORCE_AUDIO_CONTROL, doLog: true);
    }

    void setReceiverInformation(StateManager stateManager)
    {
        _masterVolumeMax = getInt(getModelDependentInt(MASTER_VOLUME_MAX), doLog: true);
    }

    List<EnumItem<ListeningMode>> getSortedListeningModes(bool allItems, EnumItem<ListeningMode> activeItem)
    {
        final List<EnumItem<ListeningMode>> result = List();
        final List<String> defItems = List();

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