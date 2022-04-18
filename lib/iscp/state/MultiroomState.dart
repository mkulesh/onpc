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
import "../ConnectionIf.dart";
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

    DeviceInfo(this.responseMsg, this._favorite, this._responses)
    {
        _friendlyName = null;
        groupMsg = null;
        _channelType = MultiroomZone.ChannelTypeEnum.defValue;
    }

    DeviceInfo.fromDevice(this.responseMsg, this._favorite, this._responses, DeviceInfo di)
    {
        _friendlyName = di._friendlyName;
        groupMsg = di.groupMsg;
        _channelType = di._channelType;
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

    int get responses
    => _responses;

    bool get isFavorite
    => _favorite;

    String getHostAndPort()
    => responseMsg.getHostAndPort;

    String getDeviceName(bool useFriendlyName)
    {
        if (isFavorite && responseMsg.alias != null)
        {
            return responseMsg.alias;
        }
        final String name = (useFriendlyName) ? _friendlyName : null;
        return (name != null) ? name : responseMsg.getDescription();
    }

    EnumItem<ChannelType> getChannelType(int zone)
    => _channelType.key != MultiroomZone.ChannelTypeEnum.defValue.key ? _channelType :
        (groupMsg != null ? groupMsg.getChannelType(zone) : MultiroomZone.ChannelTypeEnum.defValue);

    bool get isMasterDevice
    {
        final EnumItem<RoleType> roleType = groupMsg.getRole(MultiroomDeviceInformationMsg.DEFAULT_ZONE);
        return roleType.key == RoleType.SRC;
    }
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

    void clear()
    {
        _deviceList.removeWhere((key,d) => !d.isFavorite);
    }

    List<BroadcastResponseMsg> _favorites;

    set favorites(List<BroadcastResponseMsg> value)
    {
        _favorites = value;
        updateFavorites();
    }

    static const List<String> MESSAGE_SCOPE = [
        FriendlyNameMsg.CODE,
        MultiroomDeviceInformationMsg.CODE,
        MultiroomChannelSettingMsg.CODE
    ];

    List<String> getQueries(ConnectionIf connection)
    {
        Logging.info(this, "Requesting data for connection " + connection.getHostAndPort + "...");
        return MESSAGE_SCOPE;
    }

    // Update logic
    String _isChange(String type, bool change)
    => change ? type : null;

    String process(ISCPMessage msg)
    {
        if (!MESSAGE_SCOPE.contains(msg.getCode))
        {
            return null;
        }

        final DeviceInfo di = _deviceList.values.firstWhere((t)
            => t.getHostAndPort() == msg.getHostAndPort, orElse: () => null);
        if (di == null)
        {
            Logging.info(this, "<< warning: received " + msg.getCode + " from "
                + msg.getHostAndPort + " for unknown device. Ignored.");
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
        final String id = msg.getHostAndPort;
        DeviceInfo deviceInfo = _deviceList[id];
        if (deviceInfo == null)
        {
            deviceInfo = DeviceInfo(msg, false, 1);
            _deviceList[id] = deviceInfo;
        }
        else
        {
            deviceInfo._responses++;
        }
        // process message change upon the first response on discovered or favorite device
        return deviceInfo._responses == 1;
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
        int okDevice = 0;
        for (DeviceInfo di in _deviceList.values)
        {
            if ((di.isFavorite && di._responses == 0) || di._responses >= MAX_DEVICE_RESPONSE_NUMBER)
            {
                okDevice++;
            }
        }
        return (okDevice == _deviceList.length);
    }

    List<DeviceInfo> getSortedDevices()
    {
        final List<DeviceInfo> retValue = [];
        _deviceList.forEach((key, di) => retValue.add(di));
        retValue.sort((a, b) => a.getHostAndPort().compareTo(b.getHostAndPort()));
        return retValue;
    }

    void updateFavorites()
    {
        final Map<String, DeviceInfo> tmpDevices = Map.from(_deviceList);
        _deviceList.removeWhere((key, d) => d.isFavorite);
        _favorites.forEach((msg)
        {
            final String key = msg.getHostAndPort;
            final DeviceInfo oldInfo = tmpDevices[key];
            if (oldInfo == null)
            {
                Logging.info(this, "Add favorite connection " + msg.toString());
                _deviceList[key] = DeviceInfo(msg, true, 0);
            }
            else
            {
                Logging.info(this, "Update favorite connection " + msg.toString());
                _deviceList[key] = DeviceInfo.fromDevice(msg, true, 0, oldInfo);
            }
        });
    }
}