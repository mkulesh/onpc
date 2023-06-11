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

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;

import "../utils/Logging.dart";
import "ConnectionIf.dart";
import "DcpHeosMessage.dart";
import "EISCPMessage.dart";
import "ISCPMessage.dart";
import "MessageChannel.dart";
import "OnpcSocket.dart";
import "messages/DCPMessageFactory.dart";
import "messages/DcpReceiverInformationMsg.dart";
import "messages/TimeInfoMsg.dart";

typedef OnNewISCPMessage = void Function(ISCPMessage message, MessageChannel channel);

/*
 * Denon control protocol - Message channel for DCP and HEOS messages
 */
class MessageChannelDcp with ConnectionIf implements MessageChannel
{
    static const int DCP_SEND_DELAY = 75; // Send the COMMAND in 50ms or more intervals.

    // goform protocol
    static const String DCP_FORM_IPHONE_APP = "formiPhoneApp";
    static const String DCP_APP_COMMAND = "<cmd id=\"1\">";

    // HEOS protocol
    static const String DCP_HEOS_REQUEST = "heos://";
    static const String DCP_HEOS_RESPONSE = "{\"heos\":";

    static const int CR = 0x0D;
    static const int LF = 0x0A;

    // callbacks
    final OnConnected _onConnected;
    final OnNewISCPMessage _onNewISCPMessage;

    // connection state
    OnpcSocket _dcpSocket;
    OnpcSocket _heosSocket;

    // message handling
    final List<int> _buffer = [];
    final DCPMessageFactory _dcpMessageFactory = DCPMessageFactory();
    int _heosPid;

    MessageChannelDcp(this._onConnected, this._onNewISCPMessage, OnDisconnected _onDisconnected)
    {
        _heosSocket = OnpcSocket(this, _onHeosConnected, _onHeosDisconnected, _onHeosData);
        _dcpSocket = OnpcSocket(this, _onDcpConnected, _onDisconnected, _onDcpData);
        _dcpMessageFactory.prepare();
    }

    @override
    ProtoType get getProtoType
    => ProtoType.DCP;

    @override
    bool get isConnected
    => _dcpSocket.state == MessageChannelState.RUNNING;

    @override
    void addAllowedMessage(final String code)
    {
        // nothing to do
    }

    set zone(int value)
    {
        _dcpMessageFactory.zone = value;
    }

    @override
    void start(String host, int port, {bool keepConnection = false})
    {
        _dcpSocket.start(host, port, keepConnection : false);
        setHost(_dcpSocket.getHost);
        setPort(_dcpSocket.getPort);
    }

    @override
    void sendMessage(EISCPMessage raw)
    => _dcpMessageFactory.convertOutputMsg(raw, null, getHost).forEach((msg)
        => _processOutMessage(raw, msg));

    @override
    void sendIscp(ISCPMessage raw)
    => _dcpMessageFactory.convertOutputMsg(null, raw, getHost).forEach((msg)
        => _processOutMessage(raw, msg));

    void _processOutMessage(Object raw, String msg)
    {
        if (msg.startsWith(DCP_HEOS_REQUEST))
        {
            _sendDcpHeosRequest(msg);
        }
        else if (msg.startsWith(DCP_APP_COMMAND))
        {
            _sendDcpAppCommand(msg);
        }
        else
        {
            _sendDcpRawMsg(raw, msg);
        }
        sleep(const Duration(milliseconds: DCP_SEND_DELAY));
    }

    @override
    void sendQueries(List<String> queries)
    {
        queries.forEach((m)
        => sendMessage(EISCPMessage.query(m)));
    }

    @override
    void stop()
    {
        _dcpSocket.stop();
        _heosSocket.stop();
    }

    void _onDcpData(List<dynamic> data)
    => _onRawData(data, _dcpSocket);

    void _onDcpConnected(MessageChannel channel, ConnectionIf connection)
    {
        Logging.info(this, "Connected to DCP channel: " + connection.getHostAndPort + ", waiting fot HEOS");
        _heosSocket.start(getHost, DCP_HEOS_PORT, keepConnection : false);
    }

    void _onHeosConnected(MessageChannel channel, ConnectionIf connection)
    {
        Logging.info(this, "Connected to HEOS channel: " + connection.getHostAndPort);
        _sendDcpHeosRequest("heos://player/get_players");
    }

    void _onHeosDisconnected(ConnectionErrorType errorType, String result)
    {
        Logging.info(this, result);
    }

    void _onHeosData(List<dynamic> data)
    => _onRawData(data, _heosSocket);

    void _onRawData(List<dynamic> data, final OnpcSocket socket)
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
            remaining = _processDcpData(_buffer, socket);
            if (remaining < 0)
            {
                // An error, nothing to process
                return;
            }
            remaining = _remove(_buffer, _buffer.length - remaining);
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

    int _processDcpData(List<int> bytes, final OnpcSocket onpcSocket)
    {
        int expectedSize = -1;
        for (int i = 0; i < bytes.length; i++)
        {
            if (bytes[i] == CR)
            {
                expectedSize = i;
                break;
            }
        }

        if (expectedSize <= 0)
        {
            final String logMsg = utf8.decode(bytes);
            if (logMsg.startsWith(DcpReceiverInformationMsg.DCP_COMMAND_PRESET))
            {
                // A corner case: OPTPN has some time no end of message symbol
                Logging.info(this, "<< DCP warning: end of message not found: " + logMsg);
                expectedSize = logMsg.length;
            }
            else
            {
                return -1;
            }
        }

        if (expectedSize + 1 < bytes.length &&
            bytes[expectedSize] == CR && bytes[expectedSize + 1] == LF)
        {
            // Consider possible LF after CR
            expectedSize++;
        }

        final List<int> stringBytes = expectedSize + 1 == bytes.length ? bytes : bytes.sublist(0, expectedSize);
        final String dcpMsg = utf8.decode(stringBytes).trim();
        final int remaining = max(0, bytes.length - expectedSize - 1);

        bool processed = false;
        final int _heosPidPrev = _heosPid;
        DcpHeosMessage jsonMsg;
        if (dcpMsg.startsWith(DCP_HEOS_RESPONSE))
        {
            try
            {
                jsonMsg = DcpHeosMessage(dcpMsg);
                processed = _processHeosMsg(jsonMsg);
            }
            on Exception catch (ex)
            {
                Logging.info(this, "DCP HEOS error: " + ex.toString());
            }
        }

        final List<ISCPMessage> messages = _dcpMessageFactory.convertInputMsg(dcpMsg, _heosPid, jsonMsg);
        final bool logIgnored = messages.length == 1 && messages.first.getCode == TimeInfoMsg.CODE;

        if (!logIgnored)
        {
            final String resStr = processed ? " -> Processed" :
                (messages.isEmpty ? " -> Ignored" :
                    (messages.length == 1 ? " -> " + messages.first.toString() :
                        " -> " + messages.length.toString() + "msg"));
                        Logging.info(this, "<< new DCP message " + dcpMsg
                        + " from " + onpcSocket.getHostAndPort
                        + ", size=" + dcpMsg.length.toString()
                        + "B, remaining=" + remaining.toString() + "B"
                        + resStr);
        }
        if (_heosPidPrev == null && _heosPid != null)
        {
            Logging.info(this, "DCP HEOS PID received: " + _heosPid.toString() + ", starting communication...");
            _onConnected(this, _dcpSocket);
        }

        messages.forEach((m) => _onNewISCPMessage(m, this));
        return remaining;
    }

    bool _processHeosMsg(DcpHeosMessage jsonMsg)
    {
        // Device PID
        if (_heosPid == null)
        {
            if ("player/get_players" == jsonMsg.command)
            {
                _heosPid = jsonMsg.getInt("payload[0].pid");
                return true;
            }
        }
        // Events
        if (_heosPid != null && "event/player_now_playing_changed" == jsonMsg.command)
        {
            final String pidStr = jsonMsg.message["pid"];
            if (pidStr != null && _heosPid.toString() == pidStr)
            {
                _sendDcpHeosRequest("heos://player/get_now_playing_media?pid=" + _heosPid.toString());
                return true;
            }
        }
        return false;
    }

    void _sendDcpHeosRequest(String msg)
    {
        if (_heosSocket.state != MessageChannelState.RUNNING)
        {
            return;
        }
        Logging.info(this, ">> DCP HEOS sending: " + msg + " to " + _heosSocket.getHostAndPort);
        if (msg.contains(ISCPMessage.DCP_HEOS_PID))
        {
            if (_heosPid == null)
            {
                return;
            }
            msg = msg.replaceAll(ISCPMessage.DCP_HEOS_PID, _heosPid.toString());
        }
        try
        {
            final List<int> msgBin = utf8.encode(msg);
            final List<int> bytes = List<int>.filled(msgBin.length + 2, 0);
            List.copyRange(bytes, 0, msgBin, 0, msgBin.length);
            bytes[msgBin.length] = CR;
            bytes[msgBin.length + 1] = LF;
            _heosSocket.sendData(bytes, msg);
        }
        on Exception catch (ex)
        {
        Logging.info(this, "DCP HEOS error: " + ex.toString());
        }
    }

    void _sendDcpRawMsg(Object raw, String msg)
    {
        Logging.info(this, ">> DCP sending: " + raw.toString() + " => " + msg + " to " + _dcpSocket.getHostAndPort);
        try
        {
            final List<int> msgBin = utf8.encode(msg);
            final List<int> bytes = List<int>.filled(msgBin.length + 1, 0);
            List.copyRange(bytes, 0, msgBin, 0, msgBin.length);
            bytes[msgBin.length] = CR;
            _dcpSocket.sendData(bytes, msg);
        }
        on Exception catch (ex)
        {
            Logging.info(this, "DCP error: " + ex.toString());
        }
    }

    void _sendDcpAppCommand(String msg)
    {
        final String url = ISCPMessage.getDcpGoformUrl(getHost, DCP_HTTP_PORT.toString(), "AppCommand.xml");
        final String json = "{\"body\": \"" + ISCPMessage.getDcpAppCommand(msg) + "\"}";
        Logging.info(this, ">> DCP AppCommand POST request: " + url + json);
        http.post(Uri.parse(url), headers: {"Content-Type": "text/xml; charset=UTF-8"}, body: json).then((http.Response value)
        {
            final String resp = value != null && value.body != null ? value.body.replaceAll("\n", "") : "";
            Logging.info(this, "DCP AppCommand POST response: " + resp);
        }).onError((error, stackTrace)
        {
            Logging.info(this, "DCP AppCommand error: " + error);
        });
    }
}