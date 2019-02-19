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
import android.support.annotation.StringRes;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

/*
 * Listening Mode Command
 */
public class ListeningModeMsg extends ISCPMessage
{
    public final static String CODE = "LMD";

    public enum Mode implements StringParameterIf
    {
        MODE_00("00", R.string.listening_mode_mode_00),
        MODE_01("01", R.string.listening_mode_mode_01),
        MODE_02("02", R.string.listening_mode_mode_02),
        MODE_03("03", R.string.listening_mode_mode_03),
        MODE_04("04", R.string.listening_mode_mode_04),
        MODE_05("05", R.string.listening_mode_mode_05),
        MODE_06("06", R.string.listening_mode_mode_06),
        MODE_07("07", R.string.listening_mode_mode_07),
        MODE_08("08", R.string.listening_mode_mode_08),
        MODE_09("09", R.string.listening_mode_mode_09),
        MODE_0A("0A", R.string.listening_mode_mode_0a),
        MODE_0B("0B", R.string.listening_mode_mode_0b),
        MODE_0C("0C", R.string.listening_mode_mode_0c),
        MODE_0D("0D", R.string.listening_mode_mode_0d),
        MODE_0E("0E", R.string.listening_mode_mode_0e),
        MODE_0F("0F", R.string.listening_mode_mode_0f),
        MODE_11("11", R.string.listening_mode_mode_11),
        MODE_12("12", R.string.listening_mode_mode_12),
        MODE_13("13", R.string.listening_mode_mode_13),
        MODE_14("14", R.string.listening_mode_mode_14),
        MODE_15("15", R.string.listening_mode_mode_15),
        MODE_16("16", R.string.listening_mode_mode_16),
        MODE_1F("1F", R.string.listening_mode_mode_1f),
        MODE_40("40", R.string.listening_mode_mode_40),
        MODE_41("41", R.string.listening_mode_mode_41),
        MODE_42("42", R.string.listening_mode_mode_42),
        MODE_43("43", R.string.listening_mode_mode_43),
        MODE_44("44", R.string.listening_mode_mode_44),
        MODE_45("45", R.string.listening_mode_mode_45),
        MODE_50("50", R.string.listening_mode_mode_50),
        MODE_51("51", R.string.listening_mode_mode_51),
        MODE_52("52", R.string.listening_mode_mode_52),
        MODE_80("80", R.string.listening_mode_mode_80),
        MODE_81("81", R.string.listening_mode_mode_81),
        MODE_82("82", R.string.listening_mode_mode_82),
        MODE_83("83", R.string.listening_mode_mode_83),
        MODE_84("84", R.string.listening_mode_mode_84),
        MODE_85("85", R.string.listening_mode_mode_85),
        MODE_86("86", R.string.listening_mode_mode_86),
        MODE_87("87", R.string.listening_mode_mode_87),
        MODE_88("88", R.string.listening_mode_mode_88),
        MODE_89("89", R.string.listening_mode_mode_89),
        MODE_8A("8A", R.string.listening_mode_mode_8a),
        MODE_8B("8B", R.string.listening_mode_mode_8b),
        MODE_8C("8C", R.string.listening_mode_mode_8c),
        MODE_8D("8D", R.string.listening_mode_mode_8d),
        MODE_8E("8E", R.string.listening_mode_mode_8e),
        MODE_8F("8F", R.string.listening_mode_mode_8f),
        MODE_90("90", R.string.listening_mode_mode_90),
        MODE_91("91", R.string.listening_mode_mode_91),
        MODE_92("92", R.string.listening_mode_mode_92),
        MODE_93("93", R.string.listening_mode_mode_93),
        MODE_94("94", R.string.listening_mode_mode_94),
        MODE_95("95", R.string.listening_mode_mode_95),
        MODE_96("96", R.string.listening_mode_mode_96),
        MODE_97("97", R.string.listening_mode_mode_97),
        MODE_98("98", R.string.listening_mode_mode_98),
        MODE_99("99", R.string.listening_mode_mode_99),
        MODE_9A("9A", R.string.listening_mode_mode_9a),
        MODE_A0("A0", R.string.listening_mode_mode_a0),
        MODE_A1("A1", R.string.listening_mode_mode_a1),
        MODE_A2("A2", R.string.listening_mode_mode_a2),
        MODE_A3("A3", R.string.listening_mode_mode_a3),
        MODE_A4("A4", R.string.listening_mode_mode_a4),
        MODE_A5("A5", R.string.listening_mode_mode_a5),
        MODE_A6("A6", R.string.listening_mode_mode_a6),
        MODE_A7("A7", R.string.listening_mode_mode_a7),
        MODE_FF("FF", R.string.listening_mode_mode_ff),
        UP("UP", R.string.listening_mode_up);

        final String code;
        final int descriptionId;

        Mode(final String code, final int descriptionId)
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

    private final Mode mode;

    ListeningModeMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        mode = (Mode) searchParameter(data, Mode.values(), Mode.MODE_FF);
    }

    public ListeningModeMsg(Mode mode)
    {
        super(0, null);
        this.mode = mode;
    }

    public Mode getMode()
    {
        return mode;
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + data + "; MODE=" + mode.toString() + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return new EISCPMessage('1', CODE, mode.getCode());
    }

    @Override
    public boolean hasImpactOnMediaList()
    {
        return false;
    }
}
