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

class CustomTextButton extends StatelessWidget
{
    final String text, description;
    final VoidCallback onPressed;
    final EdgeInsetsGeometry padding;
    final bool isEnabled, isSelected;

    CustomTextButton(this.text,
    {
        this.description,
        this.onPressed,
        this.padding,
        this.isEnabled = true,
        this.isSelected = false
    });

    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = Theme.of(context);
        final Color color = isEnabled ?
            (isSelected ? td.accentColor : td.textTheme.button.color)
                : td.disabledColor;

        final Widget result = MaterialButton(
            child: Text(text, style: td.textTheme.button.copyWith(color: color)),
            padding: padding ?? ButtonDimens.textButtonPadding,
            color: td.backgroundColor,
            textColor: color,
            elevation: 0,
            minWidth: 0,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            height: ButtonDimens.normalButtonSize,
            onPressed: onPressed);

        return (description == null) ?
            result : Tooltip(message: description, child: result, preferBelow: false);
    }
}