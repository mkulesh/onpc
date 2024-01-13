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

import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/services.dart';

import 'Logging.dart';

enum NetworkState
{
    NONE, CELLULAR, WIFI
}

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
    static const String REGISTER_WIDGET_CALLBACK = "registerWidgetCallback";
    static const String _WIDGET_UPDATE = "widgetUpdate";

    // platform -> dart
    static const String PLATFORM_LOG = "log";
    static const String SHORTCUT = "shortcut";
    static const String VOLUME_UP = "volumeUp";
    static const String VOLUME_DOWN = "volumeDown";
    static const String NETWORK_STATE_CHANGE = "networkStateChange";

    // Intents
    static const String SHORTCUT_AUTO_POWER = "com.mkulesh.onpc.plus.AUTO_POWER";
    static const String SHORTCUT_ALL_STANDBY = "com.mkulesh.onpc.plus.ALL_STANDBY";
    static const String WIDGET_SHORTCUT = "com.mkulesh.onpc.plus.WIDGET_SHORTCUT";

    // Platforms
    static String get operatingSystem => io.Platform.operatingSystem;
    static bool get isAndroid => io.Platform.isAndroid;
    static bool get isIOS => io.Platform.isIOS;
    static bool get isWindows => io.Platform.isWindows;
    static bool get isDesktop => (io.Platform.isMacOS || io.Platform.isLinux || io.Platform.isWindows);
    static bool get isMobile => (io.Platform.isAndroid || io.Platform.isIOS);

    // Send a command to platform
    static Future<String?> sendPlatformCommand(final MethodChannel _methodChannel, final String cmd, [ dynamic arguments ])
    {
        if (isAndroid)
        {
            Logging.info(_methodChannel, "Call platform method: " + cmd);
            return _methodChannel.invokeMethod(cmd, arguments);
        }
        else
        {
            return Future.value("");
        }
    }

    // Network state from host platforms
    static Future<String?> requestNetworkState(final MethodChannel _methodChannel)
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
        final int? idx = int.tryParse(state);
        if (idx == null)
        {
            NetworkState.NONE;
        }
        return NetworkState.values.singleWhere((p) => p.index == idx, orElse: () => NetworkState.NONE);
    }

    // Auto power state from host platforms
    static Future<String?> requestIntent(final MethodChannel _methodChannel)
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

    // Delayed widget update
    static Timer? _widgetUpdateTimer;
    static void updateWidgets(final MethodChannel _methodChannel)
    {
        if (isAndroid && _widgetUpdateTimer == null)
        {
            _widgetUpdateTimer = Timer(Duration(seconds: 1), ()
            {
                _widgetUpdateTimer = null;
                Platform.sendPlatformCommand(_methodChannel, Platform._WIDGET_UPDATE);
            });
        }
    }
}