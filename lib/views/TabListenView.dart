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
import "../iscp/messages/AudioMutingMsg.dart";
import "../iscp/messages/InputSelectorMsg.dart";
import "../iscp/messages/MasterVolumeMsg.dart";
import "../iscp/state/SoundControlState.dart";
import "DeviceVolumeButtonsView.dart";
import "DeviceVolumeSliderView.dart";
import "ExtAmpVolumeView.dart";
import "ListeningModeView.dart";
import "PlayControlView.dart";
import "PlayCdControlView.dart";
import "RadioControlView.dart";
import "TrackInfoView.dart";
import "UpdatableView.dart";

class TabListenView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        StateManager.ZONE_EVENT,
        StateManager.CONNECTION_EVENT,
        InputSelectorMsg.CODE,
        // Some strange bug: DeviceVolumeButtonsView is sometime not updated in landscape mode upon reception of "AMT"/"MVL" messages
        // As a workaround, we update whole TabListenView when these messages received
        AudioMutingMsg.CODE,
        MasterVolumeMsg.CODE
    ];

    TabListenView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        final bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

        final List<Widget> widgets = List<Widget>();

        final SoundControlType soundControl = state.soundControlState.soundControlType(
            configuration.audioControl.soundControl, state.getActiveZoneInfo);

        // Add listening modes if sound is controlled by the device
        if ([SoundControlType.DEVICE_BUTTONS, SoundControlType.DEVICE_SLIDER, SoundControlType.DEVICE_BTN_SLIDER].contains(soundControl))
        {
            widgets.add(Center(child: UpdatableWidget(child: ListeningModeView(viewContext))));
        }

        // Sound controls depends on orientation and configuration
        Widget soundControlView;
        switch (soundControl)
        {
            case SoundControlType.DEVICE_BUTTONS:
                soundControlView = UpdatableWidget(child: DeviceVolumeButtonsView(viewContext));
                break;
            case SoundControlType.DEVICE_SLIDER:
            case SoundControlType.DEVICE_BTN_SLIDER:
                soundControlView = UpdatableWidget(child: isPortrait ?
                    DeviceVolumeSliderView(viewContext, soundControl == SoundControlType.DEVICE_BTN_SLIDER) : DeviceVolumeButtonsView(viewContext));
                break;
            case SoundControlType.RI_AMP:
                soundControlView = UpdatableWidget(child: ExtAmpVolumeView(viewContext));
                break;
            default:
                soundControlView = null;
                break;
        }
        if (isPortrait && soundControlView != null)
        {
            widgets.add(soundControlView);
        }

        // Track info always in the middle of screen
        widgets.add(Expanded(child: UpdatableWidget(child: TrackInfoView(viewContext)), flex: 1));

        // Play controls depends on input type
        final UpdatableView playControlView = state.mediaListState.isRadioInput ? RadioControlView(viewContext) :
            (state.isCdInput ? PlayCdControlView(viewContext) : PlayControlView(viewContext));
        final List<Widget> playControlList = List();
        if (!isPortrait && soundControlView != null)
        {
            playControlList.add(soundControlView);
        }
        playControlList.add(UpdatableWidget(child: playControlView));
        final Widget playControl = Center(
            child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: playControlList))
        );
        widgets.add(playControl);

        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widgets
        );
    }
}