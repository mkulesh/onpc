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

import 'package:json_path/json_path.dart';

/*
 * Denon control protocol - Initial parsing of HEOS messages
 */
class DcpHeosMessage
{
    dynamic _jsonMsg;
    String _command;
    String _result;
    Map<String, String> _message;

    DcpHeosMessage(String dcpMsg)
    {
        _jsonMsg = jsonDecode(dcpMsg);
        _command = nonNullString(getString("heos.command"));
        _result = nonNullString(getString("heos.result"));
        _message = _getMessage();
    }

    @override
    String toString()
    => "cmd=" + _command + ", result=" + _result + ", message=" + _message.toString();

    String get command
    => _command;

    String get result
    => _result;

    Map<String, String> get message
    => _message;

    static String nonNullString(String s)
    => s == null ? "" : s.trim();

    bool isValid(int pid)
    {
        if ("success" != _result)
        {
            return false;
        }
        final String pidStr = message["pid"];
        if (pidStr != null && pid != null && pid.toString() != pidStr)
        {
            return false;
        }
        if (message["command under process"] != null)
        {
            return false;
        }
        return true;
    }

    int getInt(final String path)
    {
        final Iterable<JsonPathMatch> list = JsonPath(r"$." + path).read(_jsonMsg);
        return list.isEmpty ? null : list.first.value;
    }

    String getString(final String path)
    {
        final Iterable<JsonPathMatch> list = JsonPath(r"$." + path).read(_jsonMsg);
        return list.isEmpty ? null : list.first.value.toString();
    }

    List<String> getStringList(final String path)
    {
        final List<String> values = [];
        JsonPath(r"$." + path).read(_jsonMsg).forEach((e) => values.add(e.value.toString()));
        return values;
    }

    Map<String, String> _getMessage()
    {
        final Map<String, String> retValue = Map();
        final String heosMsg = getString("heos.message");
        final List<String> heosTokens = heosMsg.split("&");
        for (String token in heosTokens)
        {
            final List<String> parTokens = token.split("=");
            if (parTokens.length == 2)
            {
                retValue[parTokens[0]] = parTokens[1];
            }
            else if (parTokens.length == 1)
            {
                retValue[parTokens[0]] = "";
            }
        }
        return retValue;
    }
}