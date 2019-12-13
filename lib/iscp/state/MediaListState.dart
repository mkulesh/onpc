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

    // Media list
    final List<ISCPMessage> _mediaItems = List<ISCPMessage>();

    List<ISCPMessage> get mediaItems
    => _mediaItems;

    bool get isMediaEmpty
    => _mediaItems.isEmpty;

    int get numberOfItems
    => _mediaItems.length;

    final List<String> listInfoItems = List<String>();

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
        clearItems();
    }

    void clearItems()
    {
        _mediaItems.clear();
    }

    bool processInputSelector(InputSelectorMsg msg)
    {
        final bool changed = _inputType.key != msg.getValue.key;
        _inputType = msg.getValue;
        if (!_inputType.isMediaList)
        {
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
            clearItems();
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
        return changed;
    }

    bool processXmlListInfo(XmlListInfoMsg msg)
    {
        if (!_inputType.isMediaList)
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

    bool processListInfo(ListInfoMsg msg, final List<NetworkService> networkServices)
    {
        if (msg.getInformationType.key == InformationType.CURSOR)
        {
            listInfoItems.clear();
            return false;
        }
        if (isNetworkServices)
        {
            // Since the names in ListInfoMsg and ReceiverInformationMsg are
            // not consistent for some services (see https://github.com/mkulesh/onpc/issues/35)
            // we just clone here networkServices provided by ReceiverInformationMsg
            // into serviceItems list by any NET ListInfoMsg
            _mediaItems.clear();
            networkServices.forEach((s)
            {
                final EnumItem<ServiceType> service = Services.ServiceTypeEnum.valueByCode(s.getId);
                if (service.key != ServiceType.UNKNOWN)
                {
                    _mediaItems.add(NetworkServiceMsg.output(service.key));
                }
            });
            return _mediaItems.isNotEmpty;
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
        else if (isMenuMode)
        {
            if (_mediaItems.any((i)
            => (i is XmlListItemMsg && i.getTitle.toUpperCase() == msg.getListedData.toUpperCase())))
            {
                return false;
            }
            _mediaItems.add(XmlListItemMsg.details(msg.getLineInfo, 0, msg.getListedData, ListItemIcon.UNKNOWN, true));
            return true;
        }
        return false;
    }

    bool get isPlaybackMode
    => _uiType != null && _uiType == UIType.PLAYBACK;

    bool get isMenuMode
    => _uiType != null && _uiType == UIType.MENU;

    bool get isPopupMode
    => _uiType != null && _uiType == UIType.POPUP;

    bool get isQueue
    => serviceType.key == ServiceType.PLAYQUEUE;

    bool get isTuneIn
    => serviceType.key == ServiceType.TUNEIN_RADIO;

    bool get isNetworkServices
    => _serviceType.key == ServiceType.NET;

    bool get isRadioInput
    => _inputType != null &&
        [InputSelector.FM, InputSelector.AM, InputSelector.DAB].contains(_inputType.key);

    bool get isSimpleInput
    => _inputType != null &&
        (isRadioInput || [InputSelector.TAPE1, InputSelector.TV].contains(_inputType.key));

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
}