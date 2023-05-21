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
// @dart=2.9
import "../../constants/Strings.dart";
import "../EISCPMessage.dart";
import "EnumParameterMsg.dart";

enum GoogleCastAnalytics
{
    NONE,
    OFF,
    ON
}

/*
 * Google Cast Share Usage Data Command
 */
class GoogleCastAnalyticsMsg extends EnumParameterMsg<GoogleCastAnalytics>
{
    static const String CODE = "NGU";

    static const ExtEnum<GoogleCastAnalytics> ValueEnum = ExtEnum<GoogleCastAnalytics>([
        EnumItem.code(GoogleCastAnalytics.NONE, "N/A",
            descrList: Strings.l_device_two_way_switch_none, defValue: true),
        EnumItem.code(GoogleCastAnalytics.OFF, "00",
            descrList: Strings.l_device_two_way_switch_off),
        EnumItem.code(GoogleCastAnalytics.ON, "01",
            descrList: Strings.l_device_two_way_switch_on)
    ]);

    GoogleCastAnalyticsMsg(EISCPMessage raw) : super(CODE, raw, ValueEnum);

    GoogleCastAnalyticsMsg.output(GoogleCastAnalytics v) : super.output(CODE, v, ValueEnum);

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }

    static GoogleCastAnalytics toggle(GoogleCastAnalytics s)
    {
        return (s == GoogleCastAnalytics.OFF) ? GoogleCastAnalytics.ON : GoogleCastAnalytics.OFF;
    }
}
