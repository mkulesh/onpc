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

import 'package:flutter/material.dart';

import "../constants/Strings.dart";
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

class _ListeningModesState extends State<ListeningModes>
{
    final Configuration _configuration;
    String _parameter;
    final List<CheckableItem> _items = List<CheckableItem>();

    _ListeningModesState(this._configuration)
    {
        _parameter = _configuration.getModelDependentParameter(CfgAudioControl.SELECTED_LISTENING_MODES);
        _createItems();
    }

    void _createItems()
    {
        final List<String> defItems = List();
        CfgAudioControl.DEFAULT_LISTENING_MODES.forEach((m)
            => defItems.add(ListeningModeMsg.ValueEnum.valueByKey(m).getCode));

        for (CheckableItem sp in CheckableItem.readFromPreference(_configuration, _parameter, defItems))
        {
            final EnumItem<ListeningMode> item = ListeningModeMsg.ValueEnum.valueByCode(sp.code);
            if (item.key == ListeningMode.NONE)
            {
                Logging.info(this, "Listening mode is not known: " + sp.code);
                continue;
            }
            _items.add(CheckableItem(item.getCode, item.description, sp.checked));
        }
    }

    @override
    Widget build(BuildContext context)
    {
        Logging.logRebuild(this);
        return CheckableItem.buildList(context,
            _items.map<Widget>(_buildListItem).toList(),
            Strings.pref_listening_modes,
            _onReorder,
            _configuration);
    }

    Widget _buildListItem(CheckableItem item)
    {
        return item.buildListItem((bool newValue)
        {
            setState(()
            {
                item.checked = newValue;
                CheckableItem.writeToPreference(_configuration, _parameter, _items);
            });
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