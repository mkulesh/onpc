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

import 'dart:typed_data';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'iscp/StateManager.dart';

enum PlatformCmd
{
    NETWORK_STATE,
    VOLUME_UP,
    VOLUME_DOWN,
    VOLUME_KEYS_ENABLED,
    VOLUME_KEYS_DISABLED,
    KEEP_SCREEN_ON_ENABLED,
    KEEP_SCREEN_ON_DISABLED,
    AUTO_POWER,
    INVALID
}

class Platform
{
    static const String PLATFORM_CHANNEL = "platform_channel";

    static Future<ByteData> sendPlatformCommand(PlatformCmd cmd)
    {
        final WriteBuffer buffer = WriteBuffer();
        buffer.putInt32(cmd.index);
        final ByteData message = buffer.done();
        return ServicesBinding.instance.defaultBinaryMessenger.send(PLATFORM_CHANNEL, message);
    }

    static PlatformCmd readPlatformCommand(ByteData message)
    {
        final ReadBuffer readBuffer = ReadBuffer(message);
        if (readBuffer.data.lengthInBytes > 0)
        {
            final int code = readBuffer.data.getUint8(0);
            return PlatformCmd.values.singleWhere((p) => p.index == code, orElse: () => PlatformCmd.INVALID);
        }
        return PlatformCmd.INVALID;
    }

    static String get operatingSystem => io.Platform.operatingSystem;
    static bool get isAndroid => io.Platform.isAndroid;

    // Network state from host platforms
    static Future<ByteData> requestNetworkState()
    {
        if (isAndroid)
        {
            return sendPlatformCommand(PlatformCmd.NETWORK_STATE);
        }
        else
        {
            final WriteBuffer buffer = WriteBuffer();
            buffer.putUint8(PlatformCmd.NETWORK_STATE.index);
            buffer.putUint8(NetworkState.WIFI.index);
            return Future.value(buffer.done());
        }
    }

    static NetworkState parseNetworkState(ByteData message)
    {
        final ReadBuffer readBuffer = ReadBuffer(message);
        if (readBuffer.data.lengthInBytes > 0)
        {
            final int code = readBuffer.data.getUint8(0);
            if (code == PlatformCmd.NETWORK_STATE.index && readBuffer.data.lengthInBytes > 1)
            {
                final int state = readBuffer.data.getUint8(1);
                return NetworkState.values.singleWhere((p) => p.index == state, orElse: () => NetworkState.NONE);
            }
        }
        return NetworkState.NONE;
    }

    // Auto power state from host platforms
    static Future<ByteData> requestAutoPower()
    {
        if (isAndroid)
        {
            return sendPlatformCommand(PlatformCmd.AUTO_POWER);
        }
        else
        {
            final WriteBuffer buffer = WriteBuffer();
            buffer.putUint8(0);
            return Future.value(buffer.done());
        }
    }

    static bool parseAutoPower(ByteData message)
    {
        final ReadBuffer readBuffer = ReadBuffer(message);
        if (readBuffer.data.lengthInBytes > 0)
        {
            final int code = readBuffer.data.getUint8(0);
            return code == 1;
        }
        return false;
    }
}