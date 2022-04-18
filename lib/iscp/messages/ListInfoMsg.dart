/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2022 by Mikhail Kulesh
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
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";
import "EnumParameterMsg.dart";

enum InformationType
{
    ASCII,
    CURSOR,
    UNICODE
}

enum ListProperty
{
    NO,
    PLAYING,
    ARTIST,
    ALBUM,
    FOLDER,
    MUSIC,
    PLAYLIST,
    SEARCH,
    ACCOUNT,
    PLAYLIST_C,
    STARRED,
    UNSTARRED,
    WHATS_NEW
}

enum UpdateType
{
    NO,
    PAGE,
    CURSOR
}

/*
 * NET/USB List Info
 */
class ListInfoMsg extends ISCPMessage
{
    static const String CODE = "NLS";

    /*
     * Information Type (A : ASCII letter, C : Cursor Info, U : Unicode letter)
     */
    static const ExtEnum<InformationType> InformationTypeEnum = ExtEnum<InformationType>([
        EnumItem.char(InformationType.ASCII, 'A'),
        EnumItem.char(InformationType.CURSOR, 'C', defValue: true),
        EnumItem.char(InformationType.UNICODE, 'U')
    ]);

    EnumItem<InformationType> _informationType;

    /* Line Info (0-9 : 1st to 10th Line) */
    int _lineInfo;

    /*
     * Property
     * - : no
     * 0 : Playing, A : Artist, B : Album, F : Folder, M : Music, P : Playlist, S : Search
     * a : Account, b : Playlist-C, c : Starred, d : Unstarred, e : What's New
     */
    static const ExtEnum<ListProperty> ListPropertyEnum = ExtEnum<ListProperty>([
        EnumItem.char(ListProperty.NO, '-', defValue: true),
        EnumItem.char(ListProperty.PLAYING, '0'),
        EnumItem.char(ListProperty.ARTIST, 'A'),
        EnumItem.char(ListProperty.ALBUM, 'B'),
        EnumItem.char(ListProperty.FOLDER, 'F'),
        EnumItem.char(ListProperty.MUSIC, 'M'),
        EnumItem.char(ListProperty.PLAYLIST, 'P'),
        EnumItem.char(ListProperty.SEARCH, 'S'),
        EnumItem.char(ListProperty.ACCOUNT, 'A'),
        EnumItem.char(ListProperty.PLAYLIST_C, 'B'),
        EnumItem.char(ListProperty.STARRED, 'C'),
        EnumItem.char(ListProperty.UNSTARRED, 'D'),
        EnumItem.char(ListProperty.WHATS_NEW, 'E')
    ]);

    EnumItem<ListProperty> _listProperty;

    /*
     * Update Type (P : Page Infomation Update ( Page Clear or Disable List Info) , C : Cursor Position Update)
     */
    static const ExtEnum<UpdateType> UpdateTypeEnum = ExtEnum<UpdateType>([
        EnumItem.char(UpdateType.NO, '-', defValue: true),
        EnumItem.char(UpdateType.PAGE, 'P'),
        EnumItem.char(UpdateType.CURSOR, 'C')
    ]);

    EnumItem<UpdateType> _updateType;

    String _listedData;

    ListInfoMsg(EISCPMessage raw) : super(CODE, raw)
    {
        _informationType = InformationTypeEnum.valueByCode(getData.substring(0, 1));
        _lineInfo = ISCPMessage.nonNullInteger(getData.substring(1, 2), 10, -1);
        switch (_informationType.key)
        {
            case InformationType.ASCII:
            case InformationType.UNICODE:
                _listProperty = ListPropertyEnum.valueByCode(getData.substring(2, 3));
                _updateType = UpdateTypeEnum.valueByCode("");
                _listedData = getData.substring(3);
                break;
            case InformationType.CURSOR:
                _listProperty = ListPropertyEnum.valueByCode("");
                _updateType = UpdateTypeEnum.valueByCode(getData.substring(2, 3));
                _listedData = "";
                break;
        }
    }

    ListInfoMsg.output(final int lineInfo, final String listedData) :
            super.outputId(lineInfo, CODE, _getParameterAsString(lineInfo))
    {
        _informationType = InformationTypeEnum.valueByKey(InformationType.UNICODE);
        _lineInfo = lineInfo;
        _listProperty = ListPropertyEnum.valueByKey(ListProperty.NO);
        _updateType = UpdateTypeEnum.valueByKey(UpdateType.NO);
        _listedData = listedData;
    }

    static String _getParameterAsString(final int lineInfo)
    {
        return "L" + lineInfo.toString();
    }

    EnumItem<InformationType> get getInformationType
    => _informationType;

    EnumItem<UpdateType> get getUpdateType
    => _updateType;

    String get getListedData
    => _listedData;

    int get getLineInfo
    => _lineInfo;

    @override
    String toString()
    => super.toString()
            + "[INF_TYPE=" + _informationType.toString()
            + "; LINE_INFO=" + _lineInfo.toString()
            + "; PROPERTY=" + _listProperty.toString()
            + "; UPD_TYPE=" + _updateType.toString()
            + "; LIST_DATA=" + _listedData
            + "]";
}
