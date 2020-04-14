/*
 * Copyright (C) 2019. Mikhail Kulesh
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

class CustomTextField extends StatelessWidget
{
    final TextEditingController text;
    final bool isFocused;
    final bool isBorder;
    final VoidCallback onPressed;
    final ValueChanged<String> onChanged;

    CustomTextField(this.text, { this.isFocused = false, this.isBorder = true, this.onPressed, this.onChanged });

    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = Theme.of(context);
        return TextFormField(
            controller: text,
            onChanged: onChanged,
            autofocus: isFocused,
            style: td.textTheme.subhead,
            autovalidate: false,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: onPressed != null ? TextInputAction.done : null,
            onEditingComplete: onPressed,
            cursorColor: td.accentColor,
            decoration: InputDecoration(
                contentPadding: DialogDimens.textFieldPadding,
                isDense: true,
                border: isBorder ? UnderlineInputBorder(borderSide: BorderSide(color: td.disabledColor)) : InputBorder.none,
                focusedBorder: isBorder ? UnderlineInputBorder(borderSide: BorderSide(color: td.accentColor)) : InputBorder.none
            )
        );
    }
}