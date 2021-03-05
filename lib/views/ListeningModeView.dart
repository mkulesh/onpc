/*
 * Enhanced Controller for Onkyo and Pioneer Pro
 * Copyright (C) 2019-2021 by Mikhail Kulesh
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

import "../config/CfgAudioControl.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/ListeningModeMsg.dart";
import "../iscp/messages/PowerStatusMsg.dart";
import "../iscp/state/SoundControlState.dart";
import "../utils/Logging.dart";
import "../widgets/CustomImageButton.dart";
import "../widgets/CustomTextButton.dart";
import "UpdatableView.dart";


class ListeningModeView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        StateManager.ZONE_EVENT,
        PowerStatusMsg.CODE,
        ListeningModeMsg.CODE
    ];

    ListeningModeView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.logRebuild(this);

        final SoundControlType soundControl = state.soundControlState.soundControlType(
            configuration.audioControl.soundControl, state.getActiveZoneInfo);

        if (![SoundControlType.DEVICE_BUTTONS, SoundControlType.DEVICE_SLIDER, SoundControlType.DEVICE_BTN_SLIDER].contains(soundControl))
        {
            return SizedBox.shrink();
        }

        final List<Widget> buttons = [];

        configuration.audioControl.getSortedListeningModes(false, state.soundControlState.listeningMode).forEach((m)
        {
            final ListeningModeMsg cmd = ListeningModeMsg.output(m.key);

            buttons.add(CustomTextButton(
                m.description.toUpperCase(),
                isEnabled: state.isOn,
                isSelected: state.soundControlState.listeningMode.key == m.key,
                onPressed: ()
                => stateManager.sendMessage(cmd))
            );
        });

        if (buttons.isEmpty)
        {
            return SizedBox.shrink();
        }

        final List<Widget> elements = [];

        elements.add(CustomImageButton.small(
            Drawables.listening_mode_audio,
            Strings.listening_mode_audio,
            isEnabled: state.isOn,
            isSelected: configuration.audioControl.listeningModeFilter == ListeningModeFilter.AUDIO,
            onPressed: ()
            {
                _toggleListeningModeFilter(ListeningModeFilter.AUDIO);
                updateCallback();
            })
        );

        elements.add(Expanded(
            child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: buttons)))
        );

        elements.add(CustomImageButton.small(
            Drawables.listening_mode_video,
            Strings.listening_mode_video,
            isEnabled: state.isOn,
            isSelected: configuration.audioControl.listeningModeFilter == ListeningModeFilter.VIDEO,
            onPressed: ()
            {
                _toggleListeningModeFilter(ListeningModeFilter.VIDEO);
                updateCallback();
            })
        );

        return Row(mainAxisSize: MainAxisSize.max, children: elements);
    }

    void _toggleListeningModeFilter(ListeningModeFilter mode)
    {
        configuration.audioControl.listeningModeFilter =
            configuration.audioControl.listeningModeFilter == mode ?  ListeningModeFilter.NONE : mode;
    }
}