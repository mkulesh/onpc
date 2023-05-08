/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2023 by Mikhail Kulesh
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
 * Video Information Command message
 */
public class VideoInformationMsg extends ISCPMessage
{
    public final static String CODE = "IFV";

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
    public final String videoInput;
    public final String videoOutput;

    VideoInformationMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        final String[] pars = data.split(COMMA_SEP);
        videoInput = getTags(pars, 0, 4);
        videoOutput = getTags(pars, 4, pars.length);
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + getData() + "; IN=" + videoInput + "; OUT=" + videoOutput + "]";
    }
}
