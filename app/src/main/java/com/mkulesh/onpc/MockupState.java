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

package com.mkulesh.onpc;

import android.content.Context;
import android.graphics.BitmapFactory;

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

class MockupState extends State
{
    MockupState(Context context)
    {
        //Common
        powerStatus = PowerStatusMsg.PowerStatus.ON;
        deviceProperties.put("brand", "Onkyo");
        deviceProperties.put("model", "NS-6130");
        deviceProperties.put("year", "2016");
        deviceProperties.put("firmwareversion", "1234-5678-910");
        deviceCover = BitmapFactory.decodeResource(context.getResources(), R.drawable.device_connect);
        deviceSelectors.add(new ReceiverInformationMsg.Selector("2B", "Network", "2B", false));
        deviceSelectors.add(new ReceiverInformationMsg.Selector("29", "Front USB", "29", true));
        deviceSelectors.add(new ReceiverInformationMsg.Selector("2A", "Rear USB", "2A", true));
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
        serviceItems.add(new NetworkServiceMsg("Music Server"));
        serviceItems.add(new NetworkServiceMsg("SPOTIFY"));
        serviceItems.add(new NetworkServiceMsg("TuneIn"));
        serviceItems.add(new NetworkServiceMsg("Deezer"));
        serviceItems.add(new NetworkServiceMsg("Airplay"));
        serviceItems.add(new NetworkServiceMsg("Tidal"));
        serviceItems.add(new NetworkServiceMsg("Chromecast built-in"));
        serviceItems.add(new NetworkServiceMsg("FlareConnect"));
        serviceItems.add(new NetworkServiceMsg("Play Queue"));
    }
}
