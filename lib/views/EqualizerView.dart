/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2022 by Mikhail Kulesh
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
import "package:flutter/widgets.dart";

import "../constants/Dimens.dart";
import "../iscp/messages/AllChannelEqMsg.dart";
import "../utils/Logging.dart";
import "../widgets/CustomProgressBar.dart";
import "../widgets/CustomTextLabel.dart";
import "UpdatableView.dart";

class EqualizerView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        AllChannelEqMsg.CODE
    ];

    static int VALUE_SHIFT = (AllChannelEqMsg.VALUES / 2).floor();

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
                CustomTextLabel.small("+12dB"),
                Expanded(child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [ CustomTextLabel.small("0dB")])),
                CustomTextLabel.small("-12dB"),
                SizedBox(
                    width: ButtonDimens.normalButtonSize,
                    height: ButtonDimens.normalButtonSize,
                    child: CustomTextLabel.small("", textAlign: TextAlign.center)),
            ]
        );
        controls.add(caption);

        // sliders
        for (int i = 0; i < AllChannelEqMsg.CHANNELS; i++)
        {
            controls.add(_EqualizerSlider(
                caption: AllChannelEqMsg.FREQUENCIES[i],
                currValue: state.soundControlState.eqValues[i] + VALUE_SHIFT,
                onChanged: (v)
                {
                    final AllChannelEqMsg msg = AllChannelEqMsg.output(state.soundControlState.eqValues, i, v - VALUE_SHIFT);
                    stateManager.sendMessage(msg);
                })
            );
        }

        return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: controls
            )
        );
    }
}

class _EqualizerSlider extends StatelessWidget
{
    final String caption;
    final int currValue;
    final NewValueCallback onChanged;

    _EqualizerSlider({this.caption, this.currValue, this.onChanged});

    @override
    Widget build(BuildContext context)
    {
        final Widget slider = RotatedBox(
            quarterTurns: 3,
            child: CustomProgressBar(
                minValueStr: "",
                maxValueStr: "",
                maxValueNum: AllChannelEqMsg.VALUES,
                currValue: currValue,
                divisions: AllChannelEqMsg.VALUES,
                onChanged: onChanged)
        );

        return Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                Expanded(child: slider),
                SizedBox(
                    width: ButtonDimens.equalizerWidth,
                    height: ButtonDimens.normalButtonSize,
                    child: CustomTextLabel.small(caption, textAlign: TextAlign.center)),
            ]
        );
    }
}