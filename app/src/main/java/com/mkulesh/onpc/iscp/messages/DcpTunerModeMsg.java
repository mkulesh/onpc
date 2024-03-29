/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2023 by Mikhail Kulesh
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

import java.util.ArrayList;
import java.util.Collections;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;

/*
 * Denon control protocol - actual tuner mode
 */
public class DcpTunerModeMsg extends ISCPMessage
{
    public final static String CODE = "D02";
    private final static String DCP_COMMAND = "TMAN";

    @NonNull
    public static ArrayList<String> getAcceptedDcpCodes()
    {
        return new ArrayList<>(Collections.singletonList(DCP_COMMAND));
    }

    public enum TunerMode implements DcpStringParameterIf
    {
        NONE("N/A", R.string.dashed_string, R.drawable.media_item_unknown),
        FM("FM", R.string.input_selector_fm, R.drawable.media_item_radio_fm),
        DAB("DAB", R.string.input_selector_dab, R.drawable.media_item_radio_dab);

        final String code;

        @StringRes
        final int descriptionId;

        @DrawableRes
        final int imageId;

        TunerMode(final String code, @StringRes final int descriptionId, @DrawableRes final int imageId)
        {
            this.code = code;
            this.descriptionId = descriptionId;
            this.imageId = imageId;
        }

        public String getCode()
        {
            return code;
        }

        @NonNull
        public String getDcpCode()
        {
            return code;
        }

        @StringRes
        public int getDescriptionId()
        {
            return descriptionId;
        }

        @DrawableRes
        public int getImageId()
        {
            return imageId;
        }
    }

    private final TunerMode tunerMode;

    DcpTunerModeMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        tunerMode = (TunerMode) searchParameter(data, TunerMode.values(), TunerMode.NONE);
    }

    public DcpTunerModeMsg(TunerMode mode)
    {
        super(0, null);
        this.tunerMode = mode;
    }

    public TunerMode getTunerMode()
    {
        return tunerMode;
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + tunerMode.toString() + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return new EISCPMessage(CODE, tunerMode.getCode());
    }

    @Override
    public boolean hasImpactOnMediaList()
    {
        return false;
    }

    @Nullable
    public static DcpTunerModeMsg processDcpMessage(@NonNull String dcpMsg)
    {
        final TunerMode s = (TunerMode) searchDcpParameter(DCP_COMMAND, dcpMsg, TunerMode.values());
        return s != null ? new DcpTunerModeMsg(s) : null;
    }

    @Nullable
    @Override
    public String buildDcpMsg(boolean isQuery)
    {
        return DCP_COMMAND + (isQuery ? DCP_MSG_REQ : tunerMode.getDcpCode());
    }
}
