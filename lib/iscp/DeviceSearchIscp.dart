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
import 'dart:io';

import "../utils/Convert.dart";
import "../utils/Logging.dart";
import "ConnectionIf.dart";
import "DeviceSearch.dart";
import "EISCPMessage.dart";
import "messages/BroadcastResponseMsg.dart";

class DeviceSearchIscp implements SearchEngineIf
{
    // Broadcast address for ISCP Discovery Protocol
    final String V4_BROADCAST = "255.255.255.255";

    final int _id;
    final OnDeviceFound onDeviceFound;
    final OnRequest onRequest;

    RawDatagramSocket? _socket;
    int _requestCount = 0;
    final EISCPMessage _mX = EISCPMessage.outputCat("x", "ECN", "QSTN");
    final EISCPMessage _mP = EISCPMessage.outputCat("p", "ECN", "QSTN");

    DeviceSearchIscp(this._id, this.onDeviceFound, this.onRequest);

    @override
    int get id
    => _id;

    @override
    void start(int retryDelay)
    {
        Logging.info(this, "Starting. Retry delay = " + retryDelay.toString() + "s.");
        _requestCount = 0;
        RawDatagramSocket.bind(InternetAddress.anyIPv4, ISCP_PORT).then((RawDatagramSocket sock)
        {
            _socket = sock;
            _socket!.broadcastEnabled = true;
            _socket!.listen(_onData,
                onError: _onError,
                onDone: _onDone,
                cancelOnError: false);

            Timer.periodic(Duration(seconds: retryDelay), (Timer t)
            {
                if (_socket != null)
                {
                    _requestIscp(_mX, "x");
                    _requestIscp(_mP, "p");
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
            _socket!.close();
        }
    }

    @override
    bool get isStopped
    => _socket == null;

    void _requestIscp(final EISCPMessage m, final String modelCategoryId)
    {
        final InternetAddress target = InternetAddress(V4_BROADCAST);
        if (_socket != null)
        {
            final List<int>? bytes = m.getBytes();
            if (bytes == null)
            {
                return;
            }
            _socket!.send(bytes, target, ISCP_PORT);
            Logging.info(this, "message " + m.toString()
                + " for category \'" + modelCategoryId
                + "\' send to " + target.toString());
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

        final List<int> buffer = [];
        d.data.forEach((f)
        => buffer.add(f));

        final String response = Convert.decodeUtf8(buffer);
        _processResponse(d, buffer, response);
    }

    void _processResponse(final Datagram d, List<int> buffer, final String response)
    {
        // remove unused prefix
        final int startIndex = EISCPMessage.getMsgStartIndex(buffer);
        if (startIndex > 0)
        {
            Logging.info(this, "<< warning: unexpected position of message start: " + startIndex.toString());
            buffer.removeRange(0, startIndex);
        }

        // convert header and data sizes
        final int hSize = EISCPMessage.getHeaderSize(buffer);
        final int dSize = EISCPMessage.getDataSize(buffer);
        if (hSize < 0 || dSize < 0)
        {
            Logging.info(this, "<< error: unexpected header size: " + hSize.toString());
            return;
        }

        // try to convert raw message. In case of any errors, skip expectedSize
        EISCPMessage raw;
        try
        {
            raw = EISCPMessage.input(0, buffer, hSize, dSize);
        }
        on Exception catch (e)
        {
            Logging.info(this, "<< error: invalid raw message: " + e.toString() + ": " + response);
            return;
        }

        if (raw.getParameters == "QSTN")
        {
            return;
        }

        final BroadcastResponseMsg responseMessage = BroadcastResponseMsg(d.address, raw);
        if (responseMessage.isValidConnection())
        {
            Logging.info(this, "<< ISCP device response " + responseMessage.toString());
            onDeviceFound(responseMessage);
        }
    }

    void _onError(Object error)
    {
        Logging.info(this, "UDP error:" + error.toString());
        _socket = null;
    }

    void _onDone()
    {
        Logging.info(this, "Stopped");
        _socket = null;
    }
}