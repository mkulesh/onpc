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

import 'dart:ui';

import "package:flutter/material.dart";
import "package:onpc/constants/Themes.dart";
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

    // Widget theme
    static const Pair<String, String> WIDGET_THEME = Pair<String, String>("widget_theme", Strings.pref_theme_default);
    // Note: these constants have default values from indigo-orange theme
    static const Pair<String, int> WIDGET_H_BACKGROUND = Pair<String, int>("widget_h_background", 0xFF3F51B5);
    static const Pair<String, int> WIDGET_H_TEXT = Pair<String, int>("widget_h_text", 0xFFFF9800);
    static const Pair<String, int> WIDGET_B_BACKGROUND = Pair<String, int>("widget_b_background", 0xFFFAFAFA);
    static const Pair<String, int> WIDGET_B_TEXT = Pair<String, int>("widget_b_text", 0xFF212121);

    set widgetTheme(String value)
    {
        saveStringParameter(WIDGET_THEME, value);
        final BaseAppTheme td = BaseAppTheme.getTheme(value);
        saveIntegerParameter(WIDGET_H_BACKGROUND, td.primaryColor.value);
        saveIntegerParameter(WIDGET_H_TEXT, td.accentColor.value);
        saveIntegerParameter(WIDGET_B_BACKGROUND, td.backgroundColor.value);
        saveIntegerParameter(WIDGET_B_TEXT, td.textColor.value);
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
    static const Pair<String, String> OPENED_TAB_NAME = Pair<String, String>("opened_tab_name", "LISTEN");
    AppTabs _openedTab;

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
    final List<AppTabs> _visibleTabs = List();

    List<AppTabs> get visibleTabs
    => _visibleTabs;

    bool get isSingleTab
    => _visibleTabs.length <= 1;

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
        final String tab = getString(OPENED_TAB_NAME, doLog: true);
        _openedTab = AppTabs.values.isEmpty ? AppTabs.LISTEN :
            AppTabs.values.firstWhere((t) => Convert.enumToString(t) == tab, orElse: () => AppTabs.values.first);
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
                AppControl.LISTENING_MODE_BTN
            ],
            controlsLandscapeLeft: [
                AppControl.SETUP_OP_CMD,
                AppControl.DIVIDER1,
                AppControl.LISTENING_MODE_BTN
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
            if (_visibleTabs.contains(c.tab))
            {
                c.read();
            }
        });
    }
}
