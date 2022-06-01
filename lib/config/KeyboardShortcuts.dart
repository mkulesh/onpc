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

import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../constants/Themes.dart";
import "../utils/Logging.dart";
import "../widgets/CustomImageButton.dart";
import "../widgets/CustomTextLabel.dart";
import "CfgAppSettings.dart";
import "CheckableItem.dart";
import "Configuration.dart";

class KeyboardShortcuts extends StatefulWidget
{
    final Configuration configuration;

    KeyboardShortcuts(this.configuration);

    @override
    _KeyboardShortcutsState createState()
    => _KeyboardShortcutsState(configuration);
}

class _KeyboardShortcutsState extends State<KeyboardShortcuts>
{
    final Configuration _configuration;

    _KeyboardShortcutsState(this._configuration);

    @override
    void dispose()
    {
        _configuration.appSettings.captureKeyboardShortcut(null);
        super.dispose();
    }

    @override
    Widget build(BuildContext context)
    {
        Logging.logRebuild(this);
        final ThemeData td = BaseAppTheme.getThemeData(
            _configuration.appSettings.theme,
            _configuration.appSettings.language,
            _configuration.appSettings.textSize);

        final List<TableRow> rows = [];
        rows.add(_buildRow(td, Strings.master_volume_up,     "ks_volume_up"));
        rows.add(_buildRow(td, Strings.master_volume_down,   "ks_volume_down"));
        rows.add(_buildRow(td, Strings.audio_muting_toggle,  "ks_volume_mute"));
        rows.add(_buildRow(td, Strings.cmd_description_trdn, "ks_volume_trdn"));
        rows.add(_buildRow(td, Strings.cmd_description_play, "ks_volume_play"));
        rows.add(_buildRow(td, Strings.cmd_description_pause,"ks_volume_stop"));
        rows.add(_buildRow(td, Strings.cmd_description_trup, "ks_volume_trup"));

        final Map<int, TableColumnWidth> columnWidths = Map();
        columnWidths[0] = FractionColumnWidth(0.4);
        columnWidths[1] = FractionColumnWidth(0.4);
        columnWidths[2] = FractionColumnWidth(0.1);
        columnWidths[3] = FractionColumnWidth(0.1);

        final Widget table = Table(
            columnWidths: columnWidths,
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: rows,
        );

        return CheckableItem.buildScaffold(context, Strings.pref_keyboard_shortcuts, table, _configuration);
    }

    TableRow _buildRow(final ThemeData td, final String title, final String par)
    {
        final CfgAppSettings appSettings = _configuration.appSettings;
        final Widget shortcut = Container(
            margin: const EdgeInsets.all(0.0),
            padding: const EdgeInsets.all(0.0),
            decoration: BoxDecoration(
                border: Border.all(color: appSettings.isWaitingForShortcut(par) ? td.colorScheme.secondary : Colors.transparent)
            ),
            child: CustomTextLabel.normal(appSettings.getKeyboardShortcut(par),
                padding: ActivityDimens.headerPadding, textAlign: TextAlign.center)
        );

        return TableRow(children: [
            CustomTextLabel.small(title, padding: ActivityDimens.headerPadding),
            shortcut,
            CustomImageButton.small(
                Drawables.keyboard_shortcut_update,
                Strings.pref_item_update,
                onPressed: ()
                {
                    setState(()
                    {
                        appSettings.captureKeyboardShortcut(_onShortcut, parameter: par);
                    });
                }
            ),
            CustomImageButton.small(
                Drawables.keyboard_shortcut_delete,
                Strings.pref_item_delete,
                onPressed: ()
                {
                    setState(()
                    {
                        _configuration.appSettings.captureKeyboardShortcut(null);
                        _configuration.appSettings.updateKeyboardShortcut(par, "");
                    });
                }
            )
        ]);
    }

    void _onShortcut(String par, String value)
    {
        Logging.info(this, "Captured keyboard shortcut for " + par + ": " + value);
        setState(()
        {
            _configuration.appSettings.captureKeyboardShortcut(null);
            _configuration.appSettings.updateKeyboardShortcut(par, value);
        });
    }
}
