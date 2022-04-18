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
import "../../utils/Logging.dart";
import "../ISCPMessage.dart";
import "../messages/EnumParameterMsg.dart";
import "../messages/InputSelectorMsg.dart";
import "../messages/ListInfoMsg.dart";
import "../messages/ListTitleInfoMsg.dart";
import "../messages/NetworkServiceMsg.dart";
import "../messages/PresetCommandMsg.dart";
import "../messages/ReceiverInformationMsg.dart";
import "../messages/ServiceType.dart";
import "../messages/XmlListInfoMsg.dart";
import "../messages/XmlListItemMsg.dart";
import "ReceiverInformation.dart";

class MediaListState
{
    // InputSelectorMsg
    EnumItem<InputSelector> _inputType;

    EnumItem<InputSelector> get inputType
    => _inputType;

    // ListTitleInfoMsg
    EnumItem<ServiceType> _serviceType;

    EnumItem<ServiceType> get serviceType
    => _serviceType;

    LayerInfo _layerInfo;

    LayerInfo get layerInfo
    => _layerInfo;

    UIType _uiType;

    String _titleBar;

    String get titleBar
    => _titleBar;

    int _numberOfTitles;

    int get numberOfTitles
    => _numberOfTitles;

    int _numberOfLayers;

    int get numberOfLayers
    => _numberOfLayers;

    int _currentCursorPosition;

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

    MediaListState()
    {
        clear();
    }

    void clear()
    {
        _inputType = InputSelectorMsg.ValueEnum.defValue;
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
        _movedItem = -1;
    }

    bool processInputSelector(InputSelectorMsg msg)
    {
        final bool changed = _inputType.key != msg.getValue.key;
        _inputType = msg.getValue;
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
                _mediaItems.clear();
                networkServices.forEach((s)
                {
                    final EnumItem<ServiceType> service = Services.ServiceTypeEnum.valueByCode(s.getId);
                    if (service.key != ServiceType.UNKNOWN)
                    {
                        _mediaItems.add(NetworkServiceMsg.output(service.key));
                    }
                });
            }
            else // fallback: parse listData from ListInfoMsg
            {
                for (NetworkServiceMsg i in _mediaItems)
                {
                    if (i.getValue.name.toUpperCase() == msg.getListedData.toUpperCase())
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
                msg.getLineInfo, 0, msg.getListedData, "", ListItemIcon.UNKNOWN, true, cmdMessage.getCmdMsg());
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

    bool get isUiTypeValid
    => _uiType != null;

    bool get isListMode
    => _uiType != null && _uiType == UIType.LIST;

    bool get isPlaybackMode
    => _uiType != null && _uiType == UIType.PLAYBACK;

    bool get isMenuMode
    => _uiType != null && [UIType.MENU, UIType.MENU_LIST].contains(_uiType);

    bool get isPopupMode
    => _uiType != null && [UIType.POPUP, UIType.KEYBOARD].contains(_uiType);

    bool get isQueue
    => serviceType.key == ServiceType.PLAYQUEUE;

    bool get isTuneIn
    => serviceType.key == ServiceType.TUNEIN_RADIO;

    bool get isDeezer
    => serviceType.key == ServiceType.DEEZER;

    bool get isAmazonMusic
    => serviceType.key == ServiceType.AMAZON_MUSIC;

    bool get isNetworkServices
    => _serviceType.key == ServiceType.NET;

    bool get isRadioInput
    => _inputType != null &&
        [InputSelector.FM, InputSelector.AM, InputSelector.DAB].contains(_inputType.key);

    bool get isFM
    => _inputType != null && _inputType.key == InputSelector.FM;

    bool get isDAB
    => _inputType != null && _inputType.key == InputSelector.DAB;

    bool get isSimpleInput
    => _inputType != null && _inputType.key != InputSelector.NONE && !_inputType.isMediaList;

    bool get isUsb
    => _serviceType != null &&
        [ServiceType.USB_FRONT, ServiceType.USB_REAR].contains(_serviceType.key);

    bool isTopLayer()
    {
        if (!isPlaybackMode)
        {
            if (isSimpleInput)
            {
                return true;
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

    void fillRadioPresets(int zone, List<Preset> presetList)
    {
        clearItems();
        presetList.forEach((p)
        {
            if ((inputType.key == InputSelector.FM && p.isFm)
                || (inputType.key == InputSelector.AM && p.isAm)
                || (inputType.key == InputSelector.DAB && p.isDab))
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
            if (msg is XmlListItemMsg && msg.getTitle != null && msg.getTitle.isNotEmpty)
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
        for (int i = 1; i < pathItems.length; i++)
        {
            if (pathItems[i] == null || pathItems[i].isEmpty)
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
}