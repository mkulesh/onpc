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

import "../iscp/StateManager.dart";
import "../iscp/state/SoundControlState.dart";
import "../views/ListeningModeView.dart";
import "../views/PlayControlView.dart";
import "../views/TrackCaptionView.dart";
import "../views/TrackCoverView.dart";
import "../views/TrackFileInfoView.dart";
import "../views/TrackTimeView.dart";
import "../views/UpdatableView.dart";
import "../views/VolumeControlView.dart";

class TabListenView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        StateManager.ZONE_EVENT,
        StateManager.CONNECTION_EVENT,
    ];

    TabListenView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        final bool isPortrait = MediaQuery
            .of(context)
            .orientation == Orientation.portrait;

        final List<Widget> widgets = List<Widget>();

        final SoundControlType soundControl = state.soundControlState.soundControlType(
            configuration.audioControl.soundControl, state.getActiveZoneInfo);

        // Add listening modes if sound is controlled by the device
        if ([SoundControlType.DEVICE_BUTTONS, SoundControlType.DEVICE_SLIDER, SoundControlType.DEVICE_BTN_SLIDER].contains(soundControl))
        {
            widgets.add(UpdatableWidget(child: ListeningModeView(viewContext)));
        }

        if (soundControl != SoundControlType.NONE)
        {
            widgets.add(UpdatableWidget(child: VolumeControlView(viewContext)));
        }

        widgets.add(UpdatableWidget(child: TrackFileInfoView(viewContext)));
        if (isPortrait)
        {
            widgets.add(UpdatableWidget(child: TrackCoverView(viewContext)));
        }
        widgets.add(UpdatableWidget(child: TrackTimeView(viewContext)));
        widgets.add(UpdatableWidget(child: TrackCaptionView(viewContext)));
        widgets.add(UpdatableWidget(child: PlayControlView(viewContext)));

        if (isPortrait)
        {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widgets
            );
        }
        else
        {
            final Widget column = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: widgets);
            return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    UpdatableWidget(child: TrackCoverView(viewContext, flex: 10)),
                    Expanded(child: SizedBox.shrink(), flex: 1),
                    Expanded(child: column, flex: 20)
                ]
            );
        }
    }
}