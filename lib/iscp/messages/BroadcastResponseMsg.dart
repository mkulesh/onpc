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
 */

import 'dart:io';

import "../../utils/Convert.dart";
import "../ConnectionIf.dart";
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";
import "../upnp/DeviceDescription.dart";

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

class BroadcastResponseMsg extends ISCPMessage with ProtoTypeMix
{
    static const String CODE = "ECN";

    String? _model;
    String? _destinationArea;

    // Used to store optional MAC address
    String? _identifier;

    // Used to store optional favourite name
    String? _alias;

    // Used to store optional friendly name
    String? _friendlyName;

    // Optional UPnP device description message
    DeviceDescription? _upnpDescription;

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
        setProtoType(ProtoType.ISCP);
        // _alias and _friendlyName still be null - not presented in ISCP
    }

    BroadcastResponseMsg.alias(final String host, final String port, final String alias, final String? identifier) : super.output(CODE, "")
    {
        setHost(host);
        setPort(ISCPMessage.nonNullInteger(port, 10, 0));
        this._identifier = identifier;
        this._alias = alias;
        setProtoType(getPort == DCP_PORT ? ProtoType.DCP : ProtoType.ISCP);
        // all other fields still be null
    }

    BroadcastResponseMsg.connection(ConnectionIf connection, final String? alias, final String? identifier) : super.output(CODE, "")
    {
        setHostAndPort(connection);
        this._identifier = identifier;
        this._alias = alias;
        setProtoType(getPort == DCP_PORT ? ProtoType.DCP : ProtoType.ISCP);
        // all other fields still be null
    }

    BroadcastResponseMsg.ssdp(InternetAddress hostAddress, ProtoType p, final DeviceDescription d) : super.output(CODE, "")
    {
        setHost(hostAddress.address);
        setPort(p == ProtoType.ISCP? ISCP_PORT : DCP_PORT);
        setProtoType(p);
        this._upnpDescription = d;
        this._model = d.modelName;
        this._friendlyName = d.friendlyName;
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
            + "; " + Convert.enumToString(protoType)
            + (_model != null ? "; MODEL=" + _model! : "")
            + (_destinationArea != null ? "; DST=" + _destinationArea! : "")
            + (_identifier != null ? "; ID=" + _identifier! : "")
            + (_alias != null ? "; ALIAS=" + _alias! : "")
            + (_friendlyName != null ? "; FRIENDLY_NAME=" + _friendlyName! : "") + "]";

    String getDescription(bool useFavoriteName, bool useFriendlyName)
    {
        if (useFavoriteName && _alias != null)
        {
            return _alias!;
        }
        if (useFriendlyName && _friendlyName != null)
        {
            return _friendlyName!;
        }
        return getHost + "/" + (_model != null ? _model! : "unknown");
    }

    String get getIdentifier
    => _identifier ?? "";

    String? get alias
    => _alias;

    String? get friendlyName
    => _friendlyName;

    set friendlyName(String? value)
    {
        _friendlyName = value;
    }

    DeviceDescription? get upnpDescription
    => _upnpDescription;
}
