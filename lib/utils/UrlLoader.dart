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

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';

import 'Logging.dart';

class OncpHttpOverrides extends HttpOverrides
{
    @override
    HttpClient createHttpClient(SecurityContext? context)
    {
        // Ignore CERTIFICATE_VERIFY_FAILED error for Deezer cover art on Android
        // https://stackoverflow.com/questions/54285172/how-to-solve-flutter-certificate-verify-failed-error-while-performing-a-post-req
        return super.createHttpClient(context)
            ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    }
}

class UrlLoader
{
    static const int LF = 0x0A;
    static const int CR = 0x0D;

    Future<Uint8List?> loadFromUrl(String url, {bool info = true})
    {
        if (info)
        {
            Logging.info(this, "loading data from URL: " + url.toString());
        }
        return http.get(Uri.parse(url)).then((response)
        {
            try
            {
                final Uint8List r = response.bodyBytes;
                final int offset = _getUrlHeaderLength(r);
                final int length = r.length - offset;
                if (length > 0)
                {
                    Logging.info(this, "-> loaded data size: " + length.toString() + "B");
                    return Uint8List.view(r.buffer, offset);
                }
                else
                {
                    Logging.info(this, "-> empty data");
                    return null;
                }
            }
            on Exception catch (e)
            {
                Logging.info(this, "-> can not load data: " + e.toString());
                return null;
            }
        }).catchError((e) {
            Logging.info(this, "-> can not load data: " + e.toString());
            return null;
        });
    }

    int _getUrlHeaderLength(Uint8List r)
    {
        final List<int> cnt = "Content-".codeUnits;
        int length = 0;
        while (true)
        {
            final int lf = r.indexOf(LF, length);
            final List<int> start = r.sublist(length, min(length + cnt.length, r.length));
            if (lf > 0 && IterableEquality().equals(start, cnt))
            {
                length = lf;
                while (length < r.length && (r[length] == LF || r[length] == CR))
                {
                    length++;
                }
                continue;
            }
            break;
        }
        return length;
    }
}