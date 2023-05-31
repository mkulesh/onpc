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
import "../../constants/Strings.dart";
import "../../utils/Logging.dart";
import "../ISCPMessage.dart";
import "../messages/InputSelectorMsg.dart";
import "../messages/PresetCommandMsg.dart";
import "../messages/RadioStationNameMsg.dart";
import "../messages/TuningCommandMsg.dart";
import "MediaListState.dart";

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

    // From DabStationNameMsg
    String _stationName;

    String get stationName
    => _stationName;

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
            RadioStationNameMsg.CODE
        ];
    }

    void clear()
    {
        _preset = PresetCommandMsg.NO_PRESET;
        _frequency = "";
        _stationName = "";
    }

    bool processPresetCommand(PresetCommandMsg msg)
    {
        final bool changed = _preset != msg.getPreset;
        _preset = msg.getPreset;
        return changed;
    }

    bool processTuningCommand(TuningCommandMsg msg, MediaListState ms)
    {
        final bool changed = _frequency != msg.getFrequency;
        if (ms.inputType.key != InputSelector.DCP_TUNER)
        {
            _frequency = msg.getFrequency;
            if (!ms.isDAB)
            {
                // For ISCP, station name is only available for DAB
                _stationName = "";
            }
            return changed;
        }
        else if (ms.dcpTunerMode.key == msg.getDcpTunerMode)
        {
            _frequency = msg.getFrequency;
            return changed;
        }
        return false;
    }

    bool processDabStationName(RadioStationNameMsg msg, MediaListState ms)
    {
        final bool changed = msg.getData != _stationName;
        if (ms.inputType.key != InputSelector.DCP_TUNER)
        {
            // For ISCP, station name is only available for DAB
            _stationName = ms.isDAB ? msg.getData : "";
            return changed;
        }
        else if (ms.dcpTunerMode.key == msg.getDcpTunerMode)
        {
            _stationName = msg.getData;
            return changed;
        }
        return false;
    }

    String getFrequencyInfo(MediaListState ms)
    {
        final String dashedString = Strings.dashed_string;
        if (_frequency == null)
        {
            return dashedString;
        }
        if (ms.isFM)
        {
            final int freqInt = ISCPMessage.nonNullInteger(frequency, 10, -1);
            final double freqDbl = freqInt.toDouble() / 100.0;
            return (freqInt < 0) ? Strings.dashed_string : freqDbl.toStringAsFixed(2) + " MHz";
        }
        if (ms.isDAB)
        {
            final String freq1 = !frequency.contains(":") && frequency.length > 2 ?
            _frequency.substring(0, 2) + ":" + frequency.substring(2) : frequency;
            return freq1.isNotEmpty && !freq1.contains("MHz") ? freq1 + "MHz" : freq1;
        }
        return _frequency;
    }
}