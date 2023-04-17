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

package com.mkulesh.onpc.iscp.messages;

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

import java.util.ArrayList;
import java.util.Arrays;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/*
 * DAB/FM Station Name (UTF-8)
 */
public class RadioStationNameMsg extends ISCPMessage
{
    public final static String CODE = "DSN";

    private final DcpTunerModeMsg.TunerMode dcpTunerMode;

    RadioStationNameMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        // For ISCP, station name is only available for DAB
        this.dcpTunerMode = DcpTunerModeMsg.TunerMode.DAB;
    }

    RadioStationNameMsg(String name, @NonNull DcpTunerModeMsg.TunerMode dcpTunerMode)
    {
        super(0, name);
        this.dcpTunerMode = dcpTunerMode;
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + data
                + "; MODE=" + dcpTunerMode
                + "]";
    }

    /*
     * Denon control protocol
     */
    private final static String DCP_COMMAND_FM = "TFANNAME";
    private final static String DCP_COMMAND_DAB = "DA";
    private final static String DCP_COMMAND_DAB_EXT = "STN";

    @NonNull
    public static ArrayList<String> getAcceptedDcpCodes()
    {
        return new ArrayList<>(Arrays.asList(DCP_COMMAND_FM, DCP_COMMAND_DAB + DCP_COMMAND_DAB_EXT));
    }

    @Nullable
    public static RadioStationNameMsg processDcpMessage(@NonNull String dcpMsg)
    {
        if (dcpMsg.startsWith(DCP_COMMAND_FM))
        {
            final String par = dcpMsg.substring(DCP_COMMAND_FM.length()).trim();
            return new RadioStationNameMsg(par, DcpTunerModeMsg.TunerMode.FM);
        }
        if (dcpMsg.startsWith(DCP_COMMAND_DAB + DCP_COMMAND_DAB_EXT))
        {
            final String par = dcpMsg.substring((DCP_COMMAND_DAB + DCP_COMMAND_DAB_EXT).length()).trim();
            return new RadioStationNameMsg(par, DcpTunerModeMsg.TunerMode.DAB);
        }
        return null;
    }

    @Nullable
    @Override
    public String buildDcpMsg(boolean isQuery)
    {
        final String fmReq = DCP_COMMAND_FM + DCP_MSG_REQ;
        final String dabReq = DCP_COMMAND_DAB + " " + DCP_MSG_REQ;
        return fmReq + DCP_MSG_SEP + dabReq;
    }

    @NonNull
    public DcpTunerModeMsg.TunerMode getDcpTunerMode()
    {
        return dcpTunerMode;
    }
}
