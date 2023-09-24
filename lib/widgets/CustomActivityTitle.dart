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

class CustomActivityTitle extends StatelessWidget
{
    final String title;
    final String? subTitle;

    CustomActivityTitle(this.title, this.subTitle);

    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = Theme.of(context);
        final bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

        final double titleSize = isPortrait ? td.textTheme.titleLarge!.fontSize! : td.textTheme.titleLarge!.fontSize! - 2;
        final double subTitleSize = isPortrait ? td.textTheme.titleLarge!.fontSize! - 4 : td.textTheme.titleLarge!.fontSize! - 6;

        final List<Widget> children = [];
        children.add(Text(title,
            style: td.textTheme.titleLarge!.copyWith(
                fontSize: titleSize,
                color: td.bottomAppBarTheme.color)));

        if (subTitle != null)
        {
            children.add(Text(subTitle!,
                style: td.textTheme.titleLarge!.copyWith(
                    fontSize: subTitleSize,
                    fontWeight: FontWeight.normal,
                    color: td.bottomAppBarTheme.color!.withAlpha(175))));
        }

        return children.length == 1 ? children[0] : Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children);
    }
}