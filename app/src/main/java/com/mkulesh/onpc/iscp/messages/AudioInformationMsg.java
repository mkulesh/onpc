/*
 * Enhanced Controller for Onkyo and Pioneer
 * Copyright (C) 2018-2021 by Mikhail Kulesh
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

package com.mkulesh.onpc.iscp.messages;

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

import androidx.annotation.NonNull;

/*
 * Audio Information Command message
 */
public class AudioInformationMsg extends ISCPMessage
{
    public final static String CODE = "IFA";

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
    public final String audioInput;
    public final String audioOutput;

    AudioInformationMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        final String[] pars = data.split(COMMA_SEP);
        audioInput = getTags(pars, 0, 5);
        audioOutput = getTags(pars, 5, pars.length);
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + getData() + "; IN=" + audioInput + "; OUT=" + audioOutput + "]";
    }
}
