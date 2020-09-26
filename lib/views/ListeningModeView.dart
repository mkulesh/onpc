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

import "../iscp/messages/ListeningModeMsg.dart";
import "../iscp/messages/PowerStatusMsg.dart";
import "../utils/Logging.dart";
import "../widgets/CustomTextButton.dart";
import "UpdatableView.dart";


class ListeningModeView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        PowerStatusMsg.CODE,
        ListeningModeMsg.CODE
    ];

    ListeningModeView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.info(this, "rebuild widget");

        final List<Widget> buttons = List<Widget>();

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
        return Center(
            child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: buttons))
        );
    }
}