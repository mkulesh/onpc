/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2025 by Mikhail Kulesh
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
 * Listening Mode Command
 */
public class ListeningModeMsg extends ISCPMessage
{
    public final static String CODE = "LMD";

    public enum Mode implements DcpStringParameterIf
    {
        // Integra
        MODE_00("00", R.string.listening_mode_mode_00),
        MODE_01("01", R.string.listening_mode_mode_01, true),
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
        MODE_11("11", R.string.listening_mode_mode_11, true),
        MODE_12("12", R.string.listening_mode_mode_12),
        MODE_13("13", R.string.listening_mode_mode_13),
        MODE_14("14", R.string.listening_mode_mode_14),
        MODE_15("15", R.string.listening_mode_mode_15),
        MODE_16("16", R.string.listening_mode_mode_16),
        MODE_17("17", R.string.listening_mode_mode_17),
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

        // Denon
        DCP_DIRECT("DIRECT", R.string.listening_mode_mode_01, true),
        DCP_PURE_DIRECT("PURE DIRECT", R.string.listening_mode_pure_direct, true),
        DCP_STEREO("STEREO", R.string.listening_mode_mode_00),
        DCP_ALL_ZONE_STEREO("ALL ZONE STEREO", R.string.listening_mode_all_zone_stereo),
        DCP_AUTO("AUTO", R.string.listening_mode_auto),
        DCP_DOLBY_DIGITAL("DOLBY DIGITAL", R.string.listening_mode_mode_40),
        DCP_DTS_SURROUND("DTS SURROUND", R.string.listening_mode_dts_surround),
        DCP_AURO3D("AURO3D", R.string.listening_mode_auro3d),
        DCP_AURO2DSURR("AURO2DSURR", R.string.listening_mode_auro2d_surr),
        DCP_MCH_STEREO("MCH STEREO", R.string.listening_mode_mch_stereo),
        DCP_WIDE_SCREEN("WIDE SCREEN", R.string.listening_mode_wide_screen),
        DCP_SUPER_STADIUM("SUPER STADIUM", R.string.listening_mode_super_stadium),
        DCP_ROCK_ARENA("ROCK ARENA", R.string.listening_mode_rock_arena),
        DCP_JAZZ_CLUB("JAZZ CLUB", R.string.listening_mode_jazz_club),
        DCP_CLASSIC_CONCERT("CLASSIC CONCERT", R.string.listening_mode_classic_concert),
        DCP_MONO_MOVIE("MONO MOVIE", R.string.listening_mode_mono_movie),
        DCP_MATRIX("MATRIX", R.string.listening_mode_matrix),
        DCP_VIDEO_GAME("VIDEO GAME", R.string.listening_mode_video_game),
        DCP_VIRTUAL("VIRTUAL", R.string.listening_mode_vitrual),

        UP("UP", R.string.listening_mode_up, R.drawable.cmd_right),
        DOWN("DOWN", R.string.listening_mode_down, R.drawable.cmd_left),
        NONE( "--", R.string.dashed_string);

        final String code;

        @StringRes
        final int descriptionId;

        // For direct mode, the tone control is disabled
        final boolean directMode;

        @DrawableRes
        final int imageId;

        Mode(final String code, @StringRes final int descriptionId)
        {
            this.code = code;
            this.descriptionId = descriptionId;
            this.directMode = false;
            this.imageId = -1;
        }

        @SuppressWarnings("SameParameterValue")
        Mode(final String code, @StringRes final int descriptionId, final boolean directMode)
        {
            this.code = code;
            this.descriptionId = descriptionId;
            this.directMode = directMode;
            this.imageId = -1;
        }

        Mode(final String code, @StringRes final int descriptionId, @DrawableRes final int imageId)
        {
            this.code = code;
            this.descriptionId = descriptionId;
            this.directMode = false;
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

        public boolean isDirectMode()
        {
            return directMode;
        }

        @DrawableRes
        public int getImageId()
        {
            return imageId;
        }
    }

    private final Mode mode;

    ListeningModeMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        mode = (Mode) searchParameter(data, Mode.values(), Mode.NONE);
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
        return new EISCPMessage(CODE, mode.getCode());
    }

    @Override
    public boolean hasImpactOnMediaList()
    {
        return false;
    }

    /*
     * Denon control protocol
     */
    private final static String DCP_COMMAND = "MS";

    @NonNull
    public static ArrayList<String> getAcceptedDcpCodes()
    {
        return new ArrayList<>(Collections.singletonList(DCP_COMMAND));
    }

    @Nullable
    public static ListeningModeMsg processDcpMessage(@NonNull String dcpMsg)
    {
        final Mode s = (Mode) searchDcpParameter(DCP_COMMAND, dcpMsg, Mode.values());
        return s != null ? new ListeningModeMsg(s) : null;
    }

    @Nullable
    @Override
    public String buildDcpMsg(boolean isQuery)
    {
        return DCP_COMMAND + (isQuery ? DCP_MSG_REQ : mode.getDcpCode());
    }
}
