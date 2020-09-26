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

import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../dialogs/PresetMemoryDialog.dart";
import "../iscp/messages/BroadcastResponseMsg.dart";
import "../iscp/messages/FileFormatMsg.dart";
import "../iscp/messages/InputSelectorMsg.dart";
import "../iscp/messages/ListTitleInfoMsg.dart";
import "../iscp/messages/MenuStatusMsg.dart";
import "../iscp/messages/MultiroomDeviceInformationMsg.dart";
import "../iscp/messages/OperationCommandMsg.dart";
import "../iscp/messages/PlayStatusMsg.dart";
import "../iscp/messages/PresetCommandMsg.dart";
import "../iscp/messages/ReceiverInformationMsg.dart";
import "../iscp/messages/TrackInfoMsg.dart";
import "../iscp/messages/TuningCommandMsg.dart";
import "../widgets/CustomImageButton.dart";
import "../widgets/CustomTextLabel.dart";
import "GroupButtonsView.dart";
import "UpdatableView.dart";

class TrackFileInfoView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        ReceiverInformationMsg.CODE,
        InputSelectorMsg.CODE,
        PlayStatusMsg.CODE,
        MenuStatusMsg.CODE,
        MultiroomDeviceInformationMsg.CODE,
        BroadcastResponseMsg.CODE,
        FileFormatMsg.CODE,
        TuningCommandMsg.CODE,
        PresetCommandMsg.CODE,
        TrackInfoMsg.CODE,
        ListTitleInfoMsg.CODE,
    ];

    TrackFileInfoView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    bool get _isRadioInput
    => state.mediaListState.isRadioInput;

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        // File format info
        final String serviceIcon = state.getServiceIcon();
        final Widget textFileFormat = Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
                CustomImageButton.small(serviceIcon, null, isEnabled: false),
                Expanded(child: CustomTextLabel.small(_buildFileFormat(), textAlign: TextAlign.left))
            ]);

        // Track info
        final Widget trackInfoBtn = _isRadioInput ?
        CustomImageButton.small(
            Drawables.cmd_track_menu,
            Strings.cmd_preset_memory,
            onPressed: ()
            => showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext c)
                => PresetMemoryDialog(viewContext, state.receiverInformation.nextEmptyPreset())),
            isEnabled: true)
            :
        CustomImageButton.small(
            Drawables.cmd_track_menu,
            Strings.cmd_track_menu,
            onPressed: ()
            => stateManager.sendTrackCmd(ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE, OperationCommand.MENU, false),
            isEnabled: state.playbackState.isTrackMenuActive);

        final Widget textTrackInfo = Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
                Expanded(child: CustomTextLabel.small(_buildTrackInfo(), textAlign: TextAlign.right)),
                trackInfoBtn
            ]);

        // Header row contains file format info, multiroom buttons and track info
        final List<TableColumnWidth> columnWidths = List();
        final List<Widget> columnContent = List();

        columnContent.add(textFileFormat);
        columnWidths.add(FlexColumnWidth());
        if (stateManager.isMultiroomAvailable())
        {
            columnContent.add(UpdatableWidget(child: GroupButtonsView(viewContext)));
            columnWidths.add(IntrinsicColumnWidth());
        }
        columnContent.add(textTrackInfo);
        columnWidths.add(FlexColumnWidth());

        return Table(
            columnWidths: columnWidths.asMap(),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [TableRow(children: columnContent)],
        );
    }

    String _buildFileFormat()
    {
        return _isRadioInput ? state.radioState.getFrequencyInfo(state.mediaListState.inputType.key) : state.trackState.fileFormat;
    }

    String _buildTrackInfo()
    {
        String str = "";
        final String dashedString = Strings.dashed_string;
        if (_isRadioInput)
        {
            final List<Preset> presets = state.receiverInformation.presetList;
            str += state.radioState.preset != PresetCommandMsg.NO_PRESET ?
            state.radioState.preset.toString() : dashedString;
            str += "/";
            str += presets.isNotEmpty ? presets.length.toString() : dashedString;
        }
        else
        {
            str += state.trackState.currentTrack != TrackInfoMsg.INVALID_TRACK ?
            state.trackState.currentTrack.toString() : dashedString;
            str += "/";
            str += state.trackState.maxTrack != TrackInfoMsg.INVALID_TRACK ?
            state.trackState.maxTrack.toString() : dashedString;
        }
        return str.toString();
    }
}
