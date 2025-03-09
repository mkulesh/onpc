/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2025 by Mikhail Kulesh
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

import "../../utils/Pair.dart";
import "../EISCPMessage.dart";
import "AllChannelMsg.dart";

/*
 * sets Temporary Channel Level
 * Subwoofer1/2 xxx=-1E(-15.0dB)~000(0.0dB)~+18(+12.0dB)
 * Other Ch xxx=-18(-12.0dB)~000(0.0dB)~+18(+12.0dB)
 * for not exist channel is always 000.
 *
 * 1.  aaa:Front Left
 * 2.  bbb:Front Right
 * 3.  ccc:Center
 * 4.  ddd:Surround Left
 * 5.  eee:Surround Right
 * 6.  fff:Surround Back Left
 * 7.  ggg:Surround Back Right
 * 8.  hhh:Subwoofer 1
 * 9.  iii:Height 1 Left
 * 10. jjj:Height 1 Right
 * 11. kkk:Height 2 Left
 * 12. lll:Height2 Right
 * 13. mmm:Subwoofer 2
 *
 * Example: TCL(-03+01-02000-02000000+02+08+05000000000)
 */
class AllChannelLevelMsg extends AllChannelMsg
{
    static const String CODE = "TCL";
    static const List<String> CHANNELS = [
        'Front/L',
        'Front/R',
        'Center',
        'Surround/L',
        'Surround/R',
        'Surround Back/L',
        'Surround Back/R',
        'Subwoofer/1',
        'Height 1/L',
        'Height 1/R',
        'Height 2/L',
        'Height 2/R',
        'Subwoofer/2'
    ];
    static const int VALUES = 48; // [-0x18, ... 0, ... 0x18]
    static const Pair<String, String> BOUNDS = Pair("-12dB", "+12dB");

    AllChannelLevelMsg(EISCPMessage raw) :
            super(CODE, CHANNELS.length, raw);

    AllChannelLevelMsg.output(final List<int> allValues, final int channel, final int level) :
            super.output(CODE, CHANNELS.length, allValues, channel, level);
}
