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

import 'package:flutter/material.dart';

import "../constants/Dimens.dart";
import "CustomTextLabel.dart";

class SwitchPreference extends StatefulWidget
{
    final String title;
    final bool value;
    final Widget? icon;
    final String? desc;
    final ValueChanged<bool>? onChanged;

    SwitchPreference(this.title, this.value,
    {
        this.icon,
        this.desc,
        this.onChanged,
    });

    @override
    _SwitchPreferenceState createState()
    => _SwitchPreferenceState(value);
}

class _SwitchPreferenceState extends State<SwitchPreference>
{
    bool _value;

    _SwitchPreferenceState(this._value);

    @override
    Widget build(BuildContext context)
    {
        return ListTile(
            leading: widget.icon,
            title: ListTileTheme(
                contentPadding: ActivityDimens.noPadding,
                child: CustomTextLabel.normal(widget.title)),
            subtitle: widget.desc == null ? null : CustomTextLabel.small(widget.desc!),
            trailing: Transform.scale(scale: DimensTransform.switchScaleFactor,
                child: Switch(
                    value: _value,
                    onChanged: (val)
                    => val ? onEnable() : onDisable()
                )
            ),
            onTap: ()
            => _value ? onDisable() : onEnable()
        );
    }

    void onEnable()
    {
        setState(()
        {
            _value = true;
        });
        if (widget.onChanged != null)
        {
            widget.onChanged!(_value);
        }
    }

    void onDisable()
    {
        setState(()
        {
            _value = false;
        });
        if (widget.onChanged != null)
        {
            widget.onChanged!(_value);
        }
    }
}
