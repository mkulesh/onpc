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

import "../iscp/messages/FriendlyNameMsg.dart";
import "../iscp/messages/ReceiverInformationMsg.dart";
import "../views/UpdatableView.dart";
import "AppTabView.dart";

class TabDeviceView extends AppTabView
{
    static const List<String> UPDATE_TRIGGERS = [
        ReceiverInformationMsg.CODE,
        FriendlyNameMsg.CODE,
    ];

    static const List<AppControl> CONTROLS = [
        AppControl.DEVICE_INFO,
        AppControl.DEVICE_SETTINGS,
    ];

    TabDeviceView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS,
        controlsPortrait: CONTROLS, scrollable: true, focusable: true);
}