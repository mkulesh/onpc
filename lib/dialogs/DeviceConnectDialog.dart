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
import "../utils/Convert.dart";
import "../views/UpdatableView.dart";
import "../widgets/CustomCheckbox.dart";
import "../widgets/CustomDialogEditField.dart";
import "../widgets/CustomDialogTitle.dart";

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
    bool _saveEnabled;
    final _alias = TextEditingController();

    ViewContext get viewContext
    => widget._viewContext;

    @override
    void initState()
    {
        super.initState();
        _address.text = viewContext.configuration.getDeviceName;
        _port.text = viewContext.configuration.getDevicePort.toString();
        _saveEnabled = false;
        _alias.text = "";
    }

    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = viewContext.getThemeData();

        final List<Widget> controls = List();

        controls.add(CustomDialogEditField(_address,
            textLabel: Strings.connect_dialog_address,
            isFocused: true,
            onChanged: (val)
            {
                setState(()
                {
                    // empty, just to redraw OK button
                });
            })
        );

        controls.add(CustomDialogEditField(_port, textLabel: Strings.connect_dialog_port));

        final Widget saveCheckBox = CustomCheckbox(Strings.connect_dialog_save,
            value: _saveEnabled,
            padding: ActivityDimens.noPadding,
            onChanged: (bool newValue)
            {
                setState(()
                {
                    _saveEnabled = newValue;
                });
            }
        );

        controls.add(CustomDialogEditField(_alias, widgetLabel: saveCheckBox));

        final Widget dialog = AlertDialog(
            title: CustomDialogTitle(Strings.drawer_device_connect, Drawables.drawer_connect),
            contentPadding: DialogDimens.contentPadding,
            content: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: ListBody(children: controls)),
            actions: <Widget>[
                FlatButton(
                    child: Text(Strings.action_cancel.toUpperCase(), style: td.textTheme.button),
                    onPressed: ()
                    {
                        Navigator.of(context).pop();
                    }),
                FlatButton(
                    child: Text(Strings.action_ok.toUpperCase(),
                        style: _address.text.isEmpty ? td.textTheme.button.copyWith(color: td.disabledColor) : td.textTheme.button
                    ),
                    onPressed: _address.text.isEmpty ? null : ()
                    {
                        Navigator.of(context).pop();
                        final String host = _address.text;
                        final int port1 = int.tryParse(_port.text);
                        final int port2 = port1 == null ? Configuration.SERVER_PORT.item2 : port1;
                        final String alias = _saveEnabled ?
                            (_alias.text.isEmpty ? Convert.ipToString(host, port2.toString()) : _alias.text) : null;
                        viewContext.stateManager.connect(host, port2, manualHost: host, manualAlias: alias);
                    }),
            ]
        );

        return Theme(data: td, child: dialog);
    }

    @override
    void dispose()
    {
        _address.dispose();
        _port.dispose();
        _alias.dispose();
        super.dispose();
    }
}