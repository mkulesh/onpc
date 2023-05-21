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
// @dart=2.9
import "package:flutter/material.dart";

import "../config/CfgRiCommands.dart";
import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/TapeOperationCommandMsg.dart";
import "../utils/Convert.dart";
import "../utils/Logging.dart";
import "../widgets/CustomImageButton.dart";
import "../widgets/CustomTextLabel.dart";
import "UpdatableView.dart";

class RiTapeDeckControlView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        StateManager.CONNECTION_EVENT
    ];

    RiTapeDeckControlView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.logRebuild(this);

        final Widget image = Padding(
            padding: ActivityDimens.coverImagePadding(context),
            child: Image.asset(Drawables.ri_tape_deck, width: ControlViewDimens.imageWidth)
        );

        return Column(
            children: [
                CustomTextLabel.small(Strings.app_control_ri_tape_deck,
                    padding: ActivityDimens.headerPaddingTop,
                    textAlign: TextAlign.center),
                image,
                CustomTextLabel.small(Strings.remote_interface_playback, textAlign: TextAlign.center),
                _buildPlaybackRow(),
            ]);
    }

    Widget _buildPlaybackRow()
    {
        return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                _buildImgBtn(TapeOperationCommandMsg.output(TapeOperationCommand.REW)),
                _buildImgBtn(TapeOperationCommandMsg.output(TapeOperationCommand.STOP)),
                _buildImgBtn(TapeOperationCommandMsg.output(TapeOperationCommand.PLAY_F)),
                _buildImgBtn(TapeOperationCommandMsg.output(TapeOperationCommand.FF))
            ],
        );
    }

    Widget _buildImgBtn(final TapeOperationCommandMsg cmd)
    {
        final RiCommand rc = configuration.riCommands.findCommand(
            RiDeviceType.TAPE_DECK, Convert.enumToString(cmd.getValue.key));
        return CustomImageButton.normal(
            cmd.getValue.icon,
            cmd.getValue.description,
            onPressed: ()
            => stateManager.sendRiMessage(rc, cmd),
            isEnabled: stateManager.isConnected && (!configuration.riCommands.isOn || rc != null)
        );
    }
}