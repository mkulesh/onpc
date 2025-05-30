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

import "dart:math";

import "package:flutter/material.dart";

import "../config/CfgAudioControl.dart";
import "../config/Configuration.dart";
import "../constants/Dimens.dart";
import "../constants/Strings.dart";
import "../iscp/messages/MasterVolumeMsg.dart";
import "../iscp/messages/PowerStatusMsg.dart";
import "../iscp/messages/ReceiverInformationMsg.dart";
import "../iscp/state/AllZonesState.dart";
import "../iscp/state/SoundControlState.dart";
import "../utils/Logging.dart";
import "../widgets/CustomProgressBar.dart";
import "../widgets/CustomTextLabel.dart";
import "AudioControlMaxLevelView.dart";
import "UpdatableView.dart";

class AudioControlAllZonesView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        AudioControlMaxLevelView.VOLUME_MAX_EVENT,
        Configuration.CONFIGURATION_EVENT,
        MasterVolumeMsg.CODE,
        PowerStatusMsg.CODE,
    ];

    AudioControlAllZonesView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.logRebuild(this);

        final CfgAudioControl ac = configuration.audioControl;
        final List<Widget> controls = [];

        // Title
        controls.add(CustomTextLabel.normal(Strings.master_volume + ": " + Strings.audio_control_all_zones,
            padding: DialogDimens.rowPadding));

        for (ZoneState zs in state.allZonesState.zoneState)
        {
            final Zone zoneInfo = state.receiverInformation.zones[zs.zone];
            final int maxVolume = min(state.soundControlState.getVolumeMax(zoneInfo), ac.getMasterVolumeMax(zs.zone));
            final String friendlyName = configuration.appSettings.readZoneName(zoneInfo);

            final Widget bar = zs.powerStatus == PowerStatus.ON ?
                CustomProgressBar(
                    caption: friendlyName,
                    minValueStr: "0",
                    maxValueStr: SoundControlState.getVolumeLevelStr(maxVolume, zoneInfo),
                    maxValueNum: maxVolume,
                    currValue: zs.volumeLevel,
                    onCaption: (v) => _onCaption(zoneInfo, v),
                    onChanged: (v)
                    => stateManager.sendMessage(MasterVolumeMsg.value(zs.zone, max(v, 0))),
                    onDownButton: (v)
                    => stateManager.sendMessage(MasterVolumeMsg.output(zs.zone, MasterVolume.DOWN)),
                    onUpButton: (v)
                    => stateManager.sendMessage(MasterVolumeMsg.output(zs.zone, MasterVolume.UP)),
                    isInDialog: true
                ) :
                CustomProgressBar(
                    caption: friendlyName,
                    minValueStr: "0",
                    maxValueStr: SoundControlState.getVolumeLevelStr(maxVolume, zoneInfo),
                    maxValueNum: maxVolume,
                    currValue: zs.volumeLevel,
                    onCaption: (v) => _onCaption(zoneInfo, v),
                    onChanged: null,
                    isInDialog: true
                );
            controls.add(bar);
        }

        return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ListBody(children: controls)
        );
    }

    String _onCaption(final Zone zoneInfo, double v)
    {
        final String dB = configuration.audioControl.volumeUnit == VolumeUnit.RELATIVE ?
        " (" + SoundControlState.getRelativeLevelStr(v.floor(), zoneInfo, configuration.audioControl) + ")"
            : "";
        return SoundControlState.getVolumeLevelStr(v.floor(), zoneInfo) + dB;
    }
}