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

import "../constants/Dimens.dart";
import "../utils/Platform.dart";

class ReorderableItem extends StatelessWidget
{
    final Widget child;

    ReorderableItem({Key? key, required this.child}) : super(key: key);

    @override
    Widget build(BuildContext context)
    {
        final List<Widget> items = [];
        items.add(Expanded(child: child));
        if (Platform.isDesktop)
        {
            // On desktop, add a placeholder for drag_handle instead a button
            items.add(SizedBox(width: ButtonDimens.normalButtonSize, height: ButtonDimens.normalButtonSize));
        }
        else
        {
            items.add(Icon(Icons.drag_handle));
        }
        return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: items
        );
    }
}
