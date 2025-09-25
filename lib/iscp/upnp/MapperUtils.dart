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

import 'package:xml/xml.dart';

class MapperUtils
{
    static elementMapper<T>(XmlNode? xml, String elementType, T Function(XmlElement) buildFn)
    => xml?.findAllElements(elementType).map<T>(buildFn).toList() ?? [];

    static nodeMapper<T>(XmlNode? xml, String elementType, T Function(XmlNode) buildFn)
    => xml?.findAllElements(elementType).map<T>(buildFn).toList() ?? [];
}