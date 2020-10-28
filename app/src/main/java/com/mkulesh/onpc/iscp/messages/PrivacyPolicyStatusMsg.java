/*
 * Enhanced Controller for Onkyo and Pioneer
 * Copyright (C) 2018-2020. Mikhail Kulesh
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
 * Privacy Policy Status message
 */
public class PrivacyPolicyStatusMsg extends ISCPMessage
{
    public final static String CODE = "PPS";

    public enum Status implements StringParameterIf
    {
        NONE("000", -1),
        ONKYO("100", R.string.privacy_policy_onkyo),
        GOOGLE("010", R.string.privacy_policy_google),
        SUE("001", R.string.privacy_policy_sue);

        final String code;

        @StringRes
        final int descriptionId;

        Status(final String code, @StringRes final int descriptionId)
        {
            this.code = code;
            this.descriptionId = descriptionId;
        }

        public String getCode()
        {
            return code;
        }

        @SuppressWarnings("unused")
        @StringRes
        public int getDescriptionId()
        {
            return descriptionId;
        }
    }

    private final Status status;

    PrivacyPolicyStatusMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        status = (Status) searchParameter(data, Status.values(), Status.NONE);
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + getData() + "]";
    }

    @SuppressWarnings("BooleanMethodIsAlwaysInverted")
    public boolean isPolicySet(Status s)
    {
        if (getData() == null || getData().length() < 3)
        {
            return false;
        }
        switch (s)
        {
        case NONE:
            return getData().equals(Status.NONE.getCode());
        case ONKYO:
            return getData().charAt(0) == '1';
        case GOOGLE:
            return getData().charAt(1) == '1';
        case SUE:
            return getData().charAt(2) == '1';
        }
        return false;
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return new EISCPMessage(CODE, status.getCode());
    }

    @Override
    public boolean hasImpactOnMediaList()
    {
        return false;
    }
}
