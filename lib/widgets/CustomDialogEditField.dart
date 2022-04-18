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
import "package:flutter/widgets.dart";

import "../constants/Dimens.dart";
import "CustomTextField.dart";
import "CustomTextLabel.dart";

class CustomDialogEditField extends StatelessWidget
{
    final TextEditingController controller;
    final String textLabel;
    final Widget widgetLabel;
    final bool isFocused;
    final ValueChanged<String> onChanged;

    CustomDialogEditField(this.controller,
    {
        this.textLabel,
        this.widgetLabel,
        this.isFocused = false,
        this.onChanged,
    });

    @override
    Widget build(BuildContext context)
    {
        return Padding(
            padding: DialogDimens.rowPadding,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    widgetLabel ?? (textLabel != null ? CustomTextLabel.small(textLabel) : SizedBox.shrink()),
                    CustomTextField(controller, isFocused: isFocused, onChanged: onChanged)
                ]
            )
        );
    }
}