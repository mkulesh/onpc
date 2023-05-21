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
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";

/*
 * Video Information Command message
 */
class VideoInformationMsg extends ISCPMessage
{
    static const String CODE = "IFV";

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
    String _videoInput, _videoOutput;

    VideoInformationMsg(EISCPMessage raw) : super(CODE, raw)
    {
        final List<String> pars = getData.split(ISCPMessage.COMMA_SEP);
        _videoInput = getTags(pars, 0, 4);
        _videoOutput = getTags(pars, 4, pars.length);
    }

    String get videoInput
    => _videoInput;

    String get videoOutput
    => _videoOutput;

    @override
    String toString()
    => super.toString() + "[IN=" + _videoInput + "; OUT=" + _videoOutput + "]";
}
