/*
 * Copyright (C) 2019. Mikhail Kulesh
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

import "../ISCPMessage.dart";

/*
 * Add PlayQueue List in List View (from Network Control Only)
 */
class PlayQueueAddMsg extends ISCPMessage
{
    static const String CODE = "PQA";

    // The Index number of the item to be added in the content list
    // (0000-FFFF : 1st to 65536th Item [4 HEX digits] )
    // It is also possible to set folder.
    final int itemIndex;

    // Add Type: 0:Now, 1:Next, 2:Last
    final int type;

    // The Index number in the PlayQueue to be added(0000-FFFF : 1st to 65536th Item [4 HEX digits] )
    final int targetIndex;

    PlayQueueAddMsg.output(this.itemIndex, this.type, [ this.targetIndex = 0 ]) :
            super.output(CODE, _getParameterAsString(itemIndex, type, targetIndex));

    static String _getParameterAsString(final int itemIndex, final int type, final int targetIndex)
    {
        return itemIndex.toRadixString(16).padLeft(4, '0') +
            type.toString() +
            targetIndex.toRadixString(16).padLeft(4, '0');
    }

    @override
    String toString()
    => super.toString() + "[INDEX=" + itemIndex.toString() + "; TYPE=" + type.toString() + "; TARGET=" + targetIndex.toString() + "]";
}
