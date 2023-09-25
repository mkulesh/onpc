/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2023 by Mikhail Kulesh
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU
 * General License as published by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
 * even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General License for more details. You should have received a copy of the GNU General
 * License along with this program.
 */

import "dart:io";

import "package:sprintf/sprintf.dart";

import "../constants/Strings.dart";
import "../utils/Logging.dart";
import "ConnectionIf.dart";
import "MessageChannel.dart";

enum ConnectionErrorType
{
    HOST_NOT_AVAILABLE,
    CONNECTION_CLOSED
}

typedef OnConnected = void Function(MessageChannel channel, ConnectionIf connection);
typedef OnDisconnected = void Function(ConnectionErrorType errorType, String result);
typedef OnRawData = void Function(List<dynamic> data);

// The current state of the message channel.
enum MessageChannelState
{
    IDLE, CONNECTING, RUNNING
}

class OnpcSocket with ConnectionIf
{
    // callbacks
    final MessageChannel _channel;
    final OnConnected _onConnected;
    final OnDisconnected _onDisconnected;
    final OnRawData _onData;

    // socket
    Socket? _socket;
    bool _keepConnection = false;
    MessageChannelState _state = MessageChannelState.IDLE;

    OnpcSocket(this._channel, this._onConnected, this._onDisconnected, this._onData);

    MessageChannelState get state
    => _state;

    void start(String host, int port, {bool keepConnection = false})
    {
        setHost(host);
        setPort(port);
        if (_state != MessageChannelState.IDLE)
        {
            return;
        }
        Logging.info(this, "Connecting to " + getHostAndPort + ", keep connection: " + keepConnection.toString());
        _keepConnection = keepConnection;
        _state = MessageChannelState.CONNECTING;
        Socket.connect(InternetAddress(host), port, timeout: Duration(seconds: 10)).then((Socket sock)
        {
            _socket = sock;
            _socket!.listen(_onData,
                onError: _onError,
                onDone: _onDone,
                cancelOnError: false);
            _state = MessageChannelState.RUNNING;
            // ignore: unnecessary_null_comparison
            if (sock.address != null && sock.address.host != null && sock.address.host.isNotEmpty)
            {
                setHost(sock.address.address);
            }
            _onConnected(_channel, this);
        }).catchError((dynamic e)
        {
            _state = MessageChannelState.IDLE;
            final String error = sprintf(Strings.error_connection_no_response, [getHostAndPort]);
            clearConnection();
            _onDisconnected(ConnectionErrorType.HOST_NOT_AVAILABLE, error);
        });
    }

    void _onDone()
    {
        _state = MessageChannelState.IDLE;
        _socket = null;
        _onDisconnected(ConnectionErrorType.CONNECTION_CLOSED, "Disconnected from " + getHostAndPort);
        if (_keepConnection)
        {
            // Issue #235: Randomly disconnection on iOS 14+
            sleep(Duration(seconds: 2));
            Logging.info(this, "reconnecting...");
            start(getHost, getPort, keepConnection: true);
        }
        else
        {
            clearConnection();
        }
    }

    void _onError(Object error)
    {
        Logging.info(this, "Communication error: " + error.toString());
    }

    void sendData(List<int>? bytes, String msg)
    {
        if (_socket != null && bytes != null)
        {
          Logging.info(this, ">> sending: " + msg + " to " + getHostAndPort);
          _socket!.add(bytes);
        }
    }

    void stop()
    {
        _keepConnection = false;
        if (_socket != null)
        {
          _socket!.destroy();
        }
    }
}
