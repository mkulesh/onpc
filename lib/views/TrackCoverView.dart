/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2024 by Mikhail Kulesh
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
import "package:flutter_svg/svg.dart";

import "../config/Configuration.dart";
import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/InputSelectorMsg.dart";
import "../iscp/messages/JacketArtMsg.dart";
import "../iscp/messages/PowerStatusMsg.dart";
import "../iscp/state/SoundControlState.dart";
import "../utils/Convert.dart";
import "UpdatableView.dart";

class TrackCoverView extends UpdatableView
{
    final int flex;
    static const List<String> UPDATE_TRIGGERS = [
        PowerStatusMsg.CODE,
        JacketArtMsg.CODE,
        InputSelectorMsg.CODE,
        Configuration.CONFIGURATION_EVENT
    ];

    TrackCoverView(final ViewContext viewContext, { this.flex = 1 }) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        final ThemeData td = Theme.of(context);

        final Widget cover = state.isOn && state.trackState.cover != null ?
            state.trackState.cover! : SvgPicture.asset(
                Drawables.empty_cover,
                colorFilter: Convert.toColorFilter(state.isOn ? td.colorScheme.secondary : td.disabledColor),
                fit: BoxFit.contain
            );

        String tooltip = "";
        VoidCallback? onPressed;
        switch (configuration.coverClickBehaviour)
        {
            case "none":
                break;
            case "display-mode":
                tooltip = Strings.tv_display_mode;
                onPressed = () => stateManager.sendMessage(StateManager.DISPLAY_MSG);
                break;
            case "audio-mute":
                final SoundControlType soundControl = SoundControlState.soundControlType(configuration.audioControl, state.getActiveZone);
                tooltip = (soundControl == SoundControlType.RI_AMP) ? Strings.amp_cmd_audio_muting_toggle : Strings.audio_muting_toggle;
                onPressed = () => stateManager.changeMasterVolume(configuration.audioControl, 2);
                break;
        }

        Widget box = FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.center,
            child: Material( // with Material
                elevation: ActivityDimens.elevation,
                color: td.scaffoldBackgroundColor,
                shadowColor: td.disabledColor,
                child: IconButton(
                    icon: cover,
                    padding: ActivityDimens.noPadding,
                    alignment: Alignment.center,
                    tooltip: tooltip,
                    onPressed: onPressed
                ))
        );

        if (state.trackState.isCoverPending)
        {
            box = Stack(
                fit: StackFit.expand,
                children: [box, Align(alignment: Alignment.center, child: UpdatableView.createTimerSand())]
            );
        }

        return Expanded(
            flex: flex,
            child: Container(
                padding: ActivityDimens.coverImagePadding(context),
                child: box));
    }
}
