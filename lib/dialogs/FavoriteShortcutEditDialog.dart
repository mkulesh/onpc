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

import "package:flutter/material.dart";

import "../config/CfgFavoriteShortcuts.dart";
import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/EnumParameterMsg.dart";
import "../iscp/messages/ListeningModeMsg.dart";
import "../views/UpdatableView.dart";
import "../widgets/CustomCheckbox.dart";
import "../widgets/CustomDialogEditField.dart";
import "../widgets/CustomDialogTitle.dart";
import "../widgets/CustomTextLabel.dart";
import "DropdownPreferenceDialog.dart";

class FavoriteShortcutEditDialog extends StatefulWidget
{
    final ViewContext _viewContext;
    final Shortcut _shortcut;

    FavoriteShortcutEditDialog(this._viewContext, this._shortcut);

    @override _FavoriteShortcutEditDialogState createState()
    => _FavoriteShortcutEditDialogState();
}

class _FavoriteShortcutEditDialogState extends State<FavoriteShortcutEditDialog>
{
    final _alias = TextEditingController();
    EnumItem<ListeningMode> _listeningMode = ListeningModeMsg.ValueEnum.defValue;
    bool _applyListeningMode = false;

    ViewContext get viewContext
    => widget._viewContext;

    @override
    void initState()
    {
        super.initState();
        _alias.text = widget._shortcut.alias;
        _listeningMode = ListeningModeMsg.ValueEnum.valueByKey(widget._shortcut.listeningMode);
        _applyListeningMode = _listeningMode.key != ListeningMode.NONE;
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
            textLabel: Strings.pref_item_name,
            isFocused: true)
        );

        final List<EnumItem<ListeningMode>> listening_modes =
        viewContext.configuration.audioControl.getSortedListeningModes(false, _listeningMode, viewContext.state.protoType);
        if (listening_modes.isNotEmpty)
        {
            _addListeningModeControl(context, listening_modes, controls);
        }

        final Widget dialog = AlertDialog(
            title: CustomDialogTitle(Strings.favorite_shortcut_edit, Drawables.drawer_edit_item),
            contentPadding: DialogDimens.contentPadding,
            content: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: ListBody(children: controls)),
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
                        viewContext.configuration.favoriteShortcuts.updateShortcut(
                            widget._shortcut, _alias.text, listeningMode: _listeningMode.key);
                        viewContext.stateManager.triggerStateEvent(StateManager.SHORTCUT_CHANGE_EVENT);
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

    void _addListeningModeControl(BuildContext context, List<EnumItem<ListeningMode>> listening_modes, List<Widget> controls)
    {
        controls.add(CustomCheckbox(Strings.listening_mode_apply,
            value: _applyListeningMode,
            padding: DialogDimens.rowPadding,
            onChanged: (bool newValue)
            {
                setState(()
                {
                    _applyListeningMode = newValue;
                    if (!_applyListeningMode)
                    {
                        _listeningMode = ListeningModeMsg.ValueEnum.defValue;
                    }
                });
                if (_applyListeningMode)
                {
                    _onSelectListeningMode(context, listening_modes);
                }
            }
        ));

        if (_listeningMode.key != ListeningMode.NONE)
        {
            final Widget lm = Padding(
                padding: DialogDimens.rowPadding,
                child:  CustomTextLabel.normal(_listeningMode.description, underline: true));
            controls.add(InkWell(child: lm,
                onTap: () => _onSelectListeningMode(context, listening_modes))
            );
        }
    }

    void _onSelectListeningMode(final BuildContext context, final List<EnumItem<ListeningMode>> listening_modes)
    {
        final List<String> listening_modes_keys = [];
        final List<String> listening_modes_names = [];
        listening_modes.forEach((m)
        {
            listening_modes_keys.add(m.getKey);
            listening_modes_names.add(m.description);
        });
        final Widget d = DropdownPreferenceDialog(Strings.listening_mode_apply,
            listening_modes_keys, listening_modes_names, -1,
            (String val)
            {
                setState(()
                {
                    _listeningMode = listening_modes.firstWhere((m) => m.getKey == val,
                        orElse: () => ListeningModeMsg.ValueEnum.defValue);
                });
            }
        );
        viewContext.showRootDialog(context, d);
    }
}
