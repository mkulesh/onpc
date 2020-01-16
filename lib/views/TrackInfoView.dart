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

import "package:flutter/material.dart";
import "package:flutter_svg/svg.dart";

import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../iscp/messages/AlbumNameMsg.dart";
import "../iscp/messages/ArtistNameMsg.dart";
import "../iscp/messages/DisplayModeMsg.dart";
import "../iscp/messages/FileFormatMsg.dart";
import "../iscp/messages/InputSelectorMsg.dart";
import "../iscp/messages/JacketArtMsg.dart";
import "../iscp/messages/ListTitleInfoMsg.dart";
import "../iscp/messages/MenuStatusMsg.dart";
import "../iscp/messages/MultiroomDeviceInformationMsg.dart";
import "../iscp/messages/OperationCommandMsg.dart";
import "../iscp/messages/PowerStatusMsg.dart";
import "../iscp/messages/PresetCommandMsg.dart";
import "../iscp/messages/ReceiverInformationMsg.dart";
import "../iscp/messages/TitleNameMsg.dart";
import "../iscp/messages/TrackInfoMsg.dart";
import "../utils/Logging.dart";
import "../widgets/CustomImageButton.dart";
import "../widgets/CustomTextLabel.dart";
import "GroupButtonsView.dart";
import "TrackTimeView.dart";
import "UpdatableView.dart";

class TrackInfoView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        PowerStatusMsg.CODE,
        AlbumNameMsg.CODE,
        ArtistNameMsg.CODE,
        FileFormatMsg.CODE,
        TitleNameMsg.CODE,
        TrackInfoMsg.CODE,
        JacketArtMsg.CODE,
        MenuStatusMsg.CODE,
        ReceiverInformationMsg.CODE,
        PresetCommandMsg.CODE,
        ListTitleInfoMsg.CODE,
        InputSelectorMsg.CODE,
        MultiroomDeviceInformationMsg.CODE
    ];

    TrackInfoView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        final bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
        Logging.info(this, "rebuild widget, isPortrait=" + isPortrait.toString());
        final ThemeData td = Theme.of(context);

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
        final bool isTrackMenu = state.playbackState.isTrackMenuActive;
        final Widget textTrackInfo = Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
                Expanded(child: CustomTextLabel.small(_buildTrackInfo(), textAlign: TextAlign.right)),
                CustomImageButton.small(
                    Drawables.cmd_track_menu,
                    Strings.cmd_track_menu,
                    onPressed: ()
                    => stateManager.sendTrackCmd(ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE, OperationCommand.MENU, false),
                    isEnabled: isTrackMenu
                ),
            ]);

        // Header row contains file format info, multiroom buttons and track info
        Widget headerLine;
        {
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

            headerLine = Table(
                columnWidths: columnWidths.asMap(),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [TableRow(children: columnContent)],
            );
        }

        final Widget cover = state.trackState.cover != null ?
        state.trackState.cover :
        SvgPicture.asset(
            Drawables.empty_cover,
            color: state.isOn ? td.accentColor : td.disabledColor,
            fit: BoxFit.contain);

        final Widget coverButton = Expanded(
            child: Container(
                padding: ActivityDimens.coverImagePadding(context),
                child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    child: Material(  // with Material
                        elevation: ActivityDimens.elevation,
                        child:IconButton(
                            icon: cover,
                            padding: ActivityDimens.noPadding,
                            alignment: Alignment.center,
                            tooltip: Strings.tv_display_mode,
                            onPressed: ()
                            => stateManager.sendMessage(DisplayModeMsg.output(DisplayModeMsg.TOGGLE))
                    ))
                )
            ),
        );

        // Artist and album
        final Widget artist = CustomTextLabel.normal(_buildTrackArtist(), bold: true, textAlign: TextAlign.center);
        final Widget album = CustomTextLabel.normal(_buildTrackAlbum(), textAlign: TextAlign.center);

        // Song title with feed buttons
        final List<Widget> titleItems = List<Widget>();
        if (state.playbackState.negativeFeed.isImageValid)
        {
            titleItems.add(CustomImageButton.normal(
                state.playbackState.negativeFeed.icon,
                Strings.cmd_description_f2,
                onPressed: ()
                => stateManager.sendTrackCmd(ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE, OperationCommand.F2, false),
                isEnabled: true
            ));
        }
        titleItems.add(Expanded(child: CustomTextLabel.normal(_buildTrackTitle(), textAlign: TextAlign.center)));
        if (state.playbackState.positiveFeed.isImageValid)
        {
            titleItems.add(CustomImageButton.normal(
                state.playbackState.positiveFeed.icon,
                Strings.cmd_description_f1,
                onPressed: ()
                => stateManager.sendTrackCmd(ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE, OperationCommand.F1, false),
                isEnabled: true,
                isSelected: state.playbackState.positiveFeed.key == FeedType.LOVE
            ));
        }

        final Widget titleLine = Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: titleItems
        );

        final List<Widget> captionItems = List<Widget>();
        if (isPortrait)
        {
            captionItems.add(artist);
            captionItems.add(album);
        }
        else
        {
            captionItems.add(Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [artist, album]
            ));
        }
        captionItems.add(titleLine);

        final Widget caption = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: captionItems
        );

        final UpdatableWidget trackTimeView = UpdatableWidget(
            child: TrackTimeView(viewContext)
        );

        final Widget mainView = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [headerLine, coverButton, trackTimeView, caption],
        );

        if (state.trackState.isCoverPending)
        {
            return Stack(
                children: [
                    Align(alignment: Alignment.center,
                        child: mainView),
                    Align(alignment: Alignment.center,
                        child: SvgPicture.asset(
                            Drawables.timer_sand,
                            color: td.disabledColor))
                ],
            );
        }
        else
        {
            return mainView;
        }
    }

    String _buildFileFormat()
    {
        if (state.mediaListState.isRadioInput)
        {
            return state.radioState.getFrequencyInfo(state.mediaListState.inputType.key);
        }
        else
        {
            return state.trackState.fileFormat;
        }
    }

    String _buildTrackInfo()
    {
        String str = "";
        final String dashedString = Strings.dashed_string;
        if (state.mediaListState.isRadioInput)
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

    String _buildTrackTitle()
    {
        return state.mediaListState.isRadioInput ? "" : state.trackState.title;
    }

    String _buildTrackArtist()
    {
        return state.mediaListState.isRadioInput ? "" : state.trackState.artist;
    }

    String _buildTrackAlbum()
    {
        if (state.mediaListState.isRadioInput)
        {
            final Preset preset = state.receiverInformation.getPreset(state.radioState.preset);
            Logging.info(this, "preset=" + preset.toString());
            return preset != null ? preset.displayedString : "N/A";
        }
        else
        {
            return state.trackState.album;
        }
    }
}