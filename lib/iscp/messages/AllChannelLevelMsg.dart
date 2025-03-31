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
import "../ISCPMessage.dart";
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

    // Channel indices
    static const int idx_FrontL =           0;
    static const int idx_FrontR =           1;
    static const int idx_Center =           2;
    static const int idx_SurroundL =        3;
    static const int idx_SurroundR =        4;
    static const int idx_SurroundBackL =    5;
    static const int idx_SurroundBackR =    6;
    static const int idx_Subwoofer1 =       7;
    static const int idx_Height1L =         8;
    static const int idx_Height1R =         9;
    static const int idx_Height2L =         10;
    static const int idx_Height2R =         11;
    static const int idx_Subwoofer2 =       12;

    // Channel Names
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

    final int _valueIdx;
    final bool _channelOn;

    AllChannelLevelMsg(EISCPMessage raw) :
            _valueIdx = -1,
            _channelOn = false,
            super(CODE, CHANNELS.length, raw);

    AllChannelLevelMsg.output(final List<int> allValues, final int channel, final int level, {bool channelOn = false}) :
            _valueIdx = channel,
            _channelOn = channelOn,
            super.output(CODE, CHANNELS.length, allValues, channel, level);

    int get valueIdx
    => _valueIdx;

    bool get channelOn
    => _channelOn;

    @override
    String toString()
    => super.toString() + (_channelOn ? "[ON=true]" : "");

    /*
     * Denon control protocol
     * Channel Volume:
     * CVFL 50
     * CVFR 50
     * CVC 56
     * CVSW 55
     * CVSL 50
     * CVSR 50
     * CVEND
     */
    static const String _DCP_COMMAND = "CV";
    static const int _DCB_ZERO_DB_VALUE = 50;
    static const int _DCB_MAX_DB_VALUE = 62;

    static List<String> getAcceptedDcpCodes()
    => [ _DCP_COMMAND ];

    static List<int> defDcpChannelValues()
    => List.filled(CHANNELS.length, AllChannelMsg.NO_LEVEL);

    static const List<Pair<String, int>> _DCB_CHANNELS = [
        Pair("FL", idx_FrontL),
        Pair("FR", idx_FrontR),
        Pair("C", idx_Center),
        Pair("SL", idx_SurroundL),
        Pair("SR", idx_SurroundR),
        Pair("SBL", idx_SurroundBackL),
        Pair("SBR", idx_SurroundBackR),
        Pair("SW", idx_Subwoofer1),
        Pair("FHL", idx_Height1L),
        Pair("FHR", idx_Height1R),
        Pair("SW2", idx_Subwoofer2),
    ];

    static AllChannelLevelMsg? processDcpMessage(String dcpMsg)
    {
        if (dcpMsg.startsWith(_DCP_COMMAND))
        {
            final String par = dcpMsg.substring(_DCP_COMMAND.length).trim();
            for (Pair<String, int> c in _DCB_CHANNELS)
            {
                if (par.startsWith(c.item1))
                {
                    final String valStr = par.substring(c.item1.length).trim();
                    if (valStr == "ON")
                    {
                        return AllChannelLevelMsg.output(defDcpChannelValues(), c.item2, 0, channelOn: true);
                    }
                    final int? volumeLevel = int.tryParse(valStr);
                    if (volumeLevel != null)
                    {
                        final int adjVolumeLevel = volumeLevel <= _DCB_MAX_DB_VALUE ?
                            2 * (volumeLevel - _DCB_ZERO_DB_VALUE) :
                            (2.0 * (volumeLevel.toDouble() / 10.0 - _DCB_ZERO_DB_VALUE.toDouble())).floor();
                        return AllChannelLevelMsg.output(defDcpChannelValues(), c.item2, adjVolumeLevel);
                    }
                }
            }
        }
        return null;
    }

    @override
    String? buildDcpMsg(bool isQuery)
    {
        if (isQuery)
        {
            return _DCP_COMMAND + ISCPMessage.DCP_MSG_REQ;
        }
        final int idx = values.indexWhere((e) => e != AllChannelMsg.NO_LEVEL);
        for (Pair<String, int> c in _DCB_CHANNELS)
        {
            if (idx == c.item2)
            {
                final double dVal = 10.0 * (values[idx].toDouble() / 2.0 + _DCB_ZERO_DB_VALUE.toDouble());
                final int iVal = dVal.toInt();
                String sVal = iVal.toString();
                if (sVal.length == 3 && sVal.endsWith("0"))
                {
                    sVal = sVal.substring(0,2);
                }
                return _DCP_COMMAND + c.item1 + " " + sVal.toString();
            }
        }
        return null;
    }
}
