/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2024 by Mikhail Kulesh
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

import 'package:json_path/json_path.dart';
import 'package:sprintf/sprintf.dart';

import "../../utils/Convert.dart";
import "../../utils/Logging.dart";
import "../DcpHeosMessage.dart";
import "../ISCPMessage.dart";
import "EnumParameterMsg.dart";
import "ListTitleInfoMsg.dart";
import "ServiceType.dart";
import "XmlListItemMsg.dart";

enum BrowseType
{
    MEDIA_LIST,
    PLAY_QUEUE,
    SEARCH_RESULT,
    MEDIA_ITEM,
    PLAYQUEUE_ITEM
}

/*
 * Denon control protocol - media container
 */
class DcpMediaContainerMsg extends ISCPMessage
{
    static const String CODE = "D05";
    static const String EMPTY = "";
    static const String YES = "YES";

    static const int SO_ADD_TO_HEOS = 19;
    static const int SO_REMOVE_FROM_HEOS = 20;
    static const int SO_CONTAINER = 21;
    static const int SO_ADD_AND_PLAY_ALL = 201;
    static const int SO_ADD_ALL = 203;
    static const int SO_REPLACE_AND_PLAY_ALL = 204;

    late BrowseType _browseType;
    late String _sid;
    late String _parentSid;
    late String _cid;
    late String _parentCid;
    String _mid = EMPTY;
    String _type = EMPTY;
    late bool _container;
    bool _playable = false;
    String _name = EMPTY;
    String _artist = EMPTY;
    String _album = EMPTY;
    String _imageUrl = EMPTY;
    int _start = 0;
    int _count = 0;
    String _aid = EMPTY;
    String _qid = EMPTY;
    LayerInfo? _layerInfo;
    String _scid = EMPTY;
    String _searchStr = EMPTY;
    final List<XmlListItemMsg> _items = [];
    final List<XmlListItemMsg> _options = [];

    static const String HEOS_RESP_BROWSE_SERV = "heos/browse";
    static const String HEOS_RESP_BROWSE_CONT = "browse/browse";
    static const String HEOS_RESP_BROWSE_SEARCH = "browse/search";
    static const String HEOS_RESP_BROWSE_QUEUE = "player/get_queue";
    static const String HEOS_SET_SERVICE_OPTION = "browse/set_service_option";

    DcpMediaContainerMsg.copy(final DcpMediaContainerMsg other) : super.output(CODE, other.getData)
    {
        _browseType = other._browseType;
        _sid = other._sid;
        _parentSid = other._parentSid;
        _cid = other._cid;
        _parentCid = other._parentCid;
        _mid = other._mid;
        _type = other._type;
        _container = other._container;
        _playable = other._playable;
        _name = other._name;
        _artist = other._artist;
        _album = other._album;
        _imageUrl = other._imageUrl;
        _start = other._start;
        _count = other._count;
        _aid = other._aid;
        _qid = other._qid;
        _layerInfo = other._layerInfo;
        _scid = other._scid;
        _searchStr = other._searchStr;
        // Do not copy items
    }

    DcpMediaContainerMsg.parent(final DcpHeosMessage jsonMsg, final BrowseType browseType) : super.output(CODE, "")
    {
        _browseType = browseType;
        _sid = jsonMsg.getMsgTag("sid");
        _parentSid = _sid;
        _cid = jsonMsg.getMsgTag("cid");
        _parentCid = _cid;
        _container = _cid.isNotEmpty;
        final List<String> rangeStr = jsonMsg.getMsgTag("range").split(",");
        if (rangeStr.length == 2)
        {
            _start = ISCPMessage.nonNullInteger(rangeStr.first, 10, 0);
        }
        final String countStr = jsonMsg.getMsgTag("count");
        if (countStr.isNotEmpty)
        {
            _count = ISCPMessage.nonNullInteger(countStr, 10, 0);
        }
        _layerInfo = _cid.isEmpty ? LayerInfo.SERVICE_TOP : LayerInfo.UNDER_2ND_LAYER;
        if (browseType == BrowseType.SEARCH_RESULT)
        {
            _layerInfo = LayerInfo.UNDER_2ND_LAYER;
            _scid = jsonMsg.getMsgTag("scid");
            _searchStr = jsonMsg.getMsgTag("search");
        }
        else if (browseType == BrowseType.PLAY_QUEUE)
        {
            _sid = Services.ServiceTypeEnum.valueByKey(ServiceType.DCP_PLAYQUEUE).getCode.substring(2);
        }
    }

    DcpMediaContainerMsg.item(final Map<String, dynamic> heosMsg, final String parentSid, final String parentCid) : super.output(CODE, "")
    {
        _browseType = BrowseType.MEDIA_ITEM;
        _sid = getElement(heosMsg, "sid");
        _parentSid = parentSid;
        _cid = getElement(heosMsg, "cid");
        _parentCid = parentCid;
        _mid = getElement(heosMsg, "mid");
        _type = getElement(heosMsg, "type");
        _container = YES == getElement(heosMsg, "container").toUpperCase();
        _playable = YES == getElement(heosMsg, "playable").toUpperCase();
        _name = getNameElement(getElement(heosMsg, "name"));
        _artist = getNameElement(getElement(heosMsg, "artist"));
        _album = getNameElement(getElement(heosMsg, "album"));
        _imageUrl = getElement(heosMsg, "image_url");
    }

    DcpMediaContainerMsg.queueItem(Map<String, dynamic> heosMsg) : super.output(CODE, "")
    {
        _browseType = BrowseType.PLAYQUEUE_ITEM;
        _sid = "";
        _parentSid = "";
        _cid = "";
        _parentCid = "";
        _mid = getElement(heosMsg, "mid");
        _type = "song";
        _container = false;
        _playable = true;
        _artist = getElement(heosMsg, "artist");
        _name = _artist + " - " + getElement(heosMsg, "song");
        _album = getElement(heosMsg, "album");
        _imageUrl = getElement(heosMsg, "image_url");
        _qid = getElement(heosMsg, "qid");
    }

    bool keyEqual(DcpMediaContainerMsg msg)
    => _browseType == msg._browseType && _sid == msg._sid && _cid == msg._cid;

    BrowseType getBrowseType()
    => _browseType;

    String getSid()
    => _sid;

    EnumItem<ServiceType> getServiceType()
    {
        final EnumItem<ServiceType>? st = Services.ServiceTypeEnum.valueByDcpCode("HS" + getSid());
        return (st == null) ? Services.ServiceTypeEnum.defValue : st;
    }

    String getCid()
    => _cid;

    String getMid()
    => _mid;

    bool isContainer()
    => _container;

    bool isPlayable()
    => _playable;

    String getType()
    => _type;

    int getStart()
    => _start;

    void setStart(int start)
    {
        _start = start;
    }

    int getCount()
    => _count;

    void setAid(String aid)
    {
        _aid = aid;
    }

    LayerInfo? getLayerInfo()
    => _layerInfo;

    List<XmlListItemMsg> getItems()
    => _items;

    bool isSong()
    => "song" == _type;

    List<XmlListItemMsg> getOptions()
    => _options;

    String getSearchStr()
    => _searchStr;

    @override
    String toString()
    {
        return CODE + "[TYPE=" + Convert.enumToString(_browseType)
            + "; SID=" + _sid
            + "; PSID=" + _parentSid
            + "; CID=" + _cid
            + "; PCID=" + _parentCid
            + "; MID=" + _mid
            + "; TYPE=" + _type
            + "; CONT=" + _container.toString()
            + "; PLAY=" + _playable.toString()
            + "; START=" + _start.toString()
            + "; COUNT=" + _count.toString()
            + (_aid.isEmpty ? EMPTY : "; AID=" + _aid)
            + (_qid.isEmpty ? EMPTY : "; QID=" + _qid)
            + (_name.isEmpty ? EMPTY : "; NAME=" + _name)
            + (_artist.isEmpty ? EMPTY : "; ARTIST=" + _artist)
            + (_album.isEmpty ? EMPTY : "; ALBUM=" + _album)
            + (_imageUrl.isEmpty ? EMPTY : "; IMG=" + _imageUrl)
            + (_layerInfo == null ? EMPTY : "; LAYER=" + _layerInfo.toString())
            + (_items.isEmpty ? EMPTY : "; ITEMS=" + _items.length.toString())
            + (_options.isEmpty ? EMPTY : "; OPTIONS=" + _options.length.toString())
            + (_scid.isEmpty ? EMPTY : "; SCID=" + _scid)
            + (_searchStr.isEmpty ? EMPTY : "; SEARCH=" + _searchStr)
            + "]";
    }

    static DcpMediaContainerMsg? processHeosMessage(final DcpHeosMessage jsonMsg)
    {
        if ([HEOS_RESP_BROWSE_SERV, HEOS_RESP_BROWSE_CONT, HEOS_RESP_BROWSE_SEARCH].contains(jsonMsg.command))
        {
            final BrowseType type = HEOS_RESP_BROWSE_SEARCH == jsonMsg.command ?
                BrowseType.SEARCH_RESULT : BrowseType.MEDIA_LIST;
            final DcpMediaContainerMsg parentMsg =
                DcpMediaContainerMsg.parent(jsonMsg, type);
            readMediaItems(parentMsg, jsonMsg);
            try
            {
                // options are optional
                readOptions(parentMsg, jsonMsg);
            }
            on Exception
            {
                // nothing to do
            }
            return parentMsg;
        }
        if (HEOS_RESP_BROWSE_QUEUE == jsonMsg.command)
        {
            final List<String> rangeStr = jsonMsg.getMsgTag("range").split(",");
            if (rangeStr.length == 2 && rangeStr.first == rangeStr.last)
            {
                // ignore get_queue response with equal start and end items: such a message corresponds to TrackInfoMsg
                return null;
            }
            final DcpMediaContainerMsg parentMsg =
                DcpMediaContainerMsg.parent(jsonMsg, BrowseType.PLAY_QUEUE);
            readPlayQueueItems(parentMsg, jsonMsg);
            return parentMsg;
        }
        return null;
    }

    static void readMediaItems(final DcpMediaContainerMsg parentMsg, final DcpHeosMessage jsonMsg)
    {
        final Iterable<JsonPathMatch> payload = jsonMsg.getArray("payload[*]");
        for (int i = 0; i < payload.length; i++)
        {
            final Map<String, dynamic> map = payload.elementAt(i).value as Map<String, dynamic>;
            final DcpMediaContainerMsg itemMsg = DcpMediaContainerMsg.item(map, parentMsg._sid, parentMsg._cid);
            if (itemMsg.isSong())
            {
                itemMsg.setAid("1");
            }
            final XmlListItemMsg xmlItem = XmlListItemMsg.details(
                    i + parentMsg._start,
                    parentMsg._layerInfo == LayerInfo.SERVICE_TOP ? 0 : 1,
                    itemMsg._name,
                    EMPTY, ListItemIcon.UNKNOWN,
                    true, itemMsg);
            if (itemMsg._container)
            {
                xmlItem.setIconType(itemMsg._name == "All" ? "01" :
                    (itemMsg._name == "Browse Folders" ? "99" : "50"));
                xmlItem.setIcon(itemMsg._playable ?
                    ListItemIcon.FOLDER_PLAY : ListItemIcon.FOLDER);
            }
            else
            {
                xmlItem.setIconType("75");
                xmlItem.setIcon(itemMsg._playable ?
                    ListItemIcon.MUSIC : ListItemIcon.UNKNOWN);
            }
            parentMsg._items.add(xmlItem);
        }
    }

    static void readPlayQueueItems(final DcpMediaContainerMsg parentMsg, final DcpHeosMessage jsonMsg)
    {
        final Iterable<JsonPathMatch> payload = jsonMsg.getArray("payload[*]");
        for (int i = 0; i < payload.length; i++)
        {
            final Map<String, dynamic> map = payload.elementAt(i).value as Map<String, dynamic>;
            final DcpMediaContainerMsg itemMsg = DcpMediaContainerMsg.queueItem(map);
            final XmlListItemMsg xmlItem = XmlListItemMsg.details(
                    ISCPMessage.nonNullInteger(itemMsg._qid, 10, i),
                    0,
                    itemMsg._name,
                    EMPTY, ListItemIcon.MUSIC,
                    true, itemMsg);
            xmlItem.setIconType("75");
            parentMsg._items.add(xmlItem);
        }
    }

    static void readOptions(final DcpMediaContainerMsg parentMsg, final DcpHeosMessage jsonMsg)
    {
        final Iterable<JsonPathMatch> options = jsonMsg.getArray("options[*]");
        if (options.isEmpty || !(options.first.value is Map<String, dynamic>))
        {
            return;
        }
        final List<dynamic> browse = (options.first.value as Map<String, dynamic>)["browse"];
        for (int i = 0; i < browse.length; i++)
        {
            final Map<String, dynamic> item = browse.elementAt(i);
            Logging.info(DcpMediaContainerMsg, "item: " + item.toString());
            final int? id = int.tryParse(getElement(item, "id"));
            if (id == null)
            {
                continue;
            }
            final String name = getElement(item, "name");
            if (id == SO_CONTAINER)
            {
                parentMsg._options.add(XmlListItemMsg.details(SO_ADD_ALL, 0, name,
                    EMPTY, ListItemIcon.FOLDER_PLAY, true, null));
                parentMsg._options.add(XmlListItemMsg.details(SO_ADD_AND_PLAY_ALL, 0, name,
                    EMPTY, ListItemIcon.FOLDER_PLAY, true, null));
                parentMsg._options.add(XmlListItemMsg.details(SO_REPLACE_AND_PLAY_ALL, 0, name,
                    EMPTY, ListItemIcon.FOLDER_PLAY, true, null));
            }
            else
            {
                parentMsg._options.add(XmlListItemMsg.details(id, 0, name,
                    EMPTY, ListItemIcon.UNKNOWN, true, null));
            }
        }
    }

    @override
    String? buildDcpMsg(bool isQuery)
    {
        if (_aid.startsWith(HEOS_SET_SERVICE_OPTION))
        {
            switch (_start)
            {
            case SO_ADD_TO_HEOS: // Add station to HEOS Favorites
                return sprintf("heos://browse/set_service_option?sid=%s&option=19&mid=%s&name=%s",
                        [ _parentSid, _mid, _name ]);
            case SO_REMOVE_FROM_HEOS: // Remove from HEOS Favorites
                return sprintf("heos://browse/set_service_option?option=20&mid=%s",
                        [ _mid ]);
            case SO_ADD_AND_PLAY_ALL: // Add and play
                return sprintf("heos://browse/add_to_queue?pid=%s&sid=%s&cid=%s&aid=1",
                        [ ISCPMessage.DCP_HEOS_PID, _parentSid, _parentCid ]);
            case SO_ADD_ALL: // Add
                return sprintf("heos://browse/add_to_queue?pid=%s&sid=%s&cid=%s&aid=3",
                        [ ISCPMessage.DCP_HEOS_PID, _parentSid, _parentCid ]);
            case SO_REPLACE_AND_PLAY_ALL: // Replace and play
                return sprintf("heos://browse/add_to_queue?pid=%s&sid=%s&cid=%s&aid=4",
                        [ ISCPMessage.DCP_HEOS_PID, _parentSid, _parentCid ]);
            }
        }
        else if (_container)
        {
            if (_playable && _parentSid.isNotEmpty && _cid.isNotEmpty && _aid.isNotEmpty)
            {
                return sprintf("heos://browse/add_to_queue?pid=%s&sid=%s&cid=%s&aid=%s",
                        [ ISCPMessage.DCP_HEOS_PID, _parentSid, _cid, _aid ]);
            }
            if (_parentSid.isNotEmpty && _cid.isNotEmpty)
            {
                return sprintf("heos://browse/browse?sid=%s&cid=%s&range=%d,9999",
                        [ _parentSid, _cid, _start ]);
            }
        }
        else
        {
            if (!_playable)
            {
                if (_browseType == BrowseType.PLAY_QUEUE)
                {
                    return sprintf("heos://player/get_queue?pid=%s&range=%d,9999",
                            [ ISCPMessage.DCP_HEOS_PID, _start ]);
                }
                else if (_browseType == BrowseType.SEARCH_RESULT)
                {
                    return sprintf("heos://browse/search?sid=%s&search=%s&scid=%s&range=%d,9999",
                        [ _sid, _searchStr, _scid, _start]);
                }
                else if (_sid.isNotEmpty)
                {
                    return sprintf("heos://browse/browse?sid=%s",
                            [ _sid ]);
                }
            }
            if (_playable && _mid.isNotEmpty)
            {
                if ("station" == _type && _parentSid.isNotEmpty)
                {
                    if (_parentCid.isNotEmpty)
                    {
                        return sprintf("heos://browse/play_stream?pid=%s&sid=%s&cid=%s&mid=%s",
                                [ ISCPMessage.DCP_HEOS_PID, _parentSid, _parentCid, _mid ]);
                    }
                    else
                    {
                        return sprintf("heos://browse/play_stream?pid=%s&sid=%s&mid=%s",
                                [ ISCPMessage.DCP_HEOS_PID, _parentSid, _mid ]);
                    }
                }
                if (isSong() && _parentSid.isNotEmpty)
                {
                    if (_parentCid.isNotEmpty)
                    {
                        return sprintf("heos://browse/add_to_queue?pid=%s&sid=%s&cid=%s&mid=%s&aid=%s",
                            [ ISCPMessage.DCP_HEOS_PID, _parentSid, _parentCid, _mid, _aid ]);
                    }
                    else
                    {
                        return sprintf("heos://browse/add_to_queue?pid=%s&sid=%s&mid=%s&aid=%s",
                            [ ISCPMessage.DCP_HEOS_PID, _parentSid, _mid, _aid ]);
                    }
                }
            }
            if (_playable && _browseType == BrowseType.PLAYQUEUE_ITEM && _qid.isNotEmpty)
            {
                return sprintf("heos://player/play_queue?pid=%s&qid=%s",
                        [ ISCPMessage.DCP_HEOS_PID, _qid ]);
            }
        }
        return null;
    }

    static String getElement(Map<String, dynamic> payload, String name)
    {
        final Object? obj = payload[name];
        if (obj != null)
        {
            if (obj is int || obj is String)
            {
                return obj.toString();
            }
            Logging.info(payload, "DCP HEOS error: Cannot read element " + name + ": object type unknown: " + obj.toString());
        }
        return EMPTY;
    }

    static String getNameElement(final String name)
    {
        return name.replaceAll("%26", "&")
                .replaceAll("%3D", "=")
                .replaceAll("%25", "%");
    }
}
