/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2022 by Mikhail Kulesh
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
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import "../Platform.dart";
import "../constants/Activities.dart";
import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../constants/Themes.dart";
import "../dialogs/DropdownPreferenceDialog.dart";
import "../utils/Pair.dart";
import "../widgets/CustomActivityTitle.dart";
import "../widgets/CustomDivider.dart";
import "../widgets/PreferenceTitle.dart";
import "../widgets/SwitchPreference.dart";
import "CfgAppSettings.dart";
import "CfgAudioControl.dart";
import "CfgRiCommands.dart";
import "Configuration.dart";

class PreferencesMain extends StatefulWidget
{
    final Configuration configuration;

    PreferencesMain(this.configuration);

    @override
    _PreferencesMainState createState()
    => _PreferencesMainState(configuration);
}

class _PreferencesMainState extends State<PreferencesMain>
{
    final Configuration _configuration;

    _PreferencesMainState(this._configuration);

    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = BaseAppTheme.getThemeData(
            _configuration.appSettings.theme, _configuration.appSettings.language, _configuration.appSettings.textSize);

        final List<Widget> elements = [];

        // Theme
        elements.add(_customDropdownPreference(td,
            Strings.pref_theme,
            CfgAppSettings.THEME,
            icon: Drawables.pref_app_theme,
            values: Strings.pref_theme_codes,
            displayValues: Strings.pref_theme_names,
            onChange: (String val)
            {
                setState(()
                {
                    _configuration.appSettings.theme = val;
                });
            }));

        // Widget Theme
        if (Platform.isAndroid)
        {
            elements.add(_customDropdownPreference(td,
                Strings.pref_widget_theme,
                CfgAppSettings.WIDGET_THEME,
                icon: Drawables.pref_widget_theme,
                values: Strings.pref_theme_codes,
                displayValues: Strings.pref_theme_names,
                onChange: (String val)
                {
                    setState(()
                    {
                        _configuration.appSettings.widgetTheme = val;
                    });
                }));
        }

        // Language
        elements.add(_customDropdownPreference(td,
            Strings.pref_language,
            CfgAppSettings.LANGUAGE,
            icon: Drawables.pref_language,
            values: Strings.pref_language_codes,
            displayValues: Strings.pref_language_names,
            onChange: (String val)
            {
                setState(()
                {
                    _configuration.appSettings.language = val;
                });
            }));

        // Text size
        elements.add(_customDropdownPreference(td,
            Strings.pref_text_size,
            CfgAppSettings.TEXT_SIZE,
            icon: Drawables.pref_text_size,
            values: Strings.pref_text_size_codes,
            displayValues: Strings.pref_text_size_names,
            onChange: (String val)
            {
                setState(()
                {
                    _configuration.appSettings.textSize = val;
                });
            }));

        // Visible tabs
        elements.add(_customPreferenceScreen(td,
            Strings.pref_visible_tabs,
            icon: Drawables.pref_visible_tabs,
            activity: Activities.activity_visible_tabs));

        // Device options
        elements.add(CustomDivider());
        elements.add(PreferenceTitle(Strings.pref_category_device_options));
        elements.add(_customSwitchPreference(td,
            Strings.pref_auto_power,
            Configuration.AUTO_POWER,
            icon: Drawables.pref_auto_power));
        elements.add(_customSwitchPreference(td,
            Strings.pref_friendly_names,
            Configuration.FRIENDLY_NAMES,
            icon: Drawables.pref_friendly_name,
            desc: Strings.pref_friendly_names_summary_on));
        elements.add(_customPreferenceScreen(td,
            Strings.pref_device_selectors,
            icon: Drawables.pref_device_selectors,
            activity: Activities.activity_device_selectors));
        elements.add(_customPreferenceScreen(td,
            Strings.pref_network_services,
            icon: Drawables.pref_network_services,
            activity: Activities.activity_network_services));

        // Audio control
        elements.add(CustomDivider());
        elements.add(PreferenceTitle(Strings.app_control_audio_control));
        elements.add(_customDropdownPreference(td,
            Strings.pref_sound_control,
            CfgAudioControl.SOUND_CONTROL,
            icon: Drawables.pref_sound_control,
            values: Strings.pref_sound_control_codes,
            displayValues: Strings.pref_sound_control_names,
            onChange: (String val)
            {
                setState(()
                {
                    _configuration.audioControl.soundControl = val;
                });
            }));
        elements.add(_customPreferenceScreen(td,
            Strings.pref_listening_modes,
            icon: Drawables.pref_listening_modes,
            activity: Activities.activity_listening_modes));
        if (Platform.isAndroid)
        {
            elements.add(_customSwitchPreference(td,
                Strings.pref_volume_title,
                CfgAudioControl.VOLUME_KEYS,
                icon: Drawables.pref_volume_keys,
                desc: Strings.pref_volume_summary));
        }
        elements.add(_customSwitchPreference(td,
            Strings.pref_force_audio_control,
            CfgAudioControl.FORCE_AUDIO_CONTROL,
            icon: Drawables.volume_audio_control));

        // Advanced options
        elements.add(CustomDivider());
        elements.add(PreferenceTitle(Strings.pref_category_advanced_options));

        if (Platform.isWindows)
        {
            elements.add(_customPreferenceScreen(td,
                Strings.pref_keyboard_shortcuts,
                icon: Drawables.keyboard_shortcuts,
                activity: Activities.activity_keyboard_shortcuts));
        }

        if (Platform.isDesktop)
        {
            final List<String> values = [ "" ];
            final List<String> displayValues = [ Strings.pref_usb_ri_interface_none ];
            _configuration.riCommands.ports.forEach((p)
            {
                values.add(p.item1);
                displayValues.add(p.item2);
            });
            elements.add(_customDropdownPreference(td,
                Strings.pref_usb_ri_interface,
                CfgRiCommands.USB_PORT,
                icon: Drawables.pref_usb_ri_interface,
                values: values,
                displayValues: displayValues,
                onChange: (String val)
                {
                    setState(()
                    {
                        _configuration.riCommands.usbPort = val;
                    });
                }));
        }

        if (Platform.isAndroid)
        {
            elements.add(_customSwitchPreference(td,
                Strings.pref_keep_screen_on,
                Configuration.KEEP_SCREEN_ON,
                icon: Drawables.pref_keep_screen_on));
            elements.add(_customSwitchPreference(td,
                Strings.pref_back_as_return,
                Configuration.BACK_AS_RETURN,
                icon: Drawables.cmd_return,
                desc: Strings.pref_back_as_return_summary));
        }

        elements.add(_customSwitchPreference(td,
            Strings.pref_advanced_queue,
            Configuration.ADVANCED_QUEUE,
            icon: Drawables.pref_advanced_queue,
            desc: Strings.pref_advanced_queue_summary));

        elements.add(_customSwitchPreference(td,
            Strings.pref_keep_playback_mode,
            Configuration.KEEP_PLAYBACK_MODE,
            icon: Drawables.cmd_track_menu,
            desc: Strings.pref_keep_playback_mode_summary));

        if (Platform.isAndroid)
        {
            elements.add(_customSwitchPreference(td,
                Strings.pref_exit_confirm,
                Configuration.EXIT_CONFIRM,
                icon: Drawables.pref_exit_confirm));
        }

        elements.add(_customSwitchPreference(td,
            Strings.pref_developer_mode,
            Configuration.DEVELOPER_MODE,
            icon: Drawables.pref_developer_mode));

        final Widget scaffold = Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(ActivityDimens.appBarHeight(context)), // desired height of appBar + tabBar
                child: AppBar(title: CustomActivityTitle(Strings.drawer_app_settings, null))),
            body: DropdownButtonHideUnderline(
                child: Scrollbar(child: ListView(
                    primary: true,
                    children: (elements))
                )
            )
        );

        return Theme(data: td, child: scaffold);
    }

    Widget _customDropdownPreference(final ThemeData td, String name, Pair<String, String> par,
        {String icon, List<String> values, List<String> displayValues, ValueChanged<String> onChange})
    {
        int groupValue = values.indexOf(_configuration.getString(par));
        if (groupValue < 0)
        {
            groupValue = values.indexOf(par.item2);
        }
        final Widget res = ListTile(
            leading: _getIcon(td, icon),
            title: Text(name),
            subtitle: Text(displayValues[groupValue]),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: ()
            => showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext c)
                => Theme(data: td, child: DropdownPreferenceDialog(name, values, displayValues, groupValue, onChange))
            ));
        return res;
    }

    Widget _customSwitchPreference(final ThemeData td, String title, Pair<String, bool> par, {String icon, String desc})
    {
        return SwitchPreference(
            title,
            _configuration.getBool(par),
            icon: _getIcon(td, icon),
            desc: desc,
            onChanged: (bool val)
            => _configuration.saveBoolParameter(par, val)
        );
    }

    Widget _customPreferenceScreen(final ThemeData td, String name, {String icon, String activity})
    {
        return ListTile(
            leading: _getIcon(td, icon),
            title: Text(name),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: ()
            => Navigator.pushNamed(context, activity)
        );
    }

    Widget _getIcon(final ThemeData td, String icon)
    {
        if (icon != null)
        {
            return SvgPicture.asset(icon,
                width: DialogDimens.iconSize,
                height: DialogDimens.iconSize,
                color: td.disabledColor);
        }
        return null;
    }
}