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

import "../../utils/Convert.dart";
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";

enum AudioBalance
{
    VAL,
    UP,
    DOWN
}

/*
 * Audio Balance Command
 */
class AudioBalanceMsg extends ISCPMessage
{
    static const String CODE = "BLS";
    static int NO_LEVEL = 9999;

    late AudioBalance _type;
    late int _value;

    AudioBalanceMsg(EISCPMessage raw) : super(CODE, raw)
    {
        if (getData == Convert.enumToString(AudioBalance.DOWN))
        {
            _type = AudioBalance.DOWN;
            _value = NO_LEVEL;
        }
        else if (getData == Convert.enumToString(AudioBalance.UP))
        {
            _type = AudioBalance.UP;
            _value = NO_LEVEL;
        }
        else
        {
            _type = AudioBalance.VAL;
            _value = ISCPMessage.nonNullInteger(getData, 10, NO_LEVEL);
        }
    }

    AudioBalanceMsg.output(AudioBalance type, int balance)
        : super.output(CODE, _getParameterAsString(type, balance))
    {
        _type = type;
        _value = balance;
    }

    int get getValue => _value;

    static String _getParameterAsString(AudioBalance type, int balance)
    {
        return type == AudioBalance.VAL ? balance.toString() : Convert.enumToString(type);
    }

    @override
    String toString()
    => super.toString() + "[TYPE=" + Convert.enumToString(_type) + ", VALUE=" + _value.toString() + "]";

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }

    /*
     * Denon control protocol
     */
    static const String _DCP_COMMAND_L = "BLL" ;
    static const String _DCP_COMMAND_R = "BLR" ;
    static const String _DCP_COMMAND = "BL" ;

    static List<String> getAcceptedDcpCodes()
    => [ _DCP_COMMAND_L, _DCP_COMMAND_R, _DCP_COMMAND ];

    static AudioBalanceMsg? processDcpMessage(String dcpMsg)
    {
        for (String code in getAcceptedDcpCodes())
        {
            if (dcpMsg.startsWith(code))
            {
                final int? balance = int.tryParse(dcpMsg.substring(code.length).trim());
                if (balance != null)
                {
                    final int factor = code == _DCP_COMMAND_L ? -1 : 1;
                    return AudioBalanceMsg.output(AudioBalance.VAL, factor * balance);
                }
            }
        }
        return null;
    }

    @override
    String? buildDcpMsg(bool isQuery) {
        if (isQuery)
        {
            return _DCP_COMMAND + ISCPMessage.DCP_MSG_REQ;
        }
        switch(_type)
        {
          case AudioBalance.VAL:
              final int sign = _value.sign;
              final String pref = sign < 0 ? "L" : (sign > 0 ? "R" : "");
              final String val = sign != 0 ? _value.abs().toString().padLeft(2, '0') : "0";
              return _DCP_COMMAND + pref + val;
          case AudioBalance.UP:
              return _DCP_COMMAND + "RIGHT";
          case AudioBalance.DOWN:
              return _DCP_COMMAND + "LEFT";
        }
    }
}
