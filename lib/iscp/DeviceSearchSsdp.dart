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

import 'dart:async';
import "dart:convert";
import "dart:io";

import "../utils/Logging.dart";
import "../utils/Pair.dart";
import "../utils/Platform.dart";
import "ConnectionIf.dart";
import "DeviceSearch.dart";
import "messages/BroadcastResponseMsg.dart";
import "upnp/DeviceDescription.dart";
import "upnp/MSearch.dart";

// Search using Simple Service Discovery Protocol
class DeviceSearchSsdp implements SearchEngineIf
{
    // Multicast address for Simple Service Discovery Protocol
    final String V4_MULTICAST = "239.255.255.250";
    // UPnP SSDP port for Simple Service Discovery Protocol
    final int SSDP_PORT = 1900;

    final int _id;
    final OnDeviceFound onDeviceFound;
    final OnRequest onRequest;

    RawDatagramSocket? _socket;
    int _requestCount = 0;
    final Map<String, Pair<MSearch, DeviceDescription?>> _responses = {};
    final Set<String> _lastMSearch = {};

    DeviceSearchSsdp(this._id, this.onDeviceFound, this.onRequest);

    @override
    int get id
    => _id;

    @override
    void start(int retryDelay)
    {
        Logging.info(this, "Starting. Retry delay = " + retryDelay.toString() + "s.");
        _requestCount = 0;
        RawDatagramSocket.bind(
            InternetAddress.anyIPv4,
            // Note: On iOS, HEOS and Spotify apps block the SSDP_PORT. As workaround, use any other port for iOS.
            Platform.isIOS? DCP_WEB_GUI : SSDP_PORT,
            reuseAddress: true,
            reusePort: !(Platform.isAndroid || Platform.isWindows)).then((RawDatagramSocket sock)
        {
            _socket = sock;
            _socket!.broadcastEnabled = true;
            _socket!.multicastLoopback = false;
            try
            {
                _socket!.joinMulticast(InternetAddress.anyIPv4);
            }
            on Exception
            {
                Logging.info(this, "Socket failed to join multicast group. So long as a single socket joins, this is not a critical error.");
            }
            _socket!.listen(_onData,
                onError: _onError,
                onDone: _onDone,
                cancelOnError: false);

            Timer.periodic(Duration(seconds: retryDelay), (Timer t)
            {
                if (_socket != null)
                {
                    _requestMSearch();
                    _requestCount++;
                    onRequest(id, _requestCount);
                }
                else
                {
                    t.cancel();
                }
            });
        }).catchError((dynamic e)
        {
            _onError(e);
        });
    }

    @override
    void stop()
    {
        if (_socket != null)
        {
            try
            {
                _socket!.leaveMulticast(InternetAddress.anyIPv4);
            }
            on Exception
            {
                Logging.info(this, "Socket failed to leave multicast group.");
            }
            _socket!.close();
        }
    }

    @override
    bool get isStopped
    => _socket == null;

    void _requestMSearch()
    {
        if (_socket != null)
        {
            final InternetAddress target = InternetAddress(V4_MULTICAST);
            _socket!.send(MSearch.request(V4_MULTICAST, SSDP_PORT).encode(), target, SSDP_PORT);
            _lastMSearch.clear();
            Logging.info(this, "send M-SEARCH to " + target.toString());
        }
    }

    void _onData(RawSocketEvent e)
    {
        if (_socket == null)
        {
            return;
        }

        final Datagram? d = _socket!.receive();
        if (d == null)
        {
            return;
        }

        final String data = utf8.decode(d.data);
        try
        {
            final MSearch m = MSearch.response(data);
            if (m.location == null)
            {
                return;
            }
            final String url = m.location.toString();
            if (_lastMSearch.contains(url))
            {
                // ignore multiply answers from the same receiver
                return;
            }
            _lastMSearch.add(url);
            Logging.info(this, "new M-Search response: " + url);
            final DeviceDescription? d1 = _responses[url]?.item2;
            if (d1 != null)
            {
                _processResponse(d, d1);
            }
            else
            {
                _responses[url] = Pair<MSearch, DeviceDescription?>(m, null);
                DeviceDescription.request(url).then((DeviceDescription? d2)
                {
                    if (d2 != null)
                    {
                        d2.mSearch = m;
                        Logging.info(this, "new SSDP device description: {" + d2.toString() + "}");
                        _responses[url] = Pair<MSearch, DeviceDescription?>(m, d2);
                        _processResponse(d, d2);
                    }
                });
            }
        }
        on Exception catch(e)
        {
            if (e is FormatException)
            {
                Logging.info(this, "Unable to handle M-Search response: " + e.toString());
            }
        }
    }

    void _processResponse(final Datagram d, final DeviceDescription description)
    {
        if (description.isISCP || description.isDCP)
        {
            final ProtoType p = description.isISCP? ProtoType.ISCP : ProtoType.DCP;
            final BroadcastResponseMsg responseMessage =
            BroadcastResponseMsg.ssdp(d.address, p, description);
            if (responseMessage.isValidConnection())
            {
                Logging.info(this, "<< SSDP device response " + responseMessage.toString());
                onDeviceFound(responseMessage);
            }
        }
    }

    void _onError(Object error)
    {
        Logging.info(this, "SSDP error:" + error.toString());
        _socket = null;
    }

    void _onDone()
    {
        Logging.info(this, "Stopped");
        _socket = null;
    }
}