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

import "package:flutter/material.dart";
import "package:flutter_svg/svg.dart";

import "../constants/Dimens.dart";
import "../utils/Convert.dart";

class CustomImageButton extends StatelessWidget
{
    final String icon;
    final String? description;
    final String text;
    final VoidCallback? onPressed;
    final int type;
    final EdgeInsetsGeometry? padding;
    final bool isEnabled, isSelected, isMenu;

    CustomImageButton.menu(this.icon, this.description,
    {
        this.text = "",
        this.onPressed,
        this.type = 0,
        this.padding,
        this.isEnabled = true,
        this.isSelected = false,
        this.isMenu = true
    });

    CustomImageButton.small(this.icon, this.description,
    {
        this.text = "",
        this.onPressed,
        this.type = 1,
        this.padding,
        this.isEnabled = true,
        this.isSelected = false,
        this.isMenu = false
    });

    CustomImageButton.normal(this.icon, this.description,
    {
        this.text = "",
        this.onPressed,
        this.type = 2,
        this.padding,
        this.isEnabled = true,
        this.isSelected = false,
        this.isMenu = false
    });

    CustomImageButton.big(this.icon, this.description,
    {
        this.text = "",
        this.onPressed,
        this.type = 3,
        this.padding,
        this.isEnabled = true,
        this.isSelected = false,
        this.isMenu = false
    });

    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = Theme.of(context);
        final Color color = isEnabled ?
            (isSelected ? td.colorScheme.secondary : (isMenu ? td.bottomAppBarTheme.color! : td.textTheme.labelLarge!.color!))
                : (isMenu ? td.appBarTheme.backgroundColor! : td.disabledColor);

        double _size;
        EdgeInsetsGeometry _padding;
        switch (this.type)
        {
            case 0:
                _size = ButtonDimens.menuButtonSize;
                _padding = padding ?? ButtonDimens.imgButtonPadding;
                break;
            case 1:
                _size = ButtonDimens.smallButtonSize;
                _padding = padding ?? ButtonDimens.smallButtonPadding;
                break;
            case 2:
                _size = ButtonDimens.normalButtonSize;
                _padding = padding ?? ButtonDimens.imgButtonPadding;
                break;
            default:
                _size = ButtonDimens.bigButtonSize;
                _padding = padding ?? ButtonDimens.imgButtonPadding;
                break;
        }

        final SvgPicture svg = SvgPicture.asset(
            icon,
            colorFilter: Convert.toColorFilter(color),
            width: _size,
            height: _size,
            semanticsLabel: description
        );

        Widget result = MaterialButton(
            child: svg,
            elevation: 1,
            minWidth: _size,
            height: _size,
            padding: _padding,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.standard,
            onPressed: isEnabled ? onPressed : null);

        if (text.isNotEmpty)
        {
            result = Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [result, Text(text, style: td.textTheme.labelLarge!.copyWith(color: color))]
            );

            if (isEnabled && onPressed != null)
            {
                result = InkWell(child: result, onTap: onPressed);
            }
        }

        if (description != null)
        {
            result = Tooltip(message: description,
                child: result,
                preferBelow: false
            );
        }

        return result;
    }
}