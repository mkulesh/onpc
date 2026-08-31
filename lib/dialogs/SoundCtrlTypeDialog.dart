/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2026 by Mikhail Kulesh
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

import '../config/Configuration.dart';
import '../constants/Dimens.dart';
import '../constants/Strings.dart';
import '../widgets/CustomDialogEditField.dart';
import '../widgets/CustomDialogTitle.dart';
import '../widgets/CustomTextLabel.dart';

typedef SoundCtrlTypeChanged = void Function(String type, String address, int port);

class SoundCtrlTypeDialog extends StatefulWidget
{
    final Configuration configuration;
    final SoundCtrlTypeChanged _onChange;

    SoundCtrlTypeDialog(this.configuration, this._onChange);

    @override _SoundCtrlTypeDialogState createState()
    => _SoundCtrlTypeDialogState();
}

class _SoundCtrlTypeDialogState extends State<SoundCtrlTypeDialog>
{
    final List<String> _values = Strings.pref_sound_control_codes;
    final List<String> _displayValues = Strings.pref_sound_control_names;
    int? _groupValue;
    final _address = TextEditingController();
    final _port = TextEditingController();

    @override
    void initState()
    {
        _groupValue = widget.configuration.audioControl.getSoundControlIdx();
        _address.text = widget.configuration.audioControl.soundControlHost;
        _port.text = widget.configuration.audioControl.soundControlPort.toString();
        super.initState();
    }

    @override
    void dispose()
    {
        _address.dispose();
        _port.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = Theme.of(context);
        final List<Widget> controls = [];

        int index = 0;
        _displayValues.forEach((v)
        {
            controls.add(ListTileTheme(
                contentPadding: ActivityDimens.noPadding,
                child: RadioListTile<int>(
                    title: CustomTextLabel.normal(v, padding: DialogDimens.rowPadding),
                    value: index,
                    groupValue: _groupValue,
                    onChanged: (int? val)
                    {
                        if (val != null)
                        {
                            setState(()
                            {
                                _groupValue = val;
                            });
                        }
                    })
            ));
            index++;
        });

        if (_groupValue == _values.length - 1)
        {
            controls.add(CustomDialogEditField(_address, textLabel: Strings.connect_dialog_address, isFocused: true));
            controls.add(CustomDialogEditField(_port, textLabel: Strings.connect_dialog_port));
        }

        final Widget dialog = AlertDialog(
            title: CustomDialogTitle(Strings.pref_sound_control, null),
            contentPadding: DialogDimens.contentPadding,
            content: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: ListBody(children: controls)),
            actions: <Widget>[
              TextButton(
                  child: Text(Strings.action_cancel.toUpperCase(), style: td.textTheme.labelLarge),
                  onPressed: ()
                  {
                      Navigator.of(context).pop();
                  }),
              TextButton(
                  child: Text(Strings.action_ok.toUpperCase(), style: td.textTheme.labelLarge),
                  onPressed: ()
                  {
                      if (_groupValue != null)
                      {
                          final int? port1 = int.tryParse(_port.text);
                          final int port2 = port1 == null ? Configuration.SERVER_PORT.item2 : port1;
                          widget._onChange(_values[_groupValue!], _address.text, port2);
                      }
                      Navigator.of(context).pop();
                  }),
            ]
        );

        return dialog;
    }
}