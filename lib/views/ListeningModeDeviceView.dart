/*
 * Copyright (C) 2020. Mikhail Kulesh
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

import "../constants/Dimens.dart";
import "../constants/Strings.dart";
import "../iscp/messages/EnumParameterMsg.dart";
import "../iscp/messages/ListeningModeMsg.dart";
import "../iscp/messages/PowerStatusMsg.dart";
import "../iscp/messages/ReceiverInformationMsg.dart";
import "../utils/Logging.dart";
import "../widgets/CustomImageButton.dart";
import "../widgets/CustomTextLabel.dart";
import "UpdatableView.dart";


class ListeningModeDeviceView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        ReceiverInformationMsg.CODE,
        PowerStatusMsg.CODE,
        ListeningModeMsg.CODE
    ];

    ListeningModeDeviceView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.logRebuild(this);
        if (!state.receiverInformation.isListeningModeControl())
        {
            return SizedBox.shrink();
        }

        final Widget currentMode = state.isOn ?
        CustomTextLabel.small(state.soundControlState.listeningMode.description) : SizedBox.shrink();

        return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                Row(mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [CustomTextLabel.small(Strings.pref_listening_modes, padding: ActivityDimens.headerPadding)]
                ),
                Row(mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [currentMode]
                ),
                Row(mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        _buildBtn(ListeningModeMsg.output(ListeningMode.DOWN)),
                        _buildBtn(ListeningModeMsg.output(ListeningMode.UP))
                    ]
                )
            ]
        );
    }

    Widget _buildBtn<T>(final EnumParameterMsg<T> cmd)
    {
        return CustomImageButton.big(
            cmd.getValue.icon,
            cmd.getValue.description,
            onPressed: ()
            => stateManager.sendMessage(cmd),
            isEnabled: state.isOn
        );
    }
}