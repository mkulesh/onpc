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
 * Select Network Service directly only when NET selector is selected.
 */
public class NetworkServiceMsg extends ISCPMessage
{
    public final static String CODE = "NSV";

    public enum Service implements StringParameterIf
    {
        UNKNOWN("", "", -1),
        MUSIC_SERVER("Music Server", "00", R.string.net_service_music_server, R.drawable.media_item_server),
        FAVORITE("Favorite", "01", R.string.net_service_favorite),
        VTUNER("vTuner", "02", R.string.net_service_vtuner),
        SIRIUSXM("SiriusXM", "03", R.string.net_service_siriusxm),
        PANDORA("Pandora", "04", R.string.net_service_pandora),
        RHAPSODY("Rhapsody", "05", R.string.net_service_rhapsody),
        LAST_FM("Last.fm", "06", R.string.net_service_last),
        NAPSTER("Napster", "07", R.string.net_service_napster),
        SLACKER("Slacker", "08", R.string.net_service_slacker),
        MEDIAFLY("Mediafly", "09", R.string.net_service_mediafly),
        SPOTIFY("Spotify", "0A", R.string.net_service_spotify),
        AUPEO("AUPEO!", "0B", R.string.net_service_aupeo),
        RADIKO("Radiko", "0C", R.string.net_service_radiko),
        E_ONKYO("e-onkyo", "0D", R.string.net_service_e_onkyo),
        TUNEIN_RADIO("TuneIn", "0E", R.string.net_service_tunein_radio, R.drawable.media_item_tunein),
        MP3TUNES("mp3tunes", "0F", R.string.net_service_mp3tunes),
        SIMFY("Simfy", "10", R.string.net_service_simfy),
        HOME_MEDIA("Home Media", "11", R.string.net_service_home_media),
        DEEZER("Deezer", "12", R.string.net_service_deezer, R.drawable.media_item_deezer),
        IHEARTRADIO("iHeartRadio", "13", R.string.net_service_iheartradio),
        AIRPLAY("Airplay", "18", R.string.net_service_airplay),
        ONKYO_MUSIC("onkyo music", "1A", R.string.net_service_onkyo_music),
        TIDAL("Tidal", "1B", R.string.net_service_tidal, R.drawable.media_item_tidal),
        PLAYQUEUE("Play Queue", "1D", R.string.net_service_playqueue, R.drawable.media_item_playqueue),
        CHROMECAST("Chromecast built-in", "40", R.string.net_service_chromecast, R.drawable.media_item_chromecast),
        FLARECONNECT("FlareConnect", "43", R.string.net_service_flareconnect),
        PLAY_FI("Play-Fi", "42", R.string.net_service_play_fi);

        final String code;
        final String id;
        final int descriptionId;
        final int imageId;

        Service(final String code, final String id, final int descriptionId, final int imageId)
        {
            this.code = code;
            this.id = id;
            this.descriptionId = descriptionId;
            this.imageId = imageId;
        }

        Service(final String code, final String id, final int descriptionId)
        {
            this.code = code;
            this.id = id;
            this.descriptionId = descriptionId;
            this.imageId = R.drawable.media_item_unknown;
        }

        public String getCode()
        {
            return code;
        }

        public String getId()
        {
            return id;
        }

        public int getDescriptionId()
        {
            return descriptionId;
        }

        public int getImageId()
        {
            return imageId;
        }

        public boolean isImageValid()
        {
            return imageId != -1;
        }
    }

    private final Service service;

    public NetworkServiceMsg(final String code)
    {
        super(0, null);
        this.service = (Service) searchParameter(code, Service.values(), Service.UNKNOWN);
    }

    public NetworkServiceMsg(NetworkServiceMsg other)
    {
        super(other);
        service = other.service;
    }

    public Service getService()
    {
        return service;
    }

    @Override
    public String toString()
    {
        return CODE + "[" + service.toString() + "/" + service.getId() + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        final String param = service.getId() + "0";
        return new EISCPMessage('1', CODE, param);
    }
}

 
