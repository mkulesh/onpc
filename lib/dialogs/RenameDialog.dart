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

import '../constants/Dimens.dart';
import '../constants/Drawables.dart';
import '../constants/Strings.dart';
import '../widgets/CustomDialogEditField.dart';
import '../widgets/CustomDialogTitle.dart';
import '../widgets/CustomImageButton.dart';

class RenameDialog extends StatefulWidget
{
    final String value;
    final void Function(String name) onRename;

    RenameDialog(this.value, this.onRename);

    @override _RenameDialogState createState()
    => _RenameDialogState();
}

class _RenameDialogState extends State<RenameDialog>
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

        final Widget editLine = Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
                Expanded(
                    child: CustomDialogEditField(_alias,
                        textLabel: Strings.pref_item_name,
                        isFocused: true),
                    flex: 1),
                Transform.translate(
                    child: CustomImageButton.small(
                        Drawables.cmd_delete,
                        Strings.pref_item_delete,
                        onPressed: () => _alias.text = ""),
                    offset: Offset(8, 0))
            ]);

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