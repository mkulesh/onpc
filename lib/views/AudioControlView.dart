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

import "dart:math";

import "package:flutter/material.dart";

import "../config/CfgAudioControl.dart";
import "../config/Configuration.dart";
import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../dialogs/AudioControlDialog.dart";
import "../iscp/ConnectionIf.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/AudioBalanceMsg.dart";
import "../iscp/messages/CenterLevelCommandMsg.dart";
import "../iscp/messages/DirectCommandMsg.dart";
import "../iscp/messages/ListeningModeMsg.dart";
import "../iscp/messages/MasterVolumeMsg.dart";
import "../iscp/messages/ReceiverInformationMsg.dart";
import "../iscp/messages/SubwooferLevelCommandMsg.dart";
import "../iscp/messages/ToneCommandMsg.dart";
import "../iscp/state/ReceiverInformation.dart";
import "../iscp/state/SoundControlState.dart";
import "../utils/Logging.dart";
import "../utils/Pair.dart";
import "../widgets/CustomCheckbox.dart";
import "../widgets/CustomImageButton.dart";
import "../widgets/CustomProgressBar.dart";
import "MasterVolumeMaxView.dart";
import "UpdatableView.dart";

class AudioControlView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        MasterVolumeMaxView.VOLUME_MAX_EVENT,
        StateManager.WAITING_FOR_DATA_EVENT,
        Configuration.CONFIGURATION_EVENT,
        MasterVolumeMsg.CODE,
        ToneCommandMsg.CODE,
        DirectCommandMsg.CODE,
        SubwooferLevelCommandMsg.CODE,
        CenterLevelCommandMsg.CODE,
        ListeningModeMsg.CODE,
        AudioBalanceMsg.CODE
    ];

    AudioControlView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.logRebuild(this);

        final CfgAudioControl ac = configuration.audioControl;
        final List<Widget> controls = [];

        final SoundControlState soundControl = state.soundControlState;
        final int zone = state.getActiveZone;
        final Zone? zoneInfo = state.getActiveZoneInfo;

        // Master volume
        {
            final int maxVolume = min(soundControl.getVolumeMax(zoneInfo), ac.masterVolumeMax);

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
                onCaption: (v) {
                    final String dB = ac.volumeUnit == VolumeUnit.RELATIVE ?
                        " (" + SoundControlState.getRelativeLevelStr(v.floor(), state.getActiveZoneInfo, ac) + ")"
                        : "";
                    return SoundControlState.getVolumeLevelStr(v.floor(), zoneInfo) + dB;
                },
                onChanged: (v)
                => stateManager.sendMessage(MasterVolumeMsg.value(zone, max(v, 0))),
                onDownButton: (v)
                => stateManager.sendMessage(MasterVolumeMsg.output(zone, MasterVolume.DOWN)),
                onUpButton: (v)
                => stateManager.sendMessage(MasterVolumeMsg.output(zone, MasterVolume.UP)),
                isInDialog: true,
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

            controls.add(CustomCheckbox(Strings.tone_direct,
                value: isDirectMode,
                padding: DialogDimens.rowPadding,
                icon: stateManager.waitingForData ? UpdatableView.createTimerSand() : null,
                enabled: !stateManager.waitingForData,
                onChanged: (bool newValue)
                {
                    stateManager.sendMessage(DirectCommandMsg.output(DirectCommand.TOGGLE), waitingForData: true);
                    if (zone < ToneCommandMsg.ZONE_COMMANDS.length)
                    {
                        final List<String> cmd = [];
                        cmd.add(ToneCommandMsg.ZONE_COMMANDS[zone]);
                        stateManager.sendQueries(cmd);
                    }
                }));
        }
        else if (zone < ToneCommandMsg.ZONE_COMMANDS.length)
        {
            if (soundControl.isDirectListeningMode)
            {
                controls.add(CustomCheckbox(Strings.tone_direct,
                    value: true, padding: DialogDimens.rowPadding, enabled: false));
            }
            else
            {
                _addToneControls(controls, soundControl);
            }
        }

        // Audio balance
        if (state.protoType == ProtoType.DCP &&
            state.receiverInformation.balanceRange != null &&
            soundControl.balance != AudioBalanceMsg.NO_LEVEL)
        {
            final Pair<int, int> balanceRange = state.receiverInformation.balanceRange!;
            controls.add(CustomProgressBar(
                caption: Strings.audio_balance,
                minValueStr: balanceRange.item1.toString(),
                minValueNum: balanceRange.item1,
                maxValueStr: balanceRange.item2.toString(),
                maxValueNum: balanceRange.item2,
                currValue: soundControl.balance,
                onCaption: (v) {
                    return soundControl.balance.toString();
                },
                onChanged: (v)
                => stateManager.sendMessage(AudioBalanceMsg.output(AudioBalance.VAL, v)),
                onDownButton: (v)
                => stateManager.sendMessage(AudioBalanceMsg.output(AudioBalance.DOWN, AudioBalanceMsg.NO_LEVEL)),
                onUpButton: (v)
                => stateManager.sendMessage(AudioBalanceMsg.output(AudioBalance.UP, AudioBalanceMsg.NO_LEVEL)),
                isInDialog: true
            ));
        }

        // Subwoofer and Center Level
        if (state.isDefaultZone)
        {
            final Widget? subwooferControl = _createControl(SubwooferLevelCommandMsg.KEY,
                soundControl.subwooferLevel, SubwooferLevelCommandMsg.NO_LEVEL, Strings.subwoofer_level);
            if (subwooferControl != null)
            {
                controls.add(subwooferControl);
            }

            final Widget? centerControl = _createControl(CenterLevelCommandMsg.KEY,
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

    Widget? _createControl(final String key, final int toneLevel, final int noLevel, final String caption, {ToneControl? defToneControl})
    {
        final int zone = state.getActiveZone;
        ToneControl? toneControl = state.receiverInformation.toneControls[key];
        if (toneControl == null)
        {
            toneControl = defToneControl;
        }
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
                => ((v * step).floor() + toneControl!.getMin).toString(),
                onChanged: (v)
                {
                    final int newVal = (v.toDouble() * step).floor() + toneControl!.getMin;
                    switch (key)
                    {
                        case ToneCommandMsg.BASS_KEY:
                            stateManager.sendMessage(
                                ToneCommandMsg.value(zone, newVal, ToneCommandMsg.NO_LEVEL));
                            break;
                        case ToneCommandMsg.TREBLE_KEY:
                            stateManager.sendMessage(
                                ToneCommandMsg.value(zone, ToneCommandMsg.NO_LEVEL, newVal));
                            break;
                        case SubwooferLevelCommandMsg.KEY:
                            stateManager.sendMessage(
                                SubwooferLevelCommandMsg.value(newVal, state.soundControlState.subwooferCmdLength));
                            break;
                        case CenterLevelCommandMsg.KEY:
                            stateManager.sendMessage(
                                CenterLevelCommandMsg.value(newVal, state.soundControlState.centerCmdLength));
                            break;
                    }
                },
                onDownButton: (v)
                {
                    switch (key)
                    {
                        case ToneCommandMsg.BASS_KEY:
                            stateManager.sendMessage(ToneCommandMsg.output(zone, ToneCommand.BDOWN));
                            break;
                        case ToneCommandMsg.TREBLE_KEY:
                            stateManager.sendMessage(ToneCommandMsg.output(zone, ToneCommand.TDOWN));
                            break;
                        case SubwooferLevelCommandMsg.KEY:
                            stateManager.sendMessage(SubwooferLevelCommandMsg.output(SubwooferLevelCommand.DOWN));
                            break;
                        case CenterLevelCommandMsg.KEY:
                            stateManager.sendMessage(CenterLevelCommandMsg.output(CenterLevelCommand.DOWN));
                            break;
                    }
                },
                onUpButton: (v)
                {
                    switch (key)
                    {
                        case ToneCommandMsg.BASS_KEY:
                            stateManager.sendMessage(ToneCommandMsg.output(zone, ToneCommand.BUP));
                            break;
                        case ToneCommandMsg.TREBLE_KEY:
                            stateManager.sendMessage(ToneCommandMsg.output(zone, ToneCommand.TUP));
                            break;
                        case SubwooferLevelCommandMsg.KEY:
                            stateManager.sendMessage(SubwooferLevelCommandMsg.output(SubwooferLevelCommand.UP));
                            break;
                        case CenterLevelCommandMsg.KEY:
                            stateManager.sendMessage(CenterLevelCommandMsg.output(CenterLevelCommand.UP));
                            break;
                    }
                },
                isInDialog: true
            );
        }
        return null;
    }

    void _addToneControls(List<Widget> controls, SoundControlState soundControl)
    {
        // Bass
        final Widget? bassControl = _createControl(ToneCommandMsg.BASS_KEY,
            soundControl.bassLevel, ToneCommandMsg.NO_LEVEL, Strings.tone_bass,
            defToneControl: configuration.audioControl.isForceAudioControl ? ReceiverInformation.DEFAULT_BASS_CONTROL : null);
        if (bassControl != null)
        {
            controls.add(bassControl);
        }
        // Treble
        final Widget? trebleControl = _createControl(ToneCommandMsg.TREBLE_KEY,
            soundControl.trebleLevel, ToneCommandMsg.NO_LEVEL, Strings.tone_treble,
            defToneControl: configuration.audioControl.isForceAudioControl ? ReceiverInformation.DEFAULT_TREBLE_CONTROL : null);
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