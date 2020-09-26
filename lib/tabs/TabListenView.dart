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

import "../iscp/StateManager.dart";
import "../views/UpdatableView.dart";
import "AppTabView.dart";

class TabListenView extends AppTabView
{
    static const List<String> UPDATE_TRIGGERS = [
        StateManager.ZONE_EVENT,
        StateManager.CONNECTION_EVENT,
    ];

    static const List<AppControl> PORT_CONTROLS = [
        AppControl.LISTENING_MODE,
        AppControl.VOLUME_CONTROL,
        AppControl.TRACK_FILE_INFO,
        AppControl.TRACK_COVER,
        AppControl.TRACK_TIME,
        AppControl.TRACK_CAPTION,
        AppControl.PLAY_CONTROL
    ];

    static const List<AppControl> LAND_LEFT_CONTROLS = [
        AppControl.TRACK_COVER
    ];

    static const List<AppControl> LAND_RIGHT_CONTROLS = [
        AppControl.LISTENING_MODE,
        AppControl.VOLUME_CONTROL,
        AppControl.TRACK_FILE_INFO,
        AppControl.TRACK_TIME,
        AppControl.TRACK_CAPTION,
        AppControl.PLAY_CONTROL
    ];

    TabListenView(final ViewContext viewContext) :
        super(viewContext, UPDATE_TRIGGERS,
            controlsPortrait: PORT_CONTROLS,
            controlsLandscapeLeft: LAND_LEFT_CONTROLS,
            controlsLandscapeRight: LAND_RIGHT_CONTROLS,
            scrollable: false, focusable: false);
}