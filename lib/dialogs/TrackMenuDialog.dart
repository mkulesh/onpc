/*
 * Copyright (C) 2020. Mikhail Kulesh
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

import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../iscp/messages/OperationCommandMsg.dart";
import "../iscp/messages/ReceiverInformationMsg.dart";
import "../iscp/messages/XmlListItemMsg.dart";
import "../views/TrackMenuView.dart";
import "../views/UpdatableView.dart";
import "../widgets/CustomDialogTitle.dart";

class TrackMenuDialog extends StatefulWidget
{
    final ViewContext _viewContext;
    final void Function() _onDispose;

    TrackMenuDialog(this._viewContext,this._onDispose);

    @override _TrackMenuDialogState createState()
    => _TrackMenuDialogState(_viewContext);
}

class _TrackMenuDialogState extends State<TrackMenuDialog>
{
    final ViewContext _viewContext;
    XmlListItemMsg _selectedItem;

    _TrackMenuDialogState(this._viewContext);

    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = _viewContext.getThemeData();

        final Widget dialog = AlertDialog(
            title: CustomDialogTitle(Strings.cmd_track_menu, Drawables.cmd_track_menu),
            contentPadding: DialogDimens.contentPadding,
            content: UpdatableWidget(child: TrackMenuView(_viewContext, (msg)
            {
                _selectedItem = msg;
                _viewContext.stateManager.sendMessage(msg);
                Navigator.of(context).pop();
            })),
            actions: <Widget>[
                FlatButton(
                    child: Text(Strings.action_cancel.toUpperCase(), style: td.textTheme.button),
                    onPressed: ()
                    => Navigator.of(context).pop()
                )
            ]
        );

        return Theme(data: td, child: dialog);
    }

    @override
    void dispose()
    {
        super.dispose();
        widget._onDispose();
        _viewContext.stateManager.state.mediaListState.clearMenu();
        if (_selectedItem == null && _viewContext.stateManager.state.mediaListState.isMenuMode)
        {
            _viewContext.stateManager.sendMessage(OperationCommandMsg.output(
                ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE, OperationCommand.RETURN));
        }
    }
}