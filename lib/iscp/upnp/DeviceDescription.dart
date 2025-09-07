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

import 'dart:collection';

import 'package:xml/xml.dart';

/// Utility class that separates a UPnP device type string into its component parts.
class DeviceType
{
    /// The full UPnP device type.
    final String uri;

    DeviceType({required this.uri});

    List<String> get _fields
    => uri.split(':');

    /// Domain name of this device.
    String get domainName
    => _fields[1];

    /// Type of this device.
    String get deviceType
    => _fields[3];

    /// Version of this device.
    int get version
    => int.parse(_fields[4]);

    @override
    String toString()
    => domainName + "/" + deviceType + "/" + version.toString();
}

/// Icon to depict a [Device] in a control point UI.
class DeviceIcon
{
    /// Icon's MIME type.
    final String mimeType;

    /// Horizontal dimension of the icon, in pixels.
    final int width;

    /// Vertical dimensions of the icon, in pixels.
    final int height;

    /// Number of color bits per pixel.
    final String depth;

    /// URL at which the device description is located.
    final Uri url;

    DeviceIcon({
        required this.mimeType,
        required this.width,
        required this.height,
        required this.depth,
        required this.url
    });

    factory DeviceIcon.parse(XmlElement xml)
    {
        return DeviceIcon(
            mimeType: xml.getElement('mimetype')!.innerText,
            width: int.parse(xml.getElement('width')!.innerText),
            height: int.parse(xml.getElement('height')!.innerText),
            depth: xml.getElement('depth')!.innerText,
            url: Uri.parse(xml.getElement('url')!.innerText),
        );
    }

    @override
    String toString()
    => width.toString() + "x" + height.toString() + "/" + url.toString();
}

/// This class splits up a single identifier into its component parts.
class ServiceId
{
    final String _fields;
    final String domain;
    final String serviceId;

    ServiceId(this._fields, this.domain, this.serviceId);

    factory ServiceId.parse(String str)
    {
        final fields = str.split(':');
        return ServiceId(str, fields[1], fields[3]);
    }

    @override
    String toString()
    => _fields;
}

/// A service as defined in a [DeviceDescription].
class ServiceData
{
    /// UPnP service type.
    final String serviceType;

    final String serviceVersion;

    /// Service identifier.
    final ServiceId serviceId;

    /// URL for service description.
    final Uri scpdurl;

    /// URL for control.
    final Uri controlUrl;

    /// URL for eventing.
    final Uri eventSubUrl;

    ServiceData({
        required this.serviceType,
        required this.serviceVersion,
        required this.serviceId,
        required this.scpdurl,
        required this.controlUrl,
        required this.eventSubUrl
    });

    factory ServiceData.parse(XmlNode xml)
    {
        final String? scpdurl = xml.getElement('SCPDURL')?.innerText;
        final String? controlUrl = xml.getElement('controlURL')?.innerText;
        final String? eventSubUrl = xml.getElement('eventSubURL')?.innerText;
        final String serviceType = xml.getElement('serviceType')!.innerText;
        final List<String> serviceTypeFields = serviceType.split(':');
        return ServiceData(
            serviceType: serviceTypeFields[serviceTypeFields.length - 2],
            serviceVersion: serviceTypeFields[serviceTypeFields.length - 1],
            serviceId: ServiceId.parse(xml.getElement('serviceId')!.innerText),
            scpdurl: Uri.parse(scpdurl!),
            controlUrl: Uri.parse(controlUrl!),
            eventSubUrl: Uri.parse(eventSubUrl!)
        );
    }
}

/// A collection of vendor-specific information, definitions of all embedded
/// devices, URL for presentation of the device, and listings for all services,
/// including URLs for control and eventing
class DeviceDescription
{
    /// UPnP device type.
    final DeviceType deviceType;

    final String friendlyName;

    /// Manufacturer's name.
    final String manufacturer;

    /// Web site for [manufacturer].
    final Uri? manufacturerUrl;

    /// Long description for end user.
    final String? modelDescription;

    /// Model name.
    final String modelName;

    /// Model number.
    final String? modelNumber;

    /// Web site for model.
    final Uri? modelUrl;

    /// Serial number.
    final String? serialNumber;

    /// A universally-unique identifier for the device, whether root or embedded.
    final String udn;

    /// A 12-digit, all numeric code that identifies the consumer packages.
    final String? upc;

    /// List of icons that visually represent this device.
    final List<DeviceIcon> iconList;

    /// List of services available on this device.
    final List<ServiceData> services;

    /// List of child devices on this device.
    final List<DeviceDescription> devices;

    /// URL to presentation for this device.
    final Uri? presentationUrl;

    /// Extension properties. These provide manufacturer-specific information for non-UPnP spec behaviors.
    final UnmodifiableListView<XmlElement> extensions;

    DeviceDescription({
        required this.deviceType,
        required this.friendlyName,
        required this.manufacturer,
        this.manufacturerUrl,
        this.modelDescription,
        required this.modelName,
        this.modelNumber,
        this.modelUrl,
        this.serialNumber,
        required this.udn,
        this.upc,
        required this.iconList,
        required this.services,
        required this.devices,
        this.presentationUrl,
        required this.extensions
    });

    @override
    String toString()
    => "deviceType: " + deviceType.toString()
        + ", friendlyName: " + friendlyName.toString()
        + ", manufacturer: " + manufacturer.toString()
        + ", modelName: " + modelName.toString()
        + ", modelNumber: " + modelNumber.toString()
        + ", icons: " + iconList.toString()
        + ", services: " + services.length.toString()
        + ", devices: " + devices.length.toString()
        + ", isISCP: " + isISCP.toString()
        + ", isDCP: " + isDCP.toString();

    bool get isISCP
    => ["onkyo", "pioneer", "integra"].any((t) => manufacturer.toLowerCase().contains(t));

    bool get isDCP
    => ["denon", "marantz"].any((t) => manufacturer.toLowerCase().contains(t));

    factory DeviceDescription.parse(XmlNode xml)
    {
        final XmlElement? presentationUrl = xml.getElement('presentationURL');
        final XmlElement? modelUrl = xml.getElement('modelURL');
        final XmlElement? manufacturerUrl = xml.getElement('manufacturerURL');
        final List<XmlElement> extensions =
            xml.nodes.whereType<XmlElement>().where((x) => x.namespacePrefix != null).toList();

        return DeviceDescription(
            deviceType: DeviceType(uri: xml.getElement('deviceType')!.innerText),
            friendlyName: xml.getElement('friendlyName')!.innerText,
            manufacturer: xml.getElement('manufacturer')!.innerText,
            manufacturerUrl: manufacturerUrl != null ? Uri.parse(manufacturerUrl.innerText) : null,
            modelDescription: xml.getElement('modelDescription')?.innerText,
            modelName: xml.getElement('modelName')!.innerText,
            modelNumber: xml.getElement('modelNumber')?.innerText,
            modelUrl: modelUrl != null ? Uri.parse(modelUrl.innerText) : null,
            serialNumber: xml.getElement('serialNumber')?.innerText,
            udn: xml.getElement('UDN')!.innerText,
            upc: xml.getElement('UPC')?.innerText,
            iconList: _elementMapper(xml.getElement('iconList'), 'icon', DeviceIcon.parse),
            services: _nodeMapper(xml.getElement('serviceList'), 'service', ServiceData.parse),
            devices: _nodeMapper(xml.getElement('deviceList'), 'device', DeviceDescription.parse),
            presentationUrl: presentationUrl != null ? Uri.parse(presentationUrl.innerText) : null,
            extensions: UnmodifiableListView(extensions)
        );
    }

    static _elementMapper<T>(XmlNode? xml, String elementType, T Function(XmlElement) buildFn)
    => xml?.findAllElements(elementType).map<T>(buildFn).toList() ?? [];

    static _nodeMapper<T>(XmlNode? xml,String elementType, T Function(XmlNode) buildFn)
    => xml?.findAllElements(elementType).map<T>(buildFn).toList() ?? [];
}
