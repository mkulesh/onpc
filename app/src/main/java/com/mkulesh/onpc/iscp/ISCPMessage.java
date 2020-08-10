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

package com.mkulesh.onpc.iscp;

import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.nio.charset.Charset;

import androidx.annotation.NonNull;

public class ISCPMessage implements ConnectionIf
{
    protected static final Charset UTF_8 = Charset.forName("UTF-8");
    protected final static String PAR_SEP = "/";

    protected final String code;
    protected final int messageId;
    protected final String data;
    private final Character modelCategoryId;

    // connected host (ConnectionIf)
    protected String host = ConnectionIf.EMPTY_HOST;
    protected int port = ConnectionIf.EMPTY_PORT;

    protected ISCPMessage(final int messageId, final String data)
    {
        this.code = null;
        this.messageId = messageId;
        this.data = data;
        modelCategoryId = 'X';
    }

    @SuppressWarnings("RedundantThrows")
    protected ISCPMessage(EISCPMessage raw) throws Exception
    {
        code = raw.getCode();
        messageId = raw.getMessageId();
        data = raw.getParameters().trim();
        modelCategoryId = raw.getModelCategoryId();
    }

    protected ISCPMessage(ISCPMessage other)
    {
        code = other.code;
        messageId = other.messageId;
        data = other.data;
        modelCategoryId = other.modelCategoryId;
        host = other.host;
        port = other.port;
    }

    @NonNull
    @Override
    public String getHost()
    {
        return host;
    }

    @Override
    public int getPort()
    {
        return port;
    }

    @NonNull
    @Override
    public String getHostAndPort()
    {
        return Utils.ipToString(host, port);
    }

    void setHostAndPort(@NonNull final ConnectionIf connection)
    {
        host = connection.getHost();
        port = connection.getPort();
    }

    public boolean fromHost(@NonNull final ConnectionIf connection)
    {
        return host.equals(connection.getHost()) && port == connection.getPort();
    }

    public boolean isValidConnection()
    {
        return !host.equals(ConnectionIf.EMPTY_HOST) && port != ConnectionIf.EMPTY_PORT;
    }

    public final String getCode()
    {
        return code;
    }

    public int getMessageId()
    {
        return messageId;
    }

    public final String getData()
    {
        return data;
    }

    @NonNull
    @Override
    public String toString()
    {
        return "ISCPMessage/" + modelCategoryId;
    }

    protected boolean isMultiline()
    {
        return data != null && data.length() > EISCPMessage.LOG_LINE_LENGTH;
    }

    void logParameters()
    {
        if (!Logging.isEnabled() || data == null)
        {
            return;
        }
        String p = data;
        while (true)
        {
            if (p.length() > EISCPMessage.LOG_LINE_LENGTH)
            {
                Logging.info(this, p.substring(0, EISCPMessage.LOG_LINE_LENGTH));
                p = p.substring(EISCPMessage.LOG_LINE_LENGTH);
            }
            else
            {
                Logging.info(this, p);
                break;
            }
        }
    }

    /**
     * Helper methods for enumerations based on char parameter
     */
    protected interface CharParameterIf
    {
        Character getCode();
    }

    protected static CharParameterIf searchParameter(Character code, CharParameterIf[] values, CharParameterIf defValue)
    {
        for (CharParameterIf t : values)
        {
            if (t.getCode() == code)
            {
                return t;
            }
        }
        return defValue;
    }

    /**
     * Helper methods for enumerations based on char parameter
     */
    public interface StringParameterIf
    {
        String getCode();
    }

    public static StringParameterIf searchParameter(String code, StringParameterIf[] values, StringParameterIf defValue)
    {
        if (code == null)
        {
            return defValue;
        }
        for (StringParameterIf t : values)
        {
            if (t.getCode().toUpperCase().equals(code.toUpperCase()))
            {
                return t;
            }
        }
        return defValue;
    }

    public EISCPMessage getCmdMsg()
    {
        return null;
    }

    public boolean hasImpactOnMediaList()
    {
        return true;
    }
}
