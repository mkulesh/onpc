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

import 'package:shared_preferences/shared_preferences.dart';

import "../Platform.dart";
import "../constants/Strings.dart";
import "../iscp/messages/ListeningModeMsg.dart";
import "../iscp/state/ReceiverInformation.dart";
import "../utils/Logging.dart";
import "../utils/Pair.dart";

class Configuration
{
    static const String CONFIGURATION_EVENT = "CONFIG";
    final SharedPreferences preferences;
    String appVersion;

    // Theme
    static const Pair<String, String> THEME = Pair<String, String>("theme", Strings.pref_theme_default);
    String _theme;

    String get theme
    => _theme;

    set theme(String value)
    {
        _theme = value;
    }

    // Language
    static const Pair<String, String> LANGUAGE = Pair<String, String>("language", Strings.pref_language_default);
    String _language;

    String get language
    => _language;

    set language(String value)
    {
        _language = value;
    }

    // Text size
    static const Pair<String, String> TEXT_SIZE = Pair<String, String>("text_size", Strings.pref_text_size_default);
    String _textSize;

    String get textSize
    => _textSize;

    set textSize(String value)
    {
        _textSize = value;
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

    // Device options
    static const Pair<String, bool> AUTO_POWER = Pair<String, bool>("auto_power", false);
    bool _autoPower;

    bool get autoPower
    => _autoPower;

    static const Pair<String, bool> FRIENDLY_NAMES = Pair<String, bool>("friendly_names", true);
    bool _friendlyNames;

    bool get friendlyNames
    => _friendlyNames;

    static const Pair<String, String> SOUND_CONTROL = Pair<String, String>("sound_control", Strings.pref_sound_control_default);
    String _soundControl;

    String get soundControl
    => _soundControl;

    static const Pair<String, String> MODEL = Pair<String, String>("model", "NONE");

    static const String NETWORK_SERVICES = "network_services";
    static const String SELECTED_NETWORK_SERVICES = "selected_network_services";

    static const String DEVICE_SELECTORS = "device_selectors";
    static const String SELECTED_DEVICE_SELECTORS = "selected_device_selectors";

    static const List<ListeningMode> DEFAULT_LISTENING_MODES = [
        ListeningMode.MODE_00,
        ListeningMode.MODE_01,
        ListeningMode.MODE_09,
        ListeningMode.MODE_08,
        ListeningMode.MODE_0A,
        ListeningMode.MODE_11,
        ListeningMode.MODE_0C,
        ListeningMode.MODE_80,
        ListeningMode.MODE_82
    ];
    static const String SELECTED_LISTENING_MODES = "selected_listening_modes";

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

    Configuration(this.preferences, packageInfo)
    {
        this.appVersion = "v." + packageInfo.version;
        Logging.info(this, "Application started: " + appVersion + ", OS: " + Platform.operatingSystem);
    }

    void read()
    {
        Logging.info(this, "Reading configuration...");

        // Interface options
        _theme = getString(THEME, doLog: true);
        _language = getString(LANGUAGE, doLog: true);
        _textSize = getString(TEXT_SIZE, doLog: true);

        // Connection options
        _deviceName = getString(SERVER_NAME, doLog: true);
        _devicePort = getInt(SERVER_PORT, doLog: true);

        // Device options
        _autoPower = getBool(AUTO_POWER, doLog: true);
        _friendlyNames = getBool(FRIENDLY_NAMES, doLog: true);
        _soundControl = getString(SOUND_CONTROL, doLog: true);

        // Remote interface
        _riAmp = getBool(RI_AMP, doLog: true);
        _riCd = getBool(RI_CD, doLog: true);

        // Advanced options
        _keepPlaybackMode = getBool(KEEP_PLAYBACK_MODE, doLog: true);
        _volumeKeys = Platform.isAndroid ? getBool(VOLUME_KEYS, doLog: true) : false;
        _backAsReturn = Platform.isAndroid ? getBool(BACK_AS_RETURN, doLog: true) : false;
        _keepScreenOn = Platform.isAndroid ? getBool(KEEP_SCREEN_ON, doLog: true) : false;
        _exitConfirm = Platform.isAndroid ? getBool(EXIT_CONFIRM, doLog: true) : false;
        _developerMode = getBool(DEVELOPER_MODE, doLog: true);
    }

    String getString(Pair<String, String> par, {doLog = false})
    {
        String val = par.item2;
        try
        {
            final String v = preferences.getString(par.item1);
            val = v != null ? v : par.item2;
        }
        on Exception
        {
            // nothing to do
        }
        if (doLog)
        {
            Logging.info(this, "    " + par.item1 + ": " + val);
        }
        return val;
    }

    String getStringDef(String name, String def)
    => getString(Pair<String, String>(name, def));

    int getInt(Pair<String, int> par, {doLog = false})
    {
        int val = par.item2;
        try
        {
            final int v = preferences.getInt(par.item1);
            val = v != null ? v : par.item2;
        }
        on Exception
        {
            // nothing to do
        }
        if (doLog)
        {
            Logging.info(this, "    " + par.item1 + ": " + val.toString());
        }
        return val;
    }

    bool getBool(final Pair<String, bool> par, {doLog = false})
    {
        bool val = par.item2;
        try
        {
            final bool v = preferences.getBool(par.item1);
            val = v != null ? v : par.item2;
        }
        on Exception
        {
            // nothing to do
        }
        if (doLog)
        {
            Logging.info(this, "    " + par.item1 + ": " + val.toString());
        }
        return val;
    }

    void saveStringParameter(final Pair<String, String> par, final String value) async
    {
        Logging.info(this, "Save parameter: " + par.item1 + ":" + value);
        await preferences.setString(par.item1, value);
    }

    void saveDevice(final String device, final int port) async
    {
        _deviceName = device;
        _devicePort = port;
        await preferences.setString(SERVER_NAME.item1, device);
        await preferences.setInt(SERVER_PORT.item1, port);
    }

    void setReceiverInformation(ReceiverInformation state)
    {
        Logging.info(this, "Updating configuration...");
        preferences.setString(MODEL.item1, state.model);
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
            Logging.info(this, "    Network services: " + str);
            preferences.setString(NETWORK_SERVICES, str);
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
            Logging.info(this, "    Device selectors: " + str);
            preferences.setString(DEVICE_SELECTORS, str);
        }
    }

    List<String> getTokens(final String par)
    {
        final String cfg = preferences.getString(par);
        return (cfg == null || cfg.isEmpty) ? null : cfg.split(",");
    }

    void saveTokens(final String par, final String val)
    {
        Logging.info(this, "saving " + par + ": " + val);
        preferences.setString(par, val);
    }

    String getModelDependentParameter(final String par)
    => par + "_" + getString(MODEL);
}
