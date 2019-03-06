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
        super(zone);
        Logging.info(this, "Used mockup state");

        //Common
        powerStatus = PowerStatusMsg.PowerStatus.ON;
        deviceProperties.put("brand", "Onkyo");
        deviceProperties.put("model", "NS-6130");
        deviceProperties.put("year", "2016");
        deviceProperties.put("friendlyname", "PROP_NAME");
        deviceProperties.put("firmwareversion", "1234-5678-910");
        friendlyName = "FRI_NAME";
        networkServices.put("04", "Pandora");
        networkServices.put("0A", "Spotify");
        networkServices.put("0E", "TuneIn");
        networkServices.put("12", "Deezer");
        networkServices.put("18", "Airplay");
        networkServices.put("1B", "Tidal");
        networkServices.put("1D", "Play Queue");
        zones.add(new ReceiverInformationMsg.Zone("0", "Main", 0, 0x82));
        zones.add(new ReceiverInformationMsg.Zone("2", "Zone2", 1, 0x82));
        deviceSelectors.add(new ReceiverInformationMsg.Selector("2B", "Network", 1, "2B", false));
        deviceSelectors.add(new ReceiverInformationMsg.Selector("29", "Front USB", 1, "29", true));
        deviceSelectors.add(new ReceiverInformationMsg.Selector("2A", "Rear USB", 1, "2A", true));
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
