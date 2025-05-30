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

import 'dart:async';

import "package:shared_preferences/shared_preferences.dart";

import "../config/Configuration.dart";
import "../utils/Logging.dart";
import "ConnectionIf.dart";
import "EISCPMessage.dart";
import "ISCPMessage.dart";
import "MessageChannel.dart";
import "MessageChannelDcp.dart";
import "MessageChannelIscp.dart";
import "OnpcSocket.dart";
import "State.dart";
import "messages/MessageFactory.dart";

typedef OnInitialState = void Function(MessageChannel channel);
typedef OnMessage = bool Function(MessageChannel channel, ISCPMessage msg);

class WidgetStateManager
{
    Configuration? configuration;
    MessageChannel? _messageChannel;
    StreamController? _updateNotifier;
    StreamSubscription? _updateStream;
    OnInitialState? _onInitialState;
    Timer? _autoCloseTimer;
    final Duration _autoCloseDelay;
    final State _state = State();

    State get state => _state;

    WidgetStateManager(this._autoCloseDelay);

    Future<bool> readConfiguration() async
    {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        configuration = Configuration(prefs);
        configuration?.readHomeWidgetCfg();
        return Future.value(true);
    }

    void start(final OnInitialState _onInitialState, final OnMessage _onMessage)
    {
        this._onInitialState = _onInitialState;
        _messageChannel = _createChannel();
        _updateNotifier = StreamController.broadcast();
        _updateStream = _updateNotifier?.stream.listen((dynamic obj)
        {
            if (obj is ISCPMessage)
            {
                if (_onMessage(_messageChannel!, obj))
                {
                    _updateTimer();
                }
            }
        });
        _messageChannel?.start(configuration!.getDeviceName, configuration!.getDevicePort);
    }

    MessageChannel _createChannel()
    {
        if (configuration!.getDevicePort == DCP_PORT)
        {
            final MessageChannelDcp c =
            MessageChannelDcp(_onConnected, _onNewDCPMessage, _onDisconnected);
            c.zone = configuration!.activeZone;
            return c;
        }
        else
        {
            return MessageChannelIscp(_onConnected, _onNewEISCPMessage, _onDisconnected);
        }
    }

    void _updateTimer()
    {
        Logging.info(this, "Auto-close timer started: " + _autoCloseDelay.toString());
        _autoCloseTimer?.cancel();
        _autoCloseTimer = Timer(_autoCloseDelay, ()
        {
            Logging.info(this, "Auto-close timer triggered");
            _autoCloseTimer?.cancel();
            stop();
        });
    }

    void _onConnected(MessageChannel channel, ConnectionIf connection)
    {
        Logging.info(this, "Connected to " + connection.getHostAndPort);
        _state.activeZone = configuration!.activeZone;
        _state.updateConnection(true, channel.getProtoType);
        if (_onInitialState != null)
        {
            _onInitialState!(channel);
        }
        _updateTimer();
    }

    Future<ISCPMessage> _registerISCPMessage(ISCPMessage raw) async
    {
        // this is a dummy code necessary to transfer the incoming message into
        // the asynchronous scope
        return raw;
    }

    void _onNewDCPMessage(ISCPMessage rawMsg, MessageChannel channel)
    {
        // call processing asynchronous after message is registered
        _registerISCPMessage(rawMsg).then((ISCPMessage msg)
        {
            try
            {
                msg.setHostAndPort(channel);
                _handleMessage(msg);
            }
            on Exception catch (e)
            {
                Logging.info(this, "-> can not process message " + rawMsg.toString() + ": " + e.toString());
            }
        });
    }

    Future<EISCPMessage> _registerEISCPMessage(EISCPMessage raw) async
    {
        // this is a dummy code necessary to transfer the incoming message into
        // the asynchronous scope
        return raw;
    }

    void _onNewEISCPMessage(EISCPMessage rawMsg, MessageChannel channel)
    {
        // call processing asynchronous after message is registered
        _registerEISCPMessage(rawMsg).then((EISCPMessage raw)
        {
            try
            {
                final ISCPMessage msg = MessageFactory.create(rawMsg);
                msg.setHostAndPort(channel);
                _handleMessage(msg);
            }
            on Exception catch (e)
            {
                Logging.info(this, "-> can not process message " + rawMsg.toString() + ": " + e.toString());
            }
        });
    }

    void _handleMessage(ISCPMessage msg)
    {
        _state.update(msg);
        if (_state.nonActiveZoneMsg(msg))
        {
            return;
        }
        if (_updateNotifier != null)
        {
            _updateNotifier!.sink.add(msg);
        }
    }

    void stop()
    {
        _autoCloseTimer?.cancel();
        _messageChannel?.stop();
        _updateStream?.cancel();
        _updateNotifier?.close();
        //exit(0);
    }

    void _onDisconnected(ConnectionErrorType errorType, String result)
    {
        Logging.info(this, result);
        _state.updateConnection(false, _state.protoType);
    }
}