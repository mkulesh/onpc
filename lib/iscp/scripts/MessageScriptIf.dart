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

import "../ConnectionIf.dart";
import "../ISCPMessage.dart";
import "../MessageChannel.dart";
import "../State.dart";

abstract class MessageScriptIf
{
    //
    // Checks whether the script contains valid action to be performed
    //
    bool isValid(ProtoType protoType);

    //
    // This method shall parse the data field in the input intent. After XML data is parsed,
    // the method fills attributes host, port, and zone, if the input XML contains this
    // information. After it, the method fills a list of available action. This list contains
    // elements of type "Action" that is defined within this class. If the list of actions is
    // not empty, the MessageScript is valid and these actions will be performed after the
    // connection is established.
    //
    bool initialize(final State state, MessageChannel channel);

    //
    // This method is called from the state manager after the connection is established
    // Before the method is called, the state manager checks whether this class contains
    // valid actions; i.e method is not called for invalid script
    //
    void start(final State state, MessageChannel channel);

    //
    // This method is called from the state manager after the input message is processed.
    // Before the method is called, the state manager checks whether this class contains
    // valid actions; i.e method is not called for invalid script
    //
    void processMessage(ISCPMessage msg, final State state, MessageChannel channel);
}
