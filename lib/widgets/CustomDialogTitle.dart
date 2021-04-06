/*
 * Enhanced Controller for Onkyo and Pioneer Pro
 * Copyright (C) 2019-2021 by Mikhail Kulesh
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
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_svg/svg.dart";

import "../constants/Dimens.dart";
import "CustomTextLabel.dart";

class CustomDialogTitle extends StatelessWidget
{
    final String description;
    final String icon;

    CustomDialogTitle(this.description, this.icon);

    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = Theme.of(context);
        final List<Widget> children = [];

        if (icon != null)
        {
            children.add(Padding(padding: DialogDimens.iconPadding,
                child: SvgPicture.asset(
                    icon,
                    width: DialogDimens.iconSize,
                    height: DialogDimens.iconSize,
                    color: td.disabledColor)));
        }

        children.add(Flexible(child: CustomTextLabel.normal(description, bold: true)));

        return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: children);
    }
}