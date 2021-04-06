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
// @dart=2.9
import "dart:math";

import "package:flutter/material.dart";
import "package:flutter/widgets.dart";

import "../constants/Strings.dart";
import "../iscp/messages/ReceiverInformationMsg.dart";
import "../iscp/state/SoundControlState.dart";
import "../utils/Logging.dart";
import "../widgets/CustomProgressBar.dart";
import "UpdatableView.dart";

class MasterVolumeMaxView extends UpdatableView
{
    static const String VOLUME_MAX_EVENT = "VOLUME_MAX_CHANGE";

    static const List<String> UPDATE_TRIGGERS = [
        // no external triggers
    ];

    MasterVolumeMaxView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.logRebuild(this);

        final Zone zoneInfo = state.getActiveZoneInfo;
        final int maxVolume = state.soundControlState.getVolumeMax(zoneInfo);

        return CustomProgressBar(
            caption: Strings.master_volume_max,
            minValueStr: "0",
            maxValueStr: SoundControlState.getVolumeLevelStr(maxVolume, zoneInfo),
            maxValueNum: maxVolume,
            currValue: min(maxVolume, configuration.audioControl.masterVolumeMax),
            onCaption: (v)
            => SoundControlState.getVolumeLevelStr(v.floor(), zoneInfo),
            onChanged: (v)
            {
                configuration.audioControl.masterVolumeMax = v;
                stateManager.triggerStateEvent(VOLUME_MAX_EVENT);
            }
        );
    }
}