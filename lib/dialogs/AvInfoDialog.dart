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
// @dart=2.9
import "package:flutter/material.dart";

import "../constants/Dimens.dart";
import "../constants/Strings.dart";
import "../views/AvInfoView.dart";
import "../views/UpdatableView.dart";
import "../widgets/CustomDialogTitle.dart";

class AvInfoDialog extends StatefulWidget
{
    final ViewContext _viewContext;

    AvInfoDialog(this._viewContext);

    @override _AvInfoDialogState createState()
    => _AvInfoDialogState();
}

class _AvInfoDialogState extends State<AvInfoDialog>
{
    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = Theme.of(context);
        return AlertDialog(
            title: CustomDialogTitle(Strings.av_info_dialog, widget._viewContext.state.getServiceIcon()),
            contentPadding: DialogDimens.contentPadding,
            content: UpdatableWidget(child: AvInfoView(widget._viewContext)),
            actions: <Widget>[
                TextButton(
                    child: Text(Strings.action_ok.toUpperCase(), style: td.textTheme.labelLarge),
                    onPressed: ()
                    => Navigator.of(context).pop()
                )
            ]
        );
    }
}