/*
 * Copyright (C) 2018. Mikhail Kulesh
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

package com.mkulesh.onpc.iscp.messages;

import android.support.annotation.NonNull;

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

/*
 * Select Network Service directly only when NET selector is selected.
 */
public class NetworkServiceMsg extends ISCPMessage
{
    private final static String CODE = "NSV";

    private final ServiceType service;

    public NetworkServiceMsg(@NonNull final ServiceType service)
    {
        super(0, null);
        this.service = service;
    }

    public NetworkServiceMsg(NetworkServiceMsg other)
    {
        super(other);
        service = other.service;
    }

    public ServiceType getService()
    {
        return service;
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + service.toString() + "/" + service.getCode() + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        final String param = service.getCode() + "0";
        return new EISCPMessage('1', CODE, param);
    }
}

 
