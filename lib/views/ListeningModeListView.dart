/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2025 by Mikhail Kulesh
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

import "../iscp/ConnectionIf.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/DcpAllZoneStereoMsg.dart";
import "../iscp/messages/ListeningModeMsg.dart";
import "../iscp/messages/PowerStatusMsg.dart";
import "../iscp/state/SoundControlState.dart";
import "../utils/Logging.dart";
import "../widgets/CustomTextButton.dart";
import '../widgets/TextButtonScroll.dart';
import "UpdatableView.dart";


class ListeningModeListView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        StateManager.ZONE_EVENT,
        PowerStatusMsg.CODE,
        ListeningModeMsg.CODE
    ];

    ListeningModeListView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.logRebuild(this);

        final SoundControlType soundControl = SoundControlState.soundControlType(
            configuration.audioControl, state.getActiveZone);

        if (![SoundControlType.DEVICE_BUTTONS,
              SoundControlType.DEVICE_SLIDER,
              SoundControlType.DEVICE_BTN_AROUND_SLIDER,
              SoundControlType.DEVICE_BTN_ABOVE_SLIDER].contains(soundControl))
        {
            return SizedBox.shrink();
        }

        final List<CustomTextButton> buttons = [];
        CustomTextButton? selectedButton;

        configuration.audioControl.getSortedListeningModes(
            false, state.soundControlState.listeningMode, state.protoType).forEach((m)
        {
            final ListeningModeMsg cmd = ListeningModeMsg.output(m.key);
            final bool isSelected = state.soundControlState.listeningMode.key == m.key;
            final CustomTextButton button = CustomTextButton(
                m.description.toUpperCase(),
                isEnabled: state.isOn,
                isSelected: isSelected,
                onPressed: ()
                {
                    final DcpAllZoneStereoMsg? allZoneStereoMsg =
                        state.protoType == ProtoType.DCP ? state.soundControlState.toggleAllZoneStereo(m) : null;
                    if (allZoneStereoMsg != null)
                    {
                        stateManager.sendMessage(allZoneStereoMsg);
                    }
                    stateManager.sendMessage(cmd);
                }
            );
            if (isSelected)
            {
                selectedButton = button;
            }
            buttons.add(button);
        });

        return buttons.isEmpty ? SizedBox.shrink() : Center(child: TextButtonScroll(buttons, selectedButton));
    }
}