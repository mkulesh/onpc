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
import "package:flutter/material.dart";

import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../iscp/messages/PresetMemoryMsg.dart";
import "../views/UpdatableView.dart";
import "../widgets/CustomDialogEditField.dart";
import "../widgets/CustomDialogTitle.dart";

class PresetMemoryDialog extends StatefulWidget
{
    final ViewContext _viewContext;
    final int _preset;

    PresetMemoryDialog(this._viewContext, this._preset);

    @override _PresetMemoryDialogState createState()
    => _PresetMemoryDialogState();
}

class _PresetMemoryDialogState extends State<PresetMemoryDialog>
{
    final _presetText = TextEditingController();

    ViewContext get viewContext
    => widget._viewContext;

    @override
    void initState()
    {
        super.initState();
        _presetText.text = widget._preset.toString();
    }

    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = viewContext.getThemeData();

        final List<Widget> controls = [];

        controls.add(CustomDialogEditField(_presetText,
            textLabel: Strings.cmd_preset_memory_number,
            isFocused: true,
            onChanged: (val)
            {
                setState(()
                {
                    // empty, just to redraw OK button
                });
            })
        );

        final Widget dialog = AlertDialog(
            title: CustomDialogTitle(Strings.cmd_preset_memory, Drawables.cmd_track_menu),
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
                    child: Text(Strings.action_ok.toUpperCase(),
                        style: _presetText.text.isEmpty ? td.textTheme.button.copyWith(color: td.disabledColor) : td.textTheme.button
                    ),
                    onPressed: _presetText.text.isEmpty ? null : ()
                    {
                        Navigator.of(context).pop();
                        final int preset = int.tryParse(_presetText.text);
                        if (preset != null)
                        {
                            viewContext.stateManager.sendPresetMemoryMsg(PresetMemoryMsg.outputCmd(preset));
                        }
                    }),
            ]
        );

        return Theme(data: td, child: dialog);
    }

    @override
    void dispose()
    {
        _presetText.dispose();
        super.dispose();
    }
}