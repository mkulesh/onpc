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

import "../constants/Strings.dart";
import "../iscp/messages/EnumParameterMsg.dart";
import "../iscp/messages/InputSelectorMsg.dart";
import "../utils/Logging.dart";
import "CheckableItem.dart";
import "Configuration.dart";

class DeviceSelectors extends StatefulWidget
{
    final Configuration configuration;

    DeviceSelectors(this.configuration);

    @override
    _DeviceSelectorsState createState()
    => _DeviceSelectorsState(configuration);
}

class _DeviceSelectorsState extends State<DeviceSelectors>
{
    final Configuration _configuration;
    String _parameter;
    final List<CheckableItem> _items = List<CheckableItem>();

    _DeviceSelectorsState(this._configuration)
    {
        _parameter = _configuration.getModelDependentParameter(Configuration.SELECTED_DEVICE_SELECTORS);
        _createItems();
    }

    void _createItems()
    {
        final List<String> defItems = _configuration.getTokens(Configuration.DEVICE_SELECTORS);
        if (defItems == null || defItems.isEmpty)
        {
            return;
        }

        final bool fName = _configuration.getBool(Configuration.FRIENDLY_NAMES);
        for (CheckableItem sp in CheckableItem.readFromPreference(_configuration, _parameter, defItems))
        {
            final EnumItem<InputSelector> item = InputSelectorMsg.ValueEnum.valueByCode(sp.code);
            if (item.key == InputSelector.NONE)
            {
                Logging.info(this, "Input selector not known: " + sp.code);
                continue;
            }

            final String defName = item.description;
            final String name = fName ? _configuration.getStringDef(
                Configuration.DEVICE_SELECTORS + "_" + item.getCode, defName) : defName;
            _items.add(CheckableItem(item.getCode, name, sp.checked));
        }
    }

    @override
    Widget build(BuildContext context)
    {
        Logging.info(this, "Rebuild widget");
        return CheckableItem.buildList(context,
            _items.map<Widget>(_buildListItem).toList(),
            Strings.pref_device_selectors,
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