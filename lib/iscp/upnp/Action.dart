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

import 'dart:io';

import 'package:sprintf/sprintf.dart';
import 'package:xml/xml.dart';

import 'DeviceDescription.dart';
import 'MapperUtils.dart';

enum Direction
{
    input("in"),
    output("out");

    const Direction(this.value);

    factory Direction.fromString(String value)
    {
        for (final v in Direction.values)
        {
            if (v.value == value)
            {
                return v;
            }
        }
        throw 'Unknown argument direction';
    }

    final String value;
}

/// A parameter provided to, or returned from, an [Action] during invocation.
class Argument
{
    /// Name of formal parameter.
    final String name;

    /// Defines if this argument is input or output.
    final Direction direction;

    /// Identifies at most one argument as a return value.
    final String? retval;

    /// The name of a [StateVariable] defined in the same [ServiceData] that
    /// defines the data type of this argument.
    ///
    /// There is not necessarily any semantic relationship between this argument
    /// and the related state variable.
    final String relatedStateVariable;

    Argument({
        required this.name,
        required this.direction,
        this.retval,
        required this.relatedStateVariable
    });

    factory Argument.parse(XmlNode xml)
    => Argument(
        name: xml.getElement('name')!.innerText,
        direction: Direction.fromString(xml.getElement('direction')!.innerText),
        retval: xml.getElement('retval')?.innerText,
        relatedStateVariable: xml.getElement('relatedStateVariable')!.innerText);
}

/// An object that represents an action that can be invoked on a remote [ServiceDescription].
class Action
{
    // Templates for XML message
    static final String SOAP_URN = 'urn:schemas-upnp-org:service:%s:%s';
    static final String SOAP_ARG = '<%s>%s</%s>';
    static final String SOAP_BODY =
        '''<?xml version="1.0"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:%s xmlns:u="%s">%s</u:%s></s:Body></s:Envelope>''';
    static final SOAP_HEAD =
        {
            HttpHeaders.contentTypeHeader: 'text/xml; charset="utf-8"'
        };
    static final String SOAP_ACT_HEAD = 'SOAPAction';

    /// The name of this action.
    final String name;

    /// Input and output arguments.
    final List<Argument>? arguments;

    /// Parent service data
    late ServiceData service;

    Action({required this.name, this.arguments});

    factory Action.parse(XmlNode xml)
    => Action(
        name: xml.getElement('name')!.innerText,
        arguments: MapperUtils.nodeMapper(xml.getElement('argumentList'), 'argument', Argument.parse));

    String _args(Map<String, dynamic> args)
    => args.keys.where((key) => args[key] != null).map((key)
        {
            return sprintf(SOAP_ARG, [key, args[key].toString(), key]);
        }
    ).join('\n');

    String buildXmlBody(final Map<String, dynamic> params)
    {
        final String urn = sprintf(SOAP_URN, [service.serviceId.serviceId, service.serviceVersion]);
        return sprintf(SOAP_BODY, [name, urn, _args(params), name]);
    }

    Map<String, String> buildXmlHeader()
    {
        final String urn = sprintf(SOAP_URN, [service.serviceId.serviceId, service.serviceVersion]);
        return
        {
            ...SOAP_HEAD,
            SOAP_ACT_HEAD: '"$urn#$name"'
        };
    }
}