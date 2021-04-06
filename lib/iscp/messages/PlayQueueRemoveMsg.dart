/*
 * Enhanced Controller for Onkyo and Pioneer Pro
 * Copyright (C) 2019-2021 by Mikhail Kulesh
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
 * Remove from PlayQueue List (from Network Control Only)
 */
class PlayQueueRemoveMsg extends ISCPMessage
{
    static const String CODE = "PQR";

    // Remove Type: 0:Specify Line, (1:ALL)
    final int type;

    // The Index number in the PlayQueue of the item to delete(0000-FFFF : 1st to 65536th Item [4 HEX digits] )
    final int itemIndex;

    PlayQueueRemoveMsg.output(this.type, this.itemIndex) :
            super.output(CODE, _getParameterAsString(type, itemIndex));

    static String _getParameterAsString(final int type, final int itemIndex)
    {
        return type.toString() +
            itemIndex.toRadixString(16).padLeft(4, '0');
    }

    @override
    String toString()
    => super.toString() + "[TYPE=" + type.toString() + "; INDEX=" + itemIndex.toString() + "]";
}
