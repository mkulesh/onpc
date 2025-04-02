/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2025 by Mikhail Kulesh
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

import "../constants/Strings.dart";
import "../constants/Themes.dart";
import "../iscp/ConnectionIf.dart";
import "../iscp/messages/EnumParameterMsg.dart";
import "../iscp/messages/ListeningModeMsg.dart";
import "../utils/Logging.dart";
import "CfgAudioControl.dart";
import "CheckableItem.dart";
import "Configuration.dart";

class ListeningModes extends StatefulWidget
{
    final Configuration configuration;

    ListeningModes(this.configuration);

    @override
    _ListeningModesState createState()
    => _ListeningModesState(configuration);
}

class _ListeningModesState extends State<ListeningModes> with ProtoTypeMix
{
    final Configuration _configuration;
    late String _parameter;
    final List<CheckableItem> _items = [];

    _ListeningModesState(this._configuration)
    {
        setProtoType(_configuration.protoType);
        _parameter = _configuration.getModelDependentParameter(
            CfgAudioControl.getSelectedListeningModePar(protoType));
        _createItems();
    }

    void _createItems()
    {
        _items.clear();
        final List<String> defItems = [];
        CfgAudioControl.getListeningModes(protoType).forEach((m)
            => defItems.add(ListeningModeMsg.ValueEnum.valueByKey(m).getCode));

        for (CheckableItem sp in CheckableItem.readFromPreference(_configuration, _parameter, defItems))
        {
            final EnumItem<ListeningMode> item = ListeningModeMsg.ValueEnum.valueByCode(sp.code);
            if (item.key == ListeningMode.NONE)
            {
                Logging.info(this, "Listening mode is not known: " + sp.code);
                continue;
            }
            final String mName = _configuration.audioControl.listeningModeName(item);
            _items.add(CheckableItem(item.getCode, mName, sp.checked, onRename: (String name) => _onRename(item, name)));
        }
    }

    @override
    Widget build(BuildContext context)
    {
        Logging.logRebuild(this);

        final ThemeData td = BaseAppTheme.getThemeData(
            _configuration.appSettings.theme, _configuration.appSettings.language, _configuration.appSettings.textSize);

        final List<Widget> rows = [];
        _items.forEach((item) => rows.add(_buildListItem(context, td, item)));

        return CheckableItem.buildList(context,
            rows,
            Strings.pref_listening_modes,
            _onReorder,
            _configuration);
    }

    Widget _buildListItem(final BuildContext context, final ThemeData theme, CheckableItem item)
    {
        return item.buildListItem((bool newValue)
        {
            setState(()
            {
                item.checked = newValue;
                CheckableItem.writeToPreference(_configuration, _parameter, _items);
            });
        },
        context: context,
        theme: theme);
    }

    void _onRename(EnumItem<ListeningMode> item, String name)
    {
        setState(()
        {
            _configuration.audioControl.saveManualListeningMode(item, name);
            _createItems();
        });
    }

    void _onReorder(int oldIndex, int newIndex)
    {
        setState(()
        {
            CheckableItem.reorder(_configuration, _parameter, _items, oldIndex, newIndex);
        });
    }
}