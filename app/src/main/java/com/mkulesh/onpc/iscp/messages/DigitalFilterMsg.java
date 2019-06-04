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

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

import androidx.annotation.NonNull;
import androidx.annotation.StringRes;

/*
 * Dimmer Level Command
 */
public class DigitalFilterMsg extends ISCPMessage
{
    public final static String CODE = "DGF";

    public enum Filter implements StringParameterIf
    {
        NONE("N/A", R.string.device_digital_filter_none),
        F00("00", R.string.device_digital_filter_slow),
        F01("01", R.string.device_digital_filter_sharp),
        F02("02", R.string.device_digital_filter_short),
        TOGGLE("UP", R.string.device_digital_filter_toggle);

        final String code;

        @StringRes
        final int descriptionId;

        Filter(final String code, @StringRes final int descriptionId)
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

    private final Filter filter;

    DigitalFilterMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        filter = (Filter) searchParameter(data, Filter.values(), Filter.NONE);
    }

    public DigitalFilterMsg(Filter level)
    {
        super(0, null);
        this.filter = level;
    }

    public Filter getFilter()
    {
        return filter;
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + filter.getCode() + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return new EISCPMessage(CODE, filter.getCode());
    }

    @Override
    public boolean hasImpactOnMediaList()
    {
        return false;
    }
}
