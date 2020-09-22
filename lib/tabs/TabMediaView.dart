/*
 * Copyright (C) 2019. Mikhail Kulesh
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

import "../views/InputSelectorView.dart";
import "../views/MediaListView.dart";
import "../views/UpdatableView.dart";

class TabMediaView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        // empty
    ];

    TabMediaView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        final UpdatableWidget inputSelectorView = UpdatableWidget(child: InputSelectorView(viewContext));
        final Widget mediaListView = MediaListView(viewContext);
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                inputSelectorView,
                Expanded(child: mediaListView, flex: 1)
            ],
        );
    }
}