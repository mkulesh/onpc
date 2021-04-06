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
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";

/*
 * NET/USB Album Name (variable-length, 64 ASCII letters max)
 */
class AlbumNameMsg extends ISCPMessage
{
    static const String CODE = "NAL";

    AlbumNameMsg(EISCPMessage raw) : super(CODE, raw);
}
