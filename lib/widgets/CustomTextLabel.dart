/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2024 by Mikhail Kulesh
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

import "../constants/Dimens.dart";

class CustomTextLabel extends StatelessWidget
{
    final String description;
    final EdgeInsetsGeometry padding;
    final TextAlign textAlign;
    final int size;
    final bool bold;
    final bool underline;
    final Color? color;

    CustomTextLabel.small(this.description,
    {
        this.padding = ActivityDimens.noPadding,
        this.textAlign = TextAlign.left,
        this.size = 1,
        this.bold = false,
        this.underline = false,
        this.color
    });

    CustomTextLabel.normal(this.description,
    {
        this.padding = ActivityDimens.noPadding,
        this.textAlign = TextAlign.left,
        this.size = 2,
        this.bold = false,
        this.underline = false,
        this.color
    });

    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = Theme.of(context);
        final TextStyle style = size == 1 ? td.textTheme.bodyMedium! : td.textTheme.titleMedium!;
        final Color c = this.color ?? style.color!;
        final w = bold ? FontWeight.w700 : FontWeight.w400;
        final Widget t1 = Text(description,
            style: style.copyWith(color: c, fontWeight: w), textAlign: textAlign, softWrap: true);
        final Widget t2 = (padding.vertical > 0 || padding.horizontal > 0) ? Padding(padding: padding, child: t1) : t1;
        if (underline)
        {
            return Container(
                padding: EdgeInsets.symmetric(vertical: DimensTransform.scale(1.0)),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: td.textTheme.titleMedium!.color!))),
                child: t2);
        }
        else
        {
            return t2;
        }
    }
}