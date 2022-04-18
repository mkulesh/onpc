/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2022 by Mikhail Kulesh
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
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

import "../constants/Dimens.dart";
import "../constants/Strings.dart";
import "../widgets/CustomDialogTitle.dart";
import "../widgets/CustomTextLabel.dart";

class DropdownPreferenceDialog extends StatelessWidget
{
    final String _name;
    final List<String> _values;
    final List<String> _displayValues;
    final int _groupValue;
    final ValueChanged<String> onChange;

    DropdownPreferenceDialog(this._name, this._values, this._displayValues, this._groupValue, this.onChange);

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
                    onChanged: (val)
                    {
                        if (onChange != null)
                        {
                            onChange(_values[val]);
                        }
                        Navigator.of(context).pop();
                    })
            ));
            index++;
        });

        return AlertDialog(
            title: CustomDialogTitle(_name, null),
            contentPadding: DialogDimens.contentPadding,
            content: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: ListBody(children: controls)),
            actions: <Widget>[
                TextButton(
                    child: Text(Strings.action_cancel.toUpperCase(), style: td.textTheme.button),
                    onPressed: ()
                    => Navigator.of(context).pop()
                )
            ]
        );
    }
}