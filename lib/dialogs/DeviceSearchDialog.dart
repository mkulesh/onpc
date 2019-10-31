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

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../iscp/messages/BroadcastResponseMsg.dart";
import "../views/DeviceSearchView.dart";
import "../views/UpdatableView.dart";
import "../widgets/CustomDialogTitle.dart";

class DeviceSearchDialog extends StatefulWidget
{
    final ViewContext _viewContext;

    DeviceSearchDialog(this._viewContext);

    @override _DeviceSearchDialogState createState()
    => _DeviceSearchDialogState();
}

class _DeviceSearchDialogState extends State<DeviceSearchDialog>
{
    BroadcastResponseMsg _device;

    ViewContext get viewContext
    => widget._viewContext;

    @override
    Widget build(BuildContext context)
    {
        return AlertDialog(
            title: CustomDialogTitle(Strings.drawer_device_search, Drawables.drawer_search),
            contentPadding: DialogDimens.contentPadding,
            content: UpdatableWidget(child: DeviceSearchView(viewContext, (d)
            {
                _device = d;
                Navigator.of(context).pop();
            })),
            actions: <Widget>[
                FlatButton(
                    child: Text(Strings.action_cancel.toUpperCase()),
                    onPressed: ()
                    => Navigator.of(context).pop()
                )
            ]
        );
    }

    @override
    void dispose()
    {
        super.dispose();
        viewContext.stateManager.stopSearch();
        if (_device != null)
        {
            viewContext.stateManager.connect(_device.sourceHost, _device.getPort);
        }
    }
}