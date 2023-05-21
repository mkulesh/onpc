/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2023 by Mikhail Kulesh
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

import "../constants/Strings.dart";
import "../constants/Themes.dart";
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
    final List<CheckableItem> _items = [];

    _DeviceSelectorsState(this._configuration)
    {
        _parameter = _configuration.getModelDependentParameter(Configuration.SELECTED_DEVICE_SELECTORS);
        _createItems();
    }

    void _createItems()
    {
        _items.clear();
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
            final String name = _configuration.deviceSelectorName(item, useFriendlyName: fName);
            _items.add(CheckableItem(item.getCode, name, sp.checked, onRename: (String name) => _onRename(item, name)));
        }
    }

    @override
    Widget build(BuildContext context)
    {
        Logging.logRebuild(this);

        final ThemeData td = BaseAppTheme.getThemeData(
            _configuration.appSettings.theme, _configuration.appSettings.language, _configuration.appSettings.textSize);

        final List<Widget> rows = [];
        _items.forEach((item) => rows.add(_buildListItem(context, td, item)) );

        return CheckableItem.buildList(context,
            rows,
            Strings.pref_device_selectors,
            _onReorder,
            _configuration);
    }

    Widget _buildListItem(final BuildContext context, final ThemeData theme, final CheckableItem item)
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

    void _onRename(EnumItem<InputSelector> item, String name)
    {
        setState(()
        {
            _configuration.saveManualDeviceSelector(item, name);
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