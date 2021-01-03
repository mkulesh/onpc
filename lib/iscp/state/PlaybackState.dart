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

import "../../utils/Logging.dart";
import "../messages/EnumParameterMsg.dart";
import "../messages/InputSelectorMsg.dart";
import "../messages/MenuStatusMsg.dart";
import "../messages/PlayStatusMsg.dart";
import "../messages/ServiceType.dart";

class PlaybackState
{
    // PlayStatusMsg
    PlayStatus _playStatus;

    PlayStatus get playStatus
    => _playStatus;

    EnumItem<RepeatStatus> _repeatStatus;

    EnumItem<RepeatStatus> get repeatStatus
    => _repeatStatus;

    ShuffleStatus _shuffleStatus;

    ShuffleStatus get shuffleStatus
    => _shuffleStatus;

    // MenuStatusMsg
    TimeSeek _timeSeek;

    TimeSeek get timeSeek
    => _timeSeek;

    TrackMenu _trackMenu;

    TrackMenu get trackMenu
    => _trackMenu;

    EnumItem<FeedType> _positiveFeed;

    EnumItem<FeedType> get positiveFeed
    => _positiveFeed;

    EnumItem<FeedType> _negativeFeed;

    EnumItem<FeedType> get negativeFeed
    => _negativeFeed;

    // service that is currently playing
    EnumItem<ServiceType> _serviceIcon;

    EnumItem<ServiceType> get serviceIcon
    => _serviceIcon;

    PlaybackState()
    {
        clear();
    }

    List<String> getQueries(int zone)
    {
        Logging.info(this, "Requesting data for zone " + zone.toString() + "...");
        return [
            InputSelectorMsg.ZONE_COMMANDS[zone],
            PlayStatusMsg.CODE
        ];
    }

    List<String> getCdQueries()
    {
        Logging.info(this, "Requesting CD data...");
        return [
            PlayStatusMsg.CD_CODE
        ];
    }

    clear()
    {
        _playStatus = PlayStatus.STOP;
        _repeatStatus = PlayStatusMsg.RepeatStatusEnum.defValue;
        _shuffleStatus = ShuffleStatus.DISABLE;
        _timeSeek = TimeSeek.DISABLE;
        _trackMenu = TrackMenu.DISABLE;
        _positiveFeed = MenuStatusMsg.FeedTypeEnum.defValue;
        _negativeFeed = MenuStatusMsg.FeedTypeEnum.defValue;
        _serviceIcon = Services.ServiceTypeEnum.defValue;
    }

    bool processPlayStatus(PlayStatusMsg msg)
    {
        final bool changed = _playStatus != msg.getPlayStatus.key
            || _repeatStatus.key != msg.getRepeatStatus.key
            || _shuffleStatus != msg.getShuffleStatus.key;
        _playStatus = msg.getPlayStatus.key;
        _repeatStatus = msg.getRepeatStatus;
        _shuffleStatus = msg.getShuffleStatus.key;
        return changed;
    }

    bool processMenuStatus(MenuStatusMsg msg)
    {
        final bool changed = _timeSeek != msg.getTimeSeek.key
            || _trackMenu != msg.getTrackMenu.key
            || _positiveFeed.key != msg.getPositiveFeed.key
            || _negativeFeed.key != msg.getNegativeFeed.key
            || _serviceIcon.key != msg.getServiceIcon.key;
        _timeSeek = msg.getTimeSeek.key;
        _trackMenu = msg.getTrackMenu.key;
        _positiveFeed = msg.getPositiveFeed;
        _negativeFeed = msg.getNegativeFeed;
        _serviceIcon = msg.getServiceIcon;
        return changed;
    }

    bool get isTrackMenuActive
    => trackMenu == TrackMenu.ENABLE && playStatus != PlayStatus.STOP;
}