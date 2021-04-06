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
// @dart=2.9
import "package:flutter/material.dart";

import "../config/CfgTabSettings.dart";
import "../utils/Logging.dart";
import "../widgets/CustomDivider.dart";
import "AmplifierControlView.dart";
import "CdControlView.dart";
import "DeviceInfoView.dart";
import "DeviceSettingsView.dart";
import "InputSelectorView.dart";
import "ListeningModeButtonsView.dart";
import "ListeningModeListView.dart";
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

    final int _extId;
    int _wId = 0;

    AppTabView(this._extId, final ViewContext viewContext, final CfgTabSettings cfg) : super(viewContext, [])
    {
        controlsPortrait = cfg.controlsPortrait;
        controlsLandscapeLeft = cfg.controlsLandscapeLeft;
        controlsLandscapeRight = cfg.controlsLandscapeRight;
    }

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.logRebuild(this, ext: ("id=" + _extId.toString()));

        final bool isPortrait = MediaQuery
            .of(context)
            .orientation == Orientation.portrait;

        bool expandable = false, focusable = false;
        final List<AppControl> firstColumn = _getFirstColumn(isPortrait);
        final List<AppControl> secondColumn = _getSecondColumn(isPortrait);

        Widget tab;
        if (secondColumn.isEmpty)
        {
            final List<Widget> views = [];
            _addWidgets(context, firstColumn, views);
            expandable = expandable || _isExpandable(firstColumn);
            focusable = focusable || _isFocusable(firstColumn);
            tab = (expandable) ?
                Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: views) : ListBody(children: views);
        }
        else
        {
            // collect all widgets
            final List<Widget> leftViews = [];
            _addWidgets(context, firstColumn, leftViews);
            final bool leftExpandable = _isExpandable(firstColumn);

            final List<Widget> rightViews = [];
            _addWidgets(context, secondColumn, rightViews);
            final bool rightExpandable = _isExpandable(secondColumn);

            // build two columns:
            // - If one column is expandable, other column will be stretched
            Widget leftColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: leftViews);
            Widget rightColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: rightViews);

            // - If there are no expandable column, both columns are scrollable with the same width
            final Map<int, FlexColumnWidth> columnWidths = Map();
            columnWidths[0] = FlexColumnWidth(10);
            columnWidths[1] = FlexColumnWidth(1);
            if (!leftExpandable && !rightExpandable)
            {
                leftColumn = SingleChildScrollView(scrollDirection: Axis.vertical, child: leftColumn);
                rightColumn = SingleChildScrollView(scrollDirection: Axis.vertical, child: rightColumn);
                columnWidths[2] = FlexColumnWidth(10);
            }
            else
            {
                columnWidths[2] = FlexColumnWidth(20);
            }

            tab = Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    Expanded(flex: columnWidths[0].value.toInt(), child: leftColumn),
                    Expanded(flex: columnWidths[1].value.toInt(), child: VerticalDivider(
                        color: Theme.of(context).disabledColor)),
                    Expanded(flex: columnWidths[2].value.toInt(), child: rightColumn)
                ]
            );

            focusable = focusable || _isFocusable(firstColumn) || _isFocusable(secondColumn);
            expandable = true;
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
    => (isPortrait) ? controlsPortrait : controlsLandscapeLeft;

    List<AppControl> _getSecondColumn(bool isPortrait)
    => (!isPortrait) ? controlsLandscapeRight : [];

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
        _wId++;
        final Key key = Key(_extId.toString() + "_" + _wId.toString());
        switch (c)
        {
            case AppControl.DIVIDER1:
            case AppControl.DIVIDER2:
            case AppControl.DIVIDER3:
            case AppControl.DIVIDER4:
            case AppControl.DIVIDER5:
                return CustomDivider();

            case AppControl.LISTENING_MODE_LIST:
                return UpdatableWidget(key: key, child: ListeningModeListView(viewContext));

            case AppControl.AUDIO_CONTROL:
                return UpdatableWidget(key: key, child: VolumeControlView(viewContext));

            case AppControl.TRACK_FILE_INFO:
                return UpdatableWidget(key: key, child: TrackFileInfoView(viewContext));

            case AppControl.TRACK_COVER:
                return UpdatableWidget(key: key, child: TrackCoverView(viewContext));

            case AppControl.TRACK_TIME:
                return UpdatableWidget(key: key, child: TrackTimeView(viewContext));

            case AppControl.TRACK_CAPTION:
                return UpdatableWidget(key: key, child: TrackCaptionView(viewContext));

            case AppControl.PLAY_CONTROL:
                return UpdatableWidget(key: key, child: PlayControlView(viewContext));

            case AppControl.SHORTCUTS:
                return UpdatableWidget(key: key, child: ShortcutsView(viewContext));

            case AppControl.INPUT_SELECTOR:
                return UpdatableWidget(key: key, child: InputSelectorView(viewContext));

            case AppControl.MEDIA_LIST:
                return MediaListView(key: key, viewContext: viewContext);

            case AppControl.SETUP_OP_CMD:
                return UpdatableWidget(key: key, child: SetupOperationalCommandsView(viewContext));

            case AppControl.SETUP_NAV_CMD:
                return UpdatableWidget(key: key, child: SetupNavigationCommandsView(viewContext));

            case AppControl.LISTENING_MODE_SWITCH:
                return UpdatableWidget(key: key, child: ListeningModeButtonsView(viewContext, LMButtonsType.SWITCH));

            case AppControl.LISTENING_MODE_GROUPS:
                return UpdatableWidget(key: key, child: ListeningModeButtonsView(viewContext, LMButtonsType.GROUPS));

            case AppControl.DEVICE_INFO:
                return DeviceInfoView(viewContext);

            case AppControl.DEVICE_SETTINGS:
                return UpdatableWidget(key: key, child: DeviceSettingsView(viewContext));

            case AppControl.RI_AMPLIFIER:
                return UpdatableWidget(key: key, child: AmplifierControlView(viewContext));

            case AppControl.RI_CD_PLAYER:
                return UpdatableWidget(key: key, child: CdControlView(viewContext));
        }
        return null;
    }
}