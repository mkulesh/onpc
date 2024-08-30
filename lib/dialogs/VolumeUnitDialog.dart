/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2024 by Mikhail Kulesh
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

import '../config/CfgAudioControl.dart';
import '../config/Configuration.dart';
import '../constants/Dimens.dart';
import '../constants/Drawables.dart';
import '../constants/Strings.dart';
import '../widgets/CustomCheckbox.dart';
import '../widgets/CustomDialogEditField.dart';
import '../widgets/CustomDialogTitle.dart';

class VolumeUnitDialog extends StatefulWidget
{
    final Configuration configuration;

    VolumeUnitDialog(this.configuration);

    @override _VolumeUnitDialogState createState()
    => _VolumeUnitDialogState();
}

class _VolumeUnitDialogState extends State<VolumeUnitDialog>
{
    VolumeUnit _volumeUnit = VolumeUnit.ABSOLUTE;
    final _zeroValue = TextEditingController();

    @override
    void initState()
    {
        super.initState();
        _volumeUnit = widget.configuration.audioControl.volumeUnit;
        final double? _zeroLevel = widget.configuration.audioControl.zeroLevel;
        _zeroValue.text =  _zeroLevel != null ? _zeroLevel.toString() : "";
    }

    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = Theme.of(context);

        final List<Widget> controls = [];

        controls.add(CustomCheckbox(Strings.pref_volume_unit_absolute,
            icon: Radio(
                value: VolumeUnit.ABSOLUTE,
                groupValue: _volumeUnit,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (VolumeUnit? v)
                {
                    if (v != null)
                    {
                        setState(() {
                            _volumeUnit = v;
                        });
                    }
                })
        ));

        controls.add(CustomCheckbox(Strings.pref_volume_unit_relative,
            icon: Radio(
                value: VolumeUnit.RELATIVE,
                groupValue: _volumeUnit,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (VolumeUnit? v)
                {
                    if (v != null)
                    {
                        setState(() {
                            _volumeUnit = v;
                        });
                    }
                })
        ));

        controls.add(CustomDialogEditField(_zeroValue,
            textLabel: Strings.pref_volume_unit_zero,
            isFocused: true,
            onChanged: (val)
            {
                setState(()
                {
                    // empty, just to redraw OK button
                });
            })
        );

        final Widget dialog = AlertDialog(
            title: CustomDialogTitle(Strings.pref_volume_unit, Drawables.pref_volume_unit),
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
                      widget.configuration.audioControl.setVolumeUnit(_volumeUnit, double.tryParse(_zeroValue.text));
                      Navigator.of(context).pop();
                  }),
            ]
        );

        return dialog;
    }
}