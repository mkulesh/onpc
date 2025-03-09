/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2025 by Mikhail Kulesh
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
import "../iscp/messages/AllChannelEqualizerMsg.dart";
import "../utils/Logging.dart";
import "../widgets/CustomTextLabel.dart";
import "../widgets/VerticalSlider.dart";
import "UpdatableView.dart";

class EqualizerView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        AllChannelEqualizerMsg.CODE
    ];

    static int VALUE_SHIFT = (AllChannelEqualizerMsg.VALUES / 2).floor();

    EqualizerView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.logRebuild(this);

        final List<Widget> controls = [];

        // caption
        final Widget caption = Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
                CustomTextLabel.small(AllChannelEqualizerMsg.BOUNDS.item2),
                Expanded(child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [ CustomTextLabel.small("0dB")])),
                CustomTextLabel.small(AllChannelEqualizerMsg.BOUNDS.item1),
                SizedBox(
                    width: ButtonDimens.normalButtonSize,
                    child: CustomTextLabel.small("", textAlign: TextAlign.center)),
            ]
        );
        controls.add(caption);

        // sliders
        for (int i = 0; i < AllChannelEqualizerMsg.CHANNELS.length; i++)
        {
            controls.add(VerticalSlider(
                caption: AllChannelEqualizerMsg.CHANNELS[i],
                currValue: state.soundControlState.equalizerValues[i] + VALUE_SHIFT,
                maxValueNum: AllChannelEqualizerMsg.VALUES,
                divisions: AllChannelEqualizerMsg.VALUES,
                onChanged: (v)
                {
                    final AllChannelEqualizerMsg msg = AllChannelEqualizerMsg.output(
                        state.soundControlState.equalizerValues, i, v - VALUE_SHIFT);
                    stateManager.sendMessage(msg);
                })
            );
        }

        return Center(child: Scrollbar(child: ListView(
            primary: true,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children:  controls))
        );
    }
}
