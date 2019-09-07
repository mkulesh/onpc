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

package com.mkulesh.onpc.iscp.messages;

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

import java.net.InetAddress;

import androidx.annotation.NonNull;

/*
 * Broadcast Response Message
 *
 * !cECNnnnnnn/ppppp/dd/iiiiiiiiiiii:
 * c: device category
 * nnnnnnn: model name of device
 * ppppp: ISCP port number
 * dd: destination area of device
 * iiiiiiiiiiii: Identifier
 * /: Separator
 */
public class BroadcastResponseMsg extends ISCPMessage
{
    private final static String CODE = "ECN";

    private final String host;
    private String model = null;
    private Integer port = null;
    private String destinationArea = null;
    private String identifier = null;

    public BroadcastResponseMsg(InetAddress hostAddress, EISCPMessage raw) throws Exception
    {
        super(raw);
        host = hostAddress.getHostAddress();
        String[] tokens = data.split("/");
        if (tokens.length > 0)
        {
            model = tokens[0];
        }
        if (tokens.length > 1)
        {
            port = Integer.parseInt(tokens[1], 10);
        }
        if (tokens.length > 2)
        {
            destinationArea = tokens[2];
        }
        if (tokens.length > 3)
        {
            identifier = tokens[3];
        }
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + data
                + "; HOST=" + host
                + "; MODEL=" + model
                + "; PORT=" + port
                + "; DST=" + destinationArea
                + "; ID=" + identifier + "]";
    }

    public String getHost()
    {
        return host;
    }

    public Integer getPort()
    {
        return port;
    }

    @NonNull
    public String getIdentifier()
    {
        return identifier == null ? "" : identifier;
    }

    public boolean isValid()
    {
        return host != null && port != null;
    }

    public String getDevice()
    {
        return getHost() + "/" + (model != null ? model : "unknown");
    }
}
