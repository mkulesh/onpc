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

import "dart:io";

import 'package:sprintf/sprintf.dart';

import "../constants/Strings.dart";
import "../utils/Logging.dart";
import "EISCPMessage.dart";
import "messages/TimeInfoMsg.dart";

typedef OnConnected = void Function(MessageChannel channel, String server, int port);
typedef OnNewEISCPMessage = void Function(EISCPMessage message, String host);
typedef OnDisconnected = void Function(String result, bool showError);


// The current state of the message channel.
enum MessageChannelState
{
    IDLE, CONNECTING, RUNNING
}


// A manager for the spawned isolate message channel.
class MessageChannel
{
    MessageChannelState _state = MessageChannelState.IDLE;

    bool get isConnected
    => _state == MessageChannelState.RUNNING;

    // callbacks
    final OnConnected _onConnected;
    final OnNewEISCPMessage _onNewEISCPMessage;
    final OnDisconnected _onDisconnected;

    // connection state
    Socket _socket;

    String _sourceHost = "";

    String get sourceHost
    => _sourceHost;

    int _sourcePort = 0;

    int get sourcePort
    => _sourcePort;

    // message handling
    final Set<String> _allowedMessages = Set();
    final List<int> _buffer = List<int>();
    int _messageId = 0;

    MessageChannel(this._onConnected, this._onNewEISCPMessage, this._onDisconnected);

    void addAllowedMessage(final String code)
    {
        _allowedMessages.add(code);
    }

    start(String server, int port)
    {
        final String _serverDescription = server + "/" + port.toString();

        if (_state != MessageChannelState.IDLE)
        {
            return;
        }
        Logging.info(this, "Connecting to " + _serverDescription + "...");
        _state = MessageChannelState.CONNECTING;
        Socket.connect(server, port, timeout: Duration(seconds: 10)).then((Socket sock)
        {
            _socket = sock;
            _socket.listen(_onData,
                onError: _onError,
                onDone: _onDone,
                cancelOnError: false);
            _state = MessageChannelState.RUNNING;
            if (sock.address != null && sock.address.host != null && sock.address.host.isNotEmpty)
            {
                _sourceHost = sock.address.address;
            }
            else
            {
                _sourceHost = server;
            }
            _sourcePort = port;
            _onConnected(this, _sourceHost, port);
        }).catchError((dynamic e)
        {
            _state = MessageChannelState.IDLE;
            _sourceHost = "";
            _sourcePort = 0;
            _onDisconnected(sprintf(Strings.error_connection_no_response, [_serverDescription]), true);
        });
    }

    void sendMessage(EISCPMessage m)
    {
        final List<int> bytes = m.getBytes();
        if (_socket != null && bytes != null)
        {
            Logging.info(this, ">> sending: " + m.toString() + " to " + sourceHost);
            _socket.add(bytes);
        }
    }

    void sendQueries(List<String> queries)
    {
        queries.forEach((m)
        => sendMessage(EISCPMessage.query(m)));
    }

    void stop()
    {
        if (_socket != null)
        {
            _socket.destroy();
        }
    }

    void _onDone()
    {
        _state = MessageChannelState.IDLE;
        _socket = null;
        _onDisconnected("Disconnected from " + sourceHost, false);
        _sourceHost = "";
        _sourcePort = 0;
    }

    void _onError(Object error)
    {
        Logging.info(this, "Communication error:" + error.toString());
    }

    void _onData(List<dynamic> data)
    {
        if (data == null || data.isEmpty)
        {
            return;
        }

        data.forEach((dynamic f)
        {
            if (f is int)
            {
                _buffer.add(f);
            }
        });

        int remaining = _buffer.length;

        while (remaining > 0)
        {
            // remove unused prefix
            {
                final int startIndex = EISCPMessage.getMsgStartIndex(_buffer);
                if (startIndex > 0)
                {
                    Logging.info(this, "<< warning: unexpected position of message start: "
                        + startIndex.toString() + ", remaining=" + remaining.toString() + "B");
                    _buffer.removeRange(0, startIndex);
                }
            }

            // convert header and data sizes
            final int hSize = EISCPMessage.getHeaderSize(_buffer);
            final int dSize = EISCPMessage.getDataSize(_buffer);
            if (hSize < 0 || dSize < 0)
            {
                Logging.info(this, "<< error: unexpected header size: "
                    + hSize.toString() + ", remaining=" + remaining.toString() + "B");
                return;
            }

            final int expectedSize = hSize + dSize;
            if (expectedSize > remaining)
            {
                return;
            }

            // try to convert raw message. In case of any errors, skip expectedSize
            EISCPMessage raw;
            try
            {
                _messageId++;
                raw = EISCPMessage.input(_messageId, _buffer, hSize, dSize);
            }
            on Exception catch (e)
            {
                remaining = _remove(_buffer, expectedSize);
                Logging.info(this, "<< error: invalid raw message: " + e.toString()
                    + ", remaining=" + remaining.toString() + "B");
                continue;
            }

            remaining = _remove(_buffer, expectedSize);

            final bool ignored = _allowedMessages.isNotEmpty && !_allowedMessages.contains(raw.getCode);
            if (!ignored)
            {
                if (TimeInfoMsg.CODE != raw.getCode)
                {
                    Logging.info(this, "<< new message " + raw.getCode
                        + " from " + sourceHost
                        + ", size=" + raw.getMsgSize.toString()
                        + "B, remaining=" + remaining.toString() + "B");
                }
                _onNewEISCPMessage(raw, sourceHost);
            }
        }
    }

    int _remove(List<int> l, int s)
    {
        if (s >= l.length)
        {
            l.clear();
        }
        else
        {
            l.removeRange(0, s);
        }
        return l.length;
    }
}
