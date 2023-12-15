/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2023 by Mikhail Kulesh
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

package com.mkulesh.onpc.iscp;

import androidx.annotation.NonNull;

public interface ConnectionIf
{
    int ISCP_PORT = 60128; // Onkyo main and UDP port
    int DCP_PORT = 23; // Denon main port
    int DCP_UDP_PORT = 1900; // HEOS UDP port
    int DCP_HEOS_PORT = 1255; // HEOS main port
    int DCP_HTTP_PORT = 8080; // Denon-HTTP port (receiver info and command API)

    enum ProtoType
    {
        ISCP, // Integra Serial Communication Protocol (TCP:60128)
        DCP   // Denon Control Protocol (TCP:23)
    }

    String EMPTY_HOST = "";
    int EMPTY_PORT = -1;

    @NonNull
    String getHost();

    int getPort();

    @NonNull
    @SuppressWarnings("unused")
    String getHostAndPort();
}
