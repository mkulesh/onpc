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
import 'package:shared_preferences/shared_preferences.dart';

import "../Platform.dart";
import "../constants/Version.dart";
import "../iscp/StateManager.dart";
import "../iscp/state/ReceiverInformation.dart";
import "../utils/Logging.dart";
import "../utils/Pair.dart";
import "CfgAppSettings.dart";
import "CfgAudioControl.dart";
import "CfgFavoriteConnections.dart";
import "CfgFavoriteShortcuts.dart";
import "CfgModule.dart";

class Configuration extends CfgModule
{
    static const String CONFIGURATION_EVENT = "CONFIG";
    String appVersion;

    // Connection options
    static const Pair<String, String> SERVER_NAME = Pair<String, String>("server_name", "");
    String _deviceName;

    String get getDeviceName
    => _deviceName;

    static const Pair<String, int> SERVER_PORT = Pair<String, int>("server_port", 60128);
    int _devicePort;

    int get getDevicePort
    => _devicePort;

    bool get isDeviceValid
    => _deviceName.isNotEmpty && _devicePort > 0;

    static const Pair<String, int> ACTIVE_ZONE = Pair<String, int>("active_zone", 0);
    int _activeZone;

    int get activeZone
    => _activeZone;

    set activeZone(int value)
    {
        _activeZone = value;
        saveIntegerParameter(ACTIVE_ZONE, value);
    }

    // Device options
    static const Pair<String, bool> AUTO_POWER = Pair<String, bool>("auto_power", false);
    bool _autoPower;

    bool get autoPower
    => _autoPower;

    static const Pair<String, bool> FRIENDLY_NAMES = Pair<String, bool>("friendly_names", true);
    bool _friendlyNames;

    bool get friendlyNames
    => _friendlyNames;

    static const Pair<String, String> MODEL = Pair<String, String>("model", "NONE");

    static const String NETWORK_SERVICES = "network_services";
    static const String SELECTED_NETWORK_SERVICES = "selected_network_services";

    static const String DEVICE_SELECTORS = "device_selectors";
    static const String SELECTED_DEVICE_SELECTORS = "selected_device_selectors";

    // Advanced options
    static const Pair<String, bool> KEEP_SCREEN_ON = Pair<String, bool>("keep_screen_on", false); // For Android only
    bool _keepScreenOn;

    bool get keepScreenOn
    => _keepScreenOn;

    static const Pair<String, bool> BACK_AS_RETURN = Pair<String, bool>("back_as_return", true); // For Android only
    bool _backAsReturn;

    bool get backAsReturn
    => _backAsReturn;

    static const Pair<String, bool> ADVANCED_QUEUE = Pair<String, bool>("advanced_queue", true);
    bool _advancedQueue;

    bool get isAdvancedQueue
    => _advancedQueue;

    static const Pair<String, bool> KEEP_PLAYBACK_MODE = Pair<String, bool>("keep_playback_mode", false);
    bool _keepPlaybackMode;

    bool get keepPlaybackMode
    => _keepPlaybackMode;

    static const Pair<String, bool> EXIT_CONFIRM = Pair<String, bool>("exit_confirm", false);
    bool _exitConfirm;

    bool get exitConfirm
    => _exitConfirm;

    static const Pair<String, bool> DEVELOPER_MODE = Pair<String, bool>("developer_mode", false);
    bool _developerMode;

    bool get developerMode
    => _developerMode;

    // configuration modules
    CfgAppSettings appSettings;
    CfgAudioControl audioControl;
    CfgFavoriteConnections favoriteConnections;
    CfgFavoriteShortcuts favoriteShortcuts;

    Configuration(final SharedPreferences preferences) : super(preferences)
    {
        appVersion = Version.NAME;
        appSettings = CfgAppSettings(preferences);
        audioControl = CfgAudioControl(preferences);
        favoriteConnections = CfgFavoriteConnections(preferences);
        favoriteShortcuts = CfgFavoriteShortcuts(preferences);
        Logging.info(this, "Application started: " + appVersion + ", OS: " + Platform.operatingSystem);
    }

    @override
    void read()
    {
        Logging.info(this, "Reading configuration...");

        // Connection options
        _deviceName = getString(SERVER_NAME, doLog: true);
        _devicePort = getInt(SERVER_PORT, doLog: true);
        _activeZone = getInt(ACTIVE_ZONE, doLog: true);

        // Device options
        _autoPower = getBool(AUTO_POWER, doLog: true);
        _friendlyNames = getBool(FRIENDLY_NAMES, doLog: true);

        // Advanced options
        _keepScreenOn = Platform.isAndroid ? getBool(KEEP_SCREEN_ON, doLog: true) : false;
        _backAsReturn = Platform.isAndroid ? getBool(BACK_AS_RETURN, doLog: true) : false;
        _advancedQueue = getBool(ADVANCED_QUEUE, doLog: true);
        _keepPlaybackMode = getBool(KEEP_PLAYBACK_MODE, doLog: true);
        _exitConfirm = Platform.isAndroid ? getBool(EXIT_CONFIRM, doLog: true) : false;
        _developerMode = getBool(DEVELOPER_MODE, doLog: true);

        // configuration modules
        appSettings.read();
        audioControl.read();
        favoriteConnections.read();
        favoriteShortcuts.read();
    }

    void saveDevice(final String device, final int port) async
    {
        _deviceName = device;
        _devicePort = port;
        await preferences.setString(SERVER_NAME.item1, device);
        await preferences.setInt(SERVER_PORT.item1, port);
    }

    @override
    void setReceiverInformation(StateManager stateManager)
    {
        final ReceiverInformation state = stateManager.state.receiverInformation;
        String m = state.model;
        if (m.isEmpty)
        {
            m = MODEL.item2;
        }
        Logging.info(this, "Updating configuration for model: " + m);
        preferences.setString(MODEL.item1, m);
        if (state.networkServices.isNotEmpty)
        {
            String str = "";
            state.networkServices.forEach((p)
            {
                if (str.isNotEmpty)
                {
                    str += ",";
                }
                str += p.getId;
            });
            saveStringParameter(Pair<String, String>(NETWORK_SERVICES, ""), str, prefix: "  ");
        }
        if (state.deviceSelectors.isNotEmpty)
        {
            String str = "";
            state.deviceSelectors.forEach((d)
            {
                if (str.isNotEmpty)
                {
                    str += ",";
                }
                str += d.getId;
                preferences.setString(DEVICE_SELECTORS + "_" + d.getId, d.getName);
            });
            saveStringParameter(Pair<String, String>(DEVICE_SELECTORS, ""), str, prefix: "  ");
        }
        appSettings.setReceiverInformation(stateManager);
        audioControl.setReceiverInformation(stateManager);
        favoriteConnections.setReceiverInformation(stateManager);
        favoriteShortcuts.setReceiverInformation(stateManager);
    }
}
