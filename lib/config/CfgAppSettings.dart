/*
 * Copyright (C) 2020. Mikhail Kulesh
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

import "package:shared_preferences/shared_preferences.dart";

import "../constants/Strings.dart";
import "../iscp/StateManager.dart";
import "../utils/Convert.dart";
import "../utils/Logging.dart";
import "../utils/Pair.dart";
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

class CfgAppSettings extends CfgModule
{
    // Theme
    static const Pair<String, String> THEME = Pair<String, String>("theme", Strings.pref_theme_default);
    String _theme;

    String get theme
    => _theme;

    set theme(String value)
    {
        _theme = value;
        saveStringParameter(THEME, value);
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
        saveStringParameter(LANGUAGE, value);
    }

    // Text size
    static const Pair<String, String> TEXT_SIZE = Pair<String, String>("text_size", Strings.pref_text_size_default);
    String _textSize;

    String get textSize
    => _textSize;

    set textSize(String value)
    {
        _textSize = value;
        saveStringParameter(TEXT_SIZE, value);
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

    // Visible tabs
    static final String VISIBLE_TABS = "visible_tabs";
    final List<AppTabs> _visibleTabs = List();

    List<AppTabs> get visibleTabs
    => _visibleTabs;

    // Tab settings
    final List<CfgTabSettings> _tabSettings = List();

    CfgTabSettings tabSettings(AppTabs t)
    => t != null ? _tabSettings[t.index] : null;

    // methods
    CfgAppSettings(final SharedPreferences preferences) : super(preferences);

    @override
    void read()
    {
        _theme = getString(THEME, doLog: true);
        _language = getString(LANGUAGE, doLog: true);
        _textSize = getString(TEXT_SIZE, doLog: true);
        _openedTab = getInt(OPENED_TAB, doLog: true);
        _readVisibleTabs();
        _readControlElements();
    }

    @override
    void setReceiverInformation(StateManager stateManager)
    {
        // empty
    }

    static String getTabName(AppTabs item)
    {
        return item.index < Strings.pref_visible_tabs_names.length ? Strings.pref_visible_tabs_names[item.index].toUpperCase() : "";
    }

    void _readVisibleTabs()
    {
        _visibleTabs.clear();
        final List<String> defItems = List();
        AppTabs.values.forEach((i) => defItems.add(Convert.enumToString(i)));
        for (CheckableItem sp in CheckableItem.readFromPreference(this, VISIBLE_TABS, defItems))
        {
            for (AppTabs i in AppTabs.values)
            {
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
                AppControl.DEVICE_SETTINGS
            ],
            controlsLandscapeLeft: [
                AppControl.DEVICE_INFO,
                AppControl.DEVICE_SETTINGS
            ],
            controlsLandscapeRight: [])
        );
        _tabSettings.add(CfgTabSettings(this, AppTabs.RC,
            controlsPortrait: [
                AppControl.SETUP_OP_CMD,
                AppControl.DIVIDER1,
                AppControl.SETUP_NAV_CMD,
                AppControl.LISTENING_MODE_BTN
            ],
            controlsLandscapeLeft: [
                AppControl.SETUP_OP_CMD,
                AppControl.DIVIDER1,
                AppControl.SETUP_NAV_CMD,
                AppControl.LISTENING_MODE_BTN
            ],
            controlsLandscapeRight: [])
        );
        _tabSettings.add(CfgTabSettings(this, AppTabs.RI,
            controlsPortrait: [
                AppControl.RI_AMPLIFIER,
                AppControl.RI_CD_PLAYER
            ],
            controlsLandscapeLeft: [
                AppControl.RI_AMPLIFIER,
                AppControl.RI_CD_PLAYER
            ],
            controlsLandscapeRight: [])
        );
        _tabSettings.forEach((c)
        {
            if (_visibleTabs.contains(c.tab))
            {
                c.read();
            }
        });
    }
}
