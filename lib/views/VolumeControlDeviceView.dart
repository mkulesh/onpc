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
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../dialogs/AudioControlDialog.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/AllChannelEqualizerMsg.dart";
import "../iscp/messages/AudioMutingMsg.dart";
import "../iscp/messages/MasterVolumeMsg.dart";
import "../iscp/messages/PowerStatusMsg.dart";
import "../iscp/messages/ReceiverInformationMsg.dart";
import "../iscp/state/SoundControlState.dart";
import "../utils/Logging.dart";
import "../widgets/CustomImageButton.dart";
import "../widgets/CustomProgressBar.dart";
import "AudioControlMaxLevelView.dart";
import "UpdatableView.dart";

class VolumeControlDeviceView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        StateManager.ZONE_EVENT,
        Configuration.CONFIGURATION_EVENT,
        PowerStatusMsg.CODE,
        AudioControlMaxLevelView.VOLUME_MAX_EVENT,
        AudioMutingMsg.CODE,
        MasterVolumeMsg.CODE,
        AllChannelEqualizerMsg.CODE
    ];

    final SoundControlType _soundControlType;
    int tmpVolumeLevel = -1;

    VolumeControlDeviceView(final ViewContext viewContext, this._soundControlType) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.logRebuild(this);

        final SoundControlState soundControl = state.soundControlState;
        final bool volumeValid = state.isOn && soundControl.volumeLevel != MasterVolumeMsg.NO_LEVEL;

        if (_soundControlType == SoundControlType.DEVICE_BUTTONS)
        {
            return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    _audioMutingBtn(soundControl),
                    _volumeDownBtn(),
                    _masterVolumeBtn(context, soundControl, volumeValid),
                    _volumeUpBtn()
                ]
            );
        }
        else if (_soundControlType == SoundControlType.DEVICE_SLIDER)
        {
            return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    _masterVolumeBtn(context, soundControl, volumeValid),
                    _slider(soundControl, volumeValid, updateCallback, false),
                    _audioMutingBtn(soundControl)
                ],
            );
        }
        else if (_soundControlType == SoundControlType.DEVICE_BTN_AROUND_SLIDER)
        {
            return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    _masterVolumeBtn(context, soundControl, volumeValid),
                    _volumeDownBtn(),
                    _slider(soundControl, volumeValid, updateCallback, false),
                    _volumeUpBtn(),
                    _audioMutingBtn(soundControl)
                ],
            );
        }
        else if (_soundControlType == SoundControlType.DEVICE_BTN_ABOVE_SLIDER)
        {
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                            _audioMutingBtn(soundControl),
                            _volumeDownBtn(),
                            _masterVolumeBtn(context, soundControl, volumeValid),
                            _volumeUpBtn()
                        ]
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [ _slider(soundControl, volumeValid, updateCallback, true)]
                    ),
                ]
            );
        }

        return SizedBox.shrink();
    }

    Widget _masterVolumeBtn(BuildContext context, SoundControlState soundControl, bool volumeValid)
    {
        final int volumeLevel = tmpVolumeLevel < 0 ? soundControl.volumeLevel : tmpVolumeLevel;
        final String volumeLevelStr = configuration.audioControl.volumeUnit == VolumeUnit.RELATIVE ?
            SoundControlState.getRelativeLevelStr(volumeLevel, state.getActiveZoneInfo, configuration.audioControl)
            : SoundControlState.getVolumeLevelStr( volumeLevel, state.getActiveZoneInfo);
        return CustomImageButton.normal(
            Drawables.audio_control,
            Strings.audio_control,
            text: volumeValid ? volumeLevelStr : "",
            onPressed: ()
            => _showAudioControlDialog(viewContext, context),
            isEnabled: volumeValid
        );
    }

    void _showAudioControlDialog(final ViewContext viewContext, final BuildContext context)
    {
        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext c)
            => AudioControlDialog(viewContext)
        );
    }

    Widget _volumeDownBtn()
    {
        final MasterVolumeMsg cmd = MasterVolumeMsg.output(state.getActiveZone, MasterVolume.DOWN);
        return CustomImageButton.normal(
            cmd.getCommand.icon!,
            cmd.getCommand.description,
            onPressed: () => stateManager.sendMessage(cmd),
            isEnabled: state.isOn
        );
    }

    Widget _volumeUpBtn()
    {
        final MasterVolumeMsg cmd = MasterVolumeMsg.output(state.getActiveZone, MasterVolume.UP);
        return CustomImageButton.normal(
            cmd.getCommand.icon!,
            cmd.getCommand.description,
            onPressed: ()
            => stateManager.sendMessage(cmd),
            isEnabled: state.isOn
        );
    }

    Widget _audioMutingBtn(SoundControlState soundControl)
    {
        final AudioMutingMsg cmd = AudioMutingMsg.toggle(
            state.getActiveZone, soundControl.audioMuting, state.protoType);
        return CustomImageButton.normal(
            AudioMutingMsg.TOGGLE.icon!,
            AudioMutingMsg.TOGGLE.description,
            onPressed: ()
            => stateManager.sendMessage(cmd),
            isEnabled: state.isOn,
            isSelected: state.isOn && soundControl.audioMuting.key == AudioMuting.ON
        );
    }

    Widget _slider(SoundControlState soundControl, bool volumeValid, VoidCallback updateCallback, bool showMax)
    {
        final int zone = state.getActiveZone;
        final Zone? zoneInfo = state.getActiveZoneInfo;
        final int maxVolume = zoneInfo == null ? MasterVolumeMsg.MAX_VOLUME_1_STEP :
            min(soundControl.getVolumeMax(zoneInfo), configuration.audioControl.masterVolumeMax);
        final Widget slider = CustomProgressBar(
            minValueStr: showMax ? "0" : "",
            maxValueStr: showMax ? SoundControlState.getVolumeLevelStr(maxVolume, zoneInfo) : "",
            maxValueNum: maxVolume,
            currValue: soundControl.volumeLevel,
            onMoving: volumeValid ? (v)
            {
                tmpVolumeLevel = v.toInt();
                updateCallback();
            } : null,
            onChanged: volumeValid ? (v)
            {
                stateManager.sendMessage(MasterVolumeMsg.value(zone, max(v, 0)));
                tmpVolumeLevel = -1;
            } : null
        );
        return Expanded(child: slider);
    }
}