/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2022 by Mikhail Kulesh
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
import "../ISCPMessage.dart";

/*
 * Reorder PlayQueue List (from Network Control Only)
 */
class PlayQueueReorderMsg extends ISCPMessage
{
    static const String CODE = "PQO";

    // The Index number in the PlayQueue of the item to be moved
    // (0000-FFFF : 1st to 65536th Item [4 HEX digits] )  .
    final int itemIndex;

    // The Index number in the PlayQueue of destination.
    // (0000-FFFF : 1st to 65536th Item [4 HEX digits] )
    final int targetIndex;

    PlayQueueReorderMsg.output(this.itemIndex, this.targetIndex) :
            super.output(CODE, _getParameterAsString(itemIndex, targetIndex));

    @override
    String toString()
    => super.toString() + "[INDEX=" + itemIndex.toString() + "; TARGET=" + targetIndex.toString() + "]";

    static String _getParameterAsString(final int itemIndex, final int targetIndex)
    {
        return itemIndex.toRadixString(16).padLeft(4, '0') +
            targetIndex.toRadixString(16).padLeft(4, '0');
    }
}
