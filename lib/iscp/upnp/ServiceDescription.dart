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
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:xml/xml.dart';

import '../../utils/Convert.dart';
import '../../utils/Logging.dart';
import '../../utils/UrlLoader.dart';
import 'Action.dart';
import 'DeviceDescription.dart';
import 'MapperUtils.dart';

/// A data type definition.
enum DataTypeValue
{
    /// Unsigned 1 byte int. Same format as [int] but without the leading sign.
    ui1,

    /// Unsigned 2 byte int. Same format as [int] but without the leading sign.
    ui2,

    /// Unsigned 4 byte int. Same format as [int] but without the leading sign.
    ui4,

    /// Unsigned 8 byte int. Same format as [int] but without the leading sign.
    ui8,

    /// 1 byte int. Same format as [int].
    i1,

    /// 2 byte int. Same format as [int].
    i2,

    /// 4 byte int. Same format as [int].
    ///
    /// Shall be between `-2147483648` and `2147483647`.
    i4,

    /// 8 Byte int. Same format as [int].
    ///
    /// Shall be between `−9,223,372,036,854,775,808` and `9,223,372,036,854,775,807`.
    i8,

    /// Fixed point, integer number. Is allowed to have leading zeros, which should be ignored
    /// by the recipient. (No currency symbol and no grouping of digits)
    int,

    /// 4 byte float. Same format as [float].
    ///
    /// Shall be between `3.40282347E+38` to `1.17549435E-38`.
    r4,

    /// 8 byte float. Same format as [float].
    ///
    /// Shall be between `-1.79769313486232E308` and `-4.94065645841247E-324` for negative values.
    /// Shall be between `4.94065645841247E-324` and `1.79769313486232E308` for positive values.
    ///
    /// See: IEEE 64-bit (8-Byte) double
    r8,

    /// Same as [r8].
    number,

    /// Same as [r8] but with no more than 14 digits to the left of the decimal point
    /// and no more than 4 to the right.
    fixed_14_4,

    /// Floating point number.
    ///
    /// Mantissa and/or exponent is allowed to have a leading sign and leading zeros.
    ///
    /// Decimal character in mantissa is a period `"."`.
    ///
    /// Mantissa separated from exponent by `"E"`.
    float,

    /// Unicode string; one character long.
    char,

    /// Unicode string; no limit on length.
    string,

    /// Date in a subset of ISO 8601 format without time data.
    date,

    /// Date in ISO 8601 format with allowed time but no time zone.
    dateTime,

    /// Date in ISO 8601 format with allowed time and time zone.
    // ignore: constant_identifier_names
    dateTime_tz,

    /// Time in a subset of ISO 8601 format with neither date nor time zone.
    time,

    /// Time in a subset of ISO 8601 format with no date.
    // ignore: constant_identifier_names
    time_tz,

    /// `"0"` for false or `"1"` for true.
    boolean,

    /// MIME-style Base64 encoded binary BLOB.
    // ignore: constant_identifier_names
    bin_base64,

    /// Hexadecimal digits represented by octets.
    // ignore: constant_identifier_names
    bin_hex,

    /// Universal Resource Identifier.
    uri,

    /// Universally Unique ID.
    uuid
}

Map<String, DataTypeValue> _dataTypeMap = 
{
    for (var v in DataTypeValue.values) v.name: v,
    'fixed.14.4': DataTypeValue.fixed_14_4,
    'dateTime.tz': DataTypeValue.dateTime_tz,
    'time.tz': DataTypeValue.time_tz,
    'bin.base64': DataTypeValue.bin_base64,
    'bin.hex': DataTypeValue.bin_hex
};

/// A datatype that a [StateVariable] contains.
class DataType
{
    /// The underlying type.
    final DataTypeValue type;

    DataType(this.type);

    factory DataType.parse(XmlNode xml)
    {
        final DataTypeValue type = (_dataTypeMap.keys.contains(xml.innerText)) ?
            _dataTypeMap[xml.innerText]! : DataTypeValue.string;
        return DataType(type);
    }
}

/// The architecture on which the [Device] or [ServiceDescription] was implemented.
class SpecVersion
{
    final int major;
    final int minor;

    SpecVersion({required this.major, required this.minor});

    factory SpecVersion.parse(XmlNode node)
    => SpecVersion(
        major: int.parse(node.getElement('major')!.innerText),
        minor: int.parse(node.getElement('minor')!.innerText));
}

/// Defines bounds for legal numeric values.
class AllowedValueRange
{
    /// Inclusive lower bound.
    final String minimum;

    /// Inclusive upper bound.
    final String maximum;

    /// Defines the set of allowed values permitted for the state variable between
    /// {minimum} and {maximum}.
    ///
    /// `{maximum} = {minimum} + n * {step}`.
    final int step;

    AllowedValueRange({
        required this.minimum,
        required this.maximum,
        int? step
    }) : step = step ?? 1;

    factory AllowedValueRange.parse(XmlNode xml)
    {
        final String? step = xml.getElement('step')?.innerText;
        return AllowedValueRange(
            minimum: xml.getElement('minimum')!.innerText,
            maximum: xml.getElement('maximum')!.innerText,
            step: step == null ? 1 : int.parse(step)
        );
    }
}

/// A variable that represents a value in the service's state.
class StateVariable
{
    /// If event messages are generated when the value of this variable changes.
    final bool? sendEvents;

    /// Defines if event messages will be delivered using multicast eventing.
    final bool? multicast;

    /// Name of the state variable.
    final String name;

    /// DataType of this variable.
    final DataType dataType;

    /// Expected, initial value.
    final String? defaultValue;

    /// Enumerates legal string values.
    final List<String>? allowedValues;

    /// Defines bounds and resolution for numeric values.
    final AllowedValueRange? allowedValueRange;

    StateVariable({
        this.sendEvents,
        this.multicast,
        required this.name,
        required this.dataType,
        this.defaultValue,
        this.allowedValues,
        this.allowedValueRange
    });

    factory StateVariable.parse(XmlNode xml)
    {
        final sendEvents = xml.getAttribute('sendEvents');
        final multicast = xml.getAttribute('multicast');
        final allowedValueRange = xml.getElement('allowedValueRange');
        return StateVariable(
            sendEvents: sendEvents != null ? sendEvents == 'yes' : false,
            multicast: multicast != null ? multicast == 'yes' : false,
            name: xml.getElement('name')!.innerText,
            dataType: DataType.parse(xml.getElement('dataType')!),
            defaultValue: xml.getElement('defaultValue')?.innerText,
            allowedValues: MapperUtils.nodeMapper(xml.getElement('allowedValueList'), 'allowedValue', (x) => x.innerText),
            allowedValueRange: allowedValueRange != null ? AllowedValueRange.parse(allowedValueRange) : null
        );
    }
}

/// The state of a [ServiceDescription].
class ServiceStateTable
{
    /// List of [StateVariable]s.
    final List<StateVariable> stateVariables;

    ServiceStateTable({required this.stateVariables});

    factory ServiceStateTable.parse(XmlNode xml)
    => ServiceStateTable(
        stateVariables: MapperUtils.nodeMapper<StateVariable>(xml, 'stateVariable', StateVariable.parse));
}

/// Defines [Action]s and their [Argument]s, and [StateVariable]s and
/// their [DataType], [AllowedValueRange], and event characteristics.
class ServiceDescription
{
    /// Service data
    final ServiceData service;

    /// The raw XML document
    final XmlDocument xml;

    final String namespace;

    /// The lowest version of the architecture on which the service can be implemented.
    final SpecVersion specVersion;

    /// List of actions available for this service.
    final List<Action> actions;

    /// Collection of state variables for this service.
    final ServiceStateTable serviceStateTable;

    ServiceDescription(
        this.service,
        this.xml, {
            required this.namespace,
            required this.specVersion,
            required this.actions,
            required this.serviceStateTable
        }
    );

    @override
    String toString()
    => service.serviceId.toString()
        + ": {actions: " + actions.length.toString()
        + ", serviceState: " + serviceStateTable.stateVariables.length.toString()
        + "}";

    factory ServiceDescription.parse(final ServiceData s, final XmlDocument xml)
    {
        final root = xml.getElement('scpd');
        final ServiceDescription svc = ServiceDescription(
            s, xml,
            namespace: root!.getAttribute('xmlns')!,
            specVersion: SpecVersion.parse(root.getElement('specVersion')!),
            actions: MapperUtils.nodeMapper<Action>(root.getElement('actionList'), 'action', (x) => Action.parse(x)),
            serviceStateTable: ServiceStateTable.parse(root.getElement('serviceStateTable')!)
        );
        svc.actions.forEach((a) => a.service = svc.service);
        return svc;
    }

    Action? action(String name)
    => actions.firstWhereOrNull((s) => s.name == name);

    static Future<ServiceDescription?> requestService(final DeviceDescription? device, final String serviceName)
    {
        if (device == null || device.mSearch == null || device.mSearch!.location == null)
        {
            return Future.value(null);
        }
        final String origin = device.mSearch!.location!.origin.toString();
        final ServiceData? service = device.findServiceById(serviceName);
        if (service != null)
        {
            Logging.info(ServiceDescription, "found " + serviceName + " on " + origin + ": " + service.toString());
            final String url = origin + service.scpdurl.toString();
            return UrlLoader().loadFromUrl(url).then((Uint8List? receiverData)
                {
                    if (receiverData != null)
                    {
                        try
                        {
                            final String xml = Convert.decodeUtf8(receiverData);
                            return ServiceDescription.parse(service, XmlDocument.parse(xml));
                        }
                        on Exception catch(e)
                        {
                            Logging.info(ServiceDescription, "cannot process UPnP service description from " + url + ": " + e.toString());
                        }
                    }
                    return null;
                }
            );
        }
        return Future.value(null);
    }
}