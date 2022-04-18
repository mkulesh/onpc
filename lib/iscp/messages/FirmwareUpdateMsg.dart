/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2022 by Mikhail Kulesh
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

enum FirmwareUpdate
{
    NONE,
    ACTUAL,
    NEW_VERSION,
    NEW_VERSION_NORMAL,
    NEW_VERSION_FORCE,
    UPDATE_STARTED,
    UPDATE_COMPLETE,
    NET
}

/*
 * Firmware Update message
 */
class FirmwareUpdateMsg extends EnumParameterMsg<FirmwareUpdate>
{
    static const String CODE = "UPD";

    static const ExtEnum<FirmwareUpdate> ValueEnum = ExtEnum<FirmwareUpdate>([
        EnumItem.code(FirmwareUpdate.NONE, "N/A",
            descrList: Strings.l_device_firmware_none, defValue: true),
        EnumItem.code(FirmwareUpdate.ACTUAL, "FF",
            descrList: Strings.l_device_firmware_actual),
        EnumItem.code(FirmwareUpdate.NEW_VERSION, "00",
            descrList: Strings.l_device_firmware_new_version),
        EnumItem.code(FirmwareUpdate.NEW_VERSION_NORMAL, "01",
            descrList: Strings.l_device_firmware_new_version),
        EnumItem.code(FirmwareUpdate.NEW_VERSION_FORCE, "02",
            descrList: Strings.l_device_firmware_new_version),
        EnumItem.code(FirmwareUpdate.UPDATE_STARTED, "Dxx-xx",
            descrList: Strings.l_device_firmware_update_started),
        EnumItem.code(FirmwareUpdate.UPDATE_COMPLETE, "CMP",
            descrList: Strings.l_device_firmware_update_complete),
        EnumItem.code(FirmwareUpdate.NET, "NET",
            descrList: Strings.l_device_firmware_net)
    ]);

    FirmwareUpdateMsg(EISCPMessage raw) : super(CODE, raw, ValueEnum);

    FirmwareUpdateMsg.output(FirmwareUpdate v) : super.output(CODE, v, ValueEnum);

    EnumItem<FirmwareUpdate> get getStatus
    => getValue;

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }
}
