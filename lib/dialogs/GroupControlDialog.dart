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
// @dart=2.9
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../views/GroupControlView.dart";
import "../views/UpdatableView.dart";
import "../widgets/CustomDialogTitle.dart";

class GroupControlDialog extends StatefulWidget
{
    final ViewContext _viewContext;

    GroupControlDialog(this._viewContext);

    @override _GroupControlDialogState createState()
    => _GroupControlDialogState();
}

class _GroupControlDialogState extends State<GroupControlDialog>
{
    ViewContext get viewContext
    => widget._viewContext;

    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = Theme.of(context);
        return AlertDialog(
            title: CustomDialogTitle(Strings.cmd_multiroom_group, Drawables.cmd_multiroom_group),
            contentPadding: DialogDimens.contentPadding,
            content: UpdatableWidget(child: GroupControlView(viewContext)),
            actions: <Widget>[
                FlatButton(
                    child: Text(Strings.action_cancel.toUpperCase(), style: td.textTheme.button),
                    onPressed: ()
                    => Navigator.of(context).pop()
                )
            ]
        );
    }
}