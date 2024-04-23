/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2024 by Mikhail Kulesh
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

import "package:shared_preferences/shared_preferences.dart";

import "../constants/Version.dart";
import "../iscp/ConnectionIf.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/EnumParameterMsg.dart";
import "../iscp/messages/InputSelectorMsg.dart";
import "../iscp/state/ReceiverInformation.dart";
import "../utils/Convert.dart";
import "../utils/Logging.dart";
import "../utils/Pair.dart";
import "../utils/Platform.dart";
import "CfgAppSettings.dart";
import "CfgAudioControl.dart";
import "CfgFavoriteConnections.dart";
import "CfgFavoriteShortcuts.dart";
import "CfgModule.dart";
import "CfgRiCommands.dart";

class Configuration extends CfgModule
{
    static const String CONFIGURATION_EVENT = "CONFIG";
    String appVersion = Version.NAME;

    // Connection options
    static const Pair<String, String> SERVER_NAME = Pair<String, String>("server_name", "");
    String _deviceName = SERVER_NAME.item2;

    String get getDeviceName
    => _deviceName;

    static const Pair<String, int> SERVER_PORT = Pair<String, int>("server_port", 60128);
    int _devicePort = SERVER_PORT.item2;

    int get getDevicePort
    => _devicePort;

    bool get isDeviceValid
    => _deviceName.isNotEmpty && _devicePort > 0;

    static const Pair<String, int> ACTIVE_ZONE = Pair<String, int>("active_zone", 0);
    int _activeZone = ACTIVE_ZONE.item2;

    int get activeZone
    => _activeZone;

    set activeZone(int value)
    {
        _activeZone = value;
        saveIntegerParameter(ACTIVE_ZONE, value);
    }

    // Device options
    static const Pair<String, bool> AUTO_POWER = Pair<String, bool>("auto_power", false);
    bool _autoPower = AUTO_POWER.item2;

    bool get autoPower
    => _autoPower;

    static const Pair<String, bool> FRIENDLY_NAMES = Pair<String, bool>("friendly_names", true);
    bool _friendlyNames = FRIENDLY_NAMES.item2;

    bool get friendlyNames
    => _friendlyNames;

    static const Pair<String, String> PROTO_TYPE = Pair<String, String>("proto_type", "ISCP");
    static const Pair<String, String> MODEL = Pair<String, String>("model", "NONE");
    static const Pair<String, String> DEVICE_FRIENDLY_NAME = Pair<String, String>("device_friendly_name", "");

    static const String NETWORK_SERVICES = "network_services";
    static const String SELECTED_NETWORK_SERVICES = "selected_network_services";

    static const String DEVICE_SELECTORS = "device_selectors";
    static const String SELECTED_DEVICE_SELECTORS = "selected_device_selectors";
    static const String MANUAL_DEVICE_SELECTORS = "manual_device_selectors";

    // Advanced options
    static const Pair<String, bool> KEEP_SCREEN_ON = Pair<String, bool>("keep_screen_on", false); // For Android only
    bool _keepScreenOn = KEEP_SCREEN_ON.item2;

    bool get keepScreenOn
    => _keepScreenOn;

    static const Pair<String, bool> SHOW_WHEN_LOCKED = Pair<String, bool>("show_when_locked", false); // For Android only
    bool _showWhenLocked = SHOW_WHEN_LOCKED.item2;

    bool get showWhenLocked
    => _showWhenLocked;

    static const Pair<String, bool> BACK_AS_RETURN = Pair<String, bool>("back_as_return", true); // For Android only
    bool _backAsReturn = BACK_AS_RETURN.item2;

    bool get backAsReturn
    => _backAsReturn;

    static const Pair<String, bool> ADVANCED_QUEUE = Pair<String, bool>("advanced_queue", true);
    bool _advancedQueue = ADVANCED_QUEUE.item2;

    bool get isAdvancedQueue
    => _advancedQueue;

    static const Pair<String, bool> KEEP_PLAYBACK_MODE = Pair<String, bool>("keep_playback_mode", false);
    bool _keepPlaybackMode = KEEP_PLAYBACK_MODE.item2;

    bool get keepPlaybackMode
    => _keepPlaybackMode;

    static const Pair<String, bool> EXIT_CONFIRM = Pair<String, bool>("exit_confirm", false);
    bool _exitConfirm = EXIT_CONFIRM.item2;

    bool get exitConfirm
    => _exitConfirm;

    static const Pair<String, bool> DEVELOPER_MODE = Pair<String, bool>("developer_mode", false);
    bool _developerMode = DEVELOPER_MODE.item2;

    bool get developerMode
    => _developerMode;

    // configuration modules
    late CfgAppSettings appSettings;
    late CfgAudioControl audioControl;
    late CfgFavoriteConnections favoriteConnections;
    late CfgFavoriteShortcuts favoriteShortcuts;
    late CfgRiCommands riCommands;

    Configuration(final SharedPreferences preferences) : super(preferences)
    {
        appVersion = Version.NAME;
        appSettings = CfgAppSettings(preferences);
        audioControl = CfgAudioControl(preferences);
        favoriteConnections = CfgFavoriteConnections(preferences);
        favoriteShortcuts = CfgFavoriteShortcuts(preferences);
        riCommands = CfgRiCommands(preferences);
        Logging.info(this, "Application started: " + appVersion + ", OS: " + Platform.operatingSystem);
    }

    @override
    void read({ProtoType? protoType})
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
        _showWhenLocked = Platform.isAndroid ? getBool(SHOW_WHEN_LOCKED, doLog: true) : false;
        _backAsReturn = Platform.isAndroid ? getBool(BACK_AS_RETURN, doLog: true) : false;
        _advancedQueue = getBool(ADVANCED_QUEUE, doLog: true);
        _keepPlaybackMode = getBool(KEEP_PLAYBACK_MODE, doLog: true);
        _exitConfirm = Platform.isAndroid ? getBool(EXIT_CONFIRM, doLog: true) : false;
        _developerMode = getBool(DEVELOPER_MODE, doLog: true);

        // configuration modules
        appSettings.read(protoType: protoType);
        audioControl.read();
        favoriteConnections.read();
        favoriteShortcuts.read();
        riCommands.read();
    }

    void readHomeWidgetCfg()
    {
        Logging.info(this, "Reading home widget configuration...");

        // Connection options
        _deviceName = getString(SERVER_NAME, doLog: true);
        _devicePort = getInt(SERVER_PORT, doLog: true);
        _activeZone = getInt(ACTIVE_ZONE, doLog: true);
        audioControl.read();
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
        Logging.info(this, "Save receiver information");
        saveStringParameter(PROTO_TYPE, Convert.enumToString(stateManager.protoType), prefix: "  ");
        saveStringParameter(MODEL, m, prefix: "  ");
        saveStringParameter(DEVICE_FRIENDLY_NAME, state.getDeviceName(true), prefix: "  ");
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

    void saveManualDeviceSelector(final EnumItem<InputSelector> item, final String name)
    {
        final Pair<String, String> par = Pair<String, String>(MANUAL_DEVICE_SELECTORS + "_" + item.getCode, "");
        name.isNotEmpty ? saveStringParameter(par, name) : deleteParameter(par);
    }

    String deviceSelectorName(final EnumItem<InputSelector> item, {bool useFriendlyName = false, String friendlyName = ""})
    {
        final Pair<String, String> par = Pair<String, String>(MANUAL_DEVICE_SELECTORS + "_" + item.getCode, "");
        final String manName = getString(par);
        if (manName.isNotEmpty)
        {
            return manName;
        }
        final String defName = item.description.toUpperCase();
        if (useFriendlyName)
        {
            return friendlyName.isNotEmpty ? friendlyName :
                getStringDef(Configuration.DEVICE_SELECTORS + "_" + item.getCode, defName);
        }
        return defName;
    }

    void saveDeviceFriendlyName(final ReceiverInformation state)
    {
        saveStringParameter(DEVICE_FRIENDLY_NAME, state.getDeviceName(true));
    }

    ProtoType get protoType
    => Convert.stringToProtoType(getString(PROTO_TYPE));
}
