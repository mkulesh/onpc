/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2026 by Mikhail Kulesh
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
import "../iscp/messages/AmpOperationCommandMsg.dart";
import "../iscp/state/SoundControlState.dart";
import "../utils/Logging.dart";
import "../utils/Pair.dart";
import "../widgets/CustomImageButton.dart";
import "UpdatableView.dart";


class VolumeControlAmpView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        StateManager.CONNECTION_EVENT
    ];

    VolumeControlAmpView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.logRebuild(this);

        final List<Pair<AmpOperationCommandMsg, MasterVolumeCmd>> cmd = [
            Pair(AmpOperationCommandMsg.output(AmpOperationCommand.AMTTG), MasterVolumeCmd.MUTE),
            Pair(AmpOperationCommandMsg.output(AmpOperationCommand.MVLDOWN), MasterVolumeCmd.DOWN),
            Pair(AmpOperationCommandMsg.output(AmpOperationCommand.MVLUP), MasterVolumeCmd.UP)
        ];

        final List<Widget> buttons = [];
        cmd.forEach((cmd)
        {
            buttons.add(CustomImageButton.normal(
                cmd.item1.getValue.icon!,
                cmd.item1.getValue.description,
                onPressed: ()
                => stateManager.changeMasterVolume(viewContext.configuration.audioControl, cmd.item2),
                isEnabled: state.isConnected,
            ));
        });

        return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: buttons,
        );
    }
}