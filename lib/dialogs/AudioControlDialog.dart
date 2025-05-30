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
import "../iscp/messages/EnumParameterMsg.dart";
import "../views/AudioControlAllZonesView.dart";
import "../views/AudioControlCurrentZoneView.dart";
import "../views/AudioControlChannelLevelView.dart";
import "../views/AudioControlEqualizerView.dart";
import "../views/AudioControlMaxLevelView.dart";
import "../views/UpdatableView.dart";
import "../widgets/CustomDialogTitle.dart";
import "../widgets/CustomImageButton.dart";

enum _AudioControlMode
{
    CURRENT_ZONE,
    ALL_ZONES,
    CHANNEL_LEVEL,
    EQUALIZER,
    MAX_LEVEL
}

class AudioControlDialog extends StatefulWidget
{
    final ViewContext _viewContext;

    AudioControlDialog(this._viewContext);

    @override _AudioControlDialogState createState()
    => _AudioControlDialogState();
}

class _AudioControlDialogState extends State<AudioControlDialog>
{
    _AudioControlMode _mode = _AudioControlMode.CURRENT_ZONE;

    ViewContext get viewContext
    => widget._viewContext;

    static const ExtEnum<_AudioControlMode> ValueEnum = ExtEnum<_AudioControlMode>([
            EnumItem(_AudioControlMode.CURRENT_ZONE,
                descrList: Strings.l_audio_control_current_zone, icon: Drawables.audio_control_current_zone, defValue: true),
            EnumItem(_AudioControlMode.ALL_ZONES,
                descrList: Strings.l_audio_control_all_zones, icon: Drawables.audio_control_all_zones),
            EnumItem(_AudioControlMode.CHANNEL_LEVEL,
                descrList: Strings.l_audio_control_channel_level, icon: Drawables.audio_control_channel_level),
            EnumItem(_AudioControlMode.EQUALIZER,
                descrList: Strings.l_audio_control_equalizer, icon: Drawables.audio_control_equalizer),
            EnumItem(_AudioControlMode.MAX_LEVEL,
                descrList: Strings.l_audio_control_max_level, icon: Drawables.audio_control_max_level)
        ]);

    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = Theme.of(context);

        final List<Widget> buttons = [];
        ValueEnum.values.forEach((item)
        {
            if (_isBtnAvailable(item.key))
            {
                Widget btn = CustomImageButton.normal(
                    item.icon!,
                    item.description,
                    isSelected: _mode == item.key,
                    onPressed: ()
                    {
                        setState(()
                        {
                            _mode = item.key;
                        });
                    });
                if (_mode == item.key)
                {
                    btn = Container(
                        decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: td.indicatorColor, width: 2.0))),
                        child: btn);
                }
                buttons.add(btn);
            }
        });

        final List<Widget> actions = [];
        Widget dialogContent;
        switch (_mode)
        {
            case _AudioControlMode.CURRENT_ZONE:
                dialogContent = UpdatableWidget(key: Key(_mode.toString()),
                    child: AudioControlCurrentZoneView(viewContext));
                break;
            case _AudioControlMode.ALL_ZONES:
                dialogContent = UpdatableWidget(key: Key(_mode.toString()),
                    child: AudioControlAllZonesView(viewContext));
                break;
            case _AudioControlMode.CHANNEL_LEVEL:
                dialogContent = UpdatableWidget(key: Key(_mode.toString()),
                    child: AudioControlChannelLevelView(viewContext));
                actions.add(TextButton(
                        child: Text(Strings.action_default.toUpperCase(), style: td.textTheme.labelLarge),
                        onPressed: ()
                        => AudioControlChannelLevelView.sendDefaultChannelLevel(viewContext.stateManager)
                    ));
                break;
            case _AudioControlMode.EQUALIZER:
                dialogContent = UpdatableWidget(key: Key(_mode.toString()),
                    child: AudioControlEqualizerView(viewContext));
                break;
            case _AudioControlMode.MAX_LEVEL:
                dialogContent = UpdatableWidget(key: Key(_mode.toString()),
                    child: AudioControlMaxLevelView(viewContext));
                break;
        }

        actions.add(TextButton(
                child: Text(Strings.action_ok.toUpperCase(), style: td.textTheme.labelLarge),
                onPressed: ()
                => Navigator.of(context).pop()
            )
        );

        return AlertDialog(
            title: CustomDialogTitle(Strings.audio_control, Drawables.audio_control),
            contentPadding: DialogDimens.contentPadding,
            content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Container(
                        padding: DialogDimens.rowPadding,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: buttons)),
                    Expanded(
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: dialogContent))
                ]
            ),
            insetPadding: DialogDimens.contentPadding,
            actions: actions
        );
    }

    bool _isBtnAvailable(_AudioControlMode key)
    {
        final bool isDeveloper = viewContext.configuration.developerMode;
        switch (key)
        {
            case _AudioControlMode.ALL_ZONES:
                return viewContext.state.isMultiZone;
            case _AudioControlMode.CHANNEL_LEVEL:
                return isDeveloper || viewContext.state.soundControlState.isChannelLevelAvailable(viewContext.state.protoType);
            case _AudioControlMode.EQUALIZER:
                return isDeveloper || viewContext.state.soundControlState.isEqualizerAvailable;
            default:
                return true;
        }
    }
}