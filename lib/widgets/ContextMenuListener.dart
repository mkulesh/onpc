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
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import "../Platform.dart";
import "../widgets/PositionedTapDetector.dart";

typedef ContextMenuCallback = void Function(TapPosition position);

class ContextMenuListener extends StatelessWidget
{
    final Widget child;
    final ContextMenuCallback onContextMenu;

    ContextMenuListener({Key key, this.child, this.onContextMenu}) : super(key: key);

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
                        onContextMenu(position);
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
                => onContextMenu(position)
            );
        }
    }
}