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

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:preferences/preferences.dart';

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
import "CfgAudioControl.dart";
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
            _configuration.theme, _configuration.language, _configuration.textSize);

        final List<Widget> elements = List();

        // Theme
        elements.add(_customDropdownPreference(td,
            Strings.pref_theme,
            Configuration.THEME,
            icon: Drawables.pref_app_theme,
            values: Strings.pref_theme_codes,
            displayValues: Strings.pref_theme_names,
            onChange: (String val)
            {
                setState(()
                {
                    _configuration.theme = val;
                });
            }));

        // Language
        elements.add(_customDropdownPreference(td,
            Strings.pref_language,
            Configuration.LANGUAGE,
            icon: Drawables.pref_language,
            values: Strings.pref_language_codes,
            displayValues: Strings.pref_language_names,
            onChange: (String val)
            {
                setState(()
                {
                    _configuration.language = val;
                });
            }));

        // Text size
        elements.add(_customDropdownPreference(td,
            Strings.pref_text_size,
            Configuration.TEXT_SIZE,
            icon: Drawables.pref_text_size,
            values: Strings.pref_text_size_codes,
            displayValues: Strings.pref_text_size_names,
            onChange: (String val)
            {
                setState(()
                {
                    _configuration.textSize = val;
                });
            }));

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
        elements.add(PreferenceTitle(Strings.audio_control));
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

        // Remote interface
        elements.add(CustomDivider());
        elements.add(PreferenceTitle(Strings.pref_category_ri_options));
        elements.add(_customSwitchPreference(td,
            Strings.remote_interface_amp,
            Configuration.RI_AMP,
            icon: Drawables.pref_ri_amplifier));
        elements.add(_customSwitchPreference(td,
            Strings.remote_interface_cd,
            Configuration.RI_CD,
            icon: Drawables.pref_ri_disc_player));

        // Advanced options
        elements.add(CustomDivider());
        elements.add(PreferenceTitle(Strings.pref_category_advanced_options));

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
            body: DropdownButtonHideUnderline(child: PreferencePage(elements))
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

    Widget _customSwitchPreference(final ThemeData td, String name, Pair<String, bool> par, {String icon, String desc})
    {
        return ListTile(
            leading: _getIcon(td, icon),
            title: ListTileTheme(
                contentPadding: ActivityDimens.noPadding,
                child: SwitchPreference(name, par.item1, defaultVal: par.item2, desc: desc))
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