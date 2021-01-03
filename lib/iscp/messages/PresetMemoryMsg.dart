/*
 * Enhanced Controller for Onkyo and Pioneer Pro
 * Copyright (C) 2019-2021 by Mikhail Kulesh
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

import "../EISCPMessage.dart";
import "../ISCPMessage.dart";

/*
 * Preset Memory Command (Include Tuner Pack Model Only)
 * sets Preset No. 1 - 40 (In hexadecimal representation)
 */
class PresetMemoryMsg extends ISCPMessage
{
    static const String CODE = "PRM";
    static const int MAX_NUMBER = 40;
    static const int NO_PRESET = -1;

    int _preset;

    PresetMemoryMsg(EISCPMessage raw) : super(CODE, raw)
    {
        _preset = ISCPMessage.nonNullInteger(getData, 16, NO_PRESET);
    }

    PresetMemoryMsg.outputCmd(final int preset) : super.output(CODE, _getParameterAsString(preset))
    {
        _preset = preset;
    }

    int get preset
    => _preset;

    static String _getParameterAsString(final int preset)
    {
        return preset.toRadixString(16).padLeft(2, '0');
    }

    @override
    String toString()
    => super.toString() + "[PRESET=" + _preset.toString() + "]";

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }
}
