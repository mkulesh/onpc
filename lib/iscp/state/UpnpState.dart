/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2025 by Mikhail Kulesh
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

import '../../utils/Logging.dart';
import '../upnp/Action.dart';
import '../upnp/DeviceDescription.dart';
import '../upnp/ServiceDescription.dart';

class ActionRequest
{
    final Map<String, String> headers;
    final String body;

    const ActionRequest({
        required this.headers,
        required this.body
    });
}

enum DeviceDescriptionHandling
{
    INIT,
    ALLOWED,
    PROCESSED
}

class UpnpState
{
    // State of DeviceDescription`s handling
    DeviceDescriptionHandling _ddHandling = DeviceDescriptionHandling.INIT;

    void allowDeviceDescriptionHandling()
    {
        _ddHandling = DeviceDescriptionHandling.ALLOWED;
        _processDeviceDescription();
    }

    // UPnP device description
    DeviceDescription? _upnpDescription;

    set upnpDescription(DeviceDescription value)
    {
        _upnpDescription = value;
        _processDeviceDescription();
    }

    // AVTransport service
    ServiceDescription? _aVTransport;

    String? aVTransportHost()
    {
        if (_upnpDescription != null && _aVTransport != null)
        {
            return _upnpDescription!.mSearch!.location!.origin.toString() + _aVTransport!.service.controlUrl.toString();
        }
        return null;
    }

    // Seek action
    static final String SEEK_NAME = "Seek";
    Action? _seek;

    Action? get seek
    => _seek;

    UpnpState()
    {
        clear();
    }

    void clear()
    {
        _ddHandling = DeviceDescriptionHandling.INIT;
        _upnpDescription = null;
        _aVTransport = null;
        _seek = null;
    }

    bool _processDeviceDescription()
    {
        if (_upnpDescription == null || _ddHandling != DeviceDescriptionHandling.ALLOWED)
        {
            Logging.info(this, "Processing UPnP device description skipped: " + _ddHandling.toString());
            return false;
        }
        _ddHandling = DeviceDescriptionHandling.PROCESSED;
        Logging.info(this, "Processing UPnP device description: " + _upnpDescription.toString());
        ServiceDescription.requestService(_upnpDescription, "AVTransport").then((ServiceDescription? s)
        {
            if (s != null)
            {
                Logging.info(this, "new service description: " + s.toString());
                _aVTransport = s;
                _seek = s.action(SEEK_NAME);
                if (_seek != null)
                {
                    Logging.info(this, _seek!.name + " action available");
                }
            }
        });
        return true;
    }
}