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

import 'package:sprintf/sprintf.dart';

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

    late int _preset;

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

    /*
     * Denon control protocol
     */
    static const String _DCP_COMMAND = "OPTPSTUNER";

    static List<String> getAcceptedDcpCodes()
    => [ _DCP_COMMAND ];

    static PresetMemoryMsg? processDcpMessage(String dcpMsg)
    {
        if (dcpMsg.startsWith(_DCP_COMMAND))
        {
            final String par = dcpMsg.substring(_DCP_COMMAND.length).trim();
            final List<String> pars = par.split(" ");
            if (pars.length > 1)
            {
                final int? preset = int.tryParse(pars.first);
                if (preset != null)
                {
                    return PresetMemoryMsg.outputCmd(preset);
                }
            }
        }
        return null;
    }

    @override
    String? buildDcpMsg(bool isQuery)
    {
        // For some reason, TPANMEM does not work for DAB stations:
        // return "TPANMEM" + (isQuery ? ISCPMessage.DCP_MSG_REQ : String.format("%02d", preset));
        // Use APP_COMMAND instead:
        return sprintf("<cmd id=\"1\">SetTunerPresetMemory</cmd><presetno>%d</presetno>",  [ preset ]);
    }
}
