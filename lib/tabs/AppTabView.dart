/*
 * Copyright (C) 2020. Mikhail Kulesh
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
import "../iscp/state/SoundControlState.dart";
import "../views/AmplifierControlView.dart";
import "../views/CdControlView.dart";
import "../views/DeviceInfoView.dart";
import "../views/DeviceSettingsView.dart";
import "../views/InputSelectorView.dart";
import "../views/ListeningModeDeviceView.dart";
import "../views/ListeningModeView.dart";
import "../views/MediaListView.dart";
import "../views/PlayControlView.dart";
import "../views/SetupNavigationCommandsView.dart";
import "../views/SetupOperationalCommandsView.dart";
import "../views/ShortcutsView.dart";
import "../views/TrackCaptionView.dart";
import "../views/TrackCoverView.dart";
import "../views/TrackFileInfoView.dart";
import "../views/TrackTimeView.dart";
import "../views/UpdatableView.dart";
import "../views/VolumeControlView.dart";
import "../widgets/CustomDivider.dart";

enum AppControl
{
    DIVIDER,
    LISTENING_MODE,
    VOLUME_CONTROL,
    TRACK_FILE_INFO,
    TRACK_COVER,
    TRACK_TIME,
    TRACK_CAPTION,
    PLAY_CONTROL,
    SHORTCUTS,
    INPUT_SELECTOR,
    MEDIA_LIST,
    SETUP_OP_CMD,
    SETUP_NAV_CMD,
    LISTENING_MODE_DEVICE,
    DEVICE_INFO,
    DEVICE_SETTINGS,
    RI_AMPLIFIER,
    RI_CD_PLAYER,
}

abstract class AppTabView extends UpdatableView
{
    final List<AppControl> controlsPortrait;
    final List<AppControl> controlsLandscapeLeft;
    final List<AppControl> controlsLandscapeRight;
    final bool scrollable, focusable;

    AppTabView(final ViewContext viewContext, final List<String> updateTriggers,
    {
        this.controlsPortrait,
        this.controlsLandscapeLeft,
        this.controlsLandscapeRight,
        this.scrollable = true,
        this.focusable = false
    }) : super(viewContext, updateTriggers);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        final bool isPortrait = MediaQuery
            .of(context)
            .orientation == Orientation.portrait;

        Widget tab;
        if (isPortrait || (controlsLandscapeLeft == null && controlsLandscapeRight == null))
        {
            final List<Widget> views = List();
            _addWidgets(context, controlsPortrait, views);
            tab = (scrollable) ?
            ListBody(children: views) : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: views);
        }
        else if (controlsLandscapeLeft != null && controlsLandscapeRight == null)
        {
            final List<Widget> views = List();
            _addWidgets(context, controlsLandscapeLeft, views);
            tab = (scrollable) ?
            ListBody(children: views) : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: views);
        }
        else
        {
            final List<Widget> leftViews = List();
            _addWidgets(context, controlsLandscapeLeft, leftViews);

            final List<Widget> rightViews = List();
            _addWidgets(context, controlsLandscapeRight, rightViews);

            tab = Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    Expanded(flex: 10, child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: leftViews)),
                    Expanded(flex: 1, child: SizedBox.shrink()),
                    Expanded(flex: 20, child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: rightViews))
                ]
            );
        }

        if (focusable)
        {
            tab = InkWell(
                child: tab,
                enableFeedback: false,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: ()
                => FocusScope.of(context).unfocus()
            );
        }

        if (scrollable)
        {
            tab = SingleChildScrollView(scrollDirection: Axis.vertical, child: tab);
        }

        return tab;
    }

    void _addWidgets(BuildContext context, final List<AppControl> types, final List<Widget> widgets)
    {
        types.forEach((c)
        {
            final Widget w = _buildWidget(context, c);
            if (w != null)
            {
                widgets.add(w);
            }
        });
    }

    Widget _buildWidget(BuildContext context, AppControl c)
    {
        final SoundControlType soundControl = state.soundControlState.soundControlType(
            configuration.audioControl.soundControl, state.getActiveZoneInfo);

        switch (c)
        {
            case AppControl.DIVIDER:
                return CustomDivider(height: ActivityDimens.activityMargins(context).vertical);

            case AppControl.LISTENING_MODE:
                return ([SoundControlType.DEVICE_BUTTONS, SoundControlType.DEVICE_SLIDER, SoundControlType.DEVICE_BTN_SLIDER].contains(soundControl)) ?
                UpdatableWidget(child: ListeningModeView(viewContext)) : null;

            case AppControl.VOLUME_CONTROL:
                return (soundControl != SoundControlType.NONE) ?
                UpdatableWidget(child: VolumeControlView(viewContext)) : null;

            case AppControl.TRACK_FILE_INFO:
                return UpdatableWidget(child: TrackFileInfoView(viewContext));

            case AppControl.TRACK_COVER:
                return UpdatableWidget(child: TrackCoverView(viewContext, flex: 1));

            case AppControl.TRACK_TIME:
                return UpdatableWidget(child: TrackTimeView(viewContext));

            case AppControl.TRACK_CAPTION:
                return UpdatableWidget(child: TrackCaptionView(viewContext));

            case AppControl.PLAY_CONTROL:
                return UpdatableWidget(child: PlayControlView(viewContext));

            case AppControl.SHORTCUTS:
                return UpdatableWidget(child: ShortcutsView(viewContext));

            case AppControl.INPUT_SELECTOR:
                return UpdatableWidget(child: InputSelectorView(viewContext));

            case AppControl.MEDIA_LIST:
                return MediaListView(viewContext);

            case AppControl.SETUP_OP_CMD:
                return UpdatableWidget(child: SetupOperationalCommandsView(viewContext));

            case AppControl.SETUP_NAV_CMD:
                return UpdatableWidget(child: SetupNavigationCommandsView(viewContext));

            case AppControl.LISTENING_MODE_DEVICE:
                return state.receiverInformation.isListeningModeControl() ?
                UpdatableWidget(child: ListeningModeDeviceView(viewContext)) : null;

            case AppControl.DEVICE_INFO:
                return (state.receiverInformation.isFriendlyName || state.receiverInformation.isReceiverInformation) ?
                DeviceInfoView(viewContext) : null;

            case AppControl.DEVICE_SETTINGS:
                return UpdatableWidget(child: DeviceSettingsView(viewContext));

            case AppControl.RI_AMPLIFIER:
                return configuration.appSettings.riAmp ?
                UpdatableWidget(child: AmplifierControlView(viewContext)) : null;

            case AppControl.RI_CD_PLAYER:
                return configuration.appSettings.riCd ?
                UpdatableWidget(child: CdControlView(viewContext)) : null;
        }
        return null;
    }
}