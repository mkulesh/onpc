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

import "../iscp/messages/FriendlyNameMsg.dart";
import "../iscp/messages/ReceiverInformationMsg.dart";
import "../views/DeviceInfoView.dart";
import "../views/DeviceSettingsView.dart";
import "../views/UpdatableView.dart";

class TabDeviceView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        ReceiverInformationMsg.CODE,
        FriendlyNameMsg.CODE,
    ];

    TabDeviceView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        final List<Widget> views = List();

        if (state.receiverInformation.isFriendlyName || state.receiverInformation.isReceiverInformation)
        {
            views.add(DeviceInfoView(viewContext));
        }
        views.add(UpdatableWidget(child: DeviceSettingsView(viewContext)));

        return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: InkWell(
                child: ListBody(children: views),
                enableFeedback: false,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: ()
                => FocusScope.of(context).unfocus()
            )
        );
    }
}