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

import "../EISCPMessage.dart";
import "EnumParameterMsg.dart";
import "ServiceType.dart";

/*
 * Select Network Service directly only when NET selector is selected.
 */
class NetworkServiceMsg extends EnumParameterMsg<ServiceType>
{
    static const String CODE = "NSV";

    NetworkServiceMsg.output(ServiceType v) :
            super.output(CODE, v, Services.ServiceTypeEnum);

    @override
    EISCPMessage getCmdMsg()
    {
        return EISCPMessage.output(getCode, getData + "0");
    }
}