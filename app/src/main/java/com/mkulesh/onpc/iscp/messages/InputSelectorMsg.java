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

/*
 * Input Selector Command
 */
public class InputSelectorMsg extends ISCPMessage
{
    public final static String CODE = "SLI";

    public enum InputType implements StringParameterIf
    {
        PC("05"),
        VIDEO7("06"),
        BD_DVD("10"),
        STRM_BOX("11"),
        TV("12"),
        TV_TAPE("20"),
        TAPE2("21"),
        PHONO("22"),
        TV_CD("23"),
        FM("24"),
        AM("25"),
        TUNER("26"),
        MUSIC_SERVER("27"),
        INTERNET_RADIO("28"),
        USB_FRONT("29", R.string.selector_usb_front, R.drawable.selector_usb_front),
        USB_REAR("2A", R.string.selector_usb_rear, R.drawable.selector_usb_rear),
        NET("2B", R.string.selector_net, R.drawable.selector_net),
        USB_TOGGLE("2C"),
        AIRPLAY("2D"),
        BLUETOOTH("2E"),
        USB_DAC_IN("2F"),
        LINE("41"),
        LINE2("42"),
        OPTICAL("44"),
        COAXIAL("45"),
        UNIVERSAL_PORT("40"),
        MULTI_CH("30"),
        XM_1("31"),
        SIRIUS_1("32"),
        DAB_5("33"),
        HDMI_5("55"),
        HDMI_6("56"),
        HDMI_7("57"),
        NONE("XX");

        final String code;
        final int descriptionId;
        final int imageId;

        InputType(String code)
        {
            this.code = code;
            this.descriptionId = -1;
            this.imageId = R.drawable.media_item_unknown;
        }

        InputType(String code, final int descriptionId, int imageId)
        {
            this.code = code;
            this.descriptionId = descriptionId;
            this.imageId = imageId;
        }

        public String getCode()
        {
            return code;
        }

        public int getDescriptionId()
        {
            return descriptionId;
        }

        public int getImageId()
        {
            return imageId;
        }
    }

    private final InputType inputType;

    InputSelectorMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        inputType = (InputType) searchParameter(data, InputType.values(), InputType.NONE);
    }

    public InputSelectorMsg(final String cmd)
    {
        super(0, null);
        inputType = (InputType) searchParameter(cmd, InputType.values(), InputType.NONE);
    }

    public InputType getInputType()
    {
        return inputType;
    }

    @Override
    public String toString()
    {
        return CODE + "[" + inputType.toString() + "; CODE=" + inputType.getCode() + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return new EISCPMessage('1', CODE, inputType.getCode());
    }

}
