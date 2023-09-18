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

import "../../utils/Convert.dart";
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";
import "DcpTunerModeMsg.dart";

/*
 * DAB/FM Station Name (UTF-8)
 */
class RadioStationNameMsg extends ISCPMessage
{
    static const String CODE = "DSN";

    DcpTunerMode _dcpTunerMode;

    RadioStationNameMsg(EISCPMessage raw) : super(CODE, raw)
    {
        // For ISCP, station name is only available for DAB
        _dcpTunerMode = DcpTunerMode.DAB;
    }

    RadioStationNameMsg.output(String name, DcpTunerMode dcpTunerMode) : super.output(CODE, name)
    {
        _dcpTunerMode = dcpTunerMode;
    }

    DcpTunerMode get getDcpTunerMode
    => _dcpTunerMode;

    @override
    String toString()
    => super.toString() + "[MODE=" + Convert.enumToString(_dcpTunerMode.toString()) + "]";

    /*
     * Denon control protocol
     */
    static const String _DCP_COMMAND_FM = "TFANNAME";
    static const String _DCP_COMMAND_DAB = "DA";
    static const String _DCP_COMMAND_DAB_EXT = "STN";

    static List<String> getAcceptedDcpCodes()
    => [ _DCP_COMMAND_FM, _DCP_COMMAND_DAB + _DCP_COMMAND_DAB_EXT];

    static RadioStationNameMsg? processDcpMessage(String dcpMsg)
    {
        if (dcpMsg.startsWith(_DCP_COMMAND_FM))
        {
            final String par = dcpMsg.substring(_DCP_COMMAND_FM.length).trim();
            return RadioStationNameMsg.output(par, DcpTunerMode.FM);
        }
        if (dcpMsg.startsWith(_DCP_COMMAND_DAB + _DCP_COMMAND_DAB_EXT))
        {
            final String par = dcpMsg.substring((_DCP_COMMAND_DAB + _DCP_COMMAND_DAB_EXT).length).trim();
            return RadioStationNameMsg.output(par, DcpTunerMode.DAB);
        }
        return null;
    }

    @override
    String? buildDcpMsg(bool isQuery)
    {
        final String fmReq = _DCP_COMMAND_FM + ISCPMessage.DCP_MSG_REQ;
        final String dabReq = _DCP_COMMAND_DAB + " " + ISCPMessage.DCP_MSG_REQ;
        return fmReq + ISCPMessage.DCP_MSG_SEP + dabReq;
    }
}
