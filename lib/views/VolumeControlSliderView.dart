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

import "dart:math";

import "package:flutter/material.dart";

import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../dialogs/AudioControlDialog.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/AudioMutingMsg.dart";
import "../iscp/messages/MasterVolumeMsg.dart";
import "../iscp/messages/PowerStatusMsg.dart";
import "../iscp/messages/ReceiverInformationMsg.dart";
import "../iscp/state/SoundControlState.dart";
import "../utils/Logging.dart";
import "../widgets/CustomImageButton.dart";
import "../widgets/CustomProgressBar.dart";
import "MasterVolumeMaxView.dart";
import "UpdatableView.dart";

class VolumeControlSliderView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        StateManager.ZONE_EVENT,
        PowerStatusMsg.CODE,
        MasterVolumeMaxView.VOLUME_MAX_EVENT,
        AudioMutingMsg.CODE,
        MasterVolumeMsg.CODE
    ];

    final bool addUpDownButtons;
    int tmpVolumeLevel = -1;

    VolumeControlSliderView(final ViewContext viewContext, this.addUpDownButtons) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.logRebuild(this);

        final SoundControlState soundControl = state.soundControlState;
        final List<Widget> controls = List<Widget>();
        final bool volumeValid = state.isOn && soundControl.volumeLevel != MasterVolumeMsg.NO_LEVEL;

        // master volume label
        {
            final String volumeLevel = SoundControlState.getVolumeLevelStr(
                tmpVolumeLevel < 0 ? soundControl.volumeLevel : tmpVolumeLevel, state.getActiveZoneInfo);
            controls.add(CustomImageButton.normal(
                Drawables.volume_audio_control,
                Strings.app_control_audio_control,
                text: volumeValid ? volumeLevel : "",
                onPressed: ()
                => _showAudioControlDialog(context, AudioControlType.TONE_CONTROL),
                isEnabled: volumeValid
            ));
        }

        if (addUpDownButtons) // volume down
        {
            final MasterVolumeMsg cmd = MasterVolumeMsg.output(state.getActiveZone, MasterVolume.DOWN);
            controls.add(CustomImageButton.normal(
                cmd.getCommand.icon,
                cmd.getCommand.description,
                onPressed: ()
                => stateManager.sendMessage(cmd),
                isEnabled: state.isOn
            ));
        }

        // slider
        {
            final int zone = state.getActiveZone;
            final Zone zoneInfo = state.getActiveZoneInfo;
            final int maxVolume = zoneInfo == null ? MasterVolumeMsg.MAX_VOLUME_1_STEP :
                min(soundControl.getVolumeMax(zoneInfo), configuration.audioControl.masterVolumeMax);
            final Widget slider = CustomProgressBar(
                minValueStr: "",
                maxValueStr: "",
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
            controls.add(Expanded(child: slider));
        }

        if (addUpDownButtons) // volume up
        {
            final MasterVolumeMsg cmd = MasterVolumeMsg.output(state.getActiveZone, MasterVolume.UP);
            controls.add(CustomImageButton.normal(
                cmd.getCommand.icon,
                cmd.getCommand.description,
                onPressed: ()
                => stateManager.sendMessage(cmd),
                isEnabled: state.isOn
            ));
        }

        // audio muting
        {
            final AudioMutingMsg cmd = AudioMutingMsg.output(state.getActiveZone, AudioMuting.TOGGLE);
            controls.add(CustomImageButton.normal(
                cmd.getValue.icon,
                cmd.getValue.description,
                onPressed: ()
                => stateManager.sendMessage(cmd),
                isEnabled: state.isOn,
                isSelected: state.isOn && soundControl.audioMuting.key == AudioMuting.ON
            ));
        }

        // equalizer
        if (state.isOn && state.soundControlState.isEqualizerAvailable)
        {
            controls.add(CustomImageButton.normal(
                Drawables.equalizer,
                Strings.equalizer,
                onPressed: ()
                => _showAudioControlDialog(context, AudioControlType.EQUALIZER)
            ));
        }

        return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: controls,
        );
    }

    void _showAudioControlDialog(final BuildContext context, final AudioControlType type)
    {
        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext c)
            => AudioControlDialog(viewContext, type)
        );
    }
}