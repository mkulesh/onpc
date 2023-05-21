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
import "package:flutter_svg/svg.dart";

import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/JacketArtMsg.dart";
import "../iscp/messages/PowerStatusMsg.dart";
import "UpdatableView.dart";

class TrackCoverView extends UpdatableView
{
    final int flex;
    static const List<String> UPDATE_TRIGGERS = [
        PowerStatusMsg.CODE,
        JacketArtMsg.CODE,
    ];

    TrackCoverView(final ViewContext viewContext, { this.flex = 1 }) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        final ThemeData td = Theme.of(context);

        final Widget cover = state.isOn && state.trackState.cover != null ?
            state.trackState.cover : SvgPicture.asset(
                Drawables.empty_cover,
                color: state.isOn ? td.colorScheme.secondary : td.disabledColor,
                fit: BoxFit.contain
            );

        Widget box = FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.center,
            child: Material( // with Material
                elevation: ActivityDimens.elevation,
                child: IconButton(
                    icon: cover,
                    padding: ActivityDimens.noPadding,
                    alignment: Alignment.center,
                    tooltip: Strings.tv_display_mode,
                    onPressed: ()
                    => stateManager.sendMessage(StateManager.DISPLAY_MSG)
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
