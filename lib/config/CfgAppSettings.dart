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

import 'dart:ui';

import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../constants/Strings.dart";
import "../constants/Themes.dart";
import "../iscp/ConnectionIf.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/ReceiverInformationMsg.dart";
import "../utils/Convert.dart";
import "../utils/Logging.dart";
import "../utils/Pair.dart";
import "../utils/Platform.dart";
import "CfgModule.dart";
import "CfgTabSettings.dart";
import "CheckableItem.dart";

// Tabs
enum AppTabs
{
    LISTEN,
    MEDIA,
    SHORTCUTS,
    DEVICE,
    RC,
    RI,
}

enum MediaSortMode
{
    ITEM_NAME,
    ARTIST_ALBUM
}

typedef OnKeyboardShortcut = void Function(String par, String shortcut);

class CfgAppSettings extends CfgModule
{
    // Theme
    static const Pair<String, String> THEME = Pair<String, String>("theme", Strings.pref_theme_default);
    String _theme = THEME.item2;

    String get theme
    => _theme;

    set theme(String value)
    {
        _theme = value;
        saveStringParameter(THEME, value);
    }

    // Widget theme
    static const Pair<String, String> WIDGET_THEME = Pair<String, String>("widget_theme", Strings.pref_theme_default);
    // Note: these constants are used by widget only and have default values from indigo-orange theme
    static const Pair<String, bool> WIDGET_TRANSPARENCY = Pair<String, bool>("widget_transparency", true);
    static const Pair<String, bool> WIDGET_DARK_THEME = Pair<String, bool>("widget_dark_theme", false);
    static const Pair<String, int> WIDGET_H_TEXT = Pair<String, int>("widget_h_text", 0xFFFF9800);
    static const Pair<String, int> WIDGET_B_TEXT = Pair<String, int>("widget_b_text", 0xFF212121);

    set widgetTheme(String value)
    {
        saveStringParameter(WIDGET_THEME, value);
        final BaseAppTheme td = BaseAppTheme.getTheme(value);
        saveBoolParameter(WIDGET_DARK_THEME, td.brightness == Brightness.dark);
        saveIntegerParameter(WIDGET_H_TEXT, td.accentColor.value);
        saveIntegerParameter(WIDGET_B_TEXT, td.textColor.value);
    }

    // System language
    static const Locale DEFAULT_LOCALE = Locale("en", "US");
    Locale _systemLocale = DEFAULT_LOCALE;

    set systemLocale(Locale value)
    {
        _systemLocale = value;
        Logging.info(this, "system locale: " + _systemLocale.toString());
    }

    // Language
    static const Pair<String, String> LANGUAGE = Pair<String, String>("language", Strings.pref_language_default);
    String _language = LANGUAGE.item2;

    String get language
    {
        if (_language == "system")
        {
            return Strings.app_languages.contains(_systemLocale.languageCode) ?
            _systemLocale.languageCode : DEFAULT_LOCALE.languageCode;
        }
        return _language;
    }

    set language(String value)
    {
        _language = value;
        saveStringParameter(LANGUAGE, value);
    }

    // Text size
    static const Pair<String, String> TEXT_SIZE = Pair<String, String>("text_size", Strings.pref_text_size_default);
    String _textSize = TEXT_SIZE.item2;

    String get textSize
    => _textSize;

    set textSize(String value)
    {
        _textSize = value;
        saveStringParameter(TEXT_SIZE, value);
    }

    // The latest opened tab
    static const Pair<String, String> OPENED_TAB_NAME = Pair<String, String>("opened_tab_name", "LISTEN");
    AppTabs _openedTab = AppTabs.LISTEN;

    AppTabs get openedTab
    => _openedTab;

    set openedTab(AppTabs value)
    {
        _openedTab = value;
        saveStringParameter(OPENED_TAB_NAME, Convert.enumToString(value));
    }

    int getTabIndex(AppTabs tab)
    {
        for (int i = 0; i < _visibleTabs.length; i++)
        {
            if (tab == _visibleTabs[i])
            {
                return i;
            }
        }
        return 0;
    }

    // Visible tabs
    static final String VISIBLE_TABS = "visible_tabs";
    final List<AppTabs> _visibleTabs = [];

    List<AppTabs> get visibleTabs
    => _visibleTabs;

    bool get isSingleTab
    => _visibleTabs.length <= 1;

    static bool isTabEnabled(AppTabs t, ProtoType protoType)
    {
        switch(t)
        {
            case AppTabs.SHORTCUTS:
            case AppTabs.RI:
                return protoType == ProtoType.ISCP;
            default:
                return true;
        }
    }

    // Tab settings
    final List<CfgTabSettings> _tabSettings = [];

    CfgTabSettings tabSettings(AppTabs t)
    => _tabSettings[t.index];

    // Media list sort mode
    static const Pair<String, String> MEDIA_SORT_MODE = Pair<String, String>("media_sort_mode", "ITEM_NAME");
    MediaSortMode _mediaSortMode = MediaSortMode.ITEM_NAME;

    MediaSortMode get mediaSortMode
    => _mediaSortMode;

    set mediaSortMode(MediaSortMode value)
    {
        _mediaSortMode = value;
        saveStringParameter(MEDIA_SORT_MODE, Convert.enumToString(value));
    }

    // Window size and position for desktop app
    static const Pair<String, int> WINDOW_WIDTH = Pair<String, int>("window_width", 350);
    int _windowWidth = WINDOW_WIDTH.item2;

    static const Pair<String, int> WINDOW_HEIGHT = Pair<String, int>("window_height", 720);
    int _windowHeight = WINDOW_HEIGHT.item2;

    static const Pair<String, int> WINDOW_OFFSET_X = Pair<String, int>("window_offset_x", 100);
    int _windowOffsetX = WINDOW_OFFSET_X.item2;

    static const Pair<String, int> WINDOW_OFFSET_Y = Pair<String, int>("window_offset_y", 100);
    int _windowOffsetY = WINDOW_OFFSET_Y.item2;

    Size windowSize()
    => Size(_windowWidth.toDouble(), _windowHeight.toDouble());

    Offset windowOffset()
    => Offset(_windowOffsetX.toDouble(), _windowOffsetY.toDouble());

    set windowFrame(Rect s)
    {
        final int offsetX = s.left.ceil();
        final int width = s.right.ceil() - offsetX;
        if (_windowWidth != width)
        {
            _windowWidth = width;
            saveIntegerParameter(WINDOW_WIDTH, _windowWidth);
        }
        final int offsetY = s.top.ceil();
        final int height = s.bottom.ceil() - offsetY;
        if (_windowHeight != height)
        {
            _windowHeight = height;
            saveIntegerParameter(WINDOW_HEIGHT, _windowHeight);
        }
        if (offsetX != _windowOffsetX)
        {
            _windowOffsetX = offsetX;
            saveIntegerParameter(WINDOW_OFFSET_X, _windowOffsetX);
        }
        if (offsetY != _windowOffsetY)
        {
            _windowOffsetY = offsetY;
            saveIntegerParameter(WINDOW_OFFSET_Y, _windowOffsetY);
        }
    }

    // Keyboard shortcuts
    static const List<Pair<String, String>> KEYBOARD_SHORTCUTS = [
        Pair<String, String>("ks_volume_up", "Alt + Num +"),
        Pair<String, String>("ks_volume_down", "Alt + Num -"),
        Pair<String, String>("ks_volume_mute", "Alt + Num *"),
        Pair<String, String>("ks_volume_trdn", "Alt + Num 4"),
        Pair<String, String>("ks_volume_play", "Alt + Num 8"),
        Pair<String, String>("ks_volume_stop", "Alt + Num 2"),
        Pair<String, String>("ks_volume_trup", "Alt + Num 6"),
    ];
    final Map<String, String> _keyboardShortcuts = Map();

    String getKeyboardShortcut(final String par)
    => _keyboardShortcuts.containsKey(par)? _keyboardShortcuts[par]! : "";

    void updateKeyboardShortcut(final String par, final String value)
    {
        if (_keyboardShortcuts.containsKey(par))
        {
            _keyboardShortcuts[par] = value;
            saveStringParameter(Pair<String, String>(par, ""), value);
        }
    }

    // Capture keyboard shortcuts
    Pair<String, OnKeyboardShortcut>? _captureKeyboardShortcut;

    void captureKeyboardShortcut(OnKeyboardShortcut? handler, {String parameter = ""})
    {
        if (handler != null)
        {
            Logging.info(this, "Waiting for keyboard shortcut for " + parameter);
            _captureKeyboardShortcut = Pair<String, OnKeyboardShortcut>(parameter, handler);
        }
        else if (_captureKeyboardShortcut != null)
        {
            Logging.info(this, "Cancelled keyboard shortcut for " + _captureKeyboardShortcut!.item1);
            _captureKeyboardShortcut = null;
        }
    }

    bool isWaitingForShortcut(final String par)
    => _captureKeyboardShortcut != null && _captureKeyboardShortcut!.item1 == par;

    bool processKeyboardShortcut(final String shortcut)
    {
        if (_captureKeyboardShortcut != null)
        {
            _captureKeyboardShortcut!.item2(_captureKeyboardShortcut!.item1, shortcut);
            return true;
        }
        return false;
    }

    // Device Settings names
    static const String DEVICE_SETTING = "device_setting";

    void saveDeviceSetting(final String type, final String par, final String name)
    {
        final Pair<String, String> key = Pair((DEVICE_SETTING + "_" + type + "_" + par).toLowerCase(), "");
        name.isNotEmpty ? saveStringParameter(key, name) : deleteParameter(key);
    }

    String readDeviceSetting(final String type, final String par, final String def)
    => getString(Pair((DEVICE_SETTING + "_" + type + "_" + par).toLowerCase(), def));

    // Zone names
    static const String ZONE_NAME = "zone_name";

    void saveZoneName(final Zone zone, final String name)
    {
        final Pair<String, String> key = Pair((ZONE_NAME + "_" + zone.getId).toLowerCase(), "");
        name.isNotEmpty ? saveStringParameter(key, name) : deleteParameter(key);
    }

    String readZoneName(final Zone zone)
    => getString(Pair((ZONE_NAME + "_" + zone.getId).toLowerCase(), zone.getName));

    // methods
    CfgAppSettings(final SharedPreferences preferences) : super(preferences);

    @override
    void read({ProtoType? protoType})
    {
        _theme = getString(THEME, doLog: true);
        _language = getString(LANGUAGE, doLog: true);
        _textSize = getString(TEXT_SIZE, doLog: true);
        final String tab = getString(OPENED_TAB_NAME, doLog: true);
        _openedTab = AppTabs.values.firstWhere((t)
            => Convert.enumToString(t) == tab, orElse: () => AppTabs.values.first);
        final String sortMode = getString(MEDIA_SORT_MODE, doLog: true);
        _mediaSortMode = MediaSortMode.values.firstWhere((t)
            => Convert.enumToString(t) == sortMode, orElse: () => MediaSortMode.values.first);
        _readVisibleTabs(protoType);
        _readControlElements();
        if (Platform.isDesktop)
        {
            _windowWidth = getInt(WINDOW_WIDTH, doLog: true);
            _windowHeight = getInt(WINDOW_HEIGHT, doLog: true);
            _windowOffsetX = getInt(WINDOW_OFFSET_X, doLog: true);
            _windowOffsetY = getInt(WINDOW_OFFSET_Y, doLog: true);
        }
        if (Platform.isWindows)
        {
            KEYBOARD_SHORTCUTS.forEach((shortcut)
            => _keyboardShortcuts[shortcut.item1] = getString(shortcut, doLog: true));
        }
    }

    @override
    void setReceiverInformation(StateManager stateManager)
    {
        _readVisibleTabs(stateManager.protoType);
    }

    static String getTabName(AppTabs item)
    {
        return item.index < Strings.pref_visible_tabs_names.length ? Strings.pref_visible_tabs_names[item.index].toUpperCase() : "";
    }

    void _readVisibleTabs(ProtoType? protoType)
    {
        _visibleTabs.clear();
        final List<String> defItems = [];
        AppTabs.values.forEach((i) => defItems.add(Convert.enumToString(i)));
        for (CheckableItem sp in CheckableItem.readFromPreference(this, VISIBLE_TABS, defItems))
        {
            for (AppTabs i in AppTabs.values)
            {
                if (protoType != null && !isTabEnabled(i, protoType))
                {
                    continue;
                }
                if (sp.checked && Convert.enumToString(i) == sp.code)
                {
                    _visibleTabs.add(i);
                }
            }
        }
        Logging.info(this, "  " + VISIBLE_TABS + ": " + _visibleTabs.toString());
    }

    void _readControlElements()
    {
        _tabSettings.clear();
        _tabSettings.add(CfgTabSettings(this, AppTabs.LISTEN,
            controlsPortrait: [
                AppControl.LISTENING_MODE_LIST,
                AppControl.AUDIO_CONTROL,
                AppControl.TRACK_FILE_INFO,
                AppControl.TRACK_COVER,
                AppControl.TRACK_TIME,
                AppControl.TRACK_CAPTION,
                AppControl.PLAY_CONTROL
            ],
            controlsLandscapeLeft: [
                AppControl.TRACK_COVER
            ],
            controlsLandscapeRight: [
                AppControl.LISTENING_MODE_LIST,
                AppControl.AUDIO_CONTROL,
                AppControl.TRACK_FILE_INFO,
                AppControl.TRACK_TIME,
                AppControl.TRACK_CAPTION,
                AppControl.PLAY_CONTROL
            ])
        );
        _tabSettings.add(CfgTabSettings(this, AppTabs.MEDIA,
            controlsPortrait: [
                AppControl.INPUT_SELECTOR,
                AppControl.MEDIA_LIST
            ],
            controlsLandscapeLeft: [
                AppControl.INPUT_SELECTOR,
                AppControl.MEDIA_LIST
            ],
            controlsLandscapeRight: [])
        );
        _tabSettings.add(CfgTabSettings(this, AppTabs.SHORTCUTS,
            controlsPortrait: [
                AppControl.SHORTCUTS
            ],
            controlsLandscapeLeft: [
                AppControl.SHORTCUTS
            ],
            controlsLandscapeRight: [])
        );
        _tabSettings.add(CfgTabSettings(this, AppTabs.DEVICE,
            controlsPortrait: [
                AppControl.DEVICE_INFO,
                AppControl.DIVIDER1,
                AppControl.DEVICE_SETTINGS
            ],
            controlsLandscapeLeft: [
                AppControl.DEVICE_INFO
            ],
            controlsLandscapeRight: [
                AppControl.DEVICE_SETTINGS
            ])
        );
        _tabSettings.add(CfgTabSettings(this, AppTabs.RC,
            controlsPortrait: [
                AppControl.SETUP_OP_CMD,
                AppControl.DIVIDER1,
                AppControl.SETUP_NAV_CMD,
                AppControl.DIVIDER2,
                AppControl.LISTENING_MODE_SWITCH
            ],
            controlsLandscapeLeft: [
                AppControl.SETUP_OP_CMD,
                AppControl.DIVIDER1,
                AppControl.LISTENING_MODE_SWITCH
            ],
            controlsLandscapeRight: [
                AppControl.SETUP_NAV_CMD
            ])
        );
        _tabSettings.add(CfgTabSettings(this, AppTabs.RI,
            controlsPortrait: [
                AppControl.RI_AMPLIFIER,
                AppControl.DIVIDER1,
                AppControl.RI_CD_PLAYER
            ],
            controlsLandscapeLeft: [
                AppControl.RI_AMPLIFIER
            ],
            controlsLandscapeRight: [
                AppControl.RI_CD_PLAYER
            ])
        );
        _tabSettings.forEach((c)
        {
            c.read();
        });
    }

    void toggleSortMode()
    {
        switch (mediaSortMode)
        {
            case MediaSortMode.ITEM_NAME:
                mediaSortMode = MediaSortMode.ARTIST_ALBUM;
                break;
            case MediaSortMode.ARTIST_ALBUM:
                mediaSortMode = MediaSortMode.ITEM_NAME;
                break;
        }
    }
}
