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

import "../iscp/StateManager.dart";
import "../iscp/messages/EnumParameterMsg.dart";
import "../iscp/messages/OperationCommandMsg.dart";
import "../iscp/messages/PlayStatusMsg.dart";
import "../iscp/messages/PowerStatusMsg.dart";
import "../utils/Logging.dart";
import "../widgets/CustomImageButton.dart";
import "UpdatableView.dart";

class PlayControlNetView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        StateManager.ZONE_EVENT,
        PowerStatusMsg.CODE,
        PlayStatusMsg.CODE
    ];

    PlayControlNetView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.logRebuild(this);

        final bool isPaused = [PlayStatus.STOP, PlayStatus.PAUSE].contains(state.playbackState.playStatus);

        final List<OperationCommand> cmd = [
            OperationCommand.REPEAT,
            OperationCommand.TRDN,
            OperationCommand.STOP,
            isPaused ? OperationCommand.PLAY : OperationCommand.PAUSE,
            OperationCommand.TRUP,
            OperationCommand.RANDOM
        ];

        final List<Widget> buttons = [];

        cmd.forEach((cmdEnum)
        {
            final EnumItem<OperationCommand> cmd = OperationCommandMsg.ValueEnum.valueByKey(cmdEnum);
            String icon = cmd.icon;
            bool enabled = state.isOn;
            bool selected = false;

            switch (cmd.key)
            {
                case OperationCommand.REPEAT:
                    icon = state.playbackState.repeatStatus.icon;
                    enabled = state.playbackState.repeatStatus.key != RepeatStatus.DISABLE;
                    selected = enabled && state.playbackState.repeatStatus.key != RepeatStatus.OFF;
                    break;
                case OperationCommand.RANDOM:
                    enabled = state.playbackState.shuffleStatus != ShuffleStatus.DISABLE;
                    selected = enabled && state.playbackState.shuffleStatus != ShuffleStatus.OFF;
                    break;
                case OperationCommand.TRDN:
                case OperationCommand.TRUP:
                    enabled = state.isPlaying;
                    break;
                default:
                    // nothing to do
                    break;
            }

            buttons.add(CustomImageButton.normal(
                icon,
                cmd.description,
                onPressed: ()
                => _sendCommand(cmd.key),
                isEnabled: enabled,
                isSelected: selected
            ));
        });

        return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: buttons,
        );
    }

    void _sendCommand(OperationCommand key)
    {
        if (!state.mediaListState.isPlaybackMode
            && state.mediaListState.isUsb
            && [OperationCommand.TRDN, OperationCommand.TRUP].contains(key))
        {
            // Issue-44: on some receivers, "TRDN" and "TRUP" for USB only work
            // in playback mode. Therefore, switch to this mode before
            // send OperationCommandMsg if current mode is LIST
            stateManager.sendTrackCmd(state.getActiveZone, key, false);
        }
        else if (key == OperationCommand.PLAY)
        {
            // To start play in normal mode, PAUSE shall be issue instead of PLAY command
            stateManager.sendMessage(OperationCommandMsg.output(state.getActiveZone, OperationCommand.PAUSE));
        }
        else
        {
            stateManager.sendMessage(OperationCommandMsg.output(state.getActiveZone, key));
        }
    }
}