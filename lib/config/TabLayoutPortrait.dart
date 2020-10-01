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

import 'package:flutter/material.dart';

import "../config/CfgTabSettings.dart";
import "../constants/Strings.dart";
import "../iscp/messages/EnumParameterMsg.dart";
import "../utils/Logging.dart";
import "CfgAppSettings.dart";
import 'CfgTabSettings.dart';
import "CheckableItem.dart";
import "Configuration.dart";

class TabLayoutPortrait extends StatefulWidget
{
    final Configuration configuration;
    final CfgTabSettings tabSettings;

    TabLayoutPortrait(this.configuration, this.tabSettings);

    @override
    _TabLayoutPortraitState createState()
    => _TabLayoutPortraitState(configuration, tabSettings);
}

class _TabLayoutPortraitState extends State<TabLayoutPortrait>
{
    final Configuration _configuration;
    final CfgTabSettings _tabSettings;
    String _parameter;
    final List<CheckableItem> _items = List<CheckableItem>();

    _TabLayoutPortraitState(this._configuration, this._tabSettings)
    {
        _parameter = CfgTabSettings.getParameterName(_tabSettings.tab, AppControlGroup.PORTRAIT);
        _createItems();
    }

    void _createItems()
    {
        final List<String> defItems = List();
        CfgTabSettings.ValueEnum.values.forEach((m) => defItems.add(m.code));
        // Add currently selected controls on the top
        _tabSettings.controlsPortrait.forEach((c)
        {
            final EnumItem<AppControl> m = CfgTabSettings.ValueEnum.valueByKey(c);
            _items.add(CheckableItem(m.code, m.description, true));
        });
        // Add other non-selected controls
        for (CheckableItem sp in CheckableItem.readFromPreference(_configuration, _parameter, defItems))
        {
            CfgTabSettings.ValueEnum.values.forEach((m)
            {
                if (m.code == sp.code && !_tabSettings.controlsPortrait.contains(m.key))
                {
                    _items.add(CheckableItem(m.code, m.description, false));
                }
            });
        }
    }

    @override
    Widget build(BuildContext context)
    {
        Logging.info(this, "Rebuild widget");
        return CheckableItem.buildList(context,
            _items.map<Widget>(_buildListItem).toList(),
            Strings.drawer_tab_layout + " (" + CfgAppSettings.getTabName(_tabSettings.tab) + ")",
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