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

import "../views/UpdatableView.dart";
import "AppTabView.dart";

class TabRemoteInterfaceView extends AppTabView
{
    static const List<String> UPDATE_TRIGGERS = [
        // empty
    ];

    static const List<AppControl> CONTROLS = [
        AppControl.RI_AMPLIFIER,
        AppControl.RI_CD_PLAYER,
    ];

    TabRemoteInterfaceView(final ViewContext viewContext) :
        super(viewContext, UPDATE_TRIGGERS, controlsPortrait: CONTROLS, scrollable: true, focusable: false);
}