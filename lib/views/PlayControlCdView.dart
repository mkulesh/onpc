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
// @dart=2.9
import "package:flutter/material.dart";

import "../iscp/StateManager.dart";
import "../iscp/messages/CdPlayerOperationCommandMsg.dart";
import "../iscp/messages/EnumParameterMsg.dart";
import "../iscp/messages/PlayStatusMsg.dart";
import "../iscp/messages/PowerStatusMsg.dart";
import "../utils/Logging.dart";
import "../widgets/CustomImageButton.dart";
import "UpdatableView.dart";

class PlayControlCdView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        StateManager.ZONE_EVENT,
        PowerStatusMsg.CODE,
        PlayStatusMsg.CODE
    ];

    PlayControlCdView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.logRebuild(this);

        final bool isPaused = [PlayStatus.STOP, PlayStatus.PAUSE].contains(state.playbackState.playStatus);
        final List<CdPlayerOperationCommand> cmd = [
            CdPlayerOperationCommand.REPEAT,
            CdPlayerOperationCommand.SKIP_R,
            CdPlayerOperationCommand.STOP,
            isPaused ? CdPlayerOperationCommand.PLAY : CdPlayerOperationCommand.PAUSE,
            CdPlayerOperationCommand.SKIP_F,
            CdPlayerOperationCommand.RANDOM
        ];

        final List<Widget> buttons = [];

        cmd.forEach((cmdEnum)
        {
            final EnumItem<CdPlayerOperationCommand> cmd = CdPlayerOperationCommandMsg.ValueEnum.valueByKey(cmdEnum);
            String icon = cmd.icon;
            bool selected = false;

            switch (cmd.key)
            {
                case CdPlayerOperationCommand.REPEAT:
                    icon = state.playbackState.repeatStatus.icon;
                    selected = state.playbackState.repeatStatus.key != RepeatStatus.OFF;
                    break;
                case CdPlayerOperationCommand.RANDOM:
                    selected = state.playbackState.shuffleStatus != ShuffleStatus.OFF;
                    break;
                default:
                    // nothing to do
                    break;
            }

            buttons.add(CustomImageButton.normal(
                icon,
                cmd.description,
                onPressed: ()
                => stateManager.sendMessage(CdPlayerOperationCommandMsg.output(cmd.key)),
                isEnabled: state.isOn,
                isSelected: selected
            ));
        });

        return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: buttons,
        );
    }
}