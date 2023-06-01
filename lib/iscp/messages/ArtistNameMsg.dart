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
import "../DcpHeosMessage.dart";
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";

/*
 * NET/USB Artist Name (variable-length, 64 ASCII letters max)
 */
class ArtistNameMsg extends ISCPMessage
{
    static const String CODE = "NAT";

    ArtistNameMsg(EISCPMessage raw) : super(CODE, raw);

    ArtistNameMsg._dcp(String name) : super.output(CODE, name);

    /*
     * Denon control protocol
     */
    static const String _HEOS_COMMAND = "player/get_now_playing_media";

    static ArtistNameMsg processHeosMessage(DcpHeosMessage jsonMsg)
    {
        final String name = jsonMsg.getCmdProperty(_HEOS_COMMAND, "payload.artist");
        return name != null ? ArtistNameMsg._dcp(name) : null;
    }
}
