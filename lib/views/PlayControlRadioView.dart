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

import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../iscp/ISCPMessage.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/InputSelectorMsg.dart";
import "../iscp/messages/PowerStatusMsg.dart";
import "../iscp/messages/PresetCommandMsg.dart";
import "../iscp/messages/RDSInformationMsg.dart";
import "../iscp/messages/ReceiverInformationMsg.dart";
import "../iscp/messages/TuningCommandMsg.dart";
import "../utils/Logging.dart";
import "../widgets/CustomImageButton.dart";
import "UpdatableView.dart";

class PlayControlRadioView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        StateManager.ZONE_EVENT,
        ReceiverInformationMsg.CODE,
        PowerStatusMsg.CODE,
        InputSelectorMsg.CODE
    ];

    PlayControlRadioView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.logRebuild(this);

        final List<ISCPMessage> cmd = [
            PresetCommandMsg.outputCmd(state.getActiveZone, PresetCommand.DOWN),
            TuningCommandMsg.outputCmd(state.getActiveZone, TuningCommand.DOWN),
            TuningCommandMsg.outputCmd(state.getActiveZone, TuningCommand.UP),
            PresetCommandMsg.outputCmd(state.getActiveZone, PresetCommand.UP)
        ];

        if (state.mediaListState.isFM)
        {
            cmd.insert(2, RDSInformationMsg.output(RDSInformationMsg.TOGGLE));
        }
        else if (state.mediaListState.isDAB)
        {
            cmd.insert(2, StateManager.DISPLAY_MSG);
        }

        final List<Widget> buttons = [];

        cmd.forEach((cmd)
        {
            if (cmd is PresetCommandMsg && cmd.getCommand != null)
            {
                buttons.add(CustomImageButton.normal(
                    cmd.getCommand!.icon!,
                    cmd.getCommand!.description,
                    onPressed: ()
                    => stateManager.sendMessage(cmd),
                    isEnabled: state.isOn
                ));
            }
            else if (cmd is TuningCommandMsg && cmd.getCommand != null)
            {
                buttons.add(CustomImageButton.normal(
                    cmd.getCommand!.icon!,
                    cmd.getCommand!.description,
                    onPressed: ()
                    => stateManager.sendMessage(cmd),
                    isEnabled: state.isOn
                ));
            }
            else if (cmd is RDSInformationMsg || cmd == StateManager.DISPLAY_MSG)
            {
                buttons.add(CustomImageButton.normal(
                    Drawables.cmd_rds_info,
                    Strings.cmd_rds_info,
                    onPressed: ()
                    => stateManager.sendMessage(cmd),
                    isEnabled: state.isOn
                ));
            }
        });

        return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: buttons,
        );
    }
}