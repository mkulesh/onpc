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

import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import "../Platform.dart";
import "../constants/Strings.dart";
import "../iscp/StateManager.dart";
import "../iscp/state/ReceiverInformation.dart";
import "../utils/Logging.dart";
import "../utils/Pair.dart";
import "CfgAudioControl.dart";
import "CfgFavoriteConnections.dart";
import "CfgModule.dart";

class Configuration extends CfgModule
{
    static const String CONFIGURATION_EVENT = "CONFIG";
    String appVersion;

    // Theme
    static const Pair<String, String> THEME = Pair<String, String>("theme", Strings.pref_theme_default);
    String _theme;

    String get theme
    => _theme;

    set theme(String value)
    {
        _theme = value;
        saveStringParameter(Configuration.THEME, value);
    }

    // System language
    static const Locale DEFAULT_LOCALE = Locale("en", "US");
    Locale _systemLocale;

    set systemLocale(Locale value)
    {
        _systemLocale = value;
        Logging.info(this, "system locale: " + _systemLocale.toString());
    }

    // Language
    static const Pair<String, String> LANGUAGE = Pair<String, String>("language", Strings.pref_language_default);
    String _language;

    String get language
    {
        if (_language == "system")
        {
            return _systemLocale != null && Strings.app_languages.contains(_systemLocale.languageCode) ?
                _systemLocale.languageCode : DEFAULT_LOCALE.languageCode;
        }
        return _language;
    }

    set language(String value)
    {
        _language = value;
        saveStringParameter(Configuration.LANGUAGE, value);
    }

    // Text size
    static const Pair<String, String> TEXT_SIZE = Pair<String, String>("text_size", Strings.pref_text_size_default);
    String _textSize;

    String get textSize
    => _textSize;

    set textSize(String value)
    {
        _textSize = value;
        saveStringParameter(Configuration.TEXT_SIZE, value);
    }

    // The latest opened tab
    static const Pair<String, int> OPENED_TAB = Pair<String, int>("opened_tab", 0);
    int _openedTab;

    int get openedTab
    => _openedTab;

    set openedTab(int value)
    {
        _openedTab = value;
        saveIntegerParameter(OPENED_TAB, value);
    }

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

    // Remote interface
    static const Pair<String, bool> RI_AMP = Pair<String, bool>("remote_interface_amp", false);
    bool _riAmp;

    bool get riAmp
    => _riAmp;

    static const Pair<String, bool> RI_CD = Pair<String, bool>("remote_interface_cd", false);
    bool _riCd;

    bool get riCd
    => _riCd;

    // Advanced options
    static const Pair<String, bool> VOLUME_KEYS = Pair<String, bool>("volume_keys", true); // For Android only
    bool _volumeKeys;

    bool get volumeKeys
    => _volumeKeys;

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
    CfgAudioControl audioControl;
    CfgFavoriteConnections favoriteConnections;

    Configuration(final SharedPreferences preferences, packageInfo) : super(preferences)
    {
        this.appVersion = "v." + packageInfo.version;
        this.audioControl = CfgAudioControl(preferences);
        this.favoriteConnections = CfgFavoriteConnections(preferences);
        Logging.info(this, "Application started: " + appVersion + ", OS: " + Platform.operatingSystem);
    }

    void read()
    {
        Logging.info(this, "Reading configuration...");

        // Interface options
        _theme = getString(THEME, doLog: true);
        _language = getString(LANGUAGE, doLog: true);
        _textSize = getString(TEXT_SIZE, doLog: true);
        _openedTab = getInt(OPENED_TAB, doLog: true);

        // Connection options
        _deviceName = getString(SERVER_NAME, doLog: true);
        _devicePort = getInt(SERVER_PORT, doLog: true);
        _activeZone = getInt(ACTIVE_ZONE, doLog: true);

        // Device options
        _autoPower = getBool(AUTO_POWER, doLog: true);
        _friendlyNames = getBool(FRIENDLY_NAMES, doLog: true);

        // Audio control
        audioControl.read();

        // Remote interface
        _riAmp = getBool(RI_AMP, doLog: true);
        _riCd = getBool(RI_CD, doLog: true);

        // Advanced options
        _volumeKeys = Platform.isAndroid ? getBool(VOLUME_KEYS, doLog: true) : false;
        _keepScreenOn = Platform.isAndroid ? getBool(KEEP_SCREEN_ON, doLog: true) : false;
        _backAsReturn = Platform.isAndroid ? getBool(BACK_AS_RETURN, doLog: true) : false;
        _advancedQueue = getBool(ADVANCED_QUEUE, doLog: true);
        _keepPlaybackMode = getBool(KEEP_PLAYBACK_MODE, doLog: true);
        _exitConfirm = Platform.isAndroid ? getBool(EXIT_CONFIRM, doLog: true) : false;
        _developerMode = getBool(DEVELOPER_MODE, doLog: true);

        // Favorite connections
        favoriteConnections.read();
    }

    void saveDevice(final String device, final int port) async
    {
        _deviceName = device;
        _devicePort = port;
        await preferences.setString(SERVER_NAME.item1, device);
        await preferences.setInt(SERVER_PORT.item1, port);
    }

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
            saveStringParameter(Pair<String, String>(NETWORK_SERVICES,""), str, prefix: "  ");
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
            saveStringParameter(Pair<String, String>(DEVICE_SELECTORS,""), str, prefix: "  ");
        }
        audioControl.setReceiverInformation(stateManager);
        favoriteConnections.setReceiverInformation(stateManager);
    }
}
