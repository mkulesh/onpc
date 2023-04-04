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
import com.mkulesh.onpc.iscp.ZonedMessage;
import com.mkulesh.onpc.utils.Utils;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;

/*
 * Input Selector Command
 */
public class InputSelectorMsg extends ZonedMessage
{
    public final static String CODE = "SLI";
    final static String ZONE2_CODE = "SLZ";
    final static String ZONE3_CODE = "SL3";
    final static String ZONE4_CODE = "SL4";

    public final static String[] ZONE_COMMANDS = new String[]{ CODE, ZONE2_CODE, ZONE3_CODE, ZONE4_CODE };

    public enum InputType implements StringParameterIf
    {
        // Integra
        VIDEO1("00", R.string.input_selector_vcr_dvr, R.drawable.media_item_vhs),
        VIDEO2("01", R.string.input_selector_cbl_sat, R.drawable.media_item_sat),
        VIDEO3("02", R.string.input_selector_game, R.drawable.media_item_game),
        VIDEO4("03", R.string.input_selector_aux, R.drawable.media_item_aux),
        VIDEO5("04", R.string.input_selector_aux2, R.drawable.media_item_aux),
        VIDEO6("05", R.string.input_selector_pc, R.drawable.media_item_pc),
        VIDEO7("06", R.string.input_selector_video7, R.drawable.media_item_hdmi),
        EXTRA1("07", R.string.input_selector_extra1, R.drawable.media_item_hdmi),
        EXTRA2("08", R.string.input_selector_extra2, R.drawable.media_item_hdmi),
        BD_DVD("10", R.string.input_selector_bd_dvd, R.drawable.media_item_disc_player),
        STRM_BOX("11", R.string.input_selector_strm_box, R.drawable.media_item_mplayer),
        TV("12", R.string.input_selector_tv, R.drawable.media_item_tv),
        TAPE1("20", R.string.input_selector_tape1, R.drawable.media_item_tape),
        TAPE2("21", R.string.input_selector_tape2, R.drawable.media_item_tape),
        PHONO("22", R.string.input_selector_phono, R.drawable.media_item_phono),
        CD("23", R.string.input_selector_cd, R.drawable.media_item_disc_player),
        FM("24", R.string.input_selector_fm, R.drawable.media_item_radio_fm),
        AM("25", R.string.input_selector_am, R.drawable.media_item_radio_am),
        TUNER("26", R.string.input_selector_tuner, R.drawable.media_item_radio),
        MUSIC_SERVER("27", R.string.input_selector_music_server, R.drawable.media_item_media_server, true),
        INTERNET_RADIO("28", R.string.input_selector_internet_radio, R.drawable.media_item_radio_digital),
        USB_FRONT("29", R.string.input_selector_usb_front, R.drawable.media_item_usb, true),
        USB_REAR("2A", R.string.input_selector_usb_rear, R.drawable.media_item_usb, true),
        NET("2B", R.string.input_selector_net, R.drawable.media_item_net, true),
        USB_TOGGLE("2C", R.string.input_selector_usb_toggle, R.drawable.media_item_usb),
        AIRPLAY("2D", R.string.input_selector_airplay, R.drawable.media_item_airplay),
        BLUETOOTH("2E", R.string.input_selector_bluetooth, R.drawable.media_item_bluetooth),
        USB_DAC_IN("2F", R.string.input_selector_usb_dac_in, R.drawable.media_item_usb),
        LINE("41", R.string.input_selector_line, R.drawable.media_item_rca),
        LINE2("42", R.string.input_selector_line2, R.drawable.media_item_rca),
        OPTICAL("44", R.string.input_selector_optical, R.drawable.media_item_toslink),
        COAXIAL("45", R.string.input_selector_coaxial),
        UNIVERSAL_PORT("40", R.string.input_selector_universal_port),
        MULTI_CH("30", R.string.input_selector_multi_ch),
        XM("31", R.string.input_selector_xm),
        SIRIUS("32", R.string.input_selector_sirius),
        DAB("33", R.string.input_selector_dab, R.drawable.media_item_radio_dab),
        HDMI_5("55", R.string.input_selector_hdmi_5, R.drawable.media_item_hdmi),
        HDMI_6("56", R.string.input_selector_hdmi_6, R.drawable.media_item_hdmi),
        HDMI_7("57", R.string.input_selector_hdmi_7, R.drawable.media_item_hdmi),
        SOURCE("80", R.string.input_selector_source),

        // Denon
        DCP_PHONO("PHONO", R.string.input_selector_phono, R.drawable.media_item_phono),
        DCP_CD("CD", R.string.input_selector_cd, R.drawable.media_item_disc_player),
        DCP_DVD("DVD", R.string.input_selector_dvd, R.drawable.media_item_disc_player),
        DCP_BD("BD", R.string.input_selector_bd, R.drawable.media_item_disc_player),
        DCP_TV("TV", R.string.input_selector_tv, R.drawable.media_item_tv),
        DCP_SAT_CBL("SAT/CBL", R.string.input_selector_cbl_sat, R.drawable.media_item_sat),
        DCP_MPLAY("MPLAY", R.string.input_selector_mplayer, R.drawable.media_item_mplayer),
        DCP_GAME("GAME", R.string.input_selector_game, R.drawable.media_item_game),
        DCP_TUNER("TUNER", R.string.input_selector_tuner, R.drawable.media_item_radio),
        DCP_AUX1("AUX1", R.string.input_selector_aux1, R.drawable.media_item_rca),
        DCP_AUX2("AUX2", R.string.input_selector_aux2, R.drawable.media_item_rca),
        DCP_AUX3("AUX3", R.string.input_selector_aux3, R.drawable.media_item_rca),
        DCP_AUX4("AUX4", R.string.input_selector_aux4, R.drawable.media_item_rca),
        DCP_AUX5("AUX5", R.string.input_selector_aux5, R.drawable.media_item_rca),
        DCP_AUX6("AUX6", R.string.input_selector_aux6, R.drawable.media_item_rca),
        DCP_AUX7("AUX7", R.string.input_selector_aux7, R.drawable.media_item_rca),
        DCP_NET("NET", R.string.input_selector_net, R.drawable.media_item_net),
        DCP_BT("BT", R.string.input_selector_bluetooth, R.drawable.media_item_bluetooth),
        DCP_SOURCE("SOURCE", R.string.input_selector_source),

        NONE("XX", -1);

        final String code;

        @StringRes
        final int descriptionId;

        @DrawableRes
        final int imageId;

        final boolean mediaList;

        @SuppressWarnings("SameParameterValue")
        InputType(String code, @StringRes final int descriptionId, @DrawableRes final int imageId, final boolean mediaList)
        {
            this.code = code;
            this.descriptionId = descriptionId;
            this.imageId = imageId;
            this.mediaList = mediaList;
        }

        InputType(String code, @StringRes final int descriptionId, @DrawableRes final int imageId)
        {
            this.code = code;
            this.descriptionId = descriptionId;
            this.imageId = imageId;
            this.mediaList = false;
        }

        InputType(String code, @StringRes final int descriptionId)
        {
            this.code = code;
            this.descriptionId = descriptionId;
            this.imageId = R.drawable.media_item_unknown;
            this.mediaList = false;
        }

        public Utils.ProtoType getProtoType()
        {
            return name().startsWith("DCP_") ? Utils.ProtoType.DCP : Utils.ProtoType.ISCP;
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

        @DrawableRes
        public int getImageId()
        {
            return imageId;
        }

        public boolean isMediaList()
        {
            return mediaList;
        }
    }

    private final InputType inputType;

    InputSelectorMsg(EISCPMessage raw) throws Exception
    {
        super(raw, ZONE_COMMANDS);
        inputType = (InputType) searchParameter(data, InputType.values(), InputType.NONE);
    }

    public InputSelectorMsg(int zoneIndex, final String cmd)
    {
        super(0, null, zoneIndex);
        inputType = (InputType) searchParameter(cmd, InputType.values(), InputType.NONE);
    }

    @Override
    public String getZoneCommand()
    {
        return ZONE_COMMANDS[zoneIndex];
    }

    public InputType getInputType()
    {
        return inputType;
    }

    @NonNull
    @Override
    public String toString()
    {
        return getZoneCommand() + "[" + data
                + "; ZONE_INDEX=" + zoneIndex
                + "; INPUT_TYPE=" + inputType.toString()
                + "; CODE=" + inputType.getCode() + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return new EISCPMessage(getZoneCommand(), inputType.getCode());
    }

    /*
     * Denon control protocol
     */
    public final static String[] DCP_COMMANDS = new String[]{ "SI", "Z2", "Z3" };

    @Nullable
    public static InputSelectorMsg processDcpMessage(@NonNull String dcpMsg)
    {
        for (int i = 0; i < DCP_COMMANDS.length; i++)
        {
            if (dcpMsg.startsWith(DCP_COMMANDS[i]))
            {
                final String par = dcpMsg.substring(DCP_COMMANDS[i].length()).trim();
                for (InputSelectorMsg.InputType input : InputSelectorMsg.InputType.values())
                {
                    if (par.equalsIgnoreCase(input.getCode()))
                    {
                        return new InputSelectorMsg(i, input.getCode());
                    }
                }
            }
        }
        return null;
    }

    @Nullable
    @Override
    public String buildDcpMsg(boolean isQuery)
    {
        if (zoneIndex < DCP_COMMANDS.length)
        {
            return DCP_COMMANDS[zoneIndex] + (isQuery ? DCP_MSG_REQ : inputType.getCode());
        }
        return null;
    }
}
