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
import "../iscp/messages/EnumParameterMsg.dart";
import "../iscp/messages/OperationCommandMsg.dart";
import "../iscp/messages/PlayStatusMsg.dart";
import "../iscp/messages/PowerStatusMsg.dart";
import "../utils/Logging.dart";
import "../widgets/CustomImageButton.dart";
import "UpdatableView.dart";

class PlayControlView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        StateManager.ZONE_EVENT,
        PowerStatusMsg.CODE,
        PlayStatusMsg.CODE
    ];

    PlayControlView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.info(this, "rebuild widget");

        final List<OperationCommandMsg> cmd = [
            OperationCommandMsg.output(state.getActiveZone, OperationCommand.REPEAT),
            OperationCommandMsg.output(state.getActiveZone, OperationCommand.TRDN),
            OperationCommandMsg.output(state.getActiveZone, OperationCommand.STOP),
            OperationCommandMsg.output(state.getActiveZone, OperationCommand.PAUSE),
            OperationCommandMsg.output(state.getActiveZone, OperationCommand.TRUP),
            OperationCommandMsg.output(state.getActiveZone, OperationCommand.RANDOM)
        ];

        final EnumItem<OperationCommand> play =
            OperationCommandMsg.OperationCommandEnum.valueByKey(OperationCommand.PLAY);
        final List<Widget> buttons = List<Widget>();

        cmd.forEach((cmd)
        {
            String icon = cmd.getValue.icon;
            bool enabled = state.isOn;
            bool selected = false;

            switch (cmd.getValue.key)
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
                case OperationCommand.PAUSE:
                    icon = [PlayStatus.STOP, PlayStatus.PAUSE].contains(state.playbackState.playStatus) ?
                        play.icon : cmd.getValue.icon;
                    break;
                default:
                    // nothing to do
                    break;
            }

            buttons.add(CustomImageButton.normal(
                icon,
                cmd.getValue.description,
                onPressed: ()
                => stateManager.sendMessage(cmd),
                isEnabled: enabled,
                isSelected: selected
            ));
        });

        return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: buttons,
        );
    }
}