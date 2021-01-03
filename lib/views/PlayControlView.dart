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

import "../iscp/messages/InputSelectorMsg.dart";
import "../iscp/messages/ReceiverInformationMsg.dart";
import "../views/PlayControlCdView.dart";
import "../views/PlayControlNetView.dart";
import "../views/PlayControlRadioView.dart";
import "UpdatableView.dart";

class PlayControlView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        ReceiverInformationMsg.CODE,
        InputSelectorMsg.CODE,
    ];

    PlayControlView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        // Play controls depends on input type
        final UpdatableView playControlView = state.mediaListState.isRadioInput ? PlayControlRadioView(viewContext) :
            (state.isCdInput ? PlayControlCdView(viewContext) : PlayControlNetView(viewContext));
        final List<Widget> playControlList = List();

        playControlList.add(UpdatableWidget(child: playControlView));
        return Center(
            child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: playControlList))
        );
    }
}
