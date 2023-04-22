/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2022 by Mikhail Kulesh
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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public class ISCPMessage implements ConnectionIf
{
    protected final static String PAR_SEP = "/";
    protected final static String COMMA_SEP = ",";

    private final String code;
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
            if (t.getCode().equalsIgnoreCase(code))
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

    protected String getTags(String[] pars, int start, int end)
    {
        StringBuilder str = new StringBuilder();
        for (int i = start; i < Math.min(end, pars.length); i++)
        {
            if (pars[i] != null && !pars[i].isEmpty())
            {
                if (!str.toString().isEmpty())
                {
                    str.append(", ");
                }
                str.append(pars[i]);
            }
        }
        return str.toString();
    }

    /*
     * Denon control protocol
     */
    public final static String DCP_MSG_SEP = "==>>";
    protected final static String DCP_MSG_REQ = "?";
    public final static String DCP_HEOS_PID = "{$PLAYER_PID}";

    @NonNull
    public static ArrayList<String> getAcceptedDcpCodes()
    {
        return new ArrayList<>();
    }

    @Nullable
    public String buildDcpMsg(boolean isQuery)
    {
        return null;
    }

    public interface DcpStringParameterIf extends StringParameterIf
    {
        @NonNull
        String getDcpCode();
    }

    @Nullable
    public static DcpStringParameterIf searchDcpParameter(@NonNull final String dcpCommand,
                                                          @NonNull final String dcpMsg,
                                                          @NonNull final DcpStringParameterIf[] values)
    {
        if (dcpMsg.startsWith(dcpCommand))
        {
            final String par = dcpMsg.substring(dcpCommand.length()).trim();
            return searchDcpParameter(par, values, null);
        }
        return null;
    }

    @Nullable
    public static DcpStringParameterIf searchDcpParameter(@Nullable final String par,
                                                          @NonNull final DcpStringParameterIf[] values,
                                                          DcpStringParameterIf defValue)
    {
        for (DcpStringParameterIf t : values)
        {
            if (t.getDcpCode().equalsIgnoreCase(par))
            {
                return t;
            }
        }
        return defValue;
    }

    public interface DcpCharParameterIf extends CharParameterIf
    {
        @NonNull
        String getDcpCode();
    }

    @Nullable
    public static DcpCharParameterIf searchDcpParameter(@Nullable final String par,
                                                        @NonNull final DcpCharParameterIf[] values)
    {
        for (DcpCharParameterIf t : values)
        {
            if (t.getDcpCode().equalsIgnoreCase(par))
            {
                return t;
            }
        }
        return null;
    }

    public static Map<String, String> parseHeosMessage(final String heosMsg)
    {
        final Map<String, String> retValue = new HashMap<>();
        final String[] heosTokens = heosMsg.split("&");
        for (String token : heosTokens)
        {
            final String[] parTokens = token.split("=");
            if (parTokens.length == 2)
            {
                retValue.put(parTokens[0], parTokens[1]);
            }
        }
        return retValue;
    }

    protected static String getDcpGoformUrl(final String host, final String port, final String s)
    {
        return "http://" + host + ":" + port + "/goform/" + s;
    }
}
