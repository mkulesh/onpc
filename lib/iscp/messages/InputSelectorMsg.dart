/*
 * Copyright (C) 2019. Mikhail Kulesh
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

import "../../constants/Drawables.dart";
import "../../constants/Strings.dart";
import "../EISCPMessage.dart";
import "EnumParameterMsg.dart";

enum InputSelector
{
    NONE,
    VIDEO1,
    VIDEO2,
    VIDEO3,
    VIDEO4,
    VIDEO5,
    VIDEO6,
    VIDEO7,
    EXTRA1,
    EXTRA2,
    BD_DVD,
    STRM_BOX,
    TV,
    TAPE1,
    TAPE2,
    PHONO,
    TV_CD,
    FM,
    AM,
    TUNER,
    MUSIC_SERVER,
    INTERNET_RADIO,
    USB_FRONT,
    USB_REAR,
    NET,
    USB_TOGGLE,
    AIRPLAY,
    BLUETOOTH,
    USB_DAC_IN,
    LINE,
    LINE2,
    OPTICAL,
    COAXIAL,
    UNIVERSAL_PORT,
    MULTI_CH,
    XM,
    SIRIUS,
    DAB,
    HDMI_5,
    HDMI_6,
    HDMI_7
}

/*
 * Input Selector Command
 */
class InputSelectorMsg extends EnumParameterZonedMsg
{
    static const String CODE = "SLI";
    static const String ZONE2_CODE = "SLZ";
    static const String ZONE3_CODE = "SL3";
    static const String ZONE4_CODE = "SL4";

    static const List<String> ZONE_COMMANDS = [CODE, ZONE2_CODE, ZONE3_CODE, ZONE4_CODE];

    static const ExtEnum<InputSelector> ValueEnum = ExtEnum<InputSelector>([
        EnumItem.code(InputSelector.NONE, "XX", defValue: true),
        EnumItem.code(InputSelector.VIDEO1, "00",
            descrList: Strings.l_input_selector_video1),
        EnumItem.code(InputSelector.VIDEO2, "01",
            descrList: Strings.l_input_selector_video2),
        EnumItem.code(InputSelector.VIDEO3, "02",
            descrList: Strings.l_input_selector_video3),
        EnumItem.code(InputSelector.VIDEO4, "03", icon: Drawables.media_item_aux,
            descrList: Strings.l_input_selector_video4),
        EnumItem.code(InputSelector.VIDEO5, "04", icon: Drawables.media_item_aux,
            descrList: Strings.l_input_selector_video5),
        EnumItem.code(InputSelector.VIDEO6, "05",
            descrList: Strings.l_input_selector_video6),
        EnumItem.code(InputSelector.VIDEO7, "06",
            descrList: Strings.l_input_selector_video7),
        EnumItem.code(InputSelector.EXTRA1, "07",
            descrList: Strings.l_input_selector_extra1),
        EnumItem.code(InputSelector.EXTRA2, "08",
            descrList: Strings.l_input_selector_extra2),
        EnumItem.code(InputSelector.BD_DVD, "10",
            descrList: Strings.l_input_selector_bd_dvd),
        EnumItem.code(InputSelector.STRM_BOX, "11",
            descrList: Strings.l_input_selector_strm_box),
        EnumItem.code(InputSelector.TV, "12", icon: Drawables.media_item_tv,
            descrList: Strings.l_input_selector_tv),
        EnumItem.code(InputSelector.TAPE1, "20", icon: Drawables.media_item_tape,
            descrList: Strings.l_input_selector_tape1),
        EnumItem.code(InputSelector.TAPE2, "21", icon: Drawables.media_item_tape,
            descrList: Strings.l_input_selector_tape2),
        EnumItem.code(InputSelector.PHONO, "22",
            descrList: Strings.l_input_selector_phono),
        EnumItem.code(InputSelector.TV_CD, "23",
            descrList: Strings.l_input_selector_tv_cd, icon: Drawables.media_item_disc_player),
        EnumItem.code(InputSelector.FM, "24",
            descrList: Strings.l_input_selector_fm, icon: Drawables.media_item_radio_fm),
        EnumItem.code(InputSelector.AM, "25",
            descrList: Strings.l_input_selector_am, icon: Drawables.media_item_radio_am),
        EnumItem.code(InputSelector.TUNER, "26",
            descrList: Strings.l_input_selector_tuner, icon: Drawables.media_item_radio),
        EnumItem.code(InputSelector.MUSIC_SERVER, "27",
            descrList: Strings.l_input_selector_music_server, icon: Drawables.media_item_media_server, isMediaList: true),
        EnumItem.code(InputSelector.INTERNET_RADIO, "28",
            descrList: Strings.l_input_selector_internet_radio, icon: Drawables.media_item_radio_digital),
        EnumItem.code(InputSelector.USB_FRONT, "29",
            descrList: Strings.l_input_selector_usb_front, icon: Drawables.media_item_usb, isMediaList: true),
        EnumItem.code(InputSelector.USB_REAR, "2A",
            descrList: Strings.l_input_selector_usb_rear, icon: Drawables.media_item_usb, isMediaList: true),
        EnumItem.code(InputSelector.NET, "2B",
            descrList: Strings.l_input_selector_net, icon: Drawables.media_item_net, isMediaList: true),
        EnumItem.code(InputSelector.USB_TOGGLE, "2C",
            descrList: Strings.l_input_selector_usb_toggle),
        EnumItem.code(InputSelector.AIRPLAY, "2D",
            descrList: Strings.l_input_selector_airplay, icon: Drawables.media_item_airplay),
        EnumItem.code(InputSelector.BLUETOOTH, "2E",
            descrList: Strings.l_input_selector_bluetooth, icon: Drawables.media_item_bluetooth),
        EnumItem.code(InputSelector.USB_DAC_IN, "2F",
            descrList: Strings.l_input_selector_usb_dac_in),
        EnumItem.code(InputSelector.LINE, "41",
            descrList: Strings.l_input_selector_line),
        EnumItem.code(InputSelector.LINE2, "42",
            descrList: Strings.l_input_selector_line2),
        EnumItem.code(InputSelector.OPTICAL, "44",
            descrList: Strings.l_input_selector_optical, icon: Drawables.media_item_toslink),
        EnumItem.code(InputSelector.COAXIAL, "45",
            descrList: Strings.l_input_selector_coaxial),
        EnumItem.code(InputSelector.UNIVERSAL_PORT, "40",
            descrList: Strings.l_input_selector_universal_port),
        EnumItem.code(InputSelector.MULTI_CH, "30",
            descrList: Strings.l_input_selector_multi_ch),
        EnumItem.code(InputSelector.XM, "31",
            descrList: Strings.l_input_selector_xm),
        EnumItem.code(InputSelector.SIRIUS, "32",
            descrList: Strings.l_input_selector_sirius),
        EnumItem.code(InputSelector.DAB, "33",
            descrList: Strings.l_input_selector_dab, icon: Drawables.media_item_radio_dab),
        EnumItem.code(InputSelector.HDMI_5, "55",
            descrList: Strings.l_input_selector_hdmi_5),
        EnumItem.code(InputSelector.HDMI_6, "56",
            descrList: Strings.l_input_selector_hdmi_6),
        EnumItem.code(InputSelector.HDMI_7, "57",
            descrList: Strings.l_input_selector_hdmi_7),
    ]);

    InputSelectorMsg(EISCPMessage raw) : super(ZONE_COMMANDS, raw, ValueEnum);

    InputSelectorMsg.output(int zoneIndex, InputSelector v) :
            super.output(ZONE_COMMANDS, zoneIndex, v, ValueEnum);
}