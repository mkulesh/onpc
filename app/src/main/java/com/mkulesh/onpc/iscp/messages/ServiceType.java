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
import com.mkulesh.onpc.iscp.ISCPMessage;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;
import androidx.annotation.StringRes;

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
public enum ServiceType implements ISCPMessage.DcpStringParameterIf
{
    // Integra
    // Note: some names are device-specific, see comments
    // We use the names when ListInfoMsg is processed as a fallback is no ReceiverInformationMsg
    // exists for given device
    UNKNOWN("XX", "", R.string.dashed_string),
    MUSIC_SERVER("00", "DLNA", R.string.service_music_server, R.drawable.media_item_media_server), // TX-8050
    FAVORITE("01", "My Favorites", R.string.service_favorite, R.drawable.media_item_favorite), // TX-8050
    VTUNER("02", "vTuner Internet Radio", R.string.service_vtuner), // TX-8050
    SIRIUSXM("03", "SiriusXM Internet Radio", R.string.service_siriusxm), // TX-8050
    PANDORA("04", "Pandora Internet Radio", R.string.service_pandora, R.drawable.media_item_pandora), // TX-NR616
    RHAPSODY("05", "Rhapsody", R.string.service_rhapsody), // TX-NR616
    LAST_FM("06", "Last.fm Internet Radio", R.string.service_last, R.drawable.media_item_lastfm), // TX-8050, TX-NR616
    NAPSTER("07", "Napster", R.string.service_napster, R.drawable.media_item_napster),
    SLACKER("08", "Slacker Personal Radio", R.string.service_slacker), // TX-NR616
    MEDIAFLY("09", "Mediafly", R.string.service_mediafly),
    SPOTIFY("0A", "Spotify", R.string.service_spotify, R.drawable.media_item_spotify), // TX-NR616
    AUPEO("0B", "AUPEO! PERSONAL RADIO", R.string.service_aupeo), // TX-8050, TX-NR616
    RADIKO("0C", "Radiko", R.string.service_radiko),
    E_ONKYO("0D", "e-onkyo", R.string.service_e_onkyo),
    TUNEIN_RADIO("0E", "TuneIn", R.string.service_tunein_radio, R.drawable.media_item_tunein),
    MP3TUNES("0F", "mp3tunes", R.string.service_mp3tunes), // TX-NR616
    SIMFY("10", "Simfy", R.string.service_simfy),
    HOME_MEDIA("11", "Home Media", R.string.service_home_media, R.drawable.media_item_media_server), // TX-NR616
    DEEZER("12", "Deezer", R.string.service_deezer, R.drawable.media_item_deezer),
    IHEARTRADIO("13", "iHeartRadio", R.string.service_iheartradio),
    AIRPLAY("18", "Airplay", R.string.service_airplay, R.drawable.media_item_airplay),
    ONKYO_MUSIC("1A", "onkyo music", R.string.service_onkyo_music),
    TIDAL("1B", "Tidal", R.string.service_tidal, R.drawable.media_item_tidal),
    AMAZON_MUSIC("1C", "AmazonMusic", R.string.service_amazon_music, R.drawable.media_item_amazon),
    PLAYQUEUE("1D", "Play Queue", R.string.service_playqueue, R.drawable.media_item_playqueue),
    CHROMECAST("40", "Chromecast built-in", R.string.service_chromecast, R.drawable.media_item_chromecast),
    FIRECONNECT("41", "FireConnect", R.string.service_fireconnect),
    PLAY_FI("42", "DTS Play-Fi", R.string.service_play_fi, R.drawable.media_item_play_fi),
    FLARECONNECT("43", "FlareConnect", R.string.service_flareconnect, R.drawable.media_item_flare_connect),
    AIRPLAY1("44", "Airplay", R.string.service_airplay, R.drawable.media_item_airplay), // TX-RZ630 uses code "44" for Airplay instead of "18"
    USB_FRONT("F0", "USB(Front)", R.string.service_usb_front, R.drawable.media_item_usb),
    USB_REAR("F1", "USB(Rear)", R.string.service_usb_rear, R.drawable.media_item_usb),
    INTERNET_RADIO("F2", "Internet radio", R.string.service_internet_radio, R.drawable.media_item_radio_digital),
    NET("F3", "NET", R.string.service_net, R.drawable.media_item_net),
    BLUETOOTH("F4", "Bluetooth", R.string.service_bluetooth, R.drawable.media_item_bluetooth),

    // Denon
    DCP_PANDORA("HS1", "Pandora", R.string.service_pandora, R.drawable.media_item_pandora),
    DCP_RHAPSODY("HS2", "Rhapsody", R.string.service_rhapsody),
    DCP_TUNEIN("HS3", "TuneIn", R.string.service_tunein_radio, R.drawable.media_item_tunein),
    DCP_SPOTIFY("HS4", "Spotify", R.string.service_spotify, R.drawable.media_item_spotify),
    DCP_DEEZER("HS5", "Deezer", R.string.service_deezer, R.drawable.media_item_deezer),
    DCP_NAPSTER("HS6", "Napster", R.string.service_napster, R.drawable.media_item_napster),
    DCP_IHEARTRADIO("HS7", "iHeartRadio", R.string.service_iheartradio),
    DCP_SIRIUSXM("HS8", "Sirius XM", R.string.service_siriusxm),
    DCP_SOUNDCLOUD("HS9", "Soundcloud", R.string.service_soundcloud, R.drawable.media_item_soundcloud),
    DCP_TIDAL("HS10", "Tidal", R.string.service_tidal, R.drawable.media_item_tidal),
    DCP_AMAZON_MUSIC("HS13", "Amazon Music", R.string.service_amazon_music, R.drawable.media_item_amazon),
    DCP_LOCAL("HS1024", "Local Music", R.string.service_local_music, R.drawable.media_item_folder),
    DCP_PLAYLIST("HS1025", "Playlists", R.string.service_playlist, R.drawable.media_item_playqueue),
    DCP_HISTORY("HS1026", "History", R.string.service_history, R.drawable.media_item_history),
    DCP_AUX("HS1027", "AUX Input", R.string.service_aux_input, R.drawable.media_item_aux),
    DCP_FAVORITE("HS1028", "Favorites", R.string.service_favorite, R.drawable.media_item_favorite),
    DCP_PLAYQUEUE("HS9999", "Play Queue", R.string.service_playqueue, R.drawable.media_item_playqueue);

    private final String code;
    private final String name;

    @StringRes
    private final int descriptionId;

    @DrawableRes
    private final int imageId;

    ServiceType(final String code, final String name, @StringRes final int descriptionId, @DrawableRes final int imageId)
    {
        this.code = code;
        this.name = name;
        this.descriptionId = descriptionId;
        this.imageId = imageId;
    }

    ServiceType(final String code, final String name, @StringRes final int descriptionId)
    {
        this.code = code;
        this.name = name;
        this.descriptionId = descriptionId;
        this.imageId = R.drawable.media_item_unknown;
    }

    public String getCode()
    {
        return code;
    }

    @NonNull
    @Override
    public String getDcpCode()
    {
        return code.startsWith("HS") ? code : "N/A";
    }

    public String getName()
    {
        return name;
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

