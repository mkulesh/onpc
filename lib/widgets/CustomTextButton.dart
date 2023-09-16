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

class CustomTextButton extends StatelessWidget
{
    final String text, description;
    final VoidCallback onPressed;
    final EdgeInsetsGeometry padding;
    final bool isEnabled, isSelected, isInDialog;

    CustomTextButton(this.text,
    {
        this.description,
        this.onPressed,
        this.padding,
        this.isEnabled = true,
        this.isSelected = false,
        this.isInDialog = false
    });

    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = Theme.of(context);
        final Color color = isEnabled ?
            (isSelected ? td.colorScheme.secondary : td.textTheme.labelLarge.color)
                : td.disabledColor;

        final Widget result = MaterialButton(
            child: Text(text, style: td.textTheme.labelLarge.copyWith(color: color)),
            padding: _getPadding(),
            color: isInDialog ? td.dialogBackgroundColor : td.colorScheme.background,
            textColor: color,
            elevation: 0,
            minWidth: 0,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.standard,
            height: ButtonDimens.normalButtonSize,
            onPressed: onPressed);

        return (description == null) ?
            result : Tooltip(message: description, child: result, preferBelow: false);
    }

    EdgeInsetsGeometry _getPadding()
    => padding ?? ButtonDimens.textButtonPadding;

    double getWidth(BuildContext context)
    {
        final ThemeData td = Theme.of(context);
        final Size size = (TextPainter(
            text: TextSpan(text: text, style: td.textTheme.labelLarge),
            maxLines: 1,
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
            textDirection: TextDirection.ltr)
            ..layout())
            .size;
        return size.width + _getPadding().horizontal;
    }
}