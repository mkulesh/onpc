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

import "../constants/Dimens.dart";
import "../constants/Strings.dart";
import "../iscp/messages/AudioInformationMsg.dart";
import "../iscp/messages/ListeningModeMsg.dart";
import "../iscp/messages/PowerStatusMsg.dart";
import "../iscp/messages/ReceiverInformationMsg.dart";
import "../utils/Logging.dart";
import "../widgets/CustomImageButton.dart";
import "../widgets/CustomTextButton.dart";
import "../widgets/CustomTextLabel.dart";
import "UpdatableView.dart";


enum LMButtonsType
{
    SWITCH,
    GROUPS
}

class ListeningModeButtonsView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        ReceiverInformationMsg.CODE,
        PowerStatusMsg.CODE,
        ListeningModeMsg.CODE,
        AudioInformationMsg.CODE
    ];

    final LMButtonsType lmButtonsType;

    ListeningModeButtonsView(final ViewContext viewContext, this.lmButtonsType) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.logRebuild(this);
        if (!state.receiverInformation.isListeningModeControl())
        {
            return SizedBox.shrink();
        }

        final String currentModeStr =
            state.soundControlState.listeningMode.key == ListeningMode.MODE_40 ?
                state.trackState.getListeningModeFromAvInfo() : state.soundControlState.listeningMode.description;
        final Widget currentMode = state.isOn ? CustomTextLabel.small(currentModeStr) : SizedBox.shrink();

        Widget control;
        if (lmButtonsType == LMButtonsType.SWITCH)
        {
            final List<Widget> buttons = [
                _buildImageBtn(ListeningModeMsg.output(ListeningMode.DOWN)),
                _buildImageBtn(ListeningModeMsg.output(ListeningMode.UP))
            ];
            control = Row(mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: buttons
            );
        }
        else
        {
            final List<Widget> buttons = [];
            if (state.receiverInformation.isControlExists("LMD Movie/TV"))
            {
                buttons.add(_buildTextBtn(ListeningModeMsg.output(ListeningMode.MOVIE)));
            }
            if (state.receiverInformation.isControlExists("LMD Music"))
            {
                buttons.add(_buildTextBtn(ListeningModeMsg.output(ListeningMode.MUSIC)));
            }
            if (state.receiverInformation.isControlExists("LMD Game"))
            {
                buttons.add(_buildTextBtn(ListeningModeMsg.output(ListeningMode.GAME)));
            }
            if (state.receiverInformation.isControlExists("LMD Stereo"))
            {
                buttons.add(_buildTextBtn(ListeningModeMsg.output(ListeningMode.STEREO)));
            }
            if (state.receiverInformation.isControlExists("LMD THX"))
            {
                buttons.add(_buildTextBtn(ListeningModeMsg.output(ListeningMode.THX)));
            }
            control = Center(
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: buttons)
                )
            );
        }

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
                control
            ]
        );
    }

    Widget _buildImageBtn(final ListeningModeMsg cmd)
    {
        return CustomImageButton.big(
            cmd.getValue.icon!,
            cmd.getValue.description,
            onPressed: ()
            => stateManager.sendMessage(cmd),
            isEnabled: state.isOn
        );
    }

    Widget _buildTextBtn(final ListeningModeMsg cmd)
    {
        return CustomTextButton(
            cmd.getValue.description.toUpperCase(),
            onPressed: ()
            => stateManager.sendMessage(cmd),
            isEnabled: state.isOn
        );
    }
}