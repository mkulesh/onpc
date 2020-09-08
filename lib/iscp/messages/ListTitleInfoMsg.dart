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

import "../EISCPMessage.dart";
import "../ISCPMessage.dart";
import "EnumParameterMsg.dart";
import "ServiceType.dart";

enum UIType
{
    LIST,
    MENU,
    PLAYBACK,
    POPUP,
    KEYBOARD,
    MENU_LIST
}

enum LayerInfo
{
    NET_TOP,
    SERVICE_TOP,
    UNDER_2ND_LAYER
}

enum StartFlag
{
    NOT_FIRST,
    FIRST
}

enum LeftIcon
{
    INTERNET_RADIO,
    SERVER,
    USB,
    IPOD,
    DLNA,
    WIFI,
    FAVORITE,
    ACCOUNT_SPOTIFY,
    ALBUM_SPOTIFY,
    PLAYLIST_SPOTIFY,
    PLAYLIST_C_SPOTIFY,
    STARRED_SPOTIFY,
    WHATS_NEW_SPOTIFY,
    TRACK_SPOTIFY,
    ARTIST_SPOTIFY,
    PLAY_SPOTIFY,
    SEARCH_SPOTIFY,
    FOLDER_SPOTIFY,
    NONE
}

enum RightIcon
{
    MUSIC_SERVER,
    FAVORITE,
    VTUNER,
    SIRIUSXM,
    PANDORA,
    RHAPSODY,
    LAST_FM,
    NAPSTER,
    SLACKER,
    MEDIAFLY,
    SPOTIFY,
    AUPEO,
    RADIKO,
    E_ONKYO,
    TUNEIN_RADIO,
    MP3TUNES,
    SIMFY,
    HOME_MEDIA,
    DEEZER,
    IHEARTRADIO,
    AIRPLAY,
    ONKYO_MUSIC,
    TIDAL,
    FIRECONNECT,
    USB_FRONT,
    USB_REAR,
    NONE
}

enum StatusInfo
{
    NONE,
    CONNECTING,
    ACQUIRING_LICENSE,
    BUFFERING,
    CANNOT_PLAY,
    SEARCHING,
    PROFILE_UPDATE,
    OPERATION_DISABLED,
    SERVER_START_UP,
    SONG_RATED_AS_FAVORITE,
    SONG_BANNED_FROM_STATION,
    AUTHENTICATION_FAILED,
    SPOTIFY_PAUSED,
    TRACK_NOT_AVAILABLE,
    CANNOT_SKIP
}


/*
 * NET/USB List Title Info
 */
class ListTitleInfoMsg extends ISCPMessage
{
    static const String CODE = "NLT";

    EnumItem<ServiceType> _serviceType;

    /*
     * UI Type 0 : List, 1 : Menu, 2 : Playback, 3 : Popup, 4 : Keyboard, "5" : Menu List
     */
    static const ExtEnum<UIType> UITypeEnum = ExtEnum<UIType>([
        EnumItem.char(UIType.LIST, '0', defValue: true),
        EnumItem.char(UIType.MENU, '1'),
        EnumItem.char(UIType.PLAYBACK, '2'),
        EnumItem.char(UIType.POPUP, '3'),
        EnumItem.char(UIType.KEYBOARD, '4'),
        EnumItem.char(UIType.MENU_LIST, '5')
    ]);

    EnumItem<UIType> _uiType;

    /*
     * Layer Info : 0 : NET TOP, 1 : Service Top,DLNA/USB/iPod Top, 2 : under 2nd Layer
     */
    static const ExtEnum<LayerInfo> LayerInfoEnum = ExtEnum<LayerInfo>([
        EnumItem.char(LayerInfo.NET_TOP, '0', defValue: true),
        EnumItem.char(LayerInfo.SERVICE_TOP, '1'),
        EnumItem.char(LayerInfo.UNDER_2ND_LAYER, '2')
    ]);

    EnumItem<LayerInfo> _layerInfo;

    /* Current Cursor Position (HEX 4 letters) */
    int _currentCursorPosition = 0;

    /* Number of List Items (HEX 4 letters) */
    int _numberOfItems = 0;

    /* Number of Layer(HEX 2 letters) */
    int _numberOfLayers = 0;

    /*
     * Start Flag : 0 : Not First, 1 : First
     */
    static const ExtEnum<StartFlag> StartFlagEnum = ExtEnum<StartFlag>([
        EnumItem.char(StartFlag.NOT_FIRST, '0', defValue: true),
        EnumItem.char(StartFlag.FIRST, '1')
    ]);

    EnumItem<StartFlag> _startFlag;

    /*
     * Icon on Left of Title Bar
     * 00 : Internet Radio, 01 : Server, 02 : USB, 03 : iPod, 04 : DLNA, 05 : WiFi, 06 : Favorite
     * 10 : Account(Spotify), 11 : Album(Spotify), 12 : Playlist(Spotify), 13 : Playlist-C(Spotify)
     * 14 : Starred(Spotify), 15 : What's New(Spotify), 16 : Track(Spotify), 17 : Artist(Spotify)
     * 18 : Play(Spotify), 19 : Search(Spotify), 1A : Folder(Spotify)
     * FF : None
     */
    static const ExtEnum<LeftIcon> LeftIconEnum = ExtEnum<LeftIcon>([
        EnumItem.code(LeftIcon.INTERNET_RADIO, "00"),
        EnumItem.code(LeftIcon.SERVER, "01"),
        EnumItem.code(LeftIcon.USB, "02"),
        EnumItem.code(LeftIcon.IPOD, "03"),
        EnumItem.code(LeftIcon.DLNA, "04"),
        EnumItem.code(LeftIcon.WIFI, "05"),
        EnumItem.code(LeftIcon.FAVORITE, "06"),
        EnumItem.code(LeftIcon.ACCOUNT_SPOTIFY, "10"),
        EnumItem.code(LeftIcon.ALBUM_SPOTIFY, "11"),
        EnumItem.code(LeftIcon.PLAYLIST_SPOTIFY, "12"),
        EnumItem.code(LeftIcon.PLAYLIST_C_SPOTIFY, "13"),
        EnumItem.code(LeftIcon.STARRED_SPOTIFY, "14"),
        EnumItem.code(LeftIcon.WHATS_NEW_SPOTIFY, "15"),
        EnumItem.code(LeftIcon.TRACK_SPOTIFY, "16"),
        EnumItem.code(LeftIcon.ARTIST_SPOTIFY, "17"),
        EnumItem.code(LeftIcon.PLAY_SPOTIFY, "18"),
        EnumItem.code(LeftIcon.SEARCH_SPOTIFY, "19"),
        EnumItem.code(LeftIcon.FOLDER_SPOTIFY, "1A"),
        EnumItem.code(LeftIcon.NONE, "FF", defValue: true)
    ]);

    EnumItem<LeftIcon> _leftIcon;

    /*
     * Icon on Right of Title Bar
     * 00 : Music Server (DLNA), 01 : Favorite, 02 : vTuner, 03 : SiriusXM, 04 : Pandora, 05 : Rhapsody, 06 : Last.fm,
     * 07 : Napster, 08 : Slacker, 09 : Mediafly, 0A : Spotify, 0B : AUPEO!, 0C : radiko, 0D : e-onkyo,
     * 0E : TuneIn Radio, 0F : MP3tunes, 10 : Simfy, 11:Home Media, 12:Deezer, 13:iHeartRadio,
     * 18 : Airplay, 1A:onkyo music, 1B:TIDAL, 41:FireConnect,
     * F0 : USB/USB(Front), F1:USB(Rear),
     * FF : None
     */
    static const ExtEnum<RightIcon> RightIconEnum = ExtEnum<RightIcon>([
        EnumItem.code(RightIcon.MUSIC_SERVER, "00"),
        EnumItem.code(RightIcon.FAVORITE, "01"),
        EnumItem.code(RightIcon.VTUNER, "02"),
        EnumItem.code(RightIcon.SIRIUSXM, "03"),
        EnumItem.code(RightIcon.PANDORA, "04"),
        EnumItem.code(RightIcon.RHAPSODY, "05"),
        EnumItem.code(RightIcon.LAST_FM, "06"),
        EnumItem.code(RightIcon.NAPSTER, "07"),
        EnumItem.code(RightIcon.SLACKER, "08"),
        EnumItem.code(RightIcon.MEDIAFLY, "09"),
        EnumItem.code(RightIcon.SPOTIFY, "0A"),
        EnumItem.code(RightIcon.AUPEO, "0B"),
        EnumItem.code(RightIcon.RADIKO, "0C"),
        EnumItem.code(RightIcon.E_ONKYO, "0D"),
        EnumItem.code(RightIcon.TUNEIN_RADIO, "0E"),
        EnumItem.code(RightIcon.MP3TUNES, "0F"),
        EnumItem.code(RightIcon.SIMFY, "10"),
        EnumItem.code(RightIcon.HOME_MEDIA, "11"),
        EnumItem.code(RightIcon.DEEZER, "12"),
        EnumItem.code(RightIcon.IHEARTRADIO, "13"),
        EnumItem.code(RightIcon.AIRPLAY, "18"),
        EnumItem.code(RightIcon.ONKYO_MUSIC, "1A"),
        EnumItem.code(RightIcon.TIDAL, "1B"),
        EnumItem.code(RightIcon.FIRECONNECT, "41"),
        EnumItem.code(RightIcon.USB_FRONT, "F0"),
        EnumItem.code(RightIcon.USB_REAR, "F1"),
        EnumItem.code(RightIcon.NONE, "FF", defValue: true)
    ]);

    EnumItem<RightIcon> _rightIcon;

    /*
     * ss : Status Info
     * 00 : None, 01 : Connecting, 02 : Acquiring License, 03 : Buffering
     * 04 : Cannot Play, 05 : Searching, 06 : Profile update, 07 : Operation disabled
     * 08 : Server Start-up, 09 : Song rated as Favorite, 0A : Song banned from station,
     * 0B : Authentication Failed, 0C : Spotify Paused(max 1 device), 0D : Track Not Available, 0E : Cannot Skip
     */
    static const ExtEnum<StatusInfo> StatusInfoEnum = ExtEnum<StatusInfo>([
        EnumItem.code(StatusInfo.NONE, "00", defValue: true),
        EnumItem.code(StatusInfo.CONNECTING, "01"),
        EnumItem.code(StatusInfo.ACQUIRING_LICENSE, "02"),
        EnumItem.code(StatusInfo.BUFFERING, "03"),
        EnumItem.code(StatusInfo.CANNOT_PLAY, "04"),
        EnumItem.code(StatusInfo.SEARCHING, "05"),
        EnumItem.code(StatusInfo.PROFILE_UPDATE, "06"),
        EnumItem.code(StatusInfo.OPERATION_DISABLED, "07"),
        EnumItem.code(StatusInfo.SERVER_START_UP, "08"),
        EnumItem.code(StatusInfo.SONG_RATED_AS_FAVORITE, "09"),
        EnumItem.code(StatusInfo.SONG_BANNED_FROM_STATION, "0A"),
        EnumItem.code(StatusInfo.AUTHENTICATION_FAILED, "0B"),
        EnumItem.code(StatusInfo.SPOTIFY_PAUSED, "0C"),
        EnumItem.code(StatusInfo.TRACK_NOT_AVAILABLE, "0D"),
        EnumItem.code(StatusInfo.CANNOT_SKIP, "0E")
    ]);

    EnumItem<StatusInfo> _statusInfo;

    /* Character of Title Bar (variable-length, 64 Unicode letters [UTF-8 encoded] max) */
    String _titleBar;

    ListTitleInfoMsg(EISCPMessage raw) : super(CODE, raw)
    {

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

        if (getData.length >= format.length)
        {
            _serviceType = Services.ServiceTypeEnum.valueByCode(getData.substring(0, 2));
            _uiType = UITypeEnum.valueByCode(getData.substring(2, 3));
            _layerInfo = LayerInfoEnum.valueByCode(getData.substring(3, 4));
            _currentCursorPosition = ISCPMessage.nonNullInteger(getData.substring(4, 8), 16, 0);
            _numberOfItems = ISCPMessage.nonNullInteger(getData.substring(8, 12), 16, 0);
            _numberOfLayers = ISCPMessage.nonNullInteger(getData.substring(12, 14), 16, 0);
            _startFlag = StartFlagEnum.valueByCode(getData.substring(14, 15));
            _leftIcon = LeftIconEnum.valueByCode(getData.substring(16, 18));
            _rightIcon = RightIconEnum.valueByCode(getData.substring(18, 20));
            _statusInfo = StatusInfoEnum.valueByCode(getData.substring(20, 22));
            _titleBar = getData.substring(22);
        }
    }

    EnumItem<ServiceType> get getServiceType
    => _serviceType;

    EnumItem<UIType> get getUiType
    => _uiType;

    EnumItem<LayerInfo> get getLayerInfo
    => _layerInfo;

    int get getNumberOfItems
    => _numberOfItems;

    int get getCurrentCursorPosition
    => _currentCursorPosition;

    int get getNumberOfLayers
    => _numberOfLayers;

    String get getTitleBar
    => _titleBar;

    @override
    String toString()
    => super.toString() + "["
            + "; SERVICE=" + _serviceType.toString()
            + "; UI=" + _uiType.toString()
            + "; LAYER=" + _layerInfo.toString()
            + "; CURSOR=" + _currentCursorPosition.toString()
            + "; ITEMS=" + _numberOfItems.toString()
            + "; LAYERS=" + _numberOfLayers.toString()
            + "; START=" + _startFlag.toString()
            + "; LEFT_ICON=" + _leftIcon.toString()
            + "; RIGHT_ICON=" + _rightIcon.toString()
            + "; STATUS=" + _statusInfo.toString()
            + "; title=" + _titleBar
            + "]";

    bool get isNetTopService
    => _serviceType.key == ServiceType.NET
            && _layerInfo.key == LayerInfo.NET_TOP;

    bool get isXmlListTopService
    => [ServiceType.USB_FRONT, ServiceType.USB_REAR, ServiceType.MUSIC_SERVER, ServiceType.HOME_MEDIA].contains(_serviceType.key)
            && _layerInfo.key == LayerInfo.SERVICE_TOP;
}
