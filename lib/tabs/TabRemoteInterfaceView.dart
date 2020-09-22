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

import "../views/AmplifierControlView.dart";
import "../views/CdControlView.dart";
import "../views/UpdatableView.dart";

class TabRemoteInterfaceView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        // empty
    ];

    TabRemoteInterfaceView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        final List<Widget> views = List();
        if (configuration.appSettings.riAmp)
        {
            views.add(UpdatableWidget(child: AmplifierControlView(viewContext)));
        }
        if (configuration.appSettings.riCd)
        {
            views.add(UpdatableWidget(child: CdControlView(viewContext)));
        }
        return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ListBody(children: views)
        );
    }
}