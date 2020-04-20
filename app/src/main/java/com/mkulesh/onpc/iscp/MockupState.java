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

package com.mkulesh.onpc.iscp;

import com.mkulesh.onpc.iscp.messages.AutoPowerMsg;
import com.mkulesh.onpc.iscp.messages.DigitalFilterMsg;
import com.mkulesh.onpc.iscp.messages.DimmerLevelMsg;
import com.mkulesh.onpc.iscp.messages.InputSelectorMsg;
import com.mkulesh.onpc.iscp.messages.ListTitleInfoMsg;
import com.mkulesh.onpc.iscp.messages.MenuStatusMsg;
import com.mkulesh.onpc.iscp.messages.NetworkServiceMsg;
import com.mkulesh.onpc.iscp.messages.PlayStatusMsg;
import com.mkulesh.onpc.iscp.messages.PowerStatusMsg;
import com.mkulesh.onpc.iscp.messages.ReceiverInformationMsg;
import com.mkulesh.onpc.iscp.messages.ServiceType;
import com.mkulesh.onpc.utils.Logging;

class MockupState extends State
{
    MockupState(int zone)
    {
        super("192.168.1.10", zone);
        Logging.info(this, "Used mockup state");

        //Common
        powerStatus = PowerStatusMsg.PowerStatus.ON;
        deviceProperties.put("brand", "Onkyo");
        deviceProperties.put("model", "NS-6130");
        deviceProperties.put("year", "2016");
        deviceProperties.put("friendlyname", "PROP_NAME");
        deviceProperties.put("firmwareversion", "1234-5678-910");
        friendlyName = "FRI_NAME";
        networkServices.put("04", new ReceiverInformationMsg.NetworkService("04", "Pandora"   ,1, false, false));
        networkServices.put("0A", new ReceiverInformationMsg.NetworkService("0A", "Spotify"   ,1, false, false));
        networkServices.put("0E", new ReceiverInformationMsg.NetworkService("0E", "TuneIn"    ,1, false, false));
        networkServices.put("12", new ReceiverInformationMsg.NetworkService("12", "Deezer"    ,1, false, false));
        networkServices.put("18", new ReceiverInformationMsg.NetworkService("18", "Airplay"   ,1, false, false));
        networkServices.put("1B", new ReceiverInformationMsg.NetworkService("1B", "Tidal"     ,1, false, false));
        networkServices.put("1D", new ReceiverInformationMsg.NetworkService("1D", "Play Queue",1, false, false));
        inputType = InputSelectorMsg.InputType.NET;
        dimmerLevel = DimmerLevelMsg.Level.DIM;
        digitalFilter = DigitalFilterMsg.Filter.F01;
        autoPower = AutoPowerMsg.Status.ON;

        // Track info
        cover = null;
        album = "Album";
        artist = "Artist";
        title = "Long title of song";
        currentTime = "00:00:59";
        maxTime = "00:10:15";
        currentTrack = 1;
        maxTrack = 10;
        fileFormat = "FLAC/44hHz/16b";

        // Playback
        playStatus = PlayStatusMsg.PlayStatus.PLAY;
        repeatStatus = PlayStatusMsg.RepeatStatus.ALL;
        shuffleStatus = PlayStatusMsg.ShuffleStatus.ALL;
        timeSeek = MenuStatusMsg.TimeSeek.ENABLE;

        // Navigation
        serviceType = ServiceType.NET;
        layerInfo = ListTitleInfoMsg.LayerInfo.NET_TOP;
        numberOfLayers = 0;
        numberOfItems = 9;
        titleBar = "Net";
        serviceItems.add(new NetworkServiceMsg(ServiceType.MUSIC_SERVER));
        serviceItems.add(new NetworkServiceMsg(ServiceType.SPOTIFY));
        serviceItems.add(new NetworkServiceMsg(ServiceType.TUNEIN_RADIO));
        serviceItems.add(new NetworkServiceMsg(ServiceType.DEEZER));
        serviceItems.add(new NetworkServiceMsg(ServiceType.AIRPLAY));
        serviceItems.add(new NetworkServiceMsg(ServiceType.TIDAL));
        serviceItems.add(new NetworkServiceMsg(ServiceType.CHROMECAST));
        serviceItems.add(new NetworkServiceMsg(ServiceType.FLARECONNECT));
        serviceItems.add(new NetworkServiceMsg(ServiceType.PLAYQUEUE));
    }
}
