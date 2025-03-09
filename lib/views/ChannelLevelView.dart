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
import "../iscp/messages/AllChannelLevelMsg.dart";
import "../utils/Logging.dart";
import "../utils/Pair.dart";
import "../widgets/CustomTextLabel.dart";
import "../widgets/VerticalSlider.dart";
import "UpdatableView.dart";

class ChannelLevelView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        AllChannelLevelMsg.CODE
    ];

    static int VALUE_SHIFT = (AllChannelLevelMsg.VALUES / 2).floor();

    ChannelLevelView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.logRebuild(this);

        final List<Widget> controls = [];

        final Widget bounds = Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
                CustomTextLabel.small(AllChannelLevelMsg.BOUNDS.item2),
                Expanded(child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [ CustomTextLabel.small("0dB")])),
                CustomTextLabel.small(AllChannelLevelMsg.BOUNDS.item1),
                SizedBox(
                    width: ButtonDimens.normalButtonSize,
                    child: CustomTextLabel.small("", textAlign: TextAlign.center)),
            ]
        );
        controls.add(_createPanel(bounds, "", defPadding: VerticalSliderDimens.sliderGroupPaddingVer));

        final List<Pair<int, int>> groups = [
            Pair(0, 1),   // Front
            Pair(2, 2),   // Center
            Pair(3, 4),   // Surround
            Pair(5, 6),   // Surround Back
            Pair(8, 9),   // Height 1
            Pair(10, 11), // Height 2
            Pair(7, 12),  // Subwoofer
        ];

        for (Pair<int, int> g in groups)
        {
            controls.add(g.item1 != g.item2 ? _createGroup(g.item1, g.item2) : _createSingle(g.item1));
        }

        return Center(child: Scrollbar(child: ListView(
            primary: true,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children:  controls))
        );
    }

    Widget _createSlider(int i, {String caption = ""})
    {
        final String cap = caption.isNotEmpty? caption : AllChannelLevelMsg.CHANNELS[i];
        return VerticalSlider(
            caption: cap,
            currValue: state.soundControlState.channelLevelValues[i] + VALUE_SHIFT,
            maxValueNum: AllChannelLevelMsg.VALUES,
            divisions: AllChannelLevelMsg.VALUES,
            onChanged: (v)
            {
                final AllChannelLevelMsg msg = AllChannelLevelMsg.output(
                    state.soundControlState.channelLevelValues, i, v - VALUE_SHIFT);
                stateManager.sendMessage(msg);
            });
    }

    Widget _createPanel(final Widget s, final String caption, {EdgeInsetsGeometry? defPadding})
    {
        final Widget c = Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                Expanded(child: s),
                CustomTextLabel.small(caption, textAlign: TextAlign.center)
            ]
        );
        final EdgeInsetsGeometry p = defPadding ?? VerticalSliderDimens.sliderGroupPaddingAll;
        return Padding(padding: p, child: c);
    }

    Widget _createSingle(int idx)
    {
        return _createPanel(_createSlider(idx, caption: " "), AllChannelLevelMsg.CHANNELS[idx]);
    }

    Widget _createGroup(int idx1, int idx2)
    {
        final List<String> c1 = AllChannelLevelMsg.CHANNELS[idx1].split("/");
        final List<String> c2 = AllChannelLevelMsg.CHANNELS[idx2].split("/");
        String captionG = "";
        String caption1 = "";
        String caption2 = "";
        if (c1.length == c2.length && c1.length == 2 && c1.first == c2.first)
        {
            captionG = c1.first;
            caption1 = c1.last;
            caption2 = c2.last;
        }
        final Widget row = Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [_createSlider(idx1, caption: caption1), _createSlider(idx2, caption: caption2)],
        );
        return _createPanel(row, captionG);
    }
}