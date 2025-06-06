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
import "EnumParameterMsg.dart";

/*
 * Service icon
 * "00":Music Server (DLNA), "01":My Favorite, "02":vTuner,
 * "03":SiriusXM, "04":Pandora,
 * "05":Rhapsody, "06":Last.fm, "07":Napster, "08":Slacker, "09":Mediafly,
 * "0A":Spotify, "0B":AUPEO!,
 * "0C":radiko, "0D":e-onkyo, "0E":TuneIn, "0F":MP3tunes, "10":Simfy,
 * "11":Home Media, "12":Deezer, "13":iHeartRadio, "18":Airplay,
 * “1A”: onkyo Music, “1B”:TIDAL, "1D":PlayQueue,
 * “40”:Chromecast built-in, “41”:FireConnect, "42":Play-Fi,
 * "F0": USB/USB(Front), "F1: USB(Rear), "F2":Internet Radio
 * "F3":NET, "F4":Bluetooth
 */
enum ServiceType
{
    UNKNOWN,
    // Integra
    MUSIC_SERVER,
    FAVORITE,
    VTUNER,
    SIRIUSXM,
    PANDORA,
    RHAPSODY,
    LAST_FM,
    NAPSTER,
    SLACKER,
    MEDIAFLY,
    SPOTIFY,
    AUPEO,
    RADIKO,
    E_ONKYO,
    TUNEIN_RADIO,
    MP3TUNES,
    SIMFY,
    HOME_MEDIA,
    DEEZER,
    IHEARTRADIO,
    AIRPLAY,
    ONKYO_MUSIC,
    TIDAL,
    AMAZON_MUSIC,
    PLAYQUEUE,
    CHROMECAST,
    FIRECONNECT,
    PLAY_FI,
    FLARECONNECT,
    AIRPLAY1,
    USB_FRONT,
    USB_REAR,
    INTERNET_RADIO,
    NET,
    BLUETOOTH,

    // Denon
    DCP_PANDORA,
    DCP_RHAPSODY,
    DCP_TUNEIN,
    DCP_SPOTIFY,
    DCP_DEEZER,
    DCP_NAPSTER,
    DCP_IHEARTRADIO,
    DCP_SIRIUSXM,
    DCP_SOUNDCLOUD,
    DCP_TIDAL,
    DCP_AMAZON_MUSIC,
    DCP_LOCAL,
    DCP_PLAYLIST,
    DCP_HISTORY,
    DCP_AUX,
    DCP_FAVORITE,
    DCP_PLAYQUEUE
}

class Services
{
    // Note: some names are device-specific, see comments
    // We use the names when ListInfoMsg is processed as a fallback is no ReceiverInformationMsg
    // exists for given device
    static const ExtEnum<ServiceType> ServiceTypeEnum = ExtEnum<ServiceType>([
        EnumItem.code(ServiceType.UNKNOWN, "XX",
            name: "",
            descr: Strings.dashed_string, defValue: true),

        // Integra
        // Note: some names are device-specific, see comments
        // We use the names when ListInfoMsg is processed as a fallback is no ReceiverInformationMsg
        // exists for given device
        EnumItem.code(ServiceType.MUSIC_SERVER, "00",
            name: "DLNA",
            descrList: Strings.l_service_music_server, icon: Drawables.media_item_media_server), // TX-8050
        EnumItem.code(ServiceType.FAVORITE, "01",
            name: "My Favorites",
            descrList: Strings.l_service_favorite, icon: Drawables.media_item_favorite), // TX-8050
        EnumItem.code(ServiceType.VTUNER, "02",
            name: "vTuner Internet Radio",
            descrList: Strings.l_service_vtuner), // TX-8050
        EnumItem.code(ServiceType.SIRIUSXM, "03",
            name: "SiriusXM Internet Radio",
            descrList: Strings.l_service_siriusxm), // TX-8050
        EnumItem.code(ServiceType.PANDORA, "04",
            name: "Pandora Internet Radio",
            descrList: Strings.l_service_pandora, icon: Drawables.media_item_pandora), // TX-NR616
        EnumItem.code(ServiceType.RHAPSODY, "05",
            name: "Rhapsody",
            descrList: Strings.l_service_rhapsody), // TX-NR616
        EnumItem.code(ServiceType.LAST_FM, "06",
            name: "Last.fm Internet Radio",
            descrList: Strings.l_service_last, icon: Drawables.media_item_lastfm), // TX-8050, TX-NR616
        EnumItem.code(ServiceType.NAPSTER, "07",
            name: "Napster",
            descrList: Strings.l_service_napster, icon: Drawables.media_item_napster),
        EnumItem.code(ServiceType.SLACKER, "08",
            name: "Slacker Personal Radio",
            descrList: Strings.l_service_slacker), // TX-NR616
        EnumItem.code(ServiceType.MEDIAFLY, "09",
            name: "Mediafly",
            descrList: Strings.l_service_mediafly),
        EnumItem.code(ServiceType.SPOTIFY, "0A",
            name: "Spotify",
            descrList: Strings.l_service_spotify, icon: Drawables.media_item_spotify), // TX-NR616
        EnumItem.code(ServiceType.AUPEO, "0B",
            name: "AUPEO! PERSONAL RADIO",
            descrList: Strings.l_service_aupeo), // TX-8050, TX-NR616
        EnumItem.code(ServiceType.RADIKO, "0C",
            name: "Radiko",
            descrList: Strings.l_service_radiko),
        EnumItem.code(ServiceType.E_ONKYO, "0D",
            name: "e-onkyo",
            descrList: Strings.l_service_e_onkyo),
        EnumItem.code(ServiceType.TUNEIN_RADIO, "0E",
            name: "TuneIn",
            descrList: Strings.l_service_tunein_radio, icon: Drawables.media_item_tunein),
        EnumItem.code(ServiceType.MP3TUNES, "0F",
            name: "mp3tunes",
            descrList: Strings.l_service_mp3tunes), // TX-NR616
        EnumItem.code(ServiceType.SIMFY, "10",
            name: "Simfy",
            descrList: Strings.l_service_simfy),
        EnumItem.code(ServiceType.HOME_MEDIA, "11",
            name: "Home Media",
            descrList: Strings.l_service_home_media, icon: Drawables.media_item_media_server), // TX-NR616
        EnumItem.code(ServiceType.DEEZER, "12",
            name: "Deezer",
            descrList: Strings.l_service_deezer, icon: Drawables.media_item_deezer),
        EnumItem.code(ServiceType.IHEARTRADIO, "13",
            name: "iHeartRadio",
            descrList: Strings.l_service_iheartradio),
        EnumItem.code(ServiceType.AIRPLAY, "18",
            name: "Airplay",
            descrList: Strings.l_service_airplay, icon: Drawables.media_item_airplay),
        EnumItem.code(ServiceType.ONKYO_MUSIC, "1A",
            name: "onkyo music",
            descrList: Strings.l_service_onkyo_music),
        EnumItem.code(ServiceType.TIDAL, "1B",
            name: "Tidal",
            descrList: Strings.l_service_tidal, icon: Drawables.media_item_tidal),
        EnumItem.code(ServiceType.AMAZON_MUSIC, "1C",
            name: "AmazonMusic",
            descrList: Strings.l_service_amazon_music, icon: Drawables.media_item_amazon),
        EnumItem.code(ServiceType.PLAYQUEUE, "1D",
            name: "Play Queue",
            descrList: Strings.l_service_playqueue, icon: Drawables.media_item_playqueue),
        EnumItem.code(ServiceType.CHROMECAST, "40",
            name: "Chromecast built-in",
            descrList: Strings.l_service_chromecast, icon: Drawables.media_item_chromecast),
        EnumItem.code(ServiceType.FIRECONNECT, "41",
            name: "FireConnect",
            descrList: Strings.l_service_fireconnect),
        EnumItem.code(ServiceType.PLAY_FI, "42",
            name: "DTS Play-Fi",
            descrList: Strings.l_service_play_fi, icon: Drawables.media_item_play_fi),
        EnumItem.code(ServiceType.FLARECONNECT, "43",
            name: "FlareConnect",
            descrList: Strings.l_service_flareconnect, icon: Drawables.media_item_flare_connect),
        EnumItem.code(ServiceType.AIRPLAY1, "44",
            name: "Airplay",
            descrList: Strings.l_service_airplay, icon: Drawables.media_item_airplay), // TX-RZ630 uses code "44" for Airplay instead of "18"
        EnumItem.code(ServiceType.USB_FRONT, "F0",
            name: "USB(Front)",
            descrList: Strings.l_service_usb_front, icon: Drawables.media_item_usb),
        EnumItem.code(ServiceType.USB_REAR, "F1",
            name: "USB(Rear)",
            descrList: Strings.l_service_usb_rear, icon: Drawables.media_item_usb),
        EnumItem.code(ServiceType.INTERNET_RADIO, "F2",
            name: "Internet radio",
            descrList: Strings.l_service_internet_radio, icon: Drawables.media_item_radio_digital),
        EnumItem.code(ServiceType.NET, "F3",
            name: "NET",
            descrList: Strings.l_service_net, icon: Drawables.media_item_net),
        EnumItem.code(ServiceType.BLUETOOTH, "F4",
            name: "Bluetooth",
            descrList: Strings.l_service_bluetooth, icon: Drawables.media_item_bluetooth),

        // Denon
        EnumItem.code(ServiceType.DCP_PANDORA, "HS1",    name: "Pandora",
            descrList: Strings.l_service_pandora, icon: Drawables.media_item_pandora),
        EnumItem.code(ServiceType.DCP_RHAPSODY, "HS2",    name: "Rhapsody",
            descrList: Strings.l_service_rhapsody),
        EnumItem.code(ServiceType.DCP_TUNEIN, "HS3",    name: "TuneIn",
            descrList: Strings.l_service_tunein_radio, icon: Drawables.media_item_tunein),
        EnumItem.code(ServiceType.DCP_SPOTIFY, "HS4",    name: "Spotify",
            descrList: Strings.l_service_spotify, icon: Drawables.media_item_spotify),
        EnumItem.code(ServiceType.DCP_DEEZER, "HS5",    name: "Deezer",
            descrList: Strings.l_service_deezer, icon: Drawables.media_item_deezer),
        EnumItem.code(ServiceType.DCP_NAPSTER, "HS6",    name: "Napster",
            descrList: Strings.l_service_napster, icon: Drawables.media_item_napster),
        EnumItem.code(ServiceType.DCP_IHEARTRADIO, "HS7",    name: "iHeartRadio",
            descrList: Strings.l_service_iheartradio),
        EnumItem.code(ServiceType.DCP_SIRIUSXM, "HS8",    name: "Sirius XM",
            descrList: Strings.l_service_siriusxm),
        EnumItem.code(ServiceType.DCP_SOUNDCLOUD, "HS9",    name: "Soundcloud",
            descrList: Strings.l_service_soundcloud, icon: Drawables.media_item_soundcloud),
        EnumItem.code(ServiceType.DCP_TIDAL, "HS10",   name: "Tidal",
            descrList: Strings.l_service_tidal, icon: Drawables.media_item_tidal),
        EnumItem.code(ServiceType.DCP_AMAZON_MUSIC, "HS13",   name: "Amazon Music",
            descrList: Strings.l_service_amazon_music, icon: Drawables.media_item_amazon),
        EnumItem.code(ServiceType.DCP_LOCAL, "HS1024",
            name: "Local Music",
            descrList: Strings.l_service_local_music, icon: Drawables.media_item_folder),
        EnumItem.code(ServiceType.DCP_PLAYLIST, "HS1025",
            name: "Playlists",
            descrList: Strings.l_service_playlist, icon: Drawables.media_item_playlist),
        EnumItem.code(ServiceType.DCP_HISTORY, "HS1026",
            name: "History",
            descrList: Strings.l_service_history, icon: Drawables.media_item_history),
        EnumItem.code(ServiceType.DCP_AUX, "HS1027",
            name: "AUX Input",
            descrList: Strings.l_service_aux_input, icon: Drawables.media_item_aux),
        EnumItem.code(ServiceType.DCP_FAVORITE, "HS1028",
            name: "Favorites",
            descrList: Strings.l_service_favorite, icon: Drawables.media_item_favorite),
        EnumItem.code(ServiceType.DCP_PLAYQUEUE, "HS9999",
            name: "Play Queue",
            descrList: Strings.l_service_playqueue, icon: Drawables.media_item_playqueue)
    ]);
}
