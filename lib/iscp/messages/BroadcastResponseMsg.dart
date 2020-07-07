/*
 * Copyright (C) 2019. Mikhail Kulesh
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

import "../ConnectionIf.dart";
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";

/*
 * Broadcast Response Message
 *
 * !cECNnnnnnn/ppppp/dd/iiiiiiiiiiii:
 * c: device category
 * nnnnnnn: model name of device
 * ppppp: ISCP port number
 * dd: destination area of device
 * iiiiiiiiiiii: Identifier
 * /: Separator
 */

typedef OnDeviceFound = void Function(BroadcastResponseMsg msg);

class BroadcastResponseMsg extends ISCPMessage
{
    static const String CODE = "ECN";

    String _model;
    String _destinationArea;
    String _identifier;
    String _alias;

    BroadcastResponseMsg(InternetAddress hostAddress, EISCPMessage raw) : super(CODE, raw)
    {
        setHost(hostAddress.address);
        final List<String> tokens = getData.split("/");
        if (tokens.isNotEmpty)
        {
            _model = tokens[0];
        }
        if (tokens.length > 1)
        {
            setPort(ISCPMessage.nonNullInteger(tokens[1], 10, 0));
        }
        if (tokens.length > 2)
        {
            _destinationArea = tokens[2];
        }
        if (tokens.length > 3)
        {
            _identifier = _trim(tokens[3]);
        }
        // _alias still be null
    }

    BroadcastResponseMsg.alias(final String host, final String port, final String alias, final String identifier) : super.output(CODE, "")
    {
        setHost(host);
        setPort(ISCPMessage.nonNullInteger(port, 10, 0));
        this._identifier = identifier;
        this._alias = alias;
        // all other fields still be null
    }

    BroadcastResponseMsg.connection(ConnectionIf connection, final String alias, final String identifier) : super.output(CODE, "")
    {
        setHostAndPort(connection);
        this._identifier = identifier;
        this._alias = alias;
        // all other fields still be null
    }

    String _trim(String token)
    {
        String res = "";
        for (int i = 0; i < token.length; i++)
        {
            if (token.codeUnitAt(i) == EISCPMessage.EOM)
            {
                break;
            }
            res += token[i];
        }
        return res;
    }

    @override
    String toString()
    => super.toString() + "[HOST=" + getHostAndPort
            + (_model != null ? "; MODEL=" + _model : "")
            + (_destinationArea != null ? "; DST=" + _destinationArea : "")
            + (_identifier != null ? "; ID=" + _identifier : "")
            + (_alias != null ? "; ALIAS=" + _alias : "") + "]";

    String getDescription()
    => getHost + "/" + (alias != null ? alias : (_model != null ? _model : "unknown"));

    String get getIdentifier
    => _identifier == null ? "" : _identifier;

    String get alias
    => _alias;

    set alias(String value)
    {
        _alias = value;
    }
}
