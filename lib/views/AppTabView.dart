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

import "../config/CfgTabSettings.dart";
import "../constants/Dimens.dart";
import "../widgets/CustomDivider.dart";
import "AmplifierControlView.dart";
import "CdControlView.dart";
import "DeviceInfoView.dart";
import "DeviceSettingsView.dart";
import "InputSelectorView.dart";
import "ListeningModeDeviceView.dart";
import "ListeningModeView.dart";
import "MediaListView.dart";
import "PlayControlView.dart";
import "SetupNavigationCommandsView.dart";
import "SetupOperationalCommandsView.dart";
import "ShortcutsView.dart";
import "TrackCaptionView.dart";
import "TrackCoverView.dart";
import "TrackFileInfoView.dart";
import "TrackTimeView.dart";
import "UpdatableView.dart";
import "VolumeControlView.dart";

class AppTabView extends UpdatableView
{
    static const List<AppControl> EXPANDABLE = [
        AppControl.TRACK_COVER,
        AppControl.SHORTCUTS,
        AppControl.MEDIA_LIST
    ];

    static const List<AppControl> FOCUSABLE = [
        AppControl.DEVICE_INFO,
        AppControl.MEDIA_LIST
    ];

    List<AppControl> controlsPortrait;
    List<AppControl> controlsLandscapeLeft;
    List<AppControl> controlsLandscapeRight;

    AppTabView(final ViewContext viewContext, final CfgTabSettings cfg) : super(viewContext, [])
    {
        controlsPortrait = cfg.controlsPortrait;
        controlsLandscapeLeft = cfg.controlsLandscapeLeft;
        controlsLandscapeRight = cfg.controlsLandscapeRight;
    }

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        final bool isPortrait = MediaQuery
            .of(context)
            .orientation == Orientation.portrait;

        bool expandable = false, focusable = false;
        final List<AppControl> firstColumn = _getFirstColumn(isPortrait);
        final List<AppControl> secondColumn = _getSecondColumn(isPortrait);

        Widget tab;
        if (secondColumn == null)
        {
            final List<Widget> views = List();
            _addWidgets(context, firstColumn, views);
            expandable = expandable || _isExpandable(firstColumn);
            focusable = focusable || _isFocusable(firstColumn);
            tab = (expandable) ?
                Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: views) : ListBody(children: views);
        }
        else
        {
            final List<Widget> leftViews = List();
            _addWidgets(context, firstColumn, leftViews);
            expandable = expandable || _isExpandable(firstColumn);
            focusable = focusable || _isFocusable(firstColumn);

            final List<Widget> rightViews = List();
            _addWidgets(context, secondColumn, rightViews);
            expandable = expandable || _isExpandable(secondColumn);
            focusable = focusable || _isFocusable(secondColumn);

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
            tab = GestureDetector(
                child: tab,
                onTap: ()
                => FocusScope.of(context).unfocus()
            );
        }
        else
        {
            FocusScope.of(context).unfocus();
        }

        if (!expandable)
        {
            tab = SingleChildScrollView(scrollDirection: Axis.vertical, child: tab);
        }

        return tab;
    }

    List<AppControl> _getFirstColumn(bool isPortrait)
    => (isPortrait || (controlsLandscapeLeft == null && controlsLandscapeRight == null)) ? controlsPortrait : controlsLandscapeLeft;

    List<AppControl> _getSecondColumn(bool isPortrait)
    => (!isPortrait) ? controlsLandscapeRight : null;

    bool _isExpandable(final List<AppControl> types)
    => types.firstWhere((c) => EXPANDABLE.contains(c), orElse: () => null) != null;

    bool _isFocusable(final List<AppControl> types)
    => types.firstWhere((c) => FOCUSABLE.contains(c), orElse: () => null) != null;

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
        switch (c)
        {
            case AppControl.DIVIDER:
                return CustomDivider(height: ActivityDimens.activityMargins(context).vertical);

            case AppControl.LISTENING_MODE_LIST:
                return UpdatableWidget(child: ListeningModeView(viewContext));

            case AppControl.VOLUME_CONTROL:
                return UpdatableWidget(child: VolumeControlView(viewContext));

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

            case AppControl.LISTENING_MODE_BTN:
                return UpdatableWidget(child: ListeningModeDeviceView(viewContext));

            case AppControl.DEVICE_INFO:
                return DeviceInfoView(viewContext);

            case AppControl.DEVICE_SETTINGS:
                return UpdatableWidget(child: DeviceSettingsView(viewContext));

            case AppControl.RI_AMPLIFIER:
                return UpdatableWidget(child: AmplifierControlView(viewContext));

            case AppControl.RI_CD_PLAYER:
                return UpdatableWidget(child: CdControlView(viewContext));
        }
        return null;
    }
}