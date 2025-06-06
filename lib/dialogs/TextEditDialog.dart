/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2025 by Mikhail Kulesh
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

import '../constants/Dimens.dart';
import '../constants/Drawables.dart';
import '../constants/Strings.dart';
import '../widgets/CustomDialogEditField.dart';
import '../widgets/CustomDialogTitle.dart';

class TextEditDialog extends StatefulWidget
{
    final String value;
    final void Function(String name) onRename;

    TextEditDialog(this.value, this.onRename);

    @override _TextEditDialogState createState()
    => _TextEditDialogState();
}

class _TextEditDialogState extends State<TextEditDialog>
{
    final _alias = TextEditingController();

    @override
    void initState()
    {
        super.initState();
        _alias.text = "";
    }

    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = Theme.of(context);
        _alias.text = widget.value;

        final Widget editLine = CustomDialogEditField(_alias,
            textLabel: Strings.pref_item_name,
            isFocused: true,
            onDeleteBtn: () => _alias.text = "",
        );

        final Widget dialog = AlertDialog(
            title: CustomDialogTitle(Strings.pref_item_update, Drawables.drawer_edit_item),
            contentPadding: DialogDimens.contentPadding,
            content: editLine,
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
                      widget.onRename(_alias.text);
                      Navigator.of(context).pop();
                  }),
            ]
        );

        return dialog;
    }
}