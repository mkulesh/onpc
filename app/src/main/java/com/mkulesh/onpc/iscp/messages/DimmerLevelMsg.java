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
import androidx.annotation.StringRes;

/*
 * Dimmer Level Command
 */
public class DimmerLevelMsg extends ISCPMessage
{
    public final static String CODE = "DIM";

    public enum Level implements StringParameterIf
    {
        NONE("N/A", R.string.device_dimmer_level_none),
        BRIGHT("00", R.string.device_dimmer_level_bright),
        DIM("01", R.string.device_dimmer_level_dim),
        DARK("02", R.string.device_dimmer_level_dark),
        SHUT_OFF("03", R.string.device_dimmer_level_shut_off),
        OFF("08", R.string.device_dimmer_level_off),
        TOGGLE("DIM", R.string.device_dimmer_level_toggle);

        final String code;

        @StringRes
        final int descriptionId;

        Level(final String code, @StringRes final int descriptionId)
        {
            this.code = code;
            this.descriptionId = descriptionId;
        }

        public String getCode()
        {
            return code;
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
}
