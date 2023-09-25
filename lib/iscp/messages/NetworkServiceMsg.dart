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

import "../EISCPMessage.dart";
import "../ISCPMessage.dart";
import "EnumParameterMsg.dart";
import "ServiceType.dart";

/*
 * Select Network Service directly only when NET selector is selected.
 */
class NetworkServiceMsg extends EnumParameterMsg<ServiceType>
{
    static const String CODE = "NSV";

    NetworkServiceMsg(EISCPMessage raw) :
        super.output(CODE,
            Services.ServiceTypeEnum.valueByCode(raw.getParameters.substring(0, raw.getParameters.length - 1)).key,
            Services.ServiceTypeEnum);

    NetworkServiceMsg.output(ServiceType v) :
            super.output(CODE, v, Services.ServiceTypeEnum);

    NetworkServiceMsg.fromName(final String name) :
            super.output(CODE, _searchByName(name).key, Services.ServiceTypeEnum);

    @override
    EISCPMessage getCmdMsg()
    {
        return EISCPMessage.output(getCode, getData + "0");
    }

    static EnumItem<ServiceType> _searchByName(final String name)
    => Services.ServiceTypeEnum.values.firstWhere((t) => t.name != null && t.name!.toUpperCase() == name.toUpperCase(),
        orElse: () => Services.ServiceTypeEnum.defValue);

    /*
     * Denon control protocol
     */
    static const String _HEOS_COMMAND = "heos://browse/browse";

    @override
    String? buildDcpMsg(bool isQuery)
    {
        if (getValue.key == ServiceType.DCP_PLAYQUEUE)
        {
            return "heos://player/get_queue?pid=" + ISCPMessage.DCP_HEOS_PID + "&range=0,9999";
        }
        if (getValue.key != ServiceType.UNKNOWN)
        {
            return "heos://" + _HEOS_COMMAND + "?sid=" + getValue.getDcpCode.substring(2);
        }
        return null;
    }
}
