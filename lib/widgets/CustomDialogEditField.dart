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
import "package:flutter/widgets.dart";

import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "CustomImageButton.dart";
import "CustomTextField.dart";
import "CustomTextLabel.dart";

class CustomDialogEditField extends StatelessWidget
{
    final TextEditingController controller;
    final String? textLabel;
    final Widget? widgetLabel;
    final bool isFocused;
    final bool autoCorrect;
    final ValueChanged<String>? onChanged;
    final VoidCallback? onDeleteBtn;

    CustomDialogEditField(this.controller,
    {
        this.textLabel,
        this.widgetLabel,
        this.isFocused = false,
        this.autoCorrect = false,
        this.onChanged,
        this.onDeleteBtn
    });

    @override
    Widget build(BuildContext context)
    {
        Widget editor = CustomTextField(controller, isFocused: isFocused, autoCorrect: autoCorrect, onChanged: onChanged);
        if (onDeleteBtn != null)
        {
            editor = Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                    Expanded(child: editor, flex: 1),
                    Transform.translate(
                        offset: Offset(DimensTransform.scale(4), 0.0),
                        child: CustomImageButton.small(
                            Drawables.numeric_clean, Strings.pref_item_delete, onPressed: onDeleteBtn),
                    )
                ]
            );
        }
        return Padding(
            padding: DialogDimens.rowPadding,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    widgetLabel ?? (textLabel != null ? CustomTextLabel.small(textLabel!) : SizedBox.shrink()),
                    editor
                ]
            )
        );
    }
}