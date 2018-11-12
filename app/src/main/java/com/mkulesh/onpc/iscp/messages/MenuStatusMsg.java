/*
 * Copyright (C) 2018. Mikhail Kulesh
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

package com.mkulesh.onpc.iscp.messages;

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

/*
 * NET/USB Menu Status
 */
public class MenuStatusMsg extends ISCPMessage
{
    public final static String CODE = "NMS";

    /*
     * Track Menu: "M": Menu is enable, "x": Menu is disable
     */
    public enum TrackMenu implements CharParameterIf
    {
        ENABLE('M'), DISABLE('x');
        final Character code;

        TrackMenu(Character code)
        {
            this.code = code;
        }

        public Character getCode()
        {
            return code;
        }
    }

    private TrackMenu trackMenu = TrackMenu.DISABLE;

    /*
     * Feed: "xx":disable, "01":Like, "02":don't like, "03":Love, "04":Ban,
     *       "05":episode, "06":ratings, "07":Ban(black), "08":Ban(white),
     *       "09":Favorite(black), "0A":Favorite(white), "0B":Favorite(yellow)
     */
    private enum Feed implements StringParameterIf
    {
        DISABLE("XX"),
        LIKE("01"),
        DONT_LIKE("02"),
        LOVE("03"),
        BAN("04"),
        EPISODE("05"),
        RATINGS("06"),
        BAN_BLACK("07"),
        BAN_WHITE("08"),
        FAVORITE_BLACK("09"),
        FAVORITE_WHITE("0A"),
        FAVORITE_YELLOW("0B");
        final String code;

        Feed(String code)
        {
            this.code = code;
        }

        public String getCode()
        {
            return code;
        }
    }

    private Feed positiveFeed = Feed.DISABLE;
    private Feed negativeFeed = Feed.DISABLE;

    /*
     * Time Seek "S": Time Seek is enable "x": Time Seek is disable
     */
    public enum TimeSeek implements CharParameterIf
    {
        ENABLE('S'), DISABLE('x');
        final Character code;

        TimeSeek(Character code)
        {
            this.code = code;
        }

        public Character getCode()
        {
            return code;
        }
    }

    private TimeSeek timeSeek = TimeSeek.DISABLE;

    /*
     * Time Display "1": Elapsed Time/Total Time, "2": Elapsed Time, "x": disable
     */
    private enum TimeDisplay implements CharParameterIf
    {
        ELAPSED_TOTAL('1'), ELAPSED('2'), DISABLE('x');
        final Character code;

        TimeDisplay(Character code)
        {
            this.code = code;
        }

        public Character getCode()
        {
            return code;
        }
    }

    private TimeDisplay timeDisplay = TimeDisplay.DISABLE;
    private ServiceType serviceIcon = ServiceType.UNKNOWN;

    MenuStatusMsg(EISCPMessage raw) throws Exception
    {
        super(raw);

        /* NET/USB Menu Status (9 letters)
           m -> Track Menu: "M": Menu is enable, "x": Menu is disable
           aa -> F1 button icon (Positive Feed or Mark/Unmark)
           bb -> F2 button icon (Negative Feed)
           s -> Time Seek "S": Time Seek is enable "x": Time Seek is disable
           t -> Time Display "1": Elapsed Time/Total Time, "2": Elapsed Time, "x": disable
           ii-> Service icon
        */
        final String format = "maabbstii";
        if (data.length() >= format.length())
        {
            trackMenu = (TrackMenu) searchParameter(data.charAt(0), TrackMenu.values(), trackMenu);
            positiveFeed = (Feed) searchParameter(data.substring(1, 3), Feed.values(), positiveFeed);
            negativeFeed = (Feed) searchParameter(data.substring(3, 5), Feed.values(), negativeFeed);
            timeSeek = (TimeSeek) searchParameter(data.charAt(5), TimeSeek.values(), timeSeek);
            timeDisplay = (TimeDisplay) searchParameter(data.charAt(6), TimeDisplay.values(), timeDisplay);
            serviceIcon = (ServiceType) searchParameter(data.substring(7, 9), ServiceType.values(), serviceIcon);
        }
    }

    public TrackMenu getTrackMenu()
    {
        return trackMenu;
    }

    public TimeSeek getTimeSeek()
    {
        return timeSeek;
    }

    public ServiceType getServiceIcon()
    {
        return serviceIcon;
    }

    @Override
    public String toString()
    {
        return CODE + "[" + data
                + "; TRACK_MENU=" + trackMenu.toString()
                + "; POS_FEED=" + positiveFeed.toString()
                + "; NEG_FEED=" + negativeFeed.toString()
                + "; TIME_SEEK=" + timeSeek.toString()
                + "; TIME_DISPLAY=" + timeDisplay.toString()
                + "; ICON=" + serviceIcon.toString()
                + "]";
    }
}
