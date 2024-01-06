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

import "../../constants/Strings.dart";
import "../../utils/Logging.dart";
import "../../utils/Pair.dart";
import "../ConnectionIf.dart";
import "../ISCPMessage.dart";
import "../messages/DcpMediaContainerMsg.dart";
import "../messages/DcpMediaItemMsg.dart";
import "../messages/DcpSearchCriteriaMsg.dart";
import "../messages/DcpTunerModeMsg.dart";
import "../messages/EnumParameterMsg.dart";
import "../messages/InputSelectorMsg.dart";
import "../messages/ListInfoMsg.dart";
import "../messages/ListTitleInfoMsg.dart";
import "../messages/NetworkServiceMsg.dart";
import "../messages/OperationCommandMsg.dart";
import "../messages/PresetCommandMsg.dart";
import "../messages/ReceiverInformationMsg.dart";
import "../messages/ServiceType.dart";
import "../messages/XmlListInfoMsg.dart";
import "../messages/XmlListItemMsg.dart";
import "PlaybackState.dart";
import "ReceiverInformation.dart";

class MediaListState
{
    // InputSelectorMsg
    EnumItem<InputSelector> _inputType = InputSelectorMsg.ValueEnum.defValue;

    EnumItem<InputSelector> get inputType
    => _inputType;

    // DCP tuner mode
    EnumItem<DcpTunerMode> _dcpTunerMode = DcpTunerModeMsg.ValueEnum.defValue;

    EnumItem<DcpTunerMode> get dcpTunerMode
    => _dcpTunerMode;

    // ListTitleInfoMsg
    late EnumItem<ServiceType> _serviceType = Services.ServiceTypeEnum.defValue;

    EnumItem<ServiceType> get serviceType
    => _serviceType;

    LayerInfo? _layerInfo;

    LayerInfo? get layerInfo
    => _layerInfo;

    UIType? _uiType;

    late String _titleBar;

    String get titleBar
    => _titleBar;

    late int _numberOfTitles;

    int get numberOfTitles
    => _numberOfTitles;

    late int _numberOfLayers;

    int get numberOfLayers
    => _numberOfLayers;

    late int _currentCursorPosition;

    int get currentCursorPosition
    => _currentCursorPosition;

    // Media list
    final List<ISCPMessage> _mediaItems = [];

    List<ISCPMessage> get mediaItems
    => _mediaItems;

    int _movedItem = -1;
    int get movedItem
    => _movedItem;

    bool get isMediaEmpty
    => _mediaItems.isEmpty;

    int get numberOfItems
    => _mediaItems.length;

    int _pathIndexOffset = 0;
    final List<String> _pathItems = [];

    List<String> get pathItems
    => _pathItems;

    final List<String> listInfoItems = [];

    // Total target number of media items, when media list is
    // downloaded in several steps like for huge Denon media lists
    int _mediaItemsTotal = -1;

    int get mediaItemsTotal
    => _mediaItemsTotal;

    // Denon control protocol
    final List<DcpMediaContainerMsg> _dcpMediaPath = [];

    List<DcpMediaContainerMsg> get dcpMediaPath
    => _dcpMediaPath;

    final Map<String, List<Pair<String, int>>> _dcpSearchCriteria = Map();

    String _mediaListSid = "";

    String get mediaListSid
    => _mediaListSid;

    String _mediaListCid = "";

    String get mediaListCid
    => _mediaListCid;

    String _mediaListMid = "";
    final List<XmlListItemMsg> _dcpTrackMenuItems = [];

    MediaListState()
    {
        clear();
    }

    void clear()
    {
        _inputType = InputSelectorMsg.ValueEnum.defValue;
        _dcpTunerMode = DcpTunerModeMsg.ValueEnum.defValue;
        _serviceType = Services.ServiceTypeEnum.defValue;
        _layerInfo = null;
        _uiType = null;
        _titleBar = "";
        _numberOfLayers = 0;
        _numberOfTitles = 0;
        _currentCursorPosition = 0;
        _pathItems.clear();
        _pathIndexOffset = 0;
        clearItems();
    }

    void clearItems({bool skipForRadio = false})
    {
        if (skipForRadio && isRadioInput)
        {
            return;
        }
        _mediaItems.clear();
        _mediaItemsTotal = -1;
        _movedItem = -1;
    }

    bool processInputSelector(InputSelectorMsg msg)
    {
        final bool changed = _inputType.key != msg.getValue.key;
        _inputType = msg.getValue as EnumItem<InputSelector>;
        if (isSimpleInput)
        {
            _serviceType = Services.ServiceTypeEnum.defValue;
            clearItems();
        }
        return changed;
    }

    bool processListTitleInfo(ListTitleInfoMsg msg)
    {
        bool changed = false;
        if (_serviceType.key != msg.getServiceType.key)
        {
            _serviceType = msg.getServiceType;
            clearItems();
            changed = true;
        }
        if (_layerInfo != msg.getLayerInfo.key)
        {
            _layerInfo = msg.getLayerInfo.key;
            changed = true;
        }
        if (_uiType != msg.getUiType.key)
        {
            _uiType = msg.getUiType.key;
            // skip deletion of items since there can be invalid NLT messages in radio mode upon app startup
            clearItems(skipForRadio: true);
            changed = true;
        }
        if (_titleBar != msg.getTitleBar)
        {
            _titleBar = msg.getTitleBar;
            changed = true;
        }
        if (_numberOfLayers != msg.getNumberOfLayers)
        {
            _numberOfLayers = msg.getNumberOfLayers;
            changed = true;
        }
        if (_numberOfTitles != msg.getNumberOfItems)
        {
            _numberOfTitles = msg.getNumberOfItems;
            changed = true;
        }
        if (_currentCursorPosition != msg.getCurrentCursorPosition)
        {
            _currentCursorPosition = msg.getCurrentCursorPosition;
            changed = true;
        }
        // Update path items
        if (_layerInfo != LayerInfo.UNDER_2ND_LAYER)
        {
            _pathItems.clear();
            _pathIndexOffset = _numberOfLayers;
        }
        // Issue #233: For some receivers like TX-8130, the LAYERS value for the top of service is 0 instead 1.
        // Therefore, we shift it by one in this case
        final int pathIndex = _numberOfLayers + 1 - _pathIndexOffset;
        for (int i = _pathItems.length; i < pathIndex; i++)
        {
            _pathItems.add("");
        }
        if (_uiType != UIType.PLAYBACK)
        {
            if (pathIndex > 0)
            {
                _pathItems[pathIndex - 1] = _titleBar;
                while (_pathItems.length > pathIndex)
                {
                    _pathItems.removeLast();
                }
            }
            Logging.info(this, "media list path = " + _pathItems.toString() + "(offset = " + _pathIndexOffset.toString() + ")");
        }
        return changed;
    }

    bool processXmlListInfo(XmlListInfoMsg msg)
    {
        if (isSimpleInput)
        {
            clearItems();
            Logging.info(msg, "skipped: input channel " + inputType.toString() + " is not a media list");
            return true;
        }
        if (isPopupMode)
        {
            clearItems();
            Logging.info(msg, "skipped: it is a POPUP message");
            return true;
        }
        try
        {
            clearItems();
            msg.parseXml(_mediaItems, _numberOfLayers);
            return true;
        }
        on Exception catch (e)
        {
            clearItems();
            Logging.info(msg, "Can not parse XML: " + e.toString());
        }
        return false;
    }

    bool processListInfo(ListInfoMsg msg, final ReceiverInformation ri)
    {
        if (!ri.isOn)
        {
            // Some receivers send this message before receiver information and power status.
            // In such cases, just ignore it
            return false;
        }
        final List<NetworkService> networkServices = ri.networkServices;
        if (msg.getInformationType.key == InformationType.CURSOR)
        {
            // #167: if receiver does not support XML, clear list items here
            if (!ri.isReceiverInformation && msg.getUpdateType.key == UpdateType.PAGE)
            {
                // only clear if cursor is not changed (updateType is PAGE)
                clearItems();
            }
            listInfoItems.clear();
            return false;
        }
        if (isNetworkServices && isTopLayer())
        {
            // Since the names in ListInfoMsg and ReceiverInformationMsg are
            // not consistent for some services (see https://github.com/mkulesh/onpc/issues/35)
            // we just clone here networkServices provided by ReceiverInformationMsg
            // into serviceItems list by any NET ListInfoMsg (if ReceiverInformationMsg exists)
            if (networkServices.isNotEmpty)
            {
                _createServiceItems(networkServices);
            }
            else // fallback: parse listData from ListInfoMsg
            {
                for (ISCPMessage i in _mediaItems)
                {
                    if (i is NetworkServiceMsg &&
                        i.getValue.name != null &&
                        i.getValue.name!.toUpperCase() == msg.getListedData.toUpperCase())
                    {
                        return false;
                    }
                }
                final NetworkServiceMsg nsMsg = NetworkServiceMsg.fromName(msg.getListedData);
                if (nsMsg.getValue.key != ServiceType.UNKNOWN)
                {
                    _mediaItems.add(nsMsg);
                }
            }
            return _mediaItems.isNotEmpty;
        }
        else if (isMenuMode || !ri.isReceiverInformation)
        {
            if (_mediaItems.any((i) => (i is XmlListItemMsg && i.getTitle.toUpperCase() == msg.getListedData.toUpperCase())))
            {
                return false;
            }
            // ListInfoMsg is used as an alternative command in this case, but the item is stored as XmlListItemMsg
            final ListInfoMsg cmdMessage = ListInfoMsg.output(msg.getLineInfo, msg.getListedData);
            final XmlListItemMsg nsMsg = XmlListItemMsg.details(
                msg.getLineInfo, 0, msg.getListedData, "", ListItemIcon.UNKNOWN, true, cmdMessage);
            if (nsMsg.getMessageId < _mediaItems.length)
            {
                _mediaItems[nsMsg.getMessageId] = nsMsg;
            }
            else
            {
                _mediaItems.add(nsMsg);
            }
            return true;
        }
        else if (isUsb)
        {
            final String name = msg.getListedData;
            if (!listInfoItems.contains(name))
            {
                listInfoItems.add(name);
            }
            return false;
        }
        return false;
    }

    void _createServiceItems(final List<NetworkService> networkServices)
    {
        _mediaItems.clear();
        _mediaItemsTotal = -1;
        networkServices.forEach((s)
        {
            final EnumItem<ServiceType> service = Services.ServiceTypeEnum.valueByCode(s.getId);
            if (service.key != ServiceType.UNKNOWN)
            {
                _mediaItems.add(NetworkServiceMsg.output(service.key));
            }
        });
    }

    bool get isUiTypeValid
    => _uiType != null;

    bool get isListMode
    => _uiType != null && _uiType == UIType.LIST;

    bool get isPlaybackMode
    => _uiType != null && _uiType == UIType.PLAYBACK;

    bool get isMenuMode
    => _uiType != null && !isSimpleInput && [UIType.MENU, UIType.MENU_LIST].contains(_uiType);

    bool get isPopupMode
    => _uiType != null && [UIType.POPUP, UIType.KEYBOARD].contains(_uiType);

    bool get isQueue
    => [ServiceType.PLAYQUEUE, ServiceType.DCP_PLAYQUEUE].contains(serviceType.key);

    bool get isTuneIn
    => serviceType.key == ServiceType.TUNEIN_RADIO;

    bool get isDeezer
    => serviceType.key == ServiceType.DEEZER;

    bool get isAmazonMusic
    => serviceType.key == ServiceType.AMAZON_MUSIC;

    bool get isSpotify
    => serviceType.key == ServiceType.AMAZON_MUSIC;

    bool get isNetworkServices
    => _serviceType.key == ServiceType.NET;

    bool get isRadioInput
    => isFM || isDAB || _inputType.key == InputSelector.AM;

    bool get isFM
    => _inputType.key == InputSelector.FM ||
       (_inputType.key == InputSelector.DCP_TUNER &&
           _dcpTunerMode.key == DcpTunerMode.FM);

    bool get isDAB
    => _inputType.key == InputSelector.DAB ||
        (_inputType.key == InputSelector.DCP_TUNER &&
            _dcpTunerMode.key == DcpTunerMode.DAB);

    bool get isSimpleInput
    => _inputType.key != InputSelector.NONE && !_inputType.isMediaList;

    bool get isUsb
    => [ServiceType.USB_FRONT, ServiceType.USB_REAR].contains(_serviceType.key);

    bool isTopLayer()
    {
        if (isSimpleInput)
        {
            return true;
        }
        if (!isPlaybackMode)
        {
            if (_inputType.key == InputSelector.DCP_NET)
            {
                return _layerInfo == LayerInfo.NET_TOP;
            }
            if (_serviceType.key == ServiceType.NET && _layerInfo == LayerInfo.NET_TOP)
            {
                return true;
            }
            if (_layerInfo == LayerInfo.SERVICE_TOP)
            {
                return isUsb || _serviceType.key == ServiceType.UNKNOWN;
            }
        }
        return false;
    }

    bool listInfoNotConsistent()
    {
        if (_numberOfTitles == 0 || _numberOfLayers == 0 || listInfoItems.isEmpty)
        {
            return false;
        }
        for (String s in listInfoItems)
        {
            if (mediaItems.any((i) => i is XmlListItemMsg && i.getTitle.toUpperCase() == s.toUpperCase()))
            {
                return false;
            }
        }
        return true;
    }

    void fillRadioPresets(int zone, ProtoType protoType, List<Preset> presetList)
    {
        clearItems();
        if (protoType == ProtoType.DCP)
        {
            _mediaItems.add(DcpTunerModeMsg.output(DcpTunerMode.FM));
            _mediaItems.add(DcpTunerModeMsg.output(DcpTunerMode.DAB));
        }
        presetList.forEach((p)
        {
            if ((isFM && p.isFm)
                || (isDAB && p.isDab)
                || (inputType.key == InputSelector.AM && p.isAm))
            {
                _mediaItems.add(PresetCommandMsg.outputCfg(zone, p));
            }
        });
        Logging.info(this, "Filling presets list. Items: " + numberOfItems.toString());
    }

    void popFront(int i)
    {
        if (i <= 0)
        {
            return;
        }
        if (i < mediaItems.length)
        {
            mediaItems.removeRange(0, i);
        }
        else
        {
            mediaItems.clear();
        }
    }

    List<ISCPMessage> retrieveMenu()
    {
        final List<ISCPMessage> retValue = [];
        _mediaItems.forEach((msg)
        {
            if (msg is XmlListItemMsg && msg.getTitle.isNotEmpty)
            {
                retValue.add(msg);
            }
        });
        return retValue;
    }

    void clearMenu()
    {
        if (isMenuMode)
        {
            clearItems();
        }
    }

    bool isPathItemsConsistent()
    {
        if (isRadioInput)
        {
            return true;
        }
        for (int i = 1; i < pathItems.length; i++)
        {
            if (pathItems[i].isEmpty)
            {
                return false;
            }
        }
        return true;
    }

    void reorderMediaItems(int oldId, int newId)
    {
        int oldIndex = -1;
        int newIndex = -1;
        for (int i = 0; i < _mediaItems.length; i++)
        {
            if (_mediaItems[i].getMessageId == oldId)
            {
                oldIndex = i;
            }
            if (_mediaItems[i].getMessageId == newId)
            {
                newIndex = i;
            }
        }
        if (oldIndex >= 0 && newIndex >=0 && oldIndex != newIndex)
        {
            final ISCPMessage old = _mediaItems.removeAt(oldIndex);
            _mediaItems.insert(newIndex, old);
            _movedItem = old.getMessageId;
        }
    }

    /*
     * Denon control protocol
     */
    bool processDcpTunerModeMsg(DcpTunerModeMsg msg)
    {
        final bool changed = _dcpTunerMode.key != msg.getValue.key;
        _dcpTunerMode = msg.getValue;
        return changed;
    }

    bool processDcpMediaContainerMsg(DcpMediaContainerMsg msg)
    {
        // Media items
        if (msg.getStart() == 0)
        {
            clearItems();
            // Media path
            final List<DcpMediaContainerMsg> tmpPath = [];
            for (DcpMediaContainerMsg pe in _dcpMediaPath)
            {
                if (pe.keyEqual(msg))
                {
                    break;
                }
                tmpPath.add(pe);
            }
            tmpPath.add(DcpMediaContainerMsg.copy(msg));
            _dcpMediaPath.clear();
            _dcpMediaPath.addAll(tmpPath);
            Logging.info(this, "Dcp media path: " + _dcpMediaPath.toString());
            // Info
            _serviceType = msg.getServiceType();
            _layerInfo = msg.getLayerInfo();
            _uiType = UIType.LIST;
            _numberOfLayers = _dcpMediaPath.length;
            _mediaListSid = msg.getSid();
            _mediaListCid = msg.getCid();
            _mediaItemsTotal = msg.getCount();
            if (_layerInfo == LayerInfo.SERVICE_TOP && _serviceType.key != ServiceType.UNKNOWN)
            {
                _titleBar = _serviceType.description;
            }
            else if (msg.getBrowseType() == BrowseType.SEARCH_RESULT && msg.getSearchStr().isNotEmpty)
            {
                _titleBar = Strings.medialist_search + ": " + msg.getSearchStr();
            }
            else if (_dcpMediaPath.isNotEmpty && _dcpMediaPath.length >= 2)
            {
                _titleBar = _dcpMediaPath[_dcpMediaPath.length - 2].getItems().first.getTitle;
            }
            else
            {
                _titleBar = "";
            }
        }
        else if (msg.getCid() != _mediaListCid)
        {
            return false;
        }
        _mediaItems.removeWhere((e) => isReturnMsg(e));
        _mediaItems.addAll(msg.getItems());
        _mediaItems.sort((ISCPMessage lhs, ISCPMessage rhs)
        {
            int val = 0;
            if (lhs is XmlListItemMsg && rhs is XmlListItemMsg)
            {
                val = lhs.iconType.compareTo(rhs.iconType);
                if (val == 0)
                {
                    return lhs.isSong() && rhs.isSong() ?
                        lhs.getMessageId.compareTo(rhs.getMessageId) :
                        lhs.getTitle.compareTo(rhs.getTitle);
                }
            }
            return val;
        });
        _setDcpPlayingItem();

        // Track menu
        _dcpTrackMenuItems.clear();
        _dcpTrackMenuItems.addAll(msg.getOptions());
        for (XmlListItemMsg m in _dcpTrackMenuItems)
        {
            Logging.info(this, "DCP menu: " + m.toString());
        }
        return true;
    }

    bool processDcpMediaItemMsg(DcpMediaItemMsg msg, PlaybackState ps)
    {
        final EnumItem<ServiceType> si = msg.getServiceType();
        final bool changed = msg.getData != _mediaListMid || si != ps.serviceIcon;
        _mediaListMid = msg.getData;
        ps.serviceIcon = si;
        if (changed)
        {
            _setDcpPlayingItem();
        }
        return changed;
    }

    bool processDcpSearchCriteriaMsg(DcpSearchCriteriaMsg msg)
    {
        _dcpSearchCriteria[msg.sid] = msg.criteria;
        Logging.info(this, "DCP search criteria:" + _dcpSearchCriteria.toString());
        return true;
    }

    List<Pair<String, int>> getDcpSearchCriteria()
    {
        if (inputType.key == InputSelector.DCP_NET)
        {
            final List<Pair<String, int>>? list = _dcpSearchCriteria[_mediaListSid];
            return list == null ? [] : list;
        }
        return [];
    }

    void storeSelectedDcpItem(XmlListItemMsg rowMsg)
    {
        if (_dcpMediaPath.isNotEmpty)
        {
            final DcpMediaContainerMsg last = _dcpMediaPath.last;
            last.getItems().clear();
            last.getItems().add(rowMsg);
            Logging.info(this, "Stored selected DCP item: " + rowMsg.toString() + " in container " + last.toString());
        }
    }

    DcpMediaContainerMsg? getDcpContainerMsg(final ISCPMessage msg, {bool allowContainerMsg = true})
    {
        if (msg is XmlListItemMsg && msg.getCmdMessage != null && msg.getCmdMessage is DcpMediaContainerMsg)
        {
            return msg.getCmdMessage as DcpMediaContainerMsg;
        }
        return (allowContainerMsg && msg is DcpMediaContainerMsg) ? msg : null;
    }

    void setDcpNetTopLayer(final ReceiverInformation ri)
    {
        Logging.info(this, "DCP: Set network top layer for " + ri.networkServices.length.toString() + " services");
        _serviceType = Services.ServiceTypeEnum.valueByKey(ServiceType.NET);
        _layerInfo = LayerInfo.NET_TOP;
        _uiType = UIType.LIST;
        _numberOfLayers = 0;
        _mediaListSid = "";
        _mediaListCid = "";
        _dcpMediaPath.clear();
        _titleBar = "";
        _createServiceItems(ri.networkServices);
    }

    List<XmlListItemMsg> cloneDcpTrackMenuItems(final DcpMediaContainerMsg? dcpItem)
    {
        final List<XmlListItemMsg> retValue = List.from(_dcpTrackMenuItems);
        if (dcpItem != null)
        {
            for (XmlListItemMsg msg in retValue)
            {
                final DcpMediaContainerMsg newItem = DcpMediaContainerMsg.copy(dcpItem);
                newItem.setAid(DcpMediaContainerMsg.HEOS_SET_SERVICE_OPTION);
                newItem.setStart(msg.getMessageId);
                msg.setCmdMessage(newItem);
            }
        }
        return retValue;
    }

    void _setDcpPlayingItem()
    {
        for (ISCPMessage msg in _mediaItems)
        {
            if (msg is XmlListItemMsg && msg.getCmdMessage is DcpMediaContainerMsg)
            {
                final DcpMediaContainerMsg mc = msg.getCmdMessage as DcpMediaContainerMsg;
                if (mc.getType() == "heos_server")
                {
                    msg.setIcon(ListItemIcon.HEOS_SERVER);
                }
                else if (!mc.isContainer() && mc.isPlayable() && _mediaListMid.isNotEmpty)
                {
                    msg.setIcon(_mediaListMid == mc.getMid() ?
                    ListItemIcon.PLAY : ListItemIcon.MUSIC);
                }
            }
        }
    }

    ISCPMessage getReturnMessage(ProtoType protoType)
    {
        if (protoType == ProtoType.DCP && _dcpMediaPath.length > 1)
        {
            return _dcpMediaPath[_dcpMediaPath.length - 2];
        }
        return OperationCommandMsg.output(ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE, OperationCommand.RETURN);
    }

    bool isReturnMsg(ISCPMessage msg)
    => (msg is OperationCommandMsg || msg is DcpMediaContainerMsg);
}