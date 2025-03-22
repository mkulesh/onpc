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
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../views/AudioControlView.dart";
import "../views/ChannelLevelView.dart";
import "../views/EqualizerView.dart";
import "../views/MasterVolumeMaxView.dart";
import "../views/UpdatableView.dart";
import "../widgets/CustomDialogTitle.dart";

enum AudioControlType
{
    TONE_CONTROL,
    MASTER_VOLUME_MAX,
    EQUALIZER,
    CHANNEL_LEVEL
}

void showAudioControlDialog(final ViewContext viewContext, final BuildContext context, final AudioControlType type)
{
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext c)
        => AudioControlDialog(viewContext, type)
    );
}

class AudioControlDialog extends StatefulWidget
{
    final ViewContext _viewContext;
    final AudioControlType _audioControlType;

    AudioControlDialog(this._viewContext, this._audioControlType);

    @override _AudioControlDialogState createState()
    => _AudioControlDialogState();
}

class _AudioControlDialogState extends State<AudioControlDialog>
{
    ViewContext get viewContext
    => widget._viewContext;

    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = Theme.of(context);

        Widget dialogTitle, dialogContent;
        final List<Widget> actions = [];
        switch(widget._audioControlType)
        {
            case AudioControlType.TONE_CONTROL:
                dialogTitle = CustomDialogTitle(Strings.app_control_audio_control, Drawables.volume_audio_control);
                dialogContent = UpdatableWidget(child: AudioControlView(viewContext));
                if (viewContext.state.soundControlState.isChannelLevelAvailable(widget._viewContext.state.protoType))
                {
                    actions.add(TextButton(
                        child: Text(Strings.channel_level.toUpperCase(), style: td.textTheme.labelLarge),
                        onPressed: ()
                        => showAudioControlDialog(viewContext, context, AudioControlType.CHANNEL_LEVEL)
                    ));
                }
                break;
            case AudioControlType.MASTER_VOLUME_MAX:
                dialogTitle = CustomDialogTitle(Strings.master_volume_restrict, Drawables.volume_max_limit);
                dialogContent = UpdatableWidget(child: MasterVolumeMaxView(viewContext));
                break;
            case AudioControlType.EQUALIZER:
                dialogTitle = CustomDialogTitle(Strings.equalizer, Drawables.equalizer);
                dialogContent = UpdatableWidget(child: EqualizerView(viewContext));
                break;
            case AudioControlType.CHANNEL_LEVEL:
                dialogTitle = CustomDialogTitle(Strings.channel_level, Drawables.equalizer);
                dialogContent = UpdatableWidget(child: ChannelLevelView(viewContext));
                actions.add(TextButton(
                    child: Text(Strings.action_default.toUpperCase(), style: td.textTheme.labelLarge),
                    onPressed: ()
                    => ChannelLevelView.sendDefaultChannelLevel(viewContext.stateManager)
                ));
                break;
        }

        if (widget._audioControlType != AudioControlType.MASTER_VOLUME_MAX)
        {
            dialogContent = SizedBox(
                width: MediaQuery.of(context).size.width,
                child: dialogContent);
        }

        actions.add(TextButton(
            child: Text(Strings.action_ok.toUpperCase(), style: td.textTheme.labelLarge),
            onPressed: ()
            => Navigator.of(context).pop()
        ));

        return AlertDialog(
            title: dialogTitle,
            contentPadding: DialogDimens.contentPadding,
            content: dialogContent,
            insetPadding: DialogDimens.contentPadding,
            actions: actions
        );
    }
}