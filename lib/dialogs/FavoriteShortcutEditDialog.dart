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

import "../config/CfgFavoriteShortcuts.dart";
import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../views/UpdatableView.dart";
import "../widgets/CustomDialogEditField.dart";
import "../widgets/CustomDialogTitle.dart";
import "../widgets/CustomTextLabel.dart";

class FavoriteShortcutEditDialog extends StatefulWidget
{
    static const String SHORTCUT_CHANGE_EVENT = "SHORTCUT_CHANGE";

    final ViewContext _viewContext;
    final Shortcut _shortcut;

    FavoriteShortcutEditDialog(this._viewContext, this._shortcut);

    @override _FavoriteShortcutEditDialogState createState()
    => _FavoriteShortcutEditDialogState();
}

class _FavoriteShortcutEditDialogState extends State<FavoriteShortcutEditDialog>
{
    final _alias = TextEditingController();

    ViewContext get viewContext
    => widget._viewContext;

    @override
    void initState()
    {
        super.initState();
        _alias.text = widget._shortcut.alias;
    }

    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = viewContext.getThemeData();

        final List<Widget> controls = [];

        controls.add(Padding(
            padding: DialogDimens.rowPadding,
            child: CustomTextLabel.small(widget._shortcut.getLabel()))
        );

        controls.add(CustomDialogEditField(_alias,
            textLabel: Strings.favorite_alias,
            isFocused: true)
        );

        final Widget dialog = AlertDialog(
            title: CustomDialogTitle(Strings.favorite_shortcut_edit, Drawables.drawer_edit_item),
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
                        widget._viewContext.configuration.favoriteShortcuts.updateShortcut(widget._shortcut, _alias.text);
                        widget._viewContext.stateManager.triggerStateEvent(FavoriteShortcutEditDialog.SHORTCUT_CHANGE_EVENT);
                        Navigator.of(context).pop();
                    }),
            ]
        );

        return Theme(data: td, child: dialog);
    }

    @override
    void dispose()
    {
        super.dispose();
        _alias.dispose();
    }
}
