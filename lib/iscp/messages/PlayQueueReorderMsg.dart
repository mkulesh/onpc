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
import 'package:sprintf/sprintf.dart';

import "../EISCPMessage.dart";
import "../ISCPMessage.dart";

/*
 * Reorder PlayQueue List (from Network Control Only)
 */
class PlayQueueReorderMsg extends ISCPMessage
{
    static const String CODE = "PQO";

    // The Index number in the PlayQueue of the item to be moved
    // (0000-FFFF : 1st to 65536th Item [4 HEX digits] )  .
    int _itemIndex;

    // The Index number in the PlayQueue of destination.
    // (0000-FFFF : 1st to 65536th Item [4 HEX digits] )
    int _targetIndex;

    PlayQueueReorderMsg(EISCPMessage raw) : super(CODE, raw)
    {
        _itemIndex = ISCPMessage.nonNullInteger(getData.substring(0, 4), 16, -1);
        _targetIndex = ISCPMessage.nonNullInteger(getData.substring(4), 16, -1);
    }

    PlayQueueReorderMsg.output(this._itemIndex, this._targetIndex) :
            super.output(CODE, _getParameterAsString(_itemIndex, _targetIndex));

    @override
    String toString()
    => super.toString() + "[INDEX=" + _itemIndex.toString() + "; TARGET=" + _targetIndex.toString() + "]";

    static String _getParameterAsString(final int itemIndex, final int targetIndex)
    => itemIndex.toRadixString(16).padLeft(4, '0') + targetIndex.toRadixString(16).padLeft(4, '0');

    /*
     * Denon control protocol
     */
    @override
    String buildDcpMsg(bool isQuery)
    {
        return sprintf("heos://player/move_queue_item?pid=%s&sqid=%d&dqid=%d",
            [ ISCPMessage.DCP_HEOS_PID, _itemIndex, _targetIndex ]);
    }
}
