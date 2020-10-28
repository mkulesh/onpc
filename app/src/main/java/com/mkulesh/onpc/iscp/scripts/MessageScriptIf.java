/*
 * Enhanced Controller for Onkyo and Pioneer
 * Copyright (C) 2018-2020. Mikhail Kulesh
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
package com.mkulesh.onpc.iscp.scripts;

import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.iscp.MessageChannel;
import com.mkulesh.onpc.iscp.State;

import androidx.annotation.NonNull;

public interface MessageScriptIf
{
    /**
     * Checks whether the script contains valid action to be performed
     **/
    boolean isValid();

    /**
     * This method shall parse the data field in the input intent. After XML is parsed,
     * the method fills attributes host, port, and zone, if the input XML contains this
     * information. After it, the method fills a list of available action. This list contains
     * elements of type "Action" that is defined within this class. If the list of actions is
     * not empty, the MessageScript is valid and these actions will be performed after the
     * connection is established.
     **/
    void initialize(@NonNull final String data);

    /**
     * This method is called from the state manager after the connection is established
     * Before the method is called, the state manager checks whether this class contains
     * valid actions; i.e method is not called for invalid script
     **/
    void start(@NonNull final State state, @NonNull MessageChannel channel);

    /**
     * This method is called from the state manager after the input message is processed.
     * Before the method is called, the state manager checks whether this class contains
     * valid actions; i.e method is not called for invalid script
     **/
    void processMessage(@NonNull ISCPMessage msg, @NonNull final State state, @NonNull MessageChannel channel);
}
