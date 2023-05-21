/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2023 by Mikhail Kulesh
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
import "CustomTextLabel.dart";

class CustomCheckbox extends StatelessWidget
{
    final String textLabel;
    final bool value;
    final EdgeInsetsGeometry padding;
    final Widget icon;
    final bool enabled;
    final ValueChanged<bool> onChanged;

    CustomCheckbox(this.textLabel,
    {
        this.value = false,
        this.padding = ActivityDimens.noPadding,
        this.icon,
        this.enabled = true,
        this.onChanged
    });

    @override
    Widget build(BuildContext context)
    {
        final Widget checkBox = Checkbox(
            value: value,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: enabled ? onChanged : null
        );

        final Widget row = Padding(
            padding: padding,
            child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    Flexible(child: CustomTextLabel.normal(textLabel)),
                    icon != null ? icon : checkBox,
                ])
        );

        return onChanged != null && enabled ? InkWell(child: row, onTap: () => onChanged(!value)) : row;
    }
}