/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2023 by Mikhail Kulesh
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
import "../../utils/Convert.dart";
import "../ConnectionIf.dart";
import "../EISCPMessage.dart";
import "EnumParameterMsg.dart";

enum InputSelector
{
    NONE,

    // Integra
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
    CD,
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
    HDMI_7,
    SOURCE,

    // Denon
    DCP_PHONO,
    DCP_CD,
    DCP_DVD,
    DCP_BD,
    DCP_TV,
    DCP_SAT_CBL,
    DCP_MPLAY,
    DCP_GAME,
    DCP_GAME1,
    DCP_TUNER,
    DCP_AUX1,
    DCP_AUX2,
    DCP_AUX3,
    DCP_AUX4,
    DCP_AUX5,
    DCP_AUX6,
    DCP_AUX7,
    DCP_NET,
    DCP_BT,
    DCP_SOURCE
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

        // Integra
        EnumItem.code(InputSelector.VIDEO1, "00",
            descrList: Strings.l_input_selector_vcr_dvr, icon: Drawables.media_item_vhs),
        EnumItem.code(InputSelector.VIDEO2, "01",
            descrList: Strings.l_input_selector_cbl_sat, icon: Drawables.media_item_sat),
        EnumItem.code(InputSelector.VIDEO3, "02",
            descrList: Strings.l_input_selector_game, icon: Drawables.media_item_game),
        EnumItem.code(InputSelector.VIDEO4, "03",
            descrList: Strings.l_input_selector_aux, icon: Drawables.media_item_aux),
        EnumItem.code(InputSelector.VIDEO5, "04",
            descrList: Strings.l_input_selector_aux2, icon: Drawables.media_item_aux),
        EnumItem.code(InputSelector.VIDEO6, "05",
            descrList: Strings.l_input_selector_pc, icon: Drawables.media_item_pc),
        EnumItem.code(InputSelector.VIDEO7, "06",
            descrList: Strings.l_input_selector_video7, icon: Drawables.media_item_hdmi),
        EnumItem.code(InputSelector.EXTRA1, "07",
            descrList: Strings.l_input_selector_extra1, icon: Drawables.media_item_hdmi),
        EnumItem.code(InputSelector.EXTRA2, "08",
            descrList: Strings.l_input_selector_extra2, icon: Drawables.media_item_hdmi),
        EnumItem.code(InputSelector.BD_DVD, "10",
            descrList: Strings.l_input_selector_bd_dvd, icon: Drawables.media_item_disc_player),
        EnumItem.code(InputSelector.STRM_BOX, "11",
            descrList: Strings.l_input_selector_strm_box, icon: Drawables.media_item_mplayer),
        EnumItem.code(InputSelector.TV, "12",
            descrList: Strings.l_input_selector_tv, icon: Drawables.media_item_tv),
        EnumItem.code(InputSelector.TAPE1, "20",
            descrList: Strings.l_input_selector_tape1, icon: Drawables.media_item_tape),
        EnumItem.code(InputSelector.TAPE2, "21",
            descrList: Strings.l_input_selector_tape2, icon: Drawables.media_item_tape),
        EnumItem.code(InputSelector.PHONO, "22",
            descrList: Strings.l_input_selector_phono, icon: Drawables.media_item_phono),
        EnumItem.code(InputSelector.CD, "23",
            descrList: Strings.l_input_selector_cd, icon: Drawables.media_item_disc_player),
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
            descrList: Strings.l_input_selector_usb_toggle, icon: Drawables.media_item_usb),
        EnumItem.code(InputSelector.AIRPLAY, "2D",
            descrList: Strings.l_input_selector_airplay, icon: Drawables.media_item_airplay),
        EnumItem.code(InputSelector.BLUETOOTH, "2E",
            descrList: Strings.l_input_selector_bluetooth, icon: Drawables.media_item_bluetooth),
        EnumItem.code(InputSelector.USB_DAC_IN, "2F",
            descrList: Strings.l_input_selector_usb_dac_in, icon: Drawables.media_item_usb),
        EnumItem.code(InputSelector.LINE, "41",
            descrList: Strings.l_input_selector_line, icon: Drawables.media_item_rca),
        EnumItem.code(InputSelector.LINE2, "42",
            descrList: Strings.l_input_selector_line2, icon: Drawables.media_item_rca),
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
            descrList: Strings.l_input_selector_hdmi_5, icon: Drawables.media_item_hdmi),
        EnumItem.code(InputSelector.HDMI_6, "56",
            descrList: Strings.l_input_selector_hdmi_6, icon: Drawables.media_item_hdmi),
        EnumItem.code(InputSelector.HDMI_7, "57",
            descrList: Strings.l_input_selector_hdmi_7, icon: Drawables.media_item_hdmi),
        EnumItem.code(InputSelector.SOURCE, "80",
            descrList: Strings.l_input_selector_source, icon: Drawables.media_item_source),

        // Denon
        EnumItem.code(InputSelector.DCP_PHONO, "PHONO",
            descrList: Strings.l_input_selector_phono, icon: Drawables.media_item_phono),
        EnumItem.code(InputSelector.DCP_CD, "CD",
            descrList: Strings.l_input_selector_cd, icon: Drawables.media_item_disc_player),
        EnumItem.code(InputSelector.DCP_DVD, "DVD",
            descrList: Strings.l_input_selector_dvd, icon: Drawables.media_item_disc_player),
        EnumItem.code(InputSelector.DCP_BD, "BD",
            descrList: Strings.l_input_selector_bd, icon: Drawables.media_item_disc_player),
        EnumItem.code(InputSelector.DCP_TV, "TV",
            descrList: Strings.l_input_selector_tv, icon: Drawables.media_item_tv),
        EnumItem.code(InputSelector.DCP_SAT_CBL, "SAT/CBL",
            descrList: Strings.l_input_selector_cbl_sat, icon: Drawables.media_item_sat),
        EnumItem.code(InputSelector.DCP_MPLAY, "MPLAY",
            descrList: Strings.l_input_selector_mplayer, icon: Drawables.media_item_mplayer),
        EnumItem.code(InputSelector.DCP_GAME, "GAME",
            descrList: Strings.l_input_selector_game, icon: Drawables.media_item_game),
        EnumItem.code(InputSelector.DCP_GAME1, "GAME1",
            descrList: Strings.l_input_selector_game1, icon: Drawables.media_item_game),
        EnumItem.code(InputSelector.DCP_TUNER, "TUNER",
            descrList: Strings.l_input_selector_tuner, icon: Drawables.media_item_radio),
        EnumItem.code(InputSelector.DCP_AUX1, "AUX1",
            descrList: Strings.l_input_selector_aux1, icon: Drawables.media_item_rca),
        EnumItem.code(InputSelector.DCP_AUX2, "AUX2",
            descrList: Strings.l_input_selector_aux2, icon: Drawables.media_item_rca),
        EnumItem.code(InputSelector.DCP_AUX3, "AUX3",
            descrList: Strings.l_input_selector_aux3, icon: Drawables.media_item_rca),
        EnumItem.code(InputSelector.DCP_AUX4, "AUX4",
            descrList: Strings.l_input_selector_aux4, icon: Drawables.media_item_rca),
        EnumItem.code(InputSelector.DCP_AUX5, "AUX5",
            descrList: Strings.l_input_selector_aux5, icon: Drawables.media_item_rca),
        EnumItem.code(InputSelector.DCP_AUX6, "AUX6",
            descrList: Strings.l_input_selector_aux6, icon: Drawables.media_item_rca),
        EnumItem.code(InputSelector.DCP_AUX7, "AUX7",
            descrList: Strings.l_input_selector_aux7, icon: Drawables.media_item_rca),
        EnumItem.code(InputSelector.DCP_NET, "NET",
            descrList: Strings.l_input_selector_net, icon: Drawables.media_item_net, isMediaList: true),
        EnumItem.code(InputSelector.DCP_BT, "BT",
            descrList: Strings.l_input_selector_bluetooth, icon: Drawables.media_item_bluetooth),
        EnumItem.code(InputSelector.DCP_SOURCE, "SOURCE",
            descrList: Strings.l_input_selector_source, icon: Drawables.media_item_source)
    ]);

    InputSelectorMsg(EISCPMessage raw) : super(ZONE_COMMANDS, raw, ValueEnum);

    InputSelectorMsg.output(int zoneIndex, InputSelector v) :
            super.output(ZONE_COMMANDS, zoneIndex, v, ValueEnum);

    static ProtoType getProtoType(InputSelector item)
    => Convert.enumToString(item).startsWith("DCP_") ? ProtoType.DCP : ProtoType.ISCP;

    /*
     * Denon control protocol
     */
    static const List<String> _DCP_COMMANDS = [ "SI", "Z2", "Z3" ];

    static List<String> getAcceptedDcpCodes()
    => _DCP_COMMANDS;

    static InputSelectorMsg? processDcpMessage(String dcpMsg)
    {
        for (int i = 0; i < _DCP_COMMANDS.length; i++)
        {
            final EnumItem<InputSelector>? s = ValueEnum.valueByDcpCommand(_DCP_COMMANDS[i], dcpMsg);
            if (s != null && getProtoType(s.key) == ProtoType.DCP)
            {
                return InputSelectorMsg.output(i, s.key);
            }
        }
        return null;
    }

    @override
    String? buildDcpMsg(bool isQuery)
    => buildDcpRequest(isQuery, _DCP_COMMANDS);
}