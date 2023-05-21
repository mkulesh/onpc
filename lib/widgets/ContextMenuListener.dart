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
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import "../Platform.dart";
import "../utils/Pair.dart";
import "CustomTextLabel.dart";
import "PositionedTapDetector.dart";

class ContextMenuListener<T> extends StatelessWidget
{
    final Widget child;
    final void Function(TapPosition position) onContextMenu;
    final String menuName;
    final List<Pair<String, T>> menuItems;
    final void Function(BuildContext context, T item) onItemSelected;

    ContextMenuListener(
        {Key key,
        this.child,
        this.onContextMenu,
        this.menuName,
        this.menuItems,
        this.onItemSelected,
        }) : super(key: key);

    @override
    Widget build(BuildContext context)
    {
        if (Platform.isDesktop)
        {
            return Listener(
                key: key,
                child: child,
                onPointerDown: (event)
                {
                    if (event.buttons == kSecondaryButton)
                    {
                        final TapPosition position = TapPosition(event.position, event.localPosition);
                        _onContextMenu(context, position);
                    }
                }
            );
        }
        else
        {
            return PositionedTapDetector(
                key: key,
                child: child,
                onLongPress: (position)
                => _onContextMenu(context, position)
            );
        }
    }

    void _onContextMenu(BuildContext context, TapPosition position)
    {
        if (onItemSelected != null)
        {
            final List<PopupMenuItem<T>> contextMenu = [];
            if (menuName != null)
            {
                contextMenu.add(
                    PopupMenuItem<T>(child: CustomTextLabel.small(menuName), enabled: false));
            }
            if (menuItems != null)
            {
                menuItems.forEach((item) =>
                    contextMenu.add(PopupMenuItem<T>(child: Text(item.item1), value: item.item2)));
            }
            showMenu(
                context: context,
                position: RelativeRect.fromLTRB(position.global.dx, position.global.dy, position.global.dx, position.global.dy),
                items: contextMenu).then((m)
            {
                if (m != null)
                {
                    onItemSelected(context, m);
                }
            });
        }
        else if (onContextMenu != null)
        {
            onContextMenu(position);
        }
    }
}