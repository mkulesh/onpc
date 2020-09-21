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

import "../../constants/Strings.dart";
import "../../utils/Convert.dart";
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";

class EnumItem<T>
{
    final T key;
    final String code;
    final String name;
    final String descr;
    final List<String> descrList;
    final String icon;
    final bool defValue, isMediaList, upperCase;

    const EnumItem(this.key,
    {
        this.code,
        this.name,
        this.descr,
        this.descrList,
        this.icon,
        this.defValue = false,
        this.isMediaList = false,
        this.upperCase = true
    });

    // The char constructor uses interprets the given code as case-sensitive string
    const EnumItem.char(this.key, this.code,
    {
        this.name,
        this.descr,
        this.descrList,
        this.icon,
        this.defValue = false,
        this.isMediaList = false,
        this.upperCase = false
    });

    // This constructor uses interprets the given code as case-insensitive string
    const EnumItem.code(this.key, this.code,
    {
        this.name,
        this.descr,
        this.descrList,
        this.icon,
        this.defValue = false,
        this.isMediaList = false,
        this.upperCase = true
    });

    String get getKey
    => Convert.enumToString(key);

    String get getCode
    => code == null ? getKey : (upperCase ? code.toUpperCase() : code);

    bool isCodeEqual(String c)
    => upperCase ? (getCode == c.toUpperCase()) : (getCode == c);

    bool get isImageValid
    => icon != null;

    String get description
    => descr ?? descrList[Strings.language];

    @override
    String toString()
    => getKey;
}

class ExtEnum<T>
{
    final List<EnumItem<T>> values;

    const ExtEnum(this.values);

    EnumItem<T> get defValue
    => values.firstWhere((e) => e.defValue, orElse: () => null);

    EnumItem<T> valueByCode(String code)
    => values.firstWhere((e) => e.isCodeEqual(code), orElse: () => defValue);

    EnumItem<T> valueByKey(T key)
    => values.firstWhere((e) => e.key == key, orElse: () => defValue);
}

class EnumParameterMsg<T> extends ISCPMessage
{
    EnumItem<T> _value;

    EnumParameterMsg(String code, EISCPMessage raw, final ExtEnum<T> extEnum) : super(code, raw)
    {
        _value = extEnum.valueByCode(getData);
    }

    EnumParameterMsg.output(String code, T status, final ExtEnum<T> extEnum) :
            super.output(code, extEnum.valueByKey(status).getCode)
    {
        _value = extEnum.valueByKey(status);
    }

    EnumItem<T> get getValue
    => _value;

    @override
    String toString()
    => super.toString() + "[VALUE=" + _value.toString() + "]";
}

class EnumParameterZonedMsg<T> extends ZonedMessage
{
    EnumItem<T> _value;

    EnumParameterZonedMsg(List<String> zones, EISCPMessage raw, final ExtEnum<T> extEnum) : super(zones, raw)
    {
        _value = extEnum.valueByCode(getData);
    }

    EnumParameterZonedMsg.output(List<String> zones, int zoneIndex, T status, final ExtEnum<T> extEnum) :
            super.output(zones, zoneIndex, extEnum.valueByKey(status).getCode)
    {
        _value = extEnum.valueByKey(status);
    }

    EnumItem<T> get getValue
    => _value;

    @override
    String toString()
    => super.toString() + "[VALUE=" + _value.toString() + "]";
}