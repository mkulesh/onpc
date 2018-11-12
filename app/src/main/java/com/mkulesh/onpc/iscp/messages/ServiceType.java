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
import com.mkulesh.onpc.iscp.ISCPMessage;

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
public enum ServiceType implements ISCPMessage.StringParameterIf
{
    UNKNOWN("XX", R.drawable.media_item_unknown),
    MUSIC_SERVER("00", R.drawable.media_item_server),
    FAVORITE("01"),
    VTUNER("02"),
    SIRIUSXM("03"),
    PANDORA("04"),
    RHAPSODY("05"),
    LAST_FM("06"),
    NAPSTER("07"),
    SLACKER("08"),
    MEDIAFLY("09"),
    SPOTIFY("0A", R.drawable.media_item_spotify),
    AUPEO("0B"),
    RADIKO("0C"),
    E_ONKYO("0D"),
    TUNEIN_RADIO("0E", R.drawable.media_item_tunein),
    MP3TUNES("0F"),
    SIMFY("10"),
    HOME_MEDIA("11"),
    DEEZER("12", R.drawable.media_item_deezer),
    IHEARTRADIO("13"),
    AIRPLAY("18", R.drawable.media_item_airplay),
    ONKYO_MUSIC("1A"),
    TIDAL("1B", R.drawable.media_item_tidal),
    PLAYQUEUE("1D", R.drawable.media_item_playqueue),
    CHROMECAST("40", R.drawable.media_item_chromecast),
    FIRECONNECT("41"),
    PLAY_FI("42"),
    FLARECONNECT("43"),
    USB_FRONT("F0", R.drawable.media_item_usb),
    USB_REAR("F1", R.drawable.media_item_usb),
    INTERNET_RADIO("F2"),
    NET("F3"),
    BLUETOOTH("F4");

    final String code;
    final int imageId;

    ServiceType(String code, final int imageId)
    {
        this.code = code;
        this.imageId = imageId;
    }

    ServiceType(String code)
    {
        this.code = code;
        this.imageId = R.drawable.media_item_unknown;
    }

    public String getCode()
    {
        return code;
    }

    public int getImageId()
    {
        return imageId;
    }
}

