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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';

import "../constants/Dimens.dart";
import "../constants/Strings.dart";
import "../iscp/messages/AudioInformationMsg.dart";
import "../iscp/messages/PowerStatusMsg.dart";
import "../iscp/messages/VideoInformationMsg.dart";
import "../utils/Logging.dart";
import "../widgets/CustomTextLabel.dart";
import "UpdatableView.dart";

class AvInfoView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        PowerStatusMsg.CODE,
        AudioInformationMsg.CODE,
        VideoInformationMsg.CODE
    ];

    AvInfoView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.logRebuild(this);

        final List<Widget> items = List<Widget>();

        items.add(CustomTextLabel.normal(Strings.av_info_audio, padding: DialogDimens.rowPadding));
        items.add(CustomTextLabel.small(sprintf(Strings.av_info_input, [state.trackState.avInfoAudioInput]), padding: DialogDimens.rowPadding));
        items.add(CustomTextLabel.small(sprintf(Strings.av_info_output, [state.trackState.avInfoAudioOutput]), padding: DialogDimens.rowPadding));

        items.add(CustomTextLabel.normal(Strings.av_info_video, padding: DialogDimens.rowPadding));
        items.add(CustomTextLabel.small(sprintf(Strings.av_info_input, [state.trackState.avInfoVideoInput]), padding: DialogDimens.rowPadding));
        items.add(CustomTextLabel.small(sprintf(Strings.av_info_output, [state.trackState.avInfoVideoOutput]), padding: DialogDimens.rowPadding));

        return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ListBody(children: items));
    }
}