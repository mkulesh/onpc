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
 *
 * This class is inspired by https://pub.dev/packages/upnped - A Dart library for discovering and controlling UPnP devices.
 */

import 'dart:convert';
import 'dart:io';

import 'package:sprintf/sprintf.dart';

const _multicastTemplate = '''M-SEARCH * HTTP/1.1\r
HOST: %s:%s\r
MAN: "ssdp:discover"\r
MX: %s\r
ST: %s\r
USER-AGENT: %s \r
\r
''';

class MSearchKey
{
    static const String CACHE_CONTROL = "cache-control";
    static const String DATE = "date";
    static const String EXT = "ext";
    static const String LOCATION = "location";
    static const String SERVER = "server";
    static const String ST = "st";
    static const String USN = "usn";
}

class MSearch
{
    // Request
    static const int DEF_RESPONSE_SEC = 5;
    static const String DEF_SEARCH_TARGET = "upnp:rootdevice";
    static const String DEF_USER_AGENT = "com.mkulesh.onpc.plus";

    // Response
    final Map<String, String> _headers = {};

    // Data
    late String message;

    MSearch.request(String host, int port, {
        int mx = DEF_RESPONSE_SEC,
        String st = DEF_SEARCH_TARGET,
        String userAgent = DEF_USER_AGENT})
    {
        message = sprintf(_multicastTemplate, [host, port.toString(), mx.toString(), st, userAgent]);
    }

    MSearch.response(this.message)
    {
        final List<String> lines = message.split('\r\n');
        if (lines.isEmpty)
        {
            throw FormatException("number of lines is zero");
        }
        if (lines.first.contains("M-SEARCH"))
        {
            throw Exception("request message ignored");
        }
        for (String line in lines)
        {
            final int colon = line.indexOf(':');
            if (colon == -1)
            {
                continue;
            }
            final key = line.substring(0, colon).trim().toLowerCase().trim();
            final value = line.substring(colon + 1).trim();
            if (value.isNotEmpty)
            {
                _headers[key] = value;
            }
        }
    }

    List<int> encode()
    => utf8.encode(message);

    @override
    String toString()
    => _headers.toString();

    /// After this duration, control points should assume the device is no longer available.
    String? get cacheControl
    => _headers[MSearchKey.CACHE_CONTROL];

    /// The RFC1123-date when this response was generated.
    DateTime? get date
    => _nullOrFunction(MSearchKey.DATE, HttpDate.parse);

    /// Required for backwards compatibility with UPnP 1.0.
    String? get ext
    => _headers[MSearchKey.EXT];

    /// The URL to the UPnP description of the root device.
    Uri? get location
    => _nullOrFunction(MSearchKey.LOCATION, Uri.parse);

    /// Specified by the UPnP vendor, this specifies product tokens for the device.
    String? get server
    => _headers[MSearchKey.SERVER];

    /// The search target. This field changes depending on the search request.
    String? get st
    => _headers[MSearchKey.ST];

    /// Unique service name of a device or service.
    String? get usn
    => _headers[MSearchKey.USN];

    T? _nullOrFunction<T>(String key, T Function(String value) fn)
    => _headers[key] == null ? null : fn(_headers[key]!);
}
