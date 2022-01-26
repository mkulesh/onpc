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
import 'dart:io' as io;

import 'package:flutter/services.dart';
import 'utils/Logging.dart';

import 'iscp/StateManager.dart';

class Platform
{
    static const String METHOD_CHANNEL = "platform_method_channel";

    // dart -> platform
    static const String GET_NETWORK_STATE = "getNetworkState";
    static const String VOLUME_KEYS_ENABLED = "setVolumeKeysEnabled";
    static const String VOLUME_KEYS_DISABLED = "setVolumeKeysDisabled";
    static const String KEEP_SCREEN_ON_ENABLED = "setKeepScreenOnEnabled";
    static const String KEEP_SCREEN_ON_DISABLED = "setKeepScreenOnDisabled";
    static const String GET_INTENT = "getIntent";

    // platform -> dart
    static const String PLATFORM_LOG = "log";
    static const String SHORTCUT = "shortcut";
    static const String VOLUME_UP = "volumeUp";
    static const String VOLUME_DOWN = "volumeDown";
    static const String NETWORK_STATE_CHANGE = "networkStateChange";

    // Intents
    static const String SHORTCUT_AUTO_POWER = "com.mkulesh.onpc.plus.AUTO_POWER";
    static const String WIDGET_SHORTCUT = "com.mkulesh.onpc.plus.WIDGET_SHORTCUT";

    // Platforms
    static String get operatingSystem => io.Platform.operatingSystem;
    static bool get isAndroid => io.Platform.isAndroid;
    static bool get isIOS => io.Platform.isIOS;
    static bool get isDesktop => (io.Platform.isMacOS || io.Platform.isLinux || io.Platform.isWindows);

    // Send a command to platform
    static Future<String> sendPlatformCommand(final MethodChannel _methodChannel, final String cmd)
    {
        if (isAndroid)
        {
            Logging.info(_methodChannel, "Call platform method: " + cmd);
            return _methodChannel.invokeMethod(cmd);
        }
        else
        {
            return Future.value("");
        }
    }

    // Network state from host platforms
    static Future<String> requestNetworkState(final MethodChannel _methodChannel)
    {
        if (isAndroid)
        {
            return sendPlatformCommand(_methodChannel, Platform.GET_NETWORK_STATE);
        }
        else
        {
            return Future.value(NetworkState.WIFI.index.toString());
        }
    }

    static NetworkState parseNetworkState(final String state)
    {
        final int idx = int.tryParse(state);
        if (idx == null)
        {
            NetworkState.NONE;
        }
        return NetworkState.values.singleWhere((p) => p.index == idx, orElse: () => NetworkState.NONE);
    }

    // Auto power state from host platforms
    static Future<String> requestIntent(final MethodChannel _methodChannel)
    {
        if (isAndroid)
        {
            return sendPlatformCommand(_methodChannel, Platform.GET_INTENT);
        }
        else
        {
            return Future.value("");
        }
    }
}