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
import "../iscp/messages/ServiceType.dart";
import "../utils/Logging.dart";
import "CheckableItem.dart";
import "Configuration.dart";

class NetworkServices extends StatefulWidget
{
    final Configuration configuration;

    NetworkServices(this.configuration);

    @override
    _NetworkServicesState createState()
    => _NetworkServicesState(configuration);
}

class _NetworkServicesState extends State<NetworkServices>
{
    final Configuration _configuration;
    String _parameter;
    final List<CheckableItem> _items = List<CheckableItem>();

    _NetworkServicesState(this._configuration)
    {
        _parameter = _configuration.getModelDependentParameter(Configuration.SELECTED_NETWORK_SERVICES);
        _createItems();
    }

    void _createItems()
    {
        final List<String> defItems = _configuration.getTokens(Configuration.NETWORK_SERVICES);
        if (defItems == null || defItems.isEmpty)
        {
            return;
        }

        for (CheckableItem sp in CheckableItem.readFromPreference(_configuration, _parameter, defItems))
        {
            final EnumItem<ServiceType> item = Services.ServiceTypeEnum.valueByCode(sp.code);
            if (item.key == ServiceType.UNKNOWN)
            {
                Logging.info(this, "Network service not known: " + sp.code);
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
            Strings.pref_network_services,
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