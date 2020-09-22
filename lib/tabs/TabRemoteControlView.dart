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

import "../constants/Dimens.dart";
import "../constants/Strings.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/EnumParameterMsg.dart";
import "../iscp/messages/ListeningModeMsg.dart";
import "../iscp/messages/PowerStatusMsg.dart";
import "../iscp/messages/ReceiverInformationMsg.dart";
import "../utils/Logging.dart";
import "../views/SetupNavigationCommandsView.dart";
import "../views/SetupOperationalCommandsView.dart";
import "../views/UpdatableView.dart";
import "../widgets/CustomDivider.dart";
import "../widgets/CustomImageButton.dart";
import "../widgets/CustomTextLabel.dart";

class TabRemoteControlView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        StateManager.CONNECTION_EVENT,
        PowerStatusMsg.CODE,
        ReceiverInformationMsg.CODE
    ];

    TabRemoteControlView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.info(this, "rebuild widget");

        final EdgeInsetsGeometry activityMargins = ActivityDimens.activityMargins(context);

        final List<Widget> entries = [
            SetupOperationalCommandsView(stateManager,
                enabled: stateManager.isConnected && stateManager.state.isOn,
                isSetup: state.receiverInformation.isControlExists("Setup"),
                isHome: state.receiverInformation.isControlExists("Home"),
                isQuick: state.receiverInformation.isControlExists("Quick"),
            ),
            CustomDivider(height: activityMargins.vertical),
            SetupNavigationCommandsView(stateManager,
                enabled: stateManager.isConnected && stateManager.state.isOn,
            )
        ];

        if (state.receiverInformation.isListeningModeControl())
        {
            final Widget currentMode = stateManager.isConnected && stateManager.state.isOn ?
                CustomTextLabel.small(state.soundControlState.listeningMode.description) : SizedBox.shrink();

            entries.add(Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    CustomDivider(height: activityMargins.vertical),
                    Row(mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [CustomTextLabel.small(Strings.pref_listening_modes)]
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
                ])
            );
        }

        return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ListBody(children: entries));
    }

    Widget _buildBtn<T>(final EnumParameterMsg<T> cmd)
    {
        return CustomImageButton.big(
            cmd.getValue.icon,
            cmd.getValue.description,
            onPressed: ()
            => stateManager.sendMessage(cmd),
            isEnabled: stateManager.isConnected && stateManager.state.isOn
        );
    }
}