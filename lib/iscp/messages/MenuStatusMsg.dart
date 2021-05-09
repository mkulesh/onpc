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
import "../../constants/Drawables.dart";
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";
import "EnumParameterMsg.dart";
import "ServiceType.dart";

enum TrackMenu
{
    ENABLE,
    DISABLE
}

enum FeedType
{
    DISABLE,
    LIKE,
    DONT_LIKE,
    LOVE,
    BAN,
    EPISODE,
    RATINGS,
    BAN_BLACK,
    BAN_WHITE,
    FAVORITE_BLACK,
    FAVORITE_WHITE,
    FAVORITE_YELLOW,
    LIKE_AMAZON
}

enum TimeSeek
{
    ENABLE,
    DISABLE
}

enum TimeDisplay
{
    ELAPSED_TOTAL,
    ELAPSED,
    DISABLE
}

/*
 * NET/USB Menu Status
 */
class MenuStatusMsg extends ISCPMessage
{
    static const String CODE = "NMS";

    /*
     * Track Menu: "M": Menu is enable, "x": Menu is disable
     */
    static const ExtEnum<TrackMenu> TrackMenuEnum = ExtEnum<TrackMenu>([
        EnumItem.char(TrackMenu.ENABLE, 'M'),
        EnumItem.char(TrackMenu.DISABLE, 'x', defValue: true)
    ]);

    EnumItem<TrackMenu> _trackMenu;

    /*
     * Feed: "xx":disable, "01":Like, "02":don't like, "03":Love, "04":Ban,
     *       "05":episode, "06":ratings, "07":Ban(black), "08":Ban(white),
     *       "09":Favorite(black), "0A":Favorite(white), "0B":Favorite(yellow)
     */
    static const ExtEnum<FeedType> FeedTypeEnum = ExtEnum<FeedType>([
        EnumItem.code(FeedType.DISABLE, "XX", defValue: true),
        EnumItem.code(FeedType.LIKE, "01", icon: Drawables.feed_like),
        EnumItem.code(FeedType.DONT_LIKE, "02", icon: Drawables.feed_dont_like),
        EnumItem.code(FeedType.LOVE, "03", icon: Drawables.feed_love),
        EnumItem.code(FeedType.BAN, "04", icon: Drawables.feed_ban),
        EnumItem.code(FeedType.EPISODE, "05"),
        EnumItem.code(FeedType.RATINGS, "06"),
        EnumItem.code(FeedType.BAN_BLACK, "07", icon: Drawables.feed_ban),
        EnumItem.code(FeedType.BAN_WHITE, "08", icon: Drawables.feed_ban),
        EnumItem.code(FeedType.FAVORITE_BLACK, "09", icon: Drawables.feed_love),
        EnumItem.code(FeedType.FAVORITE_WHITE, "0A", icon: Drawables.feed_love),
        EnumItem.code(FeedType.FAVORITE_YELLOW, "0B", icon: Drawables.feed_love),
        EnumItem.code(FeedType.LIKE_AMAZON, "0C", icon: Drawables.feed_like)
    ]);

    EnumItem<FeedType> _positiveFeed, _negativeFeed;

    /*
     * Time Seek "S": Time Seek is enable "x": Time Seek is disable
     */
    static const ExtEnum<TimeSeek> TimeSeekEnum = ExtEnum<TimeSeek>([
        EnumItem.char(TimeSeek.ENABLE, 'S'),
        EnumItem.char(TimeSeek.DISABLE, 'x', defValue: true)
    ]);

    EnumItem<TimeSeek> _timeSeek;

    /*
     * Time Display "1": Elapsed Time/Total Time, "2": Elapsed Time, "x": disable
     */
    static const ExtEnum<TimeDisplay> TimeDisplayEnum = ExtEnum<TimeDisplay>([
        EnumItem.char(TimeDisplay.ELAPSED_TOTAL, '1'),
        EnumItem.char(TimeDisplay.ELAPSED, '2'),
        EnumItem.char(TimeDisplay.DISABLE, 'x', defValue: true)
    ]);

    EnumItem<TimeDisplay> _timeDisplay;

    EnumItem<ServiceType> _serviceIcon;

    MenuStatusMsg(EISCPMessage raw) : super(CODE, raw)
    {

        /* NET/USB Menu Status (9 letters)
           m -> Track Menu: "M": Menu is enable, "x": Menu is disable
           aa -> F1 button icon (Positive Feed or Mark/Unmark)
           bb -> F2 button icon (Negative Feed)
           s -> Time Seek "S": Time Seek is enable "x": Time Seek is disable
           t -> Time Display "1": Elapsed Time/Total Time, "2": Elapsed Time, "x": disable
           ii-> Service icon
        */
        final String format = "maabbstii";
        if (getData.length >= format.length)
        {
            _trackMenu = TrackMenuEnum.valueByCode(getData.substring(0, 1));
            _positiveFeed = FeedTypeEnum.valueByCode(getData.substring(1, 3));
            _negativeFeed = FeedTypeEnum.valueByCode(getData.substring(3, 5));
            _timeSeek = TimeSeekEnum.valueByCode(getData.substring(5, 6));
            _timeDisplay = TimeDisplayEnum.valueByCode(getData.substring(6, 7));
            _serviceIcon = Services.ServiceTypeEnum.valueByCode(getData.substring(7, 9));
        }
    }

    EnumItem<TrackMenu> get getTrackMenu
    => _trackMenu;

    EnumItem<TimeSeek> get getTimeSeek
    => _timeSeek;

    EnumItem<FeedType> get getPositiveFeed
    => _positiveFeed;

    EnumItem<FeedType> get getNegativeFeed
    => _negativeFeed;

    EnumItem<ServiceType> get getServiceIcon
    => _serviceIcon;

    @override
    String toString()
    => super.toString() + "[TRACK_MENU=" + _trackMenu.toString()
            + "; POS_FEED=" + _positiveFeed.toString()
            + "; NEG_FEED=" + _negativeFeed.toString()
            + "; TIME_SEEK=" + _timeSeek.toString()
            + "; TIME_DISPLAY=" + _timeDisplay.toString()
            + "; ICON=" + _serviceIcon.toString()
            + "]";
}
