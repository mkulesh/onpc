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

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../views/AudioControlView.dart";
import "../views/MasterVolumeMaxView.dart";
import "../views/UpdatableView.dart";
import "../widgets/CustomDialogTitle.dart";

enum AudioControlType
{
    TONE_CONTROL,
    MASTER_VOLUME_MAX
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

        final Widget dialogTitle = widget._audioControlType == AudioControlType.TONE_CONTROL ?
        CustomDialogTitle(Strings.app_control_audio_control, Drawables.volume_audio_control) :
        CustomDialogTitle(Strings.master_volume_restrict, Drawables.volume_max_limit);

        final Widget dialogContent = widget._audioControlType == AudioControlType.TONE_CONTROL ?
        UpdatableWidget(child: AudioControlView(viewContext)) :
        UpdatableWidget(child: MasterVolumeMaxView(viewContext));

        return AlertDialog(
            title: dialogTitle,
            contentPadding: DialogDimens.contentPadding,
            content: dialogContent,
            actions: <Widget>[
                FlatButton(
                    child: Text(Strings.action_ok.toUpperCase(), style: td.textTheme.button),
                    onPressed: ()
                    => Navigator.of(context).pop()
                )
            ]
        );
    }
}