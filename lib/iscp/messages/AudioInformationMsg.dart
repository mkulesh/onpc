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

enum AudioInformationUpd
{
    ALL,
    DCP_FORMAT,
    DCP_FREQ
}

/*
 * Audio Information Command message
 */
class AudioInformationMsg extends ISCPMessage
{
    static const String CODE = "IFA";

    final AudioInformationUpd _updateType;

    AudioInformationUpd get updateType => _updateType;

    /*
     * Information of Audio(Same Immediate Display ',' is separator of informations)
     * a...a: Audio Input Port
     * b…b: Input Signal Format
     * c…c: Sampling Frequency
     * d…d: Input Signal Channel
     * e…e: Listening Mode
     * f…f: Output Signal Channel
     * g…g: Output Sampling Frequency
     * h...h: PQLS (Off/2ch/Multich/Bitstream)
     * i...i: Auto Phase Control Current Delay (0ms - 16ms / ---)
     * j...j: Auto Phase Control Phase (Normal/Reverse)
     * k...k: Upmix Mode(No/PL2/PL2X/PL2Z/DolbySurround/Neo6/NeoX/NeuralX/THXS2/ADYDSX)
     */
    late String _audioInput, _audioOutput, _frequency;

    AudioInformationMsg(EISCPMessage raw) :
            _updateType = AudioInformationUpd.ALL, super(CODE, raw)
    {
        final List<String> pars = getData.split(ISCPMessage.COMMA_SEP);
        _audioInput = getTags(pars, 0, 5);
        _audioOutput = getTags(pars, 5, pars.length);
        _frequency = "";
    }

    AudioInformationMsg.dcpFormat(String _audioInput) :
            _updateType = AudioInformationUpd.DCP_FORMAT, super.output(CODE, "")
    {
        this._audioInput = _audioInput;
        this._audioOutput = "";
        this._frequency = "";
    }

    AudioInformationMsg.dcpFreq(String _frequency) :
            _updateType = AudioInformationUpd.DCP_FREQ, super.output(CODE, "")
    {
        this._audioInput = "";
        this._audioOutput = "";
        this._frequency = _frequency;
    }

    String get audioInput
    => _audioInput;

    String get audioOutput
    => _audioOutput;

    String get frequency
    => _frequency;

    @override
    String toString()
    => super.toString() + "[IN=" + _audioInput + "; OUT=" + _audioOutput + "; FREQ=" + _frequency + "]";

    /*
     * Denon control protocol
     */
    static const String _DCP_COMMAND_INPUT = "SYSDA";
    static const String _DCP_COMMAND_FREQ = "SSINFAISFSV";

    static List<String> getAcceptedDcpCodes()
    => [ _DCP_COMMAND_INPUT, _DCP_COMMAND_FREQ ];

    static AudioInformationMsg? processDcpMessage(String dcpMsg)
    {
        if (dcpMsg.startsWith(_DCP_COMMAND_INPUT))
        {
            return AudioInformationMsg.dcpFormat(dcpMsg.substring(_DCP_COMMAND_INPUT.length).trim());
        }
        if (dcpMsg.startsWith(_DCP_COMMAND_FREQ))
        {
            String par = dcpMsg.substring(_DCP_COMMAND_FREQ.length).trim();
            if (par == "NON")
            {
                par = "";
            }
            if (par == "441")
            {
                par = "44.1 kHz";
            }
            if (par.endsWith("K"))
            {
                par = par.replaceRange(par.length - 1, null, " kHz");
            }
            return AudioInformationMsg.dcpFreq(par);
        }
        return null;
    }

    @override
    String? buildDcpMsg(bool isQuery)
    {
        final String inpReq = _DCP_COMMAND_INPUT + ISCPMessage.DCP_MSG_REQ;
        final String dabReq = _DCP_COMMAND_FREQ + " " + ISCPMessage.DCP_MSG_REQ;
        return inpReq + ISCPMessage.DCP_MSG_SEP + dabReq;
    }
}
