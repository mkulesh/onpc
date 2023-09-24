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

import "package:flutter/material.dart";

import "../constants/Strings.dart";
import "../iscp/messages/AlbumNameMsg.dart";
import "../iscp/messages/ArtistNameMsg.dart";
import "../iscp/messages/PowerStatusMsg.dart";
import "../iscp/messages/RadioStationNameMsg.dart";
import "../iscp/messages/InputSelectorMsg.dart";
import "../iscp/messages/MenuStatusMsg.dart";
import "../iscp/messages/OperationCommandMsg.dart";
import "../iscp/messages/PresetCommandMsg.dart";
import "../iscp/messages/ReceiverInformationMsg.dart";
import "../iscp/messages/TitleNameMsg.dart";
import "../widgets/CustomImageButton.dart";
import "../widgets/CustomTextLabel.dart";
import "UpdatableView.dart";

class TrackCaptionView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        ReceiverInformationMsg.CODE,
        InputSelectorMsg.CODE,
        MenuStatusMsg.CODE,
        TitleNameMsg.CODE,
        ArtistNameMsg.CODE,
        AlbumNameMsg.CODE,
        PresetCommandMsg.CODE,
        RadioStationNameMsg.CODE,
        PowerStatusMsg.CODE
    ];

    TrackCaptionView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    bool get _isRadioInput
    => state.mediaListState.isRadioInput;

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        // Artist and album
        final Widget artist = CustomTextLabel.normal(_buildTrackArtist(), bold: true, textAlign: TextAlign.center);
        final Widget album = CustomTextLabel.normal(_buildTrackAlbum(), textAlign: TextAlign.center);

        // Song title with feed buttons
        final List<Widget> titleItems = [];
        if (state.playbackState.negativeFeed.isImageValid)
        {
            titleItems.add(CustomImageButton.normal(
                state.playbackState.negativeFeed.icon!,
                Strings.cmd_description_f2,
                onPressed: ()
                => stateManager.sendTrackCmd(ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE, OperationCommand.F2, false),
                isEnabled: true
            ));
        }
        titleItems.add(Expanded(child: CustomTextLabel.normal(_buildTrackTitle(), textAlign: TextAlign.center)));
        if (state.playbackState.positiveFeed.isImageValid)
        {
            final FeedType feed = state.playbackState.positiveFeed.key;
            final bool isSelected = state.mediaListState.isAmazonMusic ? feed == FeedType.LIKE : feed == FeedType.LOVE;
            titleItems.add(CustomImageButton.normal(
                state.playbackState.positiveFeed.icon!,
                Strings.cmd_description_f1,
                onPressed: ()
                => stateManager.sendTrackCmd(ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE, OperationCommand.F1, false),
                isEnabled: true,
                isSelected: isSelected
            ));
        }

        final Widget titleLine = Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: titleItems
        );

        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [artist, album, titleLine]
        );
    }

    String _buildTrackTitle()
    {
        if (_isRadioInput)
        {
            final String stationInfo = state.mediaListState.isDAB || state.mediaListState.isFM ?
                state.radioState.stationName : "";
            return stationInfo != _presetInfo() ? stationInfo : "";
        }
        return state.trackState.title;
    }

    String _buildTrackArtist()
    {
        return _isRadioInput ? "" : state.trackState.artist;
    }

    String _buildTrackAlbum()
    {
        return _isRadioInput ? _presetInfo() : state.trackState.album;
    }

    String _presetInfo()
    {
        final Preset? preset = state.receiverInformation.getPreset(state.radioState.preset);
        return preset != null ? preset.displayedString(withId: false) : "";
    }
}
