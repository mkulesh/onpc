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

import "package:flutter/material.dart";

import "../config/TextLabelStyle.dart";
import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../views/UpdatableView.dart";
import "../widgets/CustomDialogEditField.dart";
import "../widgets/CustomDialogTitle.dart";
import "../widgets/CustomImageButton.dart";
import "../widgets/CustomTextLabel.dart";

class TextLabelStyleDialog extends StatefulWidget
{
    final ViewContext _viewContext;
    final TextLabelParName _parName;
    final TextLabelStyle _style;

    TextLabelStyleDialog(this._viewContext, this._parName, this._style);

    @override _TextLabelStyleDialogState createState()
    => _TextLabelStyleDialogState();
}

class _TextLabelStyleDialogState extends State<TextLabelStyleDialog>
{
    final _textScale = TextEditingController();
    bool _bold = false, _italic = false, _underline = false, _shadow = false;

    ViewContext get viewContext
    => widget._viewContext;

    @override
    void initState()
    {
        super.initState();
        _textScale.text = widget._style.scale.toString();
        _bold = widget._style.bold;
        _italic = widget._style.italic;
        _underline = widget._style.underline;
        _shadow = widget._style.shadow;
    }

    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = viewContext.getThemeData();

        final List<Widget> controls = [];

        controls.add(CustomDialogEditField(_textScale,
            textLabel: Strings.pref_text_scale,
            isFocused: true,
            onChanged: (val)
            {
                setState(()
                {
                    // empty, just to redraw OK button
                });
            })
        );

        controls.add(Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                CustomTextLabel.small(Strings.pref_text_font_style, padding: DialogDimens.rowPadding),

                CustomImageButton.small(Drawables.pref_text_bold, Strings.pref_text_bold, isSelected: _bold,
                    onPressed: () {
                        setState(()
                        {
                            _bold = !_bold;
                        });
                    }),

                CustomImageButton.small(Drawables.pref_text_italic, Strings.pref_text_italic, isSelected: _italic,
                    onPressed: () {
                        setState(()
                        {
                            _italic = !_italic;
                        });
                    }),

                CustomImageButton.small(Drawables.pref_text_underline, Strings.pref_text_underline, isSelected: _underline,
                    onPressed: () {
                        setState(()
                        {
                            _underline = !_underline;
                        });
                    }),

                CustomImageButton.small(Drawables.pref_text_shadow, Strings.pref_text_shadow, isSelected: _shadow,
                    onPressed: () {
                        setState(()
                        {
                            _shadow = !_shadow;
                        });
                    }),
            ]
        ));

        final Widget dialog = AlertDialog(
            title: CustomDialogTitle(Strings.pref_text_style, Drawables.pref_text_size),
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
                    child: Text(Strings.action_ok.toUpperCase(),
                        style: _textScale.text.isEmpty ? td.textTheme.labelLarge!.copyWith(color: td.disabledColor) : td.textTheme.labelLarge
                    ),
                    onPressed: _textScale.text.isEmpty ? null : ()
                    {
                        Navigator.of(context).pop();
                        final int? scale = int.tryParse(_textScale.text);
                        if (scale != null)
                        {
                            viewContext.configuration.appSettings.setTextLabelStyle(
                                widget._parName, TextLabelStyle.explicit(scale, _bold, _italic, _underline, _shadow));
                        }
                    }),
            ]
        );

        return Theme(data: td, child: dialog);
    }

    @override
    void dispose()
    {
        _textScale.dispose();
        super.dispose();
    }
}