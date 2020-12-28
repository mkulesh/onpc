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

import 'dart:convert';
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
    INTENT,
    INVALID
}

class Platform
{
    static const String PLATFORM_CHANNEL = "platform_channel";
    static const String SHORTCUT_AUTO_POWER = "com.mkulesh.onpc.plus.AUTO_POWER";
    static const String WIDGET_SHORTCUT = "com.mkulesh.onpc.plus.WIDGET_SHORTCUT";
    static const int INT8_SIZE = 1;
    static const int INT32_SIZE = 4;

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
        if (readBuffer.data.lengthInBytes >= INT8_SIZE)
        {
            final int code = readBuffer.data.getUint8(0);
            return PlatformCmd.values.singleWhere((p) => p.index == code, orElse: () => PlatformCmd.INVALID);
        }
        return PlatformCmd.INVALID;
    }

    static String get operatingSystem => io.Platform.operatingSystem;
    static bool get isAndroid => io.Platform.isAndroid;
    static bool get isMacOs => io.Platform.isMacOS;

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
        if (readBuffer.data.lengthInBytes >= INT8_SIZE)
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
    static Future<ByteData> requestIntent()
    {
        if (isAndroid)
        {
            return sendPlatformCommand(PlatformCmd.INTENT);
        }
        else
        {
            final WriteBuffer buffer = WriteBuffer();
            buffer.putUint8(0);
            return Future.value(buffer.done());
        }
    }

    static String parseIntent(ByteData message)
    {
        final ReadBuffer readBuffer = ReadBuffer(message);
        if (readBuffer.data.lengthInBytes >= INT32_SIZE)
        {
            final int length = readBuffer.data.getInt32(0);
            if (length > 0)
            {
                final List<int> bytes = List();
                for (int i = 0; i < length; i++)
                {
                    bytes.add(readBuffer.data.getUint8(4 + i));
                }
                final String intent = utf8.decode(bytes);
                return intent;
            }
        }
        return null;
    }
}