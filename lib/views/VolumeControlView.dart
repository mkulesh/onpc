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

import "package:flutter/material.dart";

import "../iscp/StateManager.dart";
import "../iscp/messages/AudioMutingMsg.dart";
import "../iscp/messages/MasterVolumeMsg.dart";
import "../iscp/state/SoundControlState.dart";
import "../views/VolumeControlAmpView.dart";
import "../views/VolumeControlButtonsView.dart";
import "../views/VolumeControlSliderView.dart";
import "UpdatableView.dart";

class VolumeControlView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        StateManager.ZONE_EVENT,
        // Some strange bug: VolumeControlButtonsView is sometime not updated in landscape mode upon reception of "AMT"/"MVL" messages
        // As a workaround, we update whole VolumeControlView when these messages received
        AudioMutingMsg.CODE,
        MasterVolumeMsg.CODE,
    ];

    VolumeControlView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        final SoundControlType soundControl = state.soundControlState.soundControlType(
            configuration.audioControl.soundControl, state.getActiveZoneInfo);

        switch (soundControl)
        {
            case SoundControlType.DEVICE_BUTTONS:
                return UpdatableWidget(child: VolumeControlButtonsView(viewContext));
            case SoundControlType.DEVICE_SLIDER:
            case SoundControlType.DEVICE_BTN_SLIDER:
                return UpdatableWidget(child: VolumeControlSliderView(viewContext, soundControl == SoundControlType.DEVICE_BTN_SLIDER));
            case SoundControlType.RI_AMP:
                return UpdatableWidget(child: VolumeControlAmpView(viewContext));
            default:
                return SizedBox.shrink();
        }
    }
}
