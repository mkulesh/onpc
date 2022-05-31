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

import "../constants/Dimens.dart";

class CustomTextLabel extends StatelessWidget
{
    final String description;
    final EdgeInsetsGeometry padding;
    final TextAlign textAlign;
    final int size;
    final bool bold;
    final Color color;

    CustomTextLabel.small(this.description,
    {
        this.padding = ActivityDimens.noPadding,
        this.textAlign = TextAlign.left,
        this.size = 1,
        this.bold = false,
        this.color
    });

    CustomTextLabel.normal(this.description,
    {
        this.padding = ActivityDimens.noPadding,
        this.textAlign = TextAlign.left,
        this.size = 2,
        this.bold = false,
        this.color
    });

    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = Theme.of(context);
        final TextStyle style = size == 1 ? td.textTheme.bodyText2 : td.textTheme.subtitle1;
        final Color c = this.color ?? style.color;
        final w = bold ? FontWeight.w700 : FontWeight.w400;
        if (padding.vertical > 0 || padding.horizontal > 0)
        {
            return Padding(
                padding: padding,
                child: Text(description, style: style.copyWith(color: c, fontWeight: w), textAlign: textAlign, softWrap: true),
            );
        }
        else
        {
            return Text(description, style: style.copyWith(color: c, fontWeight: w), textAlign: textAlign, softWrap: true);
        }
    }
}