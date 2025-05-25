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

import "dart:convert";
import "dart:math";
import "dart:typed_data";

import "../utils/Convert.dart";
import "../utils/Logging.dart";

class EISCPMessage
{
    static const String MSG_START = "ISCP";
    static const String INVALID_MSG = "INVALID";
    static const int CR = 0x0D;
    static const int LF = 0x0A;
    static const int EOF = 0x1A;
    static const int EOM = 0x19;
    static const String START_CHAR = "!";
    static const int MIN_MSG_LENGTH = 22;
    static const String QUERY = "QSTN";
    static const int LOG_LINE_LENGTH = 160;

    late final int _messageId;
    late final int _headerSize, _dataSize, _version;
    late String _modelCategoryId;
    late String _code;
    late String _parameters;

    EISCPMessage.input(this._messageId, List<int> bytes, this._headerSize, this._dataSize) :
            _version = _getVersion(bytes)
    {
        final String body = _getRawMessage(bytes);

        if (body.length < 5)
        {
            throw FormatException("Can not decode message body: " + body.length.toString() + " is invalid");
        }

        if (body.codeUnitAt(0) != START_CHAR.codeUnitAt(0))
        {
            throw FormatException("Can not find start character in the raw message");
        }

        _modelCategoryId = body.substring(1, 2);
        _code = body.substring(2, 5);
        _parameters = (body.length > 5) ? body.substring(5) : "";
    }

    EISCPMessage.output(this._code, this._parameters) :
        _modelCategoryId = "1",
        _messageId = 0,
        _headerSize = 16,
        _version = 1,
        _dataSize = 2 + _code.length + _parameters.length + 1;

    EISCPMessage.outputCat(this._modelCategoryId, this._code, this._parameters) :
            _messageId = 0,
            _headerSize = 16,
            _version = 1,
            _dataSize = 2 + _code.length + _parameters.length + 1;

    EISCPMessage.query(String code) : this.output(code, QUERY);

    @override
    String toString()
    {
        String res = MSG_START + "/v" + _version.toString()
            + "[" + _headerSize.toString() + "," + _dataSize.toString() + "]: "
            + _code + "(";
        if (isMultiline)
        {
            final double ln = _parameters.length / LOG_LINE_LENGTH;
            res += ln.ceil().toString();
            res += " lines)";
        }
        else
        {
            res += _parameters;
            res += ")";
        }
        return res;
    }

    void logParameters()
    {
        if (!Logging.isEnabled)
        {
            return;
        }
        String p = _parameters;
        while (true)
        {
            if (p.length > LOG_LINE_LENGTH)
            {
                Logging.info(this, p.substring(0, LOG_LINE_LENGTH));
                p = p.substring(LOG_LINE_LENGTH);
            }
            else
            {
                Logging.info(this, p);
                break;
            }
        }
    }

    bool get isMultiline
    => _parameters.length > LOG_LINE_LENGTH;

    int get getMsgSize
    => _headerSize + _dataSize;

    int get getMessageId
    => _messageId;

    String get getModelCategoryId
    => _modelCategoryId;

    String get getCode
    => _code;

    String get getParameters
    => _parameters;

    static int getMsgStartIndex(List<int> bytes)
    {
        for (int i = 0; i < bytes.length; i++)
        {
            if (bytes.length < MSG_START.length)
            {
                return -1;
            }
            if (bytes[i] == MSG_START.codeUnitAt(0) &&
                bytes[i + 1] == MSG_START.codeUnitAt(1) &&
                bytes[i + 2] == MSG_START.codeUnitAt(2) &&
                bytes[i + 3] == MSG_START.codeUnitAt(3))
            {
                return i;
            }
        }
        return -1;
    }

    static int getHeaderSize(List<int> bytes)
    {
        // Header Size : 4 bytes after "ISCP"
        if (MSG_START.length + 4 <= bytes.length)
        {
            final ByteBuffer d = Uint8List
                .fromList(bytes.sublist(MSG_START.length, MSG_START.length + 4))
                .buffer;
            return ByteData.view(d).getUint32(0);
        }
        return -1;
    }

    static int getDataSize(List<int> bytes)
    {
        // Data Size : 4 bytes after Header Size
        if (MSG_START.length + 8 <= bytes.length)
        {
            final ByteBuffer d = Uint8List
                .fromList(bytes.sublist(MSG_START.length + 4, MSG_START.length + 8))
                .buffer;
            return ByteData.view(d).getUint32(0);
        }
        return -1;
    }

    static int _getVersion(List<int> bytes)
    {
        // Version : 1 byte after Data Size
        if (MSG_START.length + 9 <= bytes.length)
        {
            final ByteBuffer d = Uint8List
                .fromList(bytes.sublist(MSG_START.length + 8, MSG_START.length + 9))
                .buffer;
            return ByteData.view(d).getUint8(0);
        }
        return -1;
    }

    static bool _isSpecialCharacter(int val)
    {
        return val == EOF || val == CR || val == LF;
    }

    String _getRawMessage(List<int> bytes)
    {
        if (_headerSize > 0 && _dataSize > 0 && _headerSize + _dataSize <= bytes.length)
        {
            int endIndex = _headerSize;
            for (; endIndex < _headerSize + _dataSize; endIndex++)
            {
                final int val = bytes[endIndex];
                if (_isSpecialCharacter(val))
                {
                    break;
                }
            }
            return Convert.decodeUtf8(bytes.sublist(_headerSize, endIndex));
        }
        return INVALID_MSG;
    }

    List<int>? getBytes()
    {
        final List<int> parametersBin = utf8.encode(getParameters);
        final int dSize = 2 + getCode.length + parametersBin.length + 1;

        if (_headerSize + dSize < MIN_MSG_LENGTH)
        {
            return null;
        }
        final List<int> bytes = List<int>.filled(_headerSize + dSize, 0);

        // Message header
        List.copyRange(bytes, 0, MSG_START.codeUnits, 0, 4);

        // Header size
        final ByteData uint32 = ByteData(4);
        uint32.setUint32(0, _headerSize);
        List.copyRange(bytes, 4, uint32.buffer.asUint8List(), 0, 4);

        // Data size
        uint32.setUint32(0, dSize);
        List.copyRange(bytes, 8, uint32.buffer.asUint8List(), 0, 4);

        // Version
        bytes[12] = _version;

        // CMD
        bytes[16] = START_CHAR.codeUnitAt(0);
        bytes[17] = _modelCategoryId.codeUnitAt(0);
        List.copyRange(bytes, 18, getCode.codeUnits, 0, max(3, getCode.length));

        // Parameters
        List.copyRange(bytes, 21, parametersBin, 0, parametersBin.length);

        // End char
        bytes[21 + parametersBin.length] = LF;

        return bytes;
    }

    bool isQuery()
    => _parameters.toUpperCase() == EISCPMessage.QUERY;
}