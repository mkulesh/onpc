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

    CustomTextField(this.text, { this.isFocused = false });

    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = Theme.of(context);
        return Padding(
            padding: ActivityDimens.noPadding,
            child: TextFormField(
                controller: text,
                autofocus: isFocused,
                style: td.textTheme.subhead,
                cursorColor: td.accentColor,
                decoration: InputDecoration(
                    contentPadding: DialogDimens.textFieldPadding,
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: td.accentColor)),
                )),
        );
    }
}