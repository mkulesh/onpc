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
import "../constants/Strings.dart";
import "../iscp/messages/EnumParameterMsg.dart";
import "../utils/Convert.dart";
import "../utils/Logging.dart";
import "../utils/Pair.dart";
import "CfgAppSettings.dart";
import "CfgModule.dart";
import "CheckableItem.dart";

// Control elements
enum AppControl
{
    DIVIDER1,
    DIVIDER2,
    DIVIDER3,
    DIVIDER4,
    DIVIDER5,
    LISTENING_MODE_LIST,
    LISTENING_MODE_SWITCH,
    LISTENING_MODE_GROUPS,
    AUDIO_CONTROL,
    TRACK_FILE_INFO,
    TRACK_COVER,
    TRACK_TIME,
    TRACK_CAPTION,
    PLAY_CONTROL,
    SHORTCUTS,
    INPUT_SELECTOR,
    MEDIA_LIST,
    SETUP_OP_CMD,
    SETUP_NAV_CMD,
    DEVICE_INFO,
    DEVICE_SETTINGS,
    RI_AMPLIFIER,
    RI_CD_PLAYER,
    RI_MD_PLAYER,
    RI_TAPE_DECK,
}

enum AppControlGroup
{
    PORTRAIT,
    LAND_LEFT,
    LAND_RIGHT
}

class CfgTabSettings
{
    static const ExtEnum<AppControl> ValueEnum = ExtEnum<AppControl>([
        EnumItem.code(AppControl.DIVIDER1, "DV1", descrList: Strings.l_app_control_divider, defValue: true),
        EnumItem.code(AppControl.DIVIDER2, "DV2", descrList: Strings.l_app_control_divider),
        EnumItem.code(AppControl.DIVIDER3, "DV3", descrList: Strings.l_app_control_divider),
        EnumItem.code(AppControl.DIVIDER4, "DV4", descrList: Strings.l_app_control_divider),
        EnumItem.code(AppControl.DIVIDER5, "DV5", descrList: Strings.l_app_control_divider),
        EnumItem.code(AppControl.LISTENING_MODE_LIST, "LML", descrList: Strings.l_app_control_listening_mode_list),
        EnumItem.code(AppControl.LISTENING_MODE_SWITCH, "LMB", descrList: Strings.l_app_control_listening_mode_switch),
        EnumItem.code(AppControl.LISTENING_MODE_GROUPS, "LMG", descrList: Strings.l_app_control_listening_mode_groups),
        EnumItem.code(AppControl.AUDIO_CONTROL, "ACT", descrList: Strings.l_app_control_audio_control),
        EnumItem.code(AppControl.TRACK_FILE_INFO, "TFI", descrList: Strings.l_app_control_track_file_info),
        EnumItem.code(AppControl.TRACK_COVER, "TCO", descrList: Strings.l_app_control_track_cover),
        EnumItem.code(AppControl.TRACK_TIME, "TTM", descrList: Strings.l_app_control_track_time),
        EnumItem.code(AppControl.TRACK_CAPTION, "TCA", descrList: Strings.l_app_control_track_caption),
        EnumItem.code(AppControl.PLAY_CONTROL, "PLC", descrList: Strings.l_app_control_play_control),
        EnumItem.code(AppControl.SHORTCUTS, "SHR", descrList: Strings.l_app_control_shortcuts),
        EnumItem.code(AppControl.INPUT_SELECTOR, "INP", descrList: Strings.l_app_control_input_selector),
        EnumItem.code(AppControl.MEDIA_LIST, "MLI", descrList: Strings.l_app_control_media_list),
        EnumItem.code(AppControl.SETUP_OP_CMD, "COC", descrList: Strings.l_app_control_setup_op_cmd),
        EnumItem.code(AppControl.SETUP_NAV_CMD, "CNC", descrList: Strings.l_app_control_setup_nav_cmd),
        EnumItem.code(AppControl.DEVICE_INFO, "DIN", descrList: Strings.l_app_control_device_info),
        EnumItem.code(AppControl.DEVICE_SETTINGS, "DST", descrList: Strings.l_app_control_device_settings),
        EnumItem.code(AppControl.RI_AMPLIFIER, "RIA", descrList: Strings.l_app_control_ri_amplifier),
        EnumItem.code(AppControl.RI_CD_PLAYER, "RIC", descrList: Strings.l_app_control_ri_cd_player),
        EnumItem.code(AppControl.RI_MD_PLAYER, "RIM", descrList: Strings.l_app_control_ri_md_player),
        EnumItem.code(AppControl.RI_TAPE_DECK, "RIT", descrList: Strings.l_app_control_ri_tape_deck),
    ]);

    static final String TAB_SETTINGS = "tab_settings";

    final CfgModule configuration;
    final AppTabs tab;
    List<AppControl> controlsPortrait;
    List<AppControl> controlsLandscapeLeft;
    List<AppControl> controlsLandscapeRight;

    static final String COLUMN_SEPARATOR = "column_separator";
    int _columnSeparator;

    int get columnSeparator
    => _columnSeparator;

    set columnSeparator(int value)
    {
        _columnSeparator = value;
        configuration.saveIntegerParameter(getColumnSeparatorName(tab, 0), _columnSeparator);
    }

    CfgTabSettings(this.configuration, this.tab,
    {
        this.controlsPortrait,
        this.controlsLandscapeLeft,
        this.controlsLandscapeRight
    });

    void read()
    {
        controlsPortrait = _readVisibleControls(AppControlGroup.PORTRAIT, controlsPortrait);
        controlsLandscapeLeft = _readVisibleControls(AppControlGroup.LAND_LEFT, controlsLandscapeLeft);
        controlsLandscapeRight = _readVisibleControls(AppControlGroup.LAND_RIGHT, controlsLandscapeRight);
        final int defSeparator = tab == AppTabs.LISTEN ? 33 : 50;
        _columnSeparator = configuration.getInt(getColumnSeparatorName(tab, defSeparator), doLog: true);
    }

    static Pair<String, int> getColumnSeparatorName(final AppTabs tab, final int defValue)
    => Pair<String, int>(COLUMN_SEPARATOR + "_" + Convert.enumToString(tab).toLowerCase(), defValue);

    static String getParameterName(final AppTabs tab, final AppControlGroup type)
    => TAB_SETTINGS + "_" + Convert.enumToString(tab).toLowerCase() + "_" + Convert.enumToString(type).toLowerCase();

    List<AppControl> _readVisibleControls(final AppControlGroup type, List<AppControl> defItems)
    {
        final List<AppControl> res = [];
        final String par = getParameterName(tab, type);
        for (CheckableItem sp in CheckableItem.readFromPreference(configuration, par, []))
        {
            ValueEnum.values.forEach((m)
            {
                if (sp.checked && m.getCode == sp.code)
                {
                    res.add(m.key);
                }
            });
        }
        if (res.isEmpty && configuration.getStringDef(par, "").isEmpty)
        {
            if (defItems == null)
            {
                return null;
            }
            res.addAll(defItems);
        }
        Logging.info(this, "  " + par + ": " + res.toString());
        return res;
    }

    void createCheckableItems(final List<CheckableItem> _items, final AppControlGroup type, final List<AppControl> actualItems)
    {
        final List<String> defItems = [];
        CfgTabSettings.ValueEnum.values.forEach((m) => defItems.add(m.code));
        // Add currently selected controls on the top
        actualItems.forEach((c)
        {
            final EnumItem<AppControl> m = CfgTabSettings.ValueEnum.valueByKey(c);
            _items.add(CheckableItem(m.code, m.description, true));
        });
        // Add other non-selected controls
        for (CheckableItem sp in CheckableItem.readFromPreference(configuration, getParameterName(tab, type), defItems))
        {
            CfgTabSettings.ValueEnum.values.forEach((m)
            {
                if (m.code == sp.code && !actualItems.contains(m.key))
                {
                    _items.add(CheckableItem(m.code, m.description, false));
                }
            });
        }
    }

    bool isControlActive(final AppControl c, bool isPortrait)
    {
        if (isPortrait)
        {
            return controlsPortrait != null && controlsPortrait.contains(c);
        }
        else
        {
            return (controlsLandscapeLeft != null && controlsLandscapeLeft.contains(c)) ||
                   (controlsLandscapeRight != null && controlsLandscapeRight.contains(c));
        }
    }
}