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

import "../../constants/Strings.dart";
import "../../utils/Logging.dart";
import '../ISCPMessage.dart';
import "../messages/InputSelectorMsg.dart";
import "../messages/PresetCommandMsg.dart";
import "../messages/TuningCommandMsg.dart";

class RadioState
{
    // from PresetCommandMsg
    int _preset;

    int get preset
    => _preset;

    // From TuningCommandMsg
    String _frequency;

    String get frequency
    => _frequency;

    RadioState()
    {
        clear();
    }

    List<String> getQueries(int zone)
    {
        Logging.info(this, "Requesting data for zone " + zone.toString() + "...");
        return [
            PresetCommandMsg.ZONE_COMMANDS[zone],
            TuningCommandMsg.ZONE_COMMANDS[zone],
        ];
    }

    void clear()
    {
        _preset = PresetCommandMsg.NO_PRESET;
        _frequency = "";
    }

    bool processPresetCommand(PresetCommandMsg msg)
    {
        final bool changed = _preset != msg.getPreset;
        _preset = msg.getPreset;
        return changed;
    }

    bool processTuningCommand(TuningCommandMsg msg)
    {
        final bool changed = _frequency != msg.getFrequency;
        _frequency = msg.getFrequency;
        return changed;
    }

    String getFrequencyInfo(InputSelector inputType)
    {
        if (inputType != InputSelector.FM)
        {
            return frequency;
        }
        final int freqInt = ISCPMessage.nonNullInteger(frequency, 10, -1);
        return (freqInt < 0) ? Strings.dashed_string : sprintf("%0.00f MHz", [freqInt / 100.0]);
    }
}