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
import com.mkulesh.onpc.iscp.ZonedMessage;

/*
 * Input Selector Command
 */
public class InputSelectorMsg extends ZonedMessage
{
    final static String CODE = "SLI";
    final static String ZONE2_CODE = "SLZ";
    final static String ZONE3_CODE = "SL3";
    final static String ZONE4_CODE = "SL4";

    public final static String[] ZONE_COMMANDS = new String[]{ CODE, ZONE2_CODE, ZONE3_CODE, ZONE4_CODE };

    public enum InputType implements StringParameterIf
    {
        VIDEO1("00", R.string.input_selector_video1),
        VIDEO2("01", R.string.input_selector_video2),
        VIDEO3("02", R.string.input_selector_video3),
        VIDEO4("03", R.string.input_selector_video4),
        VIDEO5("04", R.string.input_selector_video5),
        VIDEO6("05", R.string.input_selector_video6),
        VIDEO7("06", R.string.input_selector_video7),
        BD_DVD("10", R.string.input_selector_bd_dvd),
        STRM_BOX("11", R.string.input_selector_strm_box),
        TV("12", R.string.input_selector_tv),
        TAPE1("20", R.string.input_selector_tape1),
        TAPE2("21", R.string.input_selector_tape2),
        PHONO("22", R.string.input_selector_phono),
        TV_CD("23", R.string.input_selector_tv_cd),
        FM("24", R.string.input_selector_fm),
        AM("25", R.string.input_selector_am),
        TUNER("26", R.string.input_selector_tuner),
        MUSIC_SERVER("27", R.string.input_selector_music_server),
        INTERNET_RADIO("28", R.string.input_selector_internet_radio),
        USB_FRONT("29", R.string.input_selector_usb_front, true),
        USB_REAR("2A", R.string.input_selector_usb_rear, true),
        NET("2B", R.string.input_selector_net, true),
        USB_TOGGLE("2C", R.string.input_selector_usb_toggle),
        AIRPLAY("2D", R.string.input_selector_airplay),
        BLUETOOTH("2E", R.string.input_selector_bluetooth),
        USB_DAC_IN("2F", R.string.input_selector_usb_dac_in),
        LINE("41", R.string.input_selector_line),
        LINE2("42", R.string.input_selector_line2),
        OPTICAL("44", R.string.input_selector_optical),
        COAXIAL("45", R.string.input_selector_coaxial),
        UNIVERSAL_PORT("40", R.string.input_selector_universal_port),
        MULTI_CH("30", R.string.input_selector_multi_ch),
        XM("31", R.string.input_selector_xm),
        SIRIUS("32", R.string.input_selector_sirius),
        DAB("33", R.string.input_selector_dab),
        HDMI_5("55", R.string.input_selector_hdmi_5),
        HDMI_6("56", R.string.input_selector_hdmi_6),
        HDMI_7("57", R.string.input_selector_hdmi_7),
        NONE("XX", -1);

        final String code;

        @StringRes
        final int descriptionId;
        final boolean mediaList;

        InputType(String code, @StringRes final int descriptionId, final boolean mediaList)
        {
            this.code = code;
            this.descriptionId = descriptionId;
            this.mediaList = mediaList;
        }

        InputType(String code, @StringRes final int descriptionId)
        {
            this.code = code;
            this.descriptionId = descriptionId;
            this.mediaList = false;
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
        return new EISCPMessage('1', getZoneCommand(), inputType.getCode());
    }

}
