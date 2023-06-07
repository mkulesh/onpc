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
// @dart=2.9

import "../utils/Logging.dart";
import "ConnectionIf.dart";
import "EISCPMessage.dart";
import "ISCPMessage.dart";
import "MessageChannel.dart";
import "OnpcSocket.dart";
import "messages/TimeInfoMsg.dart";

typedef OnNewEISCPMessage = void Function(EISCPMessage message, MessageChannel channel);

class MessageChannelIscp with ConnectionIf implements MessageChannel
{
    // callbacks
    final OnNewEISCPMessage _onNewEISCPMessage;

    // connection state
    OnpcSocket _socket;

    // message handling
    final Set<String> _allowedMessages = Set();
    final List<int> _buffer = [];
    int _messageId = 0;

    MessageChannelIscp(OnConnected _onConnected, this._onNewEISCPMessage, OnDisconnected _onDisconnected)
    {
        _socket = OnpcSocket(this, _onConnected, _onDisconnected, _onData);
    }

    @override
    ProtoType get getProtoType
    => ProtoType.ISCP;

    @override
    bool get isConnected
    => _socket.state == MessageChannelState.RUNNING;

    @override
    void addAllowedMessage(final String code)
    => _allowedMessages.add(code);

    @override
    void start(String host, int port, {bool keepConnection = false})
    {
        _socket.start(host, port, keepConnection : keepConnection);
        setHost(_socket.getHost);
        setPort(_socket.getPort);
    }

    @override
    void sendMessage(EISCPMessage m)
    => _socket.sendData(m.getBytes(), m.toString());

    @override
    void sendIscp(ISCPMessage m)
    => sendMessage(m.getCmdMsg());

    @override
    void sendQueries(List<String> queries)
    {
        queries.forEach((m)
        => sendMessage(EISCPMessage.query(m)));
    }

    @override
    void stop()
    => _socket.stop();

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
                if (startIndex < 0)
                {
                    Logging.info(this, "<< error: message start marker not found. " + remaining.toString() + "B ignored");
                    _buffer.clear();
                    return;
                }
                else if (startIndex > 0)
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
                        + " from " + getHostAndPort
                        + ", size=" + raw.getMsgSize.toString()
                        + "B, remaining=" + remaining.toString() + "B");
                }
                _onNewEISCPMessage(raw, this);
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