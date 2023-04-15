/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2022 by Mikhail Kulesh
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

import com.mkulesh.onpc.utils.Utils;

import androidx.annotation.NonNull;

public interface MessageChannel extends ConnectionIf
{
    int DCP_PORT = 23;
    int QUEUE_SIZE = 4 * 1024;

    void start();
    void stop();
    boolean isActive();
    void addAllowedMessage(final String code);
    Utils.ProtoType getProtoType();
    boolean connectToServer(@NonNull String host, int port);
    void sendMessage(EISCPMessage eiscpMessage);
}
