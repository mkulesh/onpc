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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/Platform.dart';

class CustomScrollbar extends StatelessWidget
{
    final Widget child;
    final ScrollController? controller;

    const CustomScrollbar({
        super.key,
        required this.child,
        this.controller,
    });

    @override
    Widget build(BuildContext context)
    {
        if (Platform.isIOS)
        {
            // iOS: Use standard Cupertino scrollbar
            return CupertinoTheme(
                data: CupertinoThemeData(brightness: Theme.of(context).brightness),
                child: CupertinoScrollbar(controller: controller, child: child)
            );
        }
        else
        {
            // Android/Windows/Web: Use Material Scrollbar with local Theme
            final Color indicatorColor = Theme.of(context).indicatorColor;
            return ScrollbarTheme(
                data: ScrollbarThemeData(
                    trackVisibility: const WidgetStatePropertyAll(false),
                    thumbColor: WidgetStateProperty.resolveWith((states)
                    {
                        if (states.contains(WidgetState.dragged) || states.contains(WidgetState.hovered))
                        {
                            return indicatorColor; // use full color
                        }
                        // Default state: 70% opacity
                        return indicatorColor.withAlpha((255.0 * 0.5).round());
                    }),
                    interactive: true
                ),
                child: Scrollbar(controller: controller, child: child,)
            );
        }
    }
}
