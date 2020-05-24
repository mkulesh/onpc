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

import 'dart:collection';

import "../../utils/Logging.dart";
import "../ISCPMessage.dart";
import "../messages/BroadcastResponseMsg.dart";
import "../messages/EnumParameterMsg.dart";
import "../messages/FriendlyNameMsg.dart";
import "../messages/MultiroomChannelSettingMsg.dart";
import "../messages/MultiroomDeviceInformationMsg.dart";

class DeviceInfo
{
    final BroadcastResponseMsg responseMsg;
    final bool _favorite;
    int _responses;
    String _friendlyName;
    MultiroomDeviceInformationMsg groupMsg;
    EnumItem<ChannelType> _channelType;

    DeviceInfo(this.responseMsg, this._favorite)
    {
        _responses = 1;
        _friendlyName = null;
        groupMsg = null;
        _channelType = MultiroomZone.ChannelTypeEnum.defValue;
    }

    bool processFriendlyName(FriendlyNameMsg msg)
    {
        final bool changed = _friendlyName != msg.getFriendlyName;
        _friendlyName = msg.getFriendlyName;
        return changed;
    }

    bool processMultiroomDeviceInformation(MultiroomDeviceInformationMsg msg)
    {
        groupMsg = msg;
        return true;
    }

    bool processMultiroomChannelSetting(MultiroomChannelSettingMsg msg)
    {
        final bool changed = _channelType.key != msg.channelType.key;
        _channelType = msg.channelType;
        return changed;
    }

    bool get isFavorite
    => _favorite;

    String getId()
    => responseMsg.getDevice;

    String getDeviceName(bool useFriendlyName)
    {
        if (isFavorite && responseMsg.alias != null)
        {
            return responseMsg.alias;
        }
        final String name = (useFriendlyName) ? _friendlyName : null;
        return (name != null) ? name : getId();
    }

    EnumItem<ChannelType> getChannelType(int zone)
    => _channelType.key != MultiroomZone.ChannelTypeEnum.defValue.key ? _channelType :
        (groupMsg != null ? groupMsg.getChannelType(zone) : MultiroomZone.ChannelTypeEnum.defValue);
}

class MultiroomState
{
    // search limit
    static const int MAX_DEVICE_RESPONSE_NUMBER = 5;
    int _searchLimit = MAX_DEVICE_RESPONSE_NUMBER;

    // Multiroom: list of devices
    final Map<String, DeviceInfo> _deviceList = Map();

    Map<String, DeviceInfo> get deviceList
    => _deviceList;

    List<String> getQueries()
    {
        return [
            FriendlyNameMsg.CODE,
            MultiroomDeviceInformationMsg.CODE,
            MultiroomChannelSettingMsg.CODE
        ];
    }

    // Update logic
    String _isChange(String type, bool change)
    => change ? type : null;

    String process(ISCPMessage msg)
    {
        if (!getQueries().contains(msg.getCode))
        {
            return null;
        }

        final DeviceInfo di = _deviceList.values.firstWhere((t)
            => t.responseMsg.sourceHost == msg.sourceHost, orElse: () => null);
        if (di == null)
        {
            Logging.info(this, "<< warning: received " + msg.getCode + " from "
                + msg.sourceHost + " for unknown device. Ignored.");
            return null;
        }

        if (msg is FriendlyNameMsg)
        {
            return _isChange(FriendlyNameMsg.CODE, di.processFriendlyName(msg));
        }
        else if (msg is MultiroomDeviceInformationMsg)
        {
            return _isChange(MultiroomDeviceInformationMsg.CODE, di.processMultiroomDeviceInformation(msg));
        }
        else if (msg is MultiroomChannelSettingMsg)
        {
            return _isChange(MultiroomChannelSettingMsg.CODE, di.processMultiroomChannelSetting(msg));
        }

        return null;
    }

    bool processBroadcastResponse(BroadcastResponseMsg msg)
    {
        final String id = msg.getDevice;
        DeviceInfo deviceInfo = _deviceList[id];
        if (deviceInfo == null)
        {
            deviceInfo = DeviceInfo(msg, false);
            _deviceList[id] = deviceInfo;
            return true;
        }
        else
        {
            deviceInfo._responses++;
        }
        return false;
    }

    void startSearch({bool limited = true})
    {
        _searchLimit = limited ? MAX_DEVICE_RESPONSE_NUMBER : -1;
        _deviceList.clear();
    }

    bool isSearchFinished()
    {
        if (_searchLimit < 0)
        {
            return false;
        }
        for (DeviceInfo di in _deviceList.values)
        {
            if (di._responses < MAX_DEVICE_RESPONSE_NUMBER)
            {
                return false;
            }
        }
        return true;
    }

    List<DeviceInfo> getMultiroomDevices(final List<BroadcastResponseMsg> favoriteConnections, bool ignoreEmptyIdentifier)
    {
        final List<DeviceInfo> retValue = List();
        final Set<String> identifiers = HashSet();
        for (BroadcastResponseMsg msg in favoriteConnections)
        {
            if (ignoreEmptyIdentifier && msg.getIdentifier.isEmpty)
            {
                continue;
            }
            retValue.add(DeviceInfo(msg, true));
            if (msg.getIdentifier.isNotEmpty)
            {
                identifiers.add(msg.getIdentifier);
            }
        }
        for (DeviceInfo di in _deviceList.values)
        {
            if (identifiers.contains(di.responseMsg.getIdentifier))
            {
                continue;
            }
            retValue.add(di);
        }
        return retValue;
    }
}