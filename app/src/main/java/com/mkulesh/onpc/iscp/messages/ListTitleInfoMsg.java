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

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

/*
 * NET/USB List Title Info
 */
public class ListTitleInfoMsg extends ISCPMessage
{
    public final static String CODE = "NLT";

    /*
     * Service Type
     * 00 : Music Server (DLNA), 01 : Favorite, 02 : vTuner, 03 : SiriusXM, 04 : Pandora, 05 : Rhapsody, 06 : Last.fm,
     * 07 : Napster, 08 : Slacker, 09 : Mediafly, 0A : Spotify, 0B : AUPEO!, 0C : radiko, 0D : e-onkyo,
     * 0E : TuneIn Radio, 0F : MP3tunes, 10 : Simfy, 11:Home Media, 12:Deezer, 13:iHeartRadio, 18:Airplay, 1A:onkyo music, 1B:TIDAL, 41:FireConnect,
     *  F0 : USB/USB(Front) F1 : USB(Rear), F2 : Internet Radio, F3 : NET, FF : None
     */
    public enum ServiceType implements StringParameterIf
    {
        MUSIC_SERVER("00", R.drawable.media_item_server),
        FAVORITE("01"),
        VTUNER("02"),
        SIRIUSXM("03"),
        PANDORA("04"),
        RHAPSODY("05"),
        LAST_FM("06"),
        NAPSTER("07"),
        SLACKER("08"),
        MEDIAFLY("09"),
        SPOTIFY("0A"),
        AUPEO("0B"),
        RADIKO("0C"),
        E_ONKYO("0D"),
        TUNEIN_RADIO("0E", R.drawable.media_item_radio),
        MP3TUNES("0F"),
        SIMFY("10"),
        HOME_MEDIA("11"),
        DEEZER("12", R.drawable.media_item_deezer),
        IHEARTRADIO("13"),
        AIRPLAY("18"),
        ONKYO_MUSIC("1A"),
        TIDAL("1B"),
        PLAYQUEUE("1D", R.drawable.media_item_playqueue),
        FIRECONNECT("41"),
        USB_REAR("F1", R.drawable.media_item_usb),
        INTERNET_RADIO("F2"),
        USB_FRONT("F0", R.drawable.media_item_usb),
        NET("F3"),
        NONE("FF");

        final String code;
        final int imageId;

        ServiceType(String code, int imageId)
        {
            this.code = code;
            this.imageId = imageId;
        }

        ServiceType(String code)
        {
            this.code = code;
            this.imageId = R.drawable.media_item_unknown;
        }

        public String getCode()
        {
            return code;
        }

        public int getImageId()
        {
            return imageId;
        }
    }

    private ServiceType serviceType = ServiceType.NONE;

    /*
     * UI Type 0 : List, 1 : Menu, 2 : Playback, 3 : Popup, 4 : Keyboard, "5" : Menu List
     */
    public enum UIType implements CharParameterIf
    {
        LIST('0'), MENU('1'), PLAYBACK('2'), POPUP('3'), KEYBOARD('4'), MENU_LIST('5');
        final Character code;

        UIType(Character code)
        {
            this.code = code;
        }

        public Character getCode()
        {
            return code;
        }
    }

    private UIType uiType = UIType.LIST;

    /*
     * Layer Info : 0 : NET TOP, 1 : Service Top,DLNA/USB/iPod Top, 2 : under 2nd Layer
     */
    public enum LayerInfo implements CharParameterIf
    {
        NET_TOP('0'), SERVICE_TOP('1'), UNDER_2ND_LAYER('2');
        final Character code;

        LayerInfo(Character code)
        {
            this.code = code;
        }

        public Character getCode()
        {
            return code;
        }
    }

    private LayerInfo layerInfo = LayerInfo.NET_TOP;

    /* Current Cursor Position (HEX 4 letters) */
    private int currentCursorPosition = 0;

    /* Number of List Items (HEX 4 letters) */
    private int numberOfItems = 0;

    /* Number of Layer(HEX 2 letters) */
    private int numberOfLayers = 0;

    /*
     * Start Flag : 0 : Not First, 1 : First
     */
    private enum StartFlag implements CharParameterIf
    {
        NOT_FIRST('0'), FIRST('1');
        final Character code;

        StartFlag(Character code)
        {
            this.code = code;
        }

        public Character getCode()
        {
            return code;
        }
    }

    private StartFlag startFlag = StartFlag.FIRST;

    /*
     * Icon on Left of Title Bar
     * 00 : Internet Radio, 01 : Server, 02 : USB, 03 : iPod, 04 : DLNA, 05 : WiFi, 06 : Favorite
     * 10 : Account(Spotify), 11 : Album(Spotify), 12 : Playlist(Spotify), 13 : Playlist-C(Spotify)
     * 14 : Starred(Spotify), 15 : What's New(Spotify), 16 : Track(Spotify), 17 : Artist(Spotify)
     * 18 : Play(Spotify), 19 : Search(Spotify), 1A : Folder(Spotify)
     * FF : None
     */
    private enum LeftIcon implements StringParameterIf
    {
        INTERNET_RADIO("00"),
        SERVER("01"),
        USB("02"),
        IPOD("03"),
        DLNA("04"),
        WIFI("05"),
        FAVORITE("06"),
        ACCOUNT_SPOTIFY("10"),
        ALBUM_SPOTIFY("11"),
        PLAYLIST_SPOTIFY("12"),
        PLAYLIST_C_SPOTIFY("13"),
        STARRED_SPOTIFY("14"),
        WHATS_NEW_SPOTIFY("15"),
        TRACK_SPOTIFY("16"),
        ARTIST_SPOTIFY("17"),
        PLAY_SPOTIFY("18"),
        SEARCH_SPOTIFY("19"),
        FOLDER_SPOTIFY("1A"),
        NONE("FF");
        final String code;

        LeftIcon(String code)
        {
            this.code = code;
        }

        public String getCode()
        {
            return code;
        }
    }

    private LeftIcon leftIcon = LeftIcon.NONE;

    /*
     * Icon on Right of Title Bar
     * 00 : Music Server (DLNA), 01 : Favorite, 02 : vTuner, 03 : SiriusXM, 04 : Pandora, 05 : Rhapsody, 06 : Last.fm,
     * 07 : Napster, 08 : Slacker, 09 : Mediafly, 0A : Spotify, 0B : AUPEO!, 0C : radiko, 0D : e-onkyo,
     * 0E : TuneIn Radio, 0F : MP3tunes, 10 : Simfy, 11:Home Media, 12:Deezer, 13:iHeartRadio,
     * 18 : Airplay, 1A:onkyo music, 1B:TIDAL, 41:FireConnect,
     * F0 : USB/USB(Front), F1:USB(Rear),
     * FF : None
     */
    private enum RightIcon implements StringParameterIf
    {
        MUSIC_SERVER("00"),
        FAVORITE("01"),
        VTUNER("02"),
        SIRIUSXM("03"),
        PANDORA("04"),
        RHAPSODY("05"),
        LAST_FM("06"),
        NAPSTER("07"),
        SLACKER("08"),
        MEDIAFLY("09"),
        SPOTIFY("0A"),
        AUPEO("0B"),
        RADIKO("0C"),
        E_ONKYO("0D"),
        TUNEIN_RADIO("0E"),
        MP3TUNES("0F"),
        SIMFY("10"),
        HOME_MEDIA("11"),
        DEEZER("12"),
        IHEARTRADIO("13"),
        AIRPLAY("18"),
        ONKYO_MUSIC("1A"),
        TIDAL("1B"),
        FIRECONNECT("41"),
        USB_FRONT("F0"),
        USB_REAR("F1"),
        NONE("FF");
        final String code;

        RightIcon(String code)
        {
            this.code = code;
        }

        public String getCode()
        {
            return code;
        }
    }

    private RightIcon rightIcon = RightIcon.NONE;

    /*
     * ss : Status Info
     * 00 : None, 01 : Connecting, 02 : Acquiring License, 03 : Buffering
     * 04 : Cannot Play, 05 : Searching, 06 : Profile update, 07 : Operation disabled
     * 08 : Server Start-up, 09 : Song rated as Favorite, 0A : Song banned from station,
     * 0B : Authentication Failed, 0C : Spotify Paused(max 1 device), 0D : Track Not Available, 0E : Cannot Skip
     */
    private enum StatusInfo implements StringParameterIf
    {
        NONE("00"),
        CONNECTING("01"),
        ACQUIRING_LICENSE("02"),
        BUFFERING("03"),
        CANNOT_PLAY("04"),
        SEARCHING("05"),
        PROFILE_UPDATE("06"),
        OPERATION_DISABLED("07"),
        SERVER_START_UP("08"),
        SONG_RATED_AS_FAVORITE("09"),
        SONG_BANNED_FROM_STATION("0A"),
        AUTHENTICATION_FAILED("0B"),
        SPOTIFY_PAUSED("0C"),
        TRACK_NOT_AVAILABLE("0D"),
        CANNOT_SKIP("0E");
        final String code;

        StatusInfo(String code)
        {
            this.code = code;
        }

        public String getCode()
        {
            return code;
        }
    }

    private StatusInfo statusInfo = StatusInfo.NONE;

    /* Character of Title Bar (variable-length, 64 Unicode letters [UTF-8 encoded] max) */
    private String titleBar;

    ListTitleInfoMsg(EISCPMessage raw) throws Exception
    {
        super(raw);

        /* NET/USB List Title Info
        xx : Service Type
        u : UI Type
        y : Layer Info
        cccc : Current Cursor Position (HEX 4 letters)
        iiii : Number of List Items (HEX 4 letters)
        ll : Number of Layer(HEX 2 letters)
        s : Start Flag
        r : Reserved (1 leters, don't care)
        aa : Icon on Left of Title Bar
        bb : Icon on Right of Title Bar
        ss : Status Info
        nnn...nnn : Character of Title Bar (variable-length, 64 Unicode letters [UTF-8 encoded] max)
        */
        final String format = "xxuycccciiiillsraabbss";

        if (data.length() >= format.length())
        {
            serviceType = (ServiceType) searchParameter(data.substring(0, 2), ServiceType.values(), serviceType);
            uiType = (UIType) searchParameter(data.charAt(2), UIType.values(), uiType);
            layerInfo = (LayerInfo) searchParameter(data.charAt(3), LayerInfo.values(), layerInfo);
            currentCursorPosition = Integer.parseInt(data.substring(4, 8), 16);
            numberOfItems = Integer.parseInt(data.substring(8, 12), 16);
            numberOfLayers = Integer.parseInt(data.substring(12, 14), 16);
            startFlag = (StartFlag) searchParameter(data.charAt(14), StartFlag.values(), startFlag);
            leftIcon = (LeftIcon) searchParameter(data.substring(16, 18), LeftIcon.values(), leftIcon);
            rightIcon = (RightIcon) searchParameter(data.substring(18, 20), RightIcon.values(), rightIcon);
            statusInfo = (StatusInfo) searchParameter(data.substring(20, 22), StatusInfo.values(), statusInfo);
            titleBar = data.substring(22);
        }
    }

    public ServiceType getServiceType()
    {
        return serviceType;
    }

    public UIType getUiType()
    {
        return uiType;
    }

    public LayerInfo getLayerInfo()
    {
        return layerInfo;
    }

    public int getNumberOfItems()
    {
        return numberOfItems;
    }

    public int getNumberOfLayers()
    {
        return numberOfLayers;
    }

    public String getTitleBar()
    {
        return titleBar;
    }

    @Override
    public String toString()
    {
        return CODE + "[" + data
                + "; SERVICE=" + serviceType.toString()
                + "; UI=" + uiType.toString()
                + "; LAYER=" + layerInfo
                + "; CURSOR=" + currentCursorPosition
                + "; ITEMS=" + numberOfItems
                + "; LAYERS=" + numberOfLayers
                + "; START=" + startFlag.toString()
                + "; LEFT_ICON=" + leftIcon.toString()
                + "; RIGHT_ICON=" + rightIcon.toString()
                + "; STATUS=" + statusInfo.toString()
                + "; title=" + titleBar
                + "]";
    }
}
