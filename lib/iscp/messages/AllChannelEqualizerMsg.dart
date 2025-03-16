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

import "../EISCPMessage.dart";
import "AllChannelMsg.dart";

/*
 * sets All Channel EQ for Temporary Value
 * xxx=-18(-12.0dB)~000(0.0dB)~+18(+12.0dB)
 *
 * 1. aaa:63Hz
 * 2. bbb:125Hz
 * 3. ccc:250Hz
 * 4. ddd:500Hz
 * 5. eee:1kHz
 * 6. fff:2kHz
 * 7. ggg:4kHz
 * 8. hhh:8kHz
 * 9. iii:16kHz
 *
 * Example: ACE[000000000000000000000000000]
 */
class AllChannelEqualizerMsg extends AllChannelMsg
{
    static const String CODE = "ACE";
    static const List<String> CHANNELS = ['63', '125', '250', '500', '1k', '2k', '4k', '8k', '16k'];
    static const int VALUES = 48; // [-0x18, ... 0, ... 0x18]

    AllChannelEqualizerMsg(EISCPMessage raw) :
            super(CODE, CHANNELS.length, raw);

    AllChannelEqualizerMsg.output(final List<int> allValues, final int channel, final int level) :
            super.output(CODE, CHANNELS.length, allValues, channel, level);
}
