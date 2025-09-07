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
import "../utils/Convert.dart";

const int ISCP_PORT = 60128; // Onkyo main and UDP port
const int DCP_PORT = 23; // Denon main port
const int DCP_HEOS_PORT = 1255; // HEOS main port
const int DCP_HTTP_PORT = 8080; // Denon-HTTP port (receiver info and command API)
const int DCP_WEB_GUI = 10443; // Denon-Web-GUI port

enum ProtoType
{
    ISCP, // Integra Serial Communication Protocol (TCP:60128)
    DCP   // Denon Control Protocol (TCP:23)
}

mixin ProtoTypeMix
{
    ProtoType _protoType = ProtoType.ISCP;

    ProtoType get protoType
    => _protoType;

    void setProtoType(ProtoType p)
    {
        _protoType = p;
    }
}

mixin ConnectionIf
{
    // Source host
    static const String EMPTY_HOST = "";

    String _host = ConnectionIf.EMPTY_HOST;

    String get getHost
    => _host;

    void setHost(String host)
    {
        _host = host;
    }

    // Source port
    static const int EMPTY_PORT = -1;

    int _port = ConnectionIf.EMPTY_PORT;

    int get getPort
    => _port;

    void setPort(int port)
    {
        _port = port;
    }

    // Helper methods
    String get getHostAndPort
    => Convert.ipToString(_host, _port.toString());

    void setHostAndPort(ConnectionIf connection)
    {
        _host = connection.getHost;
        _port = connection.getPort;
    }

    void clearConnection()
    {
        _host = ConnectionIf.EMPTY_HOST;
        _port = ConnectionIf.EMPTY_PORT;
    }

    bool fromHost(final ConnectionIf connection)
    => _host == connection.getHost && _port == connection.getPort;

    bool isValidConnection()
    => _host != ConnectionIf.EMPTY_HOST && _port != ConnectionIf.EMPTY_PORT;
}
