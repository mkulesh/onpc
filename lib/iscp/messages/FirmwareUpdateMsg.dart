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

import "../../constants/Strings.dart";
import "../DcpHeosMessage.dart";
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";
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
        EnumItem.code(FirmwareUpdate.NONE, "N/A", dcpCode: "N/A",
            descrList: Strings.l_device_firmware_none, defValue: true),
        EnumItem.code(FirmwareUpdate.ACTUAL, "FF", dcpCode: "update_none",
            descrList: Strings.l_device_firmware_actual),
        EnumItem.code(FirmwareUpdate.NEW_VERSION, "00", dcpCode: "update_exist",
            descrList: Strings.l_device_firmware_new_version),
        EnumItem.code(FirmwareUpdate.NEW_VERSION_NORMAL, "01", dcpCode: "N/A",
            descrList: Strings.l_device_firmware_new_version),
        EnumItem.code(FirmwareUpdate.NEW_VERSION_FORCE, "02", dcpCode: "N/A",
            descrList: Strings.l_device_firmware_new_version),
        EnumItem.code(FirmwareUpdate.UPDATE_STARTED, "Dxx-xx", dcpCode: "N/A",
            descrList: Strings.l_device_firmware_update_started),
        EnumItem.code(FirmwareUpdate.UPDATE_COMPLETE, "CMP", dcpCode: "N/A",
            descrList: Strings.l_device_firmware_update_complete),
        EnumItem.code(FirmwareUpdate.NET, "NET", dcpCode: "N/A",
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

    /*
     * Denon control protocol
     */
    static const String _HEOS_COMMAND = "player/check_update";

    static FirmwareUpdateMsg? processHeosMessage(DcpHeosMessage jsonMsg)
    {
        if (_HEOS_COMMAND == jsonMsg.command)
        {
            final EnumItem<FirmwareUpdate>? s = ValueEnum.valueByDcpCode(jsonMsg.getString("payload.update"));
            return (s != null) ? FirmwareUpdateMsg.output(s.key) : null;
        }
        return null;
    }

    @override
    String? buildDcpMsg(bool isQuery)
    {
        if (isQuery)
        {
            return "heos://" + _HEOS_COMMAND + "?pid=" + ISCPMessage.DCP_HEOS_PID;
        }
        else if (getStatus.toString() == "NET")
        {
            return '<cmd id=\"3\"><name>SetUpdate</name><list><param name="\start\">1</param></list></cmd>';
        }
        return null;
    }
}
