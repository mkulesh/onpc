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

import "DeviceInfoView.dart";
import "DeviceSettingsView.dart";
import "UpdatableView.dart";

class TabDeviceView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        // empty
    ];

    TabDeviceView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        final result = ListBody(children: [
            UpdatableWidget(child: DeviceInfoView(viewContext)),
            UpdatableWidget(child: DeviceSettingsView(viewContext))
        ]);

        return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: InkWell(
                child: result,
                enableFeedback: false,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: ()
                => FocusScope.of(context).unfocus()
            )
        );
    }
}