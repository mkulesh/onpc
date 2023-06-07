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
import "ConnectionIf.dart";
import "EISCPMessage.dart";
import "ISCPMessage.dart";

abstract class MessageChannel with ConnectionIf
{
    ProtoType get getProtoType;

    bool get isConnected;

    void addAllowedMessage(final String code);

    void start(String host, int port, {bool keepConnection = false});

    void sendMessage(EISCPMessage m);
    void sendIscp(ISCPMessage m);

    void stop();

    void sendQueries(List<String> queries);
}