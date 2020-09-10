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

import "../config/CfgFavoriteShortcuts.dart";
import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../iscp/StateManager.dart";
import "../views/UpdatableView.dart";
import "../widgets/CustomCheckbox.dart";
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

enum _ShortcutAction
{
    UPDATE,
    DELETE
}

class _FavoriteShortcutEditDialogState extends State<FavoriteShortcutEditDialog>
{
    _ShortcutAction _shortcutAction;
    final _alias = TextEditingController();

    ViewContext get viewContext
    => widget._viewContext;

    @override
    void initState()
    {
        super.initState();
        _shortcutAction = _ShortcutAction.UPDATE;
        _alias.text = widget._shortcut.alias;
    }

    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = viewContext.getThemeData();

        final List<Widget> controls = List();

        controls.add(CustomTextLabel.small(widget._shortcut.getLabel()));

        controls.add(CustomCheckbox(Strings.favorite_update,
            icon: Radio(
                value: _ShortcutAction.UPDATE,
                groupValue: _shortcutAction,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (_ShortcutAction v)
                {
                    setState(()
                    {
                        _shortcutAction = v;
                    });
                })
        )
        );

        controls.add(CustomDialogEditField(_alias,
            textLabel: Strings.favorite_alias,
            isFocused: true)
        );

        controls.add(CustomCheckbox(Strings.favorite_delete,
            icon: Radio(
                value: _ShortcutAction.DELETE,
                groupValue: _shortcutAction,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (_ShortcutAction v)
                {
                    setState(()
                    {
                        _shortcutAction = v;
                        FocusScope.of(context).unfocus();
                    });
                })
        )
        );

        final Widget dialog = AlertDialog(
            title: CustomDialogTitle(Strings.favorite_shortcut_edit, Drawables.drawer_edit_item),
            contentPadding: DialogDimens.contentPadding,
            content: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: ListBody(children: controls)),
            actions: <Widget>[
                FlatButton(
                    child: Text(Strings.action_cancel.toUpperCase(), style: td.textTheme.button),
                    onPressed: ()
                    {
                        Navigator.of(context).pop();
                    }),
                FlatButton(
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
        final CfgFavoriteShortcuts cfg = widget._viewContext.configuration.favoriteShortcuts;
        switch (_shortcutAction)
        {
            case _ShortcutAction.UPDATE:
                cfg.updateShortcut(widget._shortcut, _alias.text);
                break;
            case _ShortcutAction.DELETE:
                cfg.deleteShortcut(widget._shortcut);
                break;
        }
        final StateManager sm = widget._viewContext.stateManager;
        sm.triggerStateEvent(FavoriteShortcutEditDialog.SHORTCUT_CHANGE_EVENT);
    }

    @override
    void dispose()
    {
        super.dispose();
        _alias.dispose();
    }
}
