/*
 * Enhanced Controller for Onkyo and Pioneer Pro
 * Copyright (C) 2019-2021 by Mikhail Kulesh
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
import 'dart:math';

import "package:xml/xml.dart" as xml;

import "ConnectionIf.dart";
import "EISCPMessage.dart";

typedef OnProcessFinished = void Function(bool changed, String changeCode);

class ISCPMessage with ConnectionIf
{
    static const String PAR_SEP = "/";
    static const String COMMA_SEP = ",";

    final int _messageId;
    final String _code;
    final String _data;
    final String _modelCategoryId;

    ISCPMessage(this._code, EISCPMessage raw) :
        _messageId = raw.getMessageId,
        _data = raw.getParameters.trim(),
        _modelCategoryId = raw.getModelCategoryId;

    ISCPMessage.output(this._code, this._data) :
        _messageId = 0,
        _modelCategoryId = 'X';

    ISCPMessage.outputId(this._messageId, this._code, this._data) :
        _modelCategoryId = 'X';

    int get getMessageId
    => _messageId;

    String get getCode
    => _code;

    String get getData
    => _data;

    String get getModelCategoryId
    => _modelCategoryId;

    bool get isMultiline
    => _data != null && _data.length > EISCPMessage.LOG_LINE_LENGTH;

    @override
    String toString()
    => _code + "[" + (isMultiline ? ("DATA<" + _data.length.toString() + "B>") : _data) + "]";

    EISCPMessage getCmdMsg()
    {
        return EISCPMessage.output(getCode, getData);
    }

    bool hasImpactOnMediaList()
    {
        return true;
    }

    static String nonNullString(String s)
    {
        return s == null ? "" : s.trim();
    }

    static int nonNullInteger(String s, int r, int def)
    {
        if (s == null)
        {
            return def;
        }
        final int val = int.tryParse(s, radix: r);
        return val != null ? val : def;
    }

    static String getProperty(xml.XmlDocument document, String name)
    {
        String res = "";
        document.findAllElements(name).forEach((xml.XmlElement e)
        {
            res = ISCPMessage.nonNullString(e.text);
        });
        return res;
    }

    String getTags(final List<String> pars, int start, int end)
    {
        String str = "";
        for (int i = start; i < min(end, pars.length); i++)
        {
            if (pars[i] != null && pars[i].isNotEmpty)
            {
                if (str.isNotEmpty)
                {
                    str += ", ";
                }
                str += pars[i];
            }
        }
        return str.toString();
    }
}

class ZonedMessage extends ISCPMessage
{
    final List<String> _zoneCommands;
    int _zoneIndex;

    ZonedMessage(this._zoneCommands, EISCPMessage raw) : super(raw.getCode, raw)
    {
        _zoneIndex = _zoneCommands.indexOf(raw.getCode.toUpperCase());
        if (_zoneIndex < 0)
        {
            throw Exception("No zone defined for message " + raw.getCode);
        }
    }

    ZonedMessage.output(this._zoneCommands, this._zoneIndex, String data) :
            super.output(_zoneCommands[_zoneIndex], data);

    String get getZoneCommand
    => _zoneCommands[_zoneIndex];

    int get zoneIndex
    => _zoneIndex;

    @override
    String toString()
    => super.toString() + "[ZONE=" + _zoneIndex.toString() + "]";
}
