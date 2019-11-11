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

import "../iscp/messages/InputSelectorMsg.dart";
import "../iscp/messages/MenuStatusMsg.dart";
import "../iscp/messages/PlayStatusMsg.dart";
import "../iscp/messages/TimeInfoMsg.dart";
import "../iscp/messages/TimeSeekMsg.dart";
import "../widgets/CustomProgressBar.dart";
import "UpdatableView.dart";

class TrackTimeView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        TimeInfoMsg.CODE,
        InputSelectorMsg.CODE,
        MenuStatusMsg.CODE,
        PlayStatusMsg.CODE
    ];

    TrackTimeView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        int currTime = _timeToSeconds(state.trackState.currentTime);
        int maxTime = _timeToSeconds(state.trackState.maxTime);
        if (currTime < 0 || maxTime < 0)
        {
            currTime = 0;
            maxTime = 300;
        }

        final bool enabled = state.isPlaying && state.playbackState.timeSeek == TimeSeek.ENABLE;

        return CustomProgressBar(
            minValueStr: state.trackState.currentTime,
            maxValueStr: state.trackState.maxTime,
            maxValueNum: maxTime,
            currValue: currTime,
            onChanged: enabled ? (v) => _seekTime(v, updateCallback) : null);
    }

    static int _timeToSeconds(final String timestampStr)
    {
        try
        {
            // #88: Track time seek is frozen on NT-503
            // some players like NT-503 use format MM:SS
            // instead of HH:MM:SS
            final List<String> tokens = timestampStr.split(":");
            if (tokens.length == 3)
            {
                final int hours = int.parse(tokens[0]);
                final int minutes = int.parse(tokens[1]);
                final int seconds = int.parse(tokens[2]);
                return 3600 * hours + 60 * minutes + seconds;
            }
            else
            {
                final int hours = 0;
                final int minutes = int.parse(tokens[0]);
                final int seconds = int.parse(tokens[1]);
                return 3600 * hours + 60 * minutes + seconds;
            }
        }
        on Exception
        {
            return -1;
        }
    }

    void _seekTime(int newSec, VoidCallback updateCallback)
    {
        final int currTime = _timeToSeconds(state.trackState.currentTime);
        final int maxTime = _timeToSeconds(state.trackState.maxTime);
        final bool sendHours = newSec >= 3600 || state.receiverInformation.model != "NT-503";
        if (currTime >= 0 && maxTime >= 0)
        {
            final int hour = (newSec / 3600).floor();
            final int min = ((newSec - hour * 3600) / 60).floor();
            final int sec = newSec - hour * 3600 - min * 60;
            stateManager.sendTimeMsg(TimeSeekMsg.output(sendHours, hour, min, sec), 2);
        }
    }
}