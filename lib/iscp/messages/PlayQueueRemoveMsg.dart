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

import 'package:sprintf/sprintf.dart';

import "../EISCPMessage.dart";
import "../ISCPMessage.dart";

/*
 * Remove from PlayQueue List (from Network Control Only)
 */
class PlayQueueRemoveMsg extends ISCPMessage
{
    static const String CODE = "PQR";

    // Remove Type: 0:Specify Line, (1:ALL)
    late int _type;

    // The Index number in the PlayQueue of the item to delete(0000-FFFF : 1st to 65536th Item [4 HEX digits] )
    late int _itemIndex;

    PlayQueueRemoveMsg(EISCPMessage raw) : super(CODE, raw)
    {
        _type = ISCPMessage.nonNullInteger(getData.substring(0, 1), 10, -1);
        _itemIndex = ISCPMessage.nonNullInteger(getData.substring(1), 16, -1);
    }
    
    PlayQueueRemoveMsg.output(this._type, this._itemIndex) :
            super.output(CODE, _getParameterAsString(_type, _itemIndex));

    static String _getParameterAsString(final int type, final int itemIndex)
    => type.toString() + itemIndex.toRadixString(16).padLeft(4, '0');

    @override
    String toString()
    => super.toString() + "[TYPE=" + _type.toString() + "; INDEX=" + _itemIndex.toString() + "]";

    /*
     * Denon control protocol
     */
    @override
    String? buildDcpMsg(bool isQuery)
    {
        switch (_type)
        {
            case 0:
                return sprintf("heos://player/remove_from_queue?pid=%s&qid=%d",
                    [ ISCPMessage.DCP_HEOS_PID, _itemIndex ]);
            case 1:
                return sprintf("heos://player/clear_queue?pid=%s",
                    [ ISCPMessage.DCP_HEOS_PID ]);
        }
        return null;
    }
}
