/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2023 by Mikhail Kulesh
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

import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../views/AudioControlView.dart";
import "../views/EqualizerView.dart";
import "../views/MasterVolumeMaxView.dart";
import "../views/UpdatableView.dart";
import "../widgets/CustomDialogTitle.dart";

enum AudioControlType
{
    TONE_CONTROL,
    MASTER_VOLUME_MAX,
    EQUALIZER
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
        switch(widget._audioControlType)
        {
            case AudioControlType.TONE_CONTROL:
                dialogTitle = CustomDialogTitle(Strings.app_control_audio_control, Drawables.volume_audio_control);
                dialogContent = UpdatableWidget(child: AudioControlView(viewContext));
                break;
            case AudioControlType.MASTER_VOLUME_MAX:
                dialogTitle = CustomDialogTitle(Strings.master_volume_restrict, Drawables.volume_max_limit);
                dialogContent = UpdatableWidget(child: MasterVolumeMaxView(viewContext));
                break;
            case AudioControlType.EQUALIZER:
                dialogTitle = CustomDialogTitle(Strings.equalizer, Drawables.equalizer);
                dialogContent = UpdatableWidget(child: EqualizerView(viewContext));
                break;
        }

        if (widget._audioControlType != AudioControlType.MASTER_VOLUME_MAX)
        {
            dialogContent = SizedBox(
                width: MediaQuery.of(context).size.width,
                child: dialogContent);
        }

        return AlertDialog(
            title: dialogTitle,
            contentPadding: DialogDimens.contentPadding,
            content: dialogContent,
            insetPadding: DialogDimens.contentPadding,
            actions: <Widget>[
                TextButton(
                    child: Text(Strings.action_ok.toUpperCase(), style: td.textTheme.labelLarge),
                    onPressed: ()
                    => Navigator.of(context).pop()
                )
            ]
        );
    }
}