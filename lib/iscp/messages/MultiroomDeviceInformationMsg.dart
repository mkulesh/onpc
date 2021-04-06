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
import "package:xml/xml.dart" as xml;

import "../../constants/Strings.dart";
import "../../utils/Logging.dart";
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";
import 'EnumParameterMsg.dart';

enum ChannelType
{
    ST, FL, FR, NONE
}

enum RoleType
{
    SRC, DST, NONE
}

class MultiroomZone
{
    static const int NO_GROUP = 0;

    static const ExtEnum<ChannelType> ChannelTypeEnum = ExtEnum<ChannelType>([
        EnumItem.code(ChannelType.ST, "ST"),
        EnumItem.code(ChannelType.FL, "FL"),
        EnumItem.code(ChannelType.FR, "FR"),
        EnumItem.code(ChannelType.NONE, "NONE", defValue: true)
    ]);

    static const ExtEnum<RoleType> RoleTypeEnum = ExtEnum<RoleType>([
        EnumItem.code(RoleType.SRC, "SRC", descrList: Strings.l_multiroom_master),
        EnumItem.code(RoleType.DST, "DST", descrList: Strings.l_multiroom_slave),
        EnumItem.code(RoleType.NONE, "NONE", descrList: Strings.l_multiroom_none, defValue: true)
    ]);

    int _id;
    int _groupid;
    EnumItem<ChannelType> _ch;
    EnumItem<RoleType> _role;
    String _roomname;
    String _groupname;
    int _powerstate;
    int _iconid;
    int _color;
    int _delay;

    MultiroomZone.fromXml(xml.XmlElement e)
    {
        _id = ISCPMessage.nonNullInteger(e.getAttribute("id"), 10, 0);
        _groupid = ISCPMessage.nonNullInteger(e.getAttribute("groupid"), 10, NO_GROUP);
        _ch = ChannelTypeEnum.valueByCode(ISCPMessage.nonNullString(e.getAttribute("ch")));
        _role = RoleTypeEnum.valueByCode(ISCPMessage.nonNullString(e.getAttribute("role")));
        _roomname = ISCPMessage.nonNullString(e.getAttribute("roomname"));
        _groupname = ISCPMessage.nonNullString(e.getAttribute("groupname"));
        _powerstate = ISCPMessage.nonNullInteger(e.getAttribute("powerstate"), 10, -1);
        _iconid = ISCPMessage.nonNullInteger(e.getAttribute("iconid"), 10, -1);
        _color = ISCPMessage.nonNullInteger(e.getAttribute("color"), 10, -1);
        _delay = ISCPMessage.nonNullInteger(e.getAttribute("delay"), 10, -1);
    }

    @override
    String toString()
    => _id.toString() + ": groupid=" + _groupid.toString()
            + ", ch=" + _ch.toString()
            + ", role=" + _role.toString()
            + ", roomname=" + _roomname
            + ", groupname=" + _groupname
            + ", powerstate=" + _powerstate.toString()
            + ", iconid=" + _iconid.toString()
            + ", color=" + _color.toString()
            + ", delay=" + _delay.toString();

    int get id
    => _id;

    int get groupid
    => _groupid;

    EnumItem<RoleType> get role
    => _role;

    EnumItem<ChannelType> get ch
    => _ch;
}

/*
 * Multiroom Device Information Command: gets the Multiroom Device Information as an XML message:
 * <mdi>
 *   <deviceid>111111111111</deviceid>
 *   <currentversion>100</currentversion>
 *   <zonelist>
 *　  <zone id="1" groupid="3" ch="ST" role="src" roomname="" groupname="" powerstate="1" iconid="1" color="1" delay="1000"/>
 *    <zone id="2" groupid="3" ch="ST" role="dst" roomname="" groupname="" powerstate="1" iconid="1" color="1" delay="1000"/>
 *    <zone id="3" groupid="1" ch="ST" role="none" roomname="" groupname="" powerstate="1" iconid="1" color="1" delay="1000"/>
 *   </zonelist>
 *  </mdi>
 */
class MultiroomDeviceInformationMsg extends ISCPMessage
{
    static const String CODE = "MDI";
    static const int DEFAULT_ZONE = 1;

    final Map<String, String> _properties = Map();
    final List<MultiroomZone> _zones = [];

    MultiroomDeviceInformationMsg(EISCPMessage raw) : super(CODE, raw)
    {
        _parseXml();
    }

    void _parseXml()
    {
        final xml.XmlDocument document = xml.XmlDocument.parse(getData);

        _properties["deviceid"] = ISCPMessage.getProperty(document, "deviceid");
        _properties["currentversion"] = ISCPMessage.getProperty(document, "currentversion");
        Logging.info(this, "  properties: " + _properties.toString());

        document.findAllElements("zone").forEach((element)
        {
            final String id = element.getAttribute("id");
            if (id != null)
            {
                _zones.add(MultiroomZone.fromXml(element));
            }
        });
        _zones.forEach((z)
        {
            Logging.info(this, "  zone: " + z.toString());
        });
    }

    List<MultiroomZone> get zones
    => _zones;

    String getProperty(final String name)
    {
        final String prop = _properties[name];
        return prop == null ? "" : prop;
    }

    EnumItem<RoleType> getRole(int zone)
    {
        final MultiroomZone z = _zones.firstWhere((z) => z.id == zone, orElse: () => null);
        return z != null ? z.role : MultiroomZone.RoleTypeEnum.defValue;
    }

    EnumItem<ChannelType> getChannelType(int zone)
    {
        final MultiroomZone z = _zones.firstWhere((z) => z.id == zone, orElse: () => null);
        return z != null ? z.ch : MultiroomZone.ChannelTypeEnum.defValue;
    }

    int getGroupId(int zone)
    {
        final MultiroomZone z = _zones.firstWhere((z) => z.id == zone, orElse: () => null);
        return z != null ? z.groupid : MultiroomZone.NO_GROUP;
    }
}
