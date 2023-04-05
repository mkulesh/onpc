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

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;

/*
 * Dimmer Level Command
 */
public class DimmerLevelMsg extends ISCPMessage
{
    public final static String CODE = "DIM";

    public enum Level implements DcpStringParameterIf
    {
        NONE("N/A", "N/A",R.string.device_dimmer_level_none),
        BRIGHT("00", "BRI", R.string.device_dimmer_level_bright),
        DIM("01", "DIM", R.string.device_dimmer_level_dim),
        DARK("02", "DAR", R.string.device_dimmer_level_dark),
        SHUT_OFF("03", "N/A", R.string.device_dimmer_level_shut_off),
        OFF("08", "OFF", R.string.device_dimmer_level_off),
        TOGGLE("DIM", "SEL", R.string.device_dimmer_level_toggle);

        final String code, dcpCode;

        @StringRes
        final int descriptionId;

        Level(final String code, final String dcpCode, @StringRes final int descriptionId)
        {
            this.code = code;
            this.dcpCode = dcpCode;
            this.descriptionId = descriptionId;
        }

        public String getCode()
        {
            return code;
        }

        @NonNull
        public String getDcpCode()
        {
            return dcpCode;
        }

        @StringRes
        public int getDescriptionId()
        {
            return descriptionId;
        }
    }

    private final Level level;

    DimmerLevelMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        level = (Level) searchParameter(data, Level.values(), Level.NONE);
    }

    public DimmerLevelMsg(Level level)
    {
        super(0, null);
        this.level = level;
    }

    public Level getLevel()
    {
        return level;
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + level.getCode() + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return new EISCPMessage(CODE, level.getCode());
    }

    @Override
    public boolean hasImpactOnMediaList()
    {
        return false;
    }

    /*
     * Denon control protocol
     */
    private final static String DCP_COMMAND = "DIM";

    @Nullable
    public static DimmerLevelMsg processDcpMessage(@NonNull String dcpMsg)
    {
        final Level s = (Level) searchDcpParameter(DCP_COMMAND, dcpMsg, Level.values());
        return s != null ? new DimmerLevelMsg(s) : null;
    }

    @Nullable
    @Override
    public String buildDcpMsg(boolean isQuery)
    {
        // A space is needed for this command
        return DCP_COMMAND + " " + (isQuery ? DCP_MSG_REQ : level.getDcpCode());
    }
}
