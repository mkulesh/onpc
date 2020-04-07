/*
 * Copyright (C) 2019. Mikhail Kulesh
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

import "dart:async";
import "dart:math";

import "package:flutter/material.dart";
import "package:flutter/widgets.dart";

import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../dialogs/AudioControlDialog.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/CenterLevelCommandMsg.dart";
import "../iscp/messages/DirectCommandMsg.dart";
import "../iscp/messages/MasterVolumeMsg.dart";
import "../iscp/messages/ReceiverInformationMsg.dart";
import "../iscp/messages/SubwooferLevelCommandMsg.dart";
import "../iscp/messages/ToneCommandMsg.dart";
import "../iscp/state/SoundControlState.dart";
import "../utils/Logging.dart";
import "../widgets/CustomImageButton.dart";
import "../widgets/CustomProgressBar.dart";
import "../widgets/CustomTextLabel.dart";
import "MasterVolumeMaxView.dart";
import "UpdatableView.dart";

class AudioControlView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        MasterVolumeMaxView.VOLUME_MAX_EVENT,
        StateManager.WAITING_FOR_DATA_EVENT,
        MasterVolumeMsg.CODE,
        ToneCommandMsg.CODE,
        DirectCommandMsg.CODE,
        SubwooferLevelCommandMsg.CODE,
        CenterLevelCommandMsg.CODE
    ];

    AudioControlView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.info(this, "rebuild widget");

        final List<Widget> controls = List<Widget>();

        final SoundControlState soundControl = state.soundControlState;
        final int zone = state.getActiveZone;
        final Zone zoneInfo = state.getActiveZoneInfo;

        // Master volume
        {
            final int maxVolume = min(soundControl.getVolumeMax(zoneInfo), configuration.masterVolumeMax);

            final Widget maxVolumeBtn = CustomImageButton.small(
                Drawables.volume_max_limit,
                Strings.master_volume_restrict,
                onPressed: ()
                => _showMasterVolumeMaxDialog(context)
            );

            controls.add(CustomProgressBar(
                caption: Strings.master_volume,
                minValueStr: "0",
                maxValueStr: SoundControlState.getVolumeLevelStr(maxVolume, zoneInfo),
                maxValueNum: maxVolume,
                currValue: soundControl.volumeLevel,
                onCaption: (v)
                => SoundControlState.getVolumeLevelStr(v.floor(), zoneInfo),
                onChanged: (v)
                => stateManager.sendMessage(MasterVolumeMsg.value(zone, v)),
                extendedCmd: maxVolumeBtn
            ));
        }

        // Bass and treble control
        final bool isDirectCmdAvailable = soundControl.toneDirect.key != DirectCommand.NONE;
        if (isDirectCmdAvailable)
        {
            final bool isDirectMode = soundControl.toneDirect.key == DirectCommand.ON;
            if (!isDirectMode)
            {
                _addToneControls(controls, soundControl);
            }

            final Widget checkBox = Checkbox(
                value: isDirectMode,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (bool newValue)
                {
                    stateManager.sendMessage(DirectCommandMsg.output(DirectCommand.TOGGLE), waitingForData: true);
                    if (zone < ToneCommandMsg.ZONE_COMMANDS.length)
                    {
                        final List<String> cmd = List();
                        cmd.add(ToneCommandMsg.ZONE_COMMANDS[zone]);
                        stateManager.sendQueries(cmd);
                    }
                });

            Widget checkBoxRow = Padding(padding: EdgeInsets.only(bottom: DialogDimens.rowPadding.vertical), child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    CustomTextLabel.normal(Strings.tone_direct),
                    stateManager.waitingForData ? createTimerSand() : checkBox
                ]));

            if (!stateManager.waitingForData)
            {
                checkBoxRow = InkWell(
                    child: checkBoxRow,
                    onTap: ()
                    => stateManager.sendMessage(DirectCommandMsg.output(DirectCommand.TOGGLE), waitingForData: true)
                );
            }

            controls.add(checkBoxRow);
        }
        else if (!soundControl.isDirectListeningMode && zone < ToneCommandMsg.ZONE_COMMANDS.length)
        {
            _addToneControls(controls, soundControl);
        }

        // Subwoofer and Center Level
        if (state.isDefaultZone)
        {
            final Widget subwooferControl = _createControl(SubwooferLevelCommandMsg.KEY,
                soundControl.subwooferLevel, SubwooferLevelCommandMsg.NO_LEVEL, Strings.subwoofer_level);
            if (subwooferControl != null)
            {
                controls.add(subwooferControl);
            }

            final Widget centerControl = _createControl(CenterLevelCommandMsg.KEY,
                soundControl.centerLevel, CenterLevelCommandMsg.NO_LEVEL, Strings.center_level);
            if (centerControl != null)
            {
                controls.add(centerControl);
            }
        }

        return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ListBody(children: controls)
        );
    }

    Widget _createControl(final String key, final int toneLevel, final int noLevel, final String caption)
    {
        final int zone = state.getActiveZone;
        final ToneControl toneControl = state.receiverInformation.toneControls[key];
        if (toneControl != null && toneLevel != noLevel)
        {
            final double step = toneControl.getStep == 0 ? 0.5 : toneControl.getStep.toDouble();
            final int max = ((toneControl.getMax - toneControl.getMin) / step).floor();
            final int progress = ((toneLevel - toneControl.getMin) / step).floor();
            return CustomProgressBar(
                caption: caption,
                minValueStr: toneControl.getMin.toString(),
                maxValueStr: toneControl.getMax.toString(),
                maxValueNum: max,
                currValue: progress,
                onCaption: (v)
                => ((v * step).floor() + toneControl.getMin).toString(),
                onChanged: (v)
                {
                    final int newVal = (v.toDouble() * step).floor() + toneControl.getMin;
                    switch (key)
                    {
                        case ToneCommandMsg.BASS_KEY:
                            stateManager.sendMessage(
                                ToneCommandMsg.output(zone, newVal, ToneCommandMsg.NO_LEVEL));
                            break;
                        case ToneCommandMsg.TREBLE_KEY:
                            stateManager.sendMessage(
                                ToneCommandMsg.output(zone, ToneCommandMsg.NO_LEVEL, newVal));
                            break;
                        case SubwooferLevelCommandMsg.KEY:
                            stateManager.sendMessage(SubwooferLevelCommandMsg.output(newVal, 1));
                            stateManager.sendMessage(SubwooferLevelCommandMsg.output(newVal, 2));
                            break;
                        case CenterLevelCommandMsg.KEY:
                            stateManager.sendMessage(CenterLevelCommandMsg.output(newVal, 1));
                            stateManager.sendMessage(CenterLevelCommandMsg.output(newVal, 2));
                            break;
                    }
                }
            );
        }
        return null;
    }

    void _addToneControls(List<Widget> controls, SoundControlState soundControl)
    {
        // Bass
        final Widget bassControl = _createControl(ToneCommandMsg.BASS_KEY,
            soundControl.bassLevel, ToneCommandMsg.NO_LEVEL, Strings.tone_bass);
        if (bassControl != null)
        {
            controls.add(bassControl);
        }
        // Treble
        final Widget trebleControl = _createControl(ToneCommandMsg.TREBLE_KEY,
            soundControl.trebleLevel, ToneCommandMsg.NO_LEVEL, Strings.tone_treble);
        if (trebleControl != null)
        {
            controls.add(trebleControl);
        }
    }

    void _showMasterVolumeMaxDialog(final BuildContext context)
    {
        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext c)
            => AudioControlDialog(viewContext, AudioControlType.MASTER_VOLUME_MAX)
        );
    }
}