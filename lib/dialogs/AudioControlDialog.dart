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
import "../views/UpdatableView.dart";
import "../widgets/CustomDialogTitle.dart";

class AudioControlDialog extends StatefulWidget
{
    final ViewContext _viewContext;

    AudioControlDialog(this._viewContext);

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
        return AlertDialog(
            title: CustomDialogTitle(Strings.audio_control, Drawables.volume_audio_control),
            contentPadding: DialogDimens.contentPadding,
            content: UpdatableWidget(child: AudioControlView(viewContext)),
            actions: <Widget>[
                FlatButton(
                    child: Text(Strings.action_cancel.toUpperCase()),
                    onPressed: ()
                    => Navigator.of(context).pop()
                )
            ]
        );
    }
}