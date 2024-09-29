/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2024 by Mikhail Kulesh
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

enum VideoInformationUpd
{
    ALL,
    DCP_INPUT,
    DCP_OUTPUT
}

/*
 * Video Information Command message
 */
class VideoInformationMsg extends ISCPMessage
{
    static const String CODE = "IFV";

    final VideoInformationUpd _updateType;

    VideoInformationUpd get updateType => _updateType;

    /*
     * Information of Video(Same Immediate Display ',' is separator of informations)
     * a…a: Video Input Port
     * b…b: Input Resolution, Frame Rate
     * c…c: RGB/YCbCr
     * d…d: Color Depth
     * e…e: Video Output Port
     * f…f: Output Resolution, Frame Rate
     * g…g: RGB/YCbCr
     * h…h: Color Depth
     * i...i: Picture Mode
     */
    late String _videoInput, _videoOutput;

    VideoInformationMsg(EISCPMessage raw) :
            _updateType = VideoInformationUpd.ALL, super(CODE, raw)
    {
        final List<String> pars = getData.split(ISCPMessage.COMMA_SEP);
        _videoInput = getTags(pars, 0, 4);
        _videoOutput = getTags(pars, 4, pars.length);
    }

    VideoInformationMsg.dcpInput(String _videoInput) :
            _updateType = VideoInformationUpd.DCP_INPUT, super.output(CODE, "")
    {
        this._videoInput = _videoInput;
        this._videoOutput = "";
    }

    VideoInformationMsg.dcpOutput(String _videoOutput) :
            _updateType = VideoInformationUpd.DCP_OUTPUT, super.output(CODE, "")
    {
        this._videoInput = "";
        this._videoOutput = _videoOutput;
    }

    String get videoInput
    => _videoInput;

    String get videoOutput
    => _videoOutput;

    @override
    String toString()
    => super.toString() + "[IN=" + _videoInput + "; OUT=" + _videoOutput + "]";

    /*
     * Denon control protocol
     */
    static const String _DCP_COMMAND_INPUT = "SSINFSIGRES";

    static List<String> getAcceptedDcpCodes()
    => [ _DCP_COMMAND_INPUT ];

    static VideoInformationMsg? processDcpMessage(String dcpMsg)
    {
        if (dcpMsg.startsWith(_DCP_COMMAND_INPUT))
        {
            final String par = dcpMsg.substring(_DCP_COMMAND_INPUT.length).trim();
            if (par.startsWith("I"))
            {
                return VideoInformationMsg.dcpInput(par.substring(1));
            }
            if (par.startsWith("O"))
            {
                return VideoInformationMsg.dcpOutput(par.substring(1));
            }
        }
        return null;
    }

    @override
    String? buildDcpMsg(bool isQuery)
    => _DCP_COMMAND_INPUT + " " + ISCPMessage.DCP_MSG_REQ;
}
