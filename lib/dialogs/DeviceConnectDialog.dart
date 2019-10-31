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

import "../config/Configuration.dart";
import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../views/UpdatableView.dart";
import "../widgets/CustomDialogTitle.dart";
import "../widgets/CustomTextField.dart";
import "../widgets/CustomTextLabel.dart";

class DeviceConnectDialog extends StatefulWidget
{
    final ViewContext _viewContext;

    DeviceConnectDialog(this._viewContext);

    @override _DeviceConnectDialogState createState()
    => _DeviceConnectDialogState();
}

class _DeviceConnectDialogState extends State<DeviceConnectDialog>
{
    final _address = TextEditingController();
    final _port = TextEditingController();

    ViewContext get viewContext
    => widget._viewContext;

    @override
    void initState()
    {
        super.initState();
        _address.text = viewContext.configuration.getDeviceName;
        _port.text = viewContext.configuration.getDevicePort.toString();
    }

    @override
    Widget build(BuildContext context)
    {
        final Widget row1 = Padding(
            padding: DialogDimens.rowPadding,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    CustomTextLabel.small(Strings.connect_dialog_address),
                    CustomTextField(_address, isFocused: true)
                ]
            )
        );

        final Widget row2 = Padding(
            padding: DialogDimens.rowPadding,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    CustomTextLabel.small(Strings.connect_dialog_port),
                    CustomTextField(_port),
                ]
            )
        );

        return AlertDialog(
            title: CustomDialogTitle(Strings.drawer_device_connect, Drawables.drawer_connect),
            contentPadding: DialogDimens.contentPadding,
            content: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [row1, row2]),
            actions: <Widget>[
                FlatButton(
                    child: Text(Strings.action_cancel.toUpperCase()),
                    onPressed: ()
                    {
                        Navigator.of(context).pop();
                    }),
                FlatButton(
                    child: Text(Strings.action_ok.toUpperCase()),
                    onPressed: ()
                    {
                        Navigator.of(context).pop();
                        final int port1 = int.tryParse(_port.text);
                        final int port2 = port1 == null ? Configuration.SERVER_PORT.item2 : port1;
                        viewContext.stateManager.connect(_address.text, port2);
                    }),
            ]
        );
    }

    @override
    void dispose()
    {
        _address.dispose();
        _port.dispose();
        super.dispose();
    }
}