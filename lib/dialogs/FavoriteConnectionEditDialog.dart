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
import "../iscp/StateManager.dart";

import "../config/CfgFavoriteConnections.dart";
import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../iscp/messages/BroadcastResponseMsg.dart";
import "../views/UpdatableView.dart";
import "../widgets/CustomCheckbox.dart";
import "../widgets/CustomDialogEditField.dart";
import "../widgets/CustomDialogTitle.dart";
import "../widgets/CustomTextLabel.dart";

class FavoriteConnectionEditDialog extends StatefulWidget
{
    final ViewContext _viewContext;
    final BroadcastResponseMsg _msg;

    FavoriteConnectionEditDialog(this._viewContext, this._msg);

    @override _FavoriteConnectionEditDialogState createState()
    => _FavoriteConnectionEditDialogState();
}

enum _ConnectionAction
{
    UPDATE,
    DELETE
}

class _FavoriteConnectionEditDialogState extends State<FavoriteConnectionEditDialog>
{
    _ConnectionAction _connectionAction;
    final _alias = TextEditingController();
    final _identifier = TextEditingController();

    ViewContext get viewContext
    => widget._viewContext;

    @override
    void initState()
    {
        super.initState();
        _connectionAction = _ConnectionAction.UPDATE;
        _alias.text = widget._msg.alias;
        _identifier.text = widget._msg.getIdentifier;
    }

    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = viewContext.getThemeData();

        final List<Widget> controls = [];

        controls.add(CustomTextLabel.small(Strings.connect_dialog_address + " " + widget._msg.getHostAndPort));

        controls.add(CustomCheckbox(Strings.favorite_update,
            icon: Radio(
                value: _ConnectionAction.UPDATE,
                groupValue: _connectionAction,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (_ConnectionAction v)
                {
                    setState(()
                    {
                        _connectionAction = v;
                    });
                })
            )
        );

        controls.add(CustomDialogEditField(_alias,
            textLabel: Strings.favorite_alias,
            isFocused: true)
        );

        controls.add(CustomDialogEditField(_identifier,
            textLabel: Strings.favorite_connection_identifier));

        controls.add(CustomCheckbox(Strings.favorite_delete,
            icon: Radio(
                value: _ConnectionAction.DELETE,
                groupValue: _connectionAction,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (_ConnectionAction v)
                {
                    setState(()
                    {
                        _connectionAction = v;
                        FocusScope.of(context).unfocus();
                    });
                })
            )
        );

        final Widget dialog = AlertDialog(
            title: CustomDialogTitle(Strings.favorite_connection_edit, Drawables.drawer_edit_item),
            contentPadding: DialogDimens.contentPadding,
            content: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: ListBody(children: controls)),
            actions: <Widget>[
                TextButton(
                    child: Text(Strings.action_cancel.toUpperCase(), style: td.textTheme.button),
                    onPressed: ()
                    {
                        Navigator.of(context).pop();
                    }),
                TextButton(
                    child: Text(Strings.action_ok.toUpperCase(), style: td.textTheme.button),
                    onPressed: ()
                    {
                        _apply();
                        Navigator.of(context).pop();
                    }),
            ]
        );

        return Theme(data: td, child: dialog);
    }

    void _apply()
    {
        final CfgFavoriteConnections cfg = widget._viewContext.configuration.favoriteConnections;
        switch (_connectionAction)
        {
            case _ConnectionAction.UPDATE:
                cfg.updateDevice(widget._msg, _alias.text,
                    _identifier.text.isEmpty ? null : _identifier.text);

                break;
            case _ConnectionAction.DELETE:
                cfg.deleteDevice(widget._msg);
                break;
        }
        final StateManager sm = widget._viewContext.stateManager;
        sm.state.multiroomState.updateFavorites();
        sm.triggerStateEvent(BroadcastResponseMsg.CODE);
    }

    @override
    void dispose()
    {
        super.dispose();
        _alias.dispose();
        _identifier.dispose();
    }
}

