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

import android.graphics.Bitmap;

import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.iscp.messages.AlbumNameMsg;
import com.mkulesh.onpc.iscp.messages.ArtistNameMsg;
import com.mkulesh.onpc.iscp.messages.DigitalFilterMsg;
import com.mkulesh.onpc.iscp.messages.DimmerLevelMsg;
import com.mkulesh.onpc.iscp.messages.FileFormatMsg;
import com.mkulesh.onpc.iscp.messages.FirmwareUpdateMsg;
import com.mkulesh.onpc.iscp.messages.InputSelectorMsg;
import com.mkulesh.onpc.iscp.messages.JacketArtMsg;
import com.mkulesh.onpc.iscp.messages.ListInfoMsg;
import com.mkulesh.onpc.iscp.messages.ListTitleInfoMsg;
import com.mkulesh.onpc.iscp.messages.MenuStatusMsg;
import com.mkulesh.onpc.iscp.messages.NetworkServiceMsg;
import com.mkulesh.onpc.iscp.messages.PlayStatusMsg;
import com.mkulesh.onpc.iscp.messages.PowerStatusMsg;
import com.mkulesh.onpc.iscp.messages.ReceiverInformationMsg;
import com.mkulesh.onpc.iscp.messages.TimeInfoMsg;
import com.mkulesh.onpc.iscp.messages.TitleNameMsg;
import com.mkulesh.onpc.iscp.messages.TrackInfoMsg;
import com.mkulesh.onpc.iscp.messages.XmlListInfoMsg;
import com.mkulesh.onpc.iscp.messages.XmlListItemMsg;
import com.mkulesh.onpc.utils.Logging;

import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class State
{
    //Common
    PowerStatusMsg.PowerStatus powerStatus = PowerStatusMsg.PowerStatus.STB;
    boolean newFirmware = false;
    Map<String, String> deviceProperties = new HashMap<>();
    Bitmap deviceCover = null;
    List<ReceiverInformationMsg.Selector> deviceSelectors;
    InputSelectorMsg.InputType inputType = InputSelectorMsg.InputType.NONE;
    DimmerLevelMsg.Level dimmerLevel = DimmerLevelMsg.Level.NONE;
    DigitalFilterMsg.Filter digitalFilter = DigitalFilterMsg.Filter.NONE;

    // Track info
    Bitmap cover = null;
    String album = "", artist = "", title = "";
    String currentTime = "", maxTime = "";
    String trackInfo = "";
    String fileFormat = "";
    private ByteArrayOutputStream coverBuffer = null;

    // Playback
    PlayStatusMsg.PlayStatus playStatus = PlayStatusMsg.PlayStatus.STOP;
    PlayStatusMsg.RepeatStatus repeatStatus = PlayStatusMsg.RepeatStatus.OFF;
    PlayStatusMsg.ShuffleStatus shuffleStatus = PlayStatusMsg.ShuffleStatus.OFF;
    MenuStatusMsg.TimeSeek timeSeek = MenuStatusMsg.TimeSeek.ENABLE;

    // Navigation
    ListTitleInfoMsg.ServiceType serviceType = null;
    ListTitleInfoMsg.LayerInfo layerInfo = null;
    ListTitleInfoMsg.UIType uiType = null;
    int numberOfLayers = 0;
    int numberOfItems = 0;
    String titleBar = "";
    protected final List<XmlListItemMsg> mediaItems = new ArrayList<>();
    protected final List<NetworkServiceMsg> serviceItems = new ArrayList<>();
    boolean itemsChanged = false;

    State()
    {
        deviceSelectors = new ArrayList<>();
    }

    @Override
    public String toString()
    {
        return powerStatus.toString()
                + "; " + album + "/" + artist + "/" + title
                + "; " + currentTime + "/" + maxTime
                + "; " + playStatus.toString() + "/" + repeatStatus.toString() + "/" + shuffleStatus.toString()
                + "; cover=" + ((cover != null) ? "YES" : "NO");
    }

    boolean isOn()
    {
        return powerStatus == PowerStatusMsg.PowerStatus.ON;
    }

    boolean isPlaying()
    {
        return playStatus != PlayStatusMsg.PlayStatus.STOP;
    }

    boolean update(ISCPMessage msg)
    {
        if (!(msg instanceof TimeInfoMsg) && !(msg instanceof JacketArtMsg))
        {
            Logging.info(msg, "<< " + msg.toString());
        }

        //Common
        if (msg instanceof PowerStatusMsg)
        {
            return process((PowerStatusMsg) msg);
        }
        if (msg instanceof FirmwareUpdateMsg)
        {
            return process((FirmwareUpdateMsg) msg);
        }
        if (msg instanceof ReceiverInformationMsg)
        {
            return process((ReceiverInformationMsg) msg);
        }
        if (msg instanceof InputSelectorMsg)
        {
            return process((InputSelectorMsg) msg);
        }
        if (msg instanceof DimmerLevelMsg)
        {
            return process((DimmerLevelMsg) msg);
        }
        if (msg instanceof DigitalFilterMsg)
        {
            return process((DigitalFilterMsg) msg);
        }

        // Track info
        if (msg instanceof JacketArtMsg)
        {
            return process((JacketArtMsg) msg);
        }
        if (msg instanceof AlbumNameMsg)
        {
            return process((AlbumNameMsg) msg);
        }
        if (msg instanceof ArtistNameMsg)
        {
            return process((ArtistNameMsg) msg);
        }
        if (msg instanceof TitleNameMsg)
        {
            return process((TitleNameMsg) msg);
        }
        if (msg instanceof FileFormatMsg)
        {
            return process((FileFormatMsg) msg);
        }
        if (msg instanceof TimeInfoMsg)
        {
            return process((TimeInfoMsg) msg);
        }
        if (msg instanceof TrackInfoMsg)
        {
            return process((TrackInfoMsg) msg);
        }

        // Playback
        if (msg instanceof PlayStatusMsg)
        {
            return process((PlayStatusMsg) msg);
        }
        if (msg instanceof MenuStatusMsg)
        {
            return process((MenuStatusMsg) msg);
        }

        // Navigation
        if (msg instanceof ListTitleInfoMsg)
        {
            return process((ListTitleInfoMsg) msg);
        }
        if (msg instanceof XmlListInfoMsg)
        {
            return process((XmlListInfoMsg) msg);
        }
        return msg instanceof ListInfoMsg && process((ListInfoMsg) msg);
    }

    private boolean process(PowerStatusMsg msg)
    {
        final boolean changed = msg.getPowerStatus() != powerStatus;
        powerStatus = msg.getPowerStatus();
        return changed;
    }

    private boolean process(FirmwareUpdateMsg msg)
    {
        final boolean changed = newFirmware != msg.isNewFirmware();
        newFirmware = msg.isNewFirmware();
        return changed;
    }

    private boolean process(ReceiverInformationMsg msg)
    {
        try
        {
            msg.parseXml();
            deviceProperties = msg.getDeviceProperties();
            deviceCover = msg.getDeviceCover();
            deviceSelectors = msg.getDeviceSelectors();
            return true;
        }
        catch (Exception e)
        {
            Logging.info(msg, "Can not parse XML: " + e.getLocalizedMessage());
        }
        return false;
    }

    private boolean process(InputSelectorMsg msg)
    {
        final boolean changed = inputType != msg.getInputType();
        inputType = msg.getInputType();
        return changed;
    }

    private boolean process(DimmerLevelMsg msg)
    {
        final boolean changed = dimmerLevel != msg.getLevel();
        dimmerLevel = msg.getLevel();
        return changed;
    }

    private boolean process(DigitalFilterMsg msg)
    {
        final boolean changed = digitalFilter != msg.getFilter();
        digitalFilter = msg.getFilter();
        return changed;
    }

    private boolean process(JacketArtMsg msg)
    {
        if (msg.getImageType() == JacketArtMsg.ImageType.URL)
        {
            Logging.info(msg, "<< " + msg.toString());
            cover = msg.loadFromUrl();
            return true;
        }
        else if (msg.getRawData() != null)
        {
            final byte in[] = msg.getRawData();
            if (msg.getPacketFlag() == JacketArtMsg.PacketFlag.START)
            {
                Logging.info(msg, "<< " + msg.toString());
                coverBuffer = new ByteArrayOutputStream();
            }
            if (coverBuffer != null)
            {
                coverBuffer.write(in, 0, in.length);
            }
            if (msg.getPacketFlag() == JacketArtMsg.PacketFlag.END)
            {
                Logging.info(msg, "<< " + msg.toString());
                cover = msg.loadFromBuffer(coverBuffer);
                coverBuffer = null;
                return true;
            }
        }
        else
        {
            Logging.info(msg, "<< " + msg.toString());
        }
        return false;
    }

    private boolean process(AlbumNameMsg msg)
    {
        final boolean changed = !msg.getData().equals(album);
        album = msg.getData();
        return changed;
    }

    private boolean process(ArtistNameMsg msg)
    {
        final boolean changed = !msg.getData().equals(artist);
        artist = msg.getData();
        return changed;
    }

    private boolean process(TitleNameMsg msg)
    {
        final boolean changed = !msg.getData().equals(title);
        title = msg.getData();
        return changed;
    }

    private boolean process(TimeInfoMsg msg)
    {
        final boolean changed = !msg.getCurrentTime().equals(currentTime)
                || !msg.getMaxTime().equals(maxTime);
        currentTime = msg.getCurrentTime();
        maxTime = msg.getMaxTime();
        return changed;
    }

    private boolean process(TrackInfoMsg msg)
    {
        final String newInfo = msg.getCurrentTrack() + "/" + msg.getMaxTrack();
        final boolean changed = !newInfo.equals(trackInfo);
        trackInfo = newInfo;
        return changed;
    }

    private boolean process(FileFormatMsg msg)
    {
        final boolean changed = !msg.getFullFormat().equals(title);
        fileFormat = msg.getFullFormat();
        return changed;
    }

    private boolean process(PlayStatusMsg msg)
    {
        final boolean changed = msg.getPlayStatus() != playStatus
                || msg.getRepeatStatus() != repeatStatus
                || msg.getShuffleStatus() != shuffleStatus;
        playStatus = msg.getPlayStatus();
        repeatStatus = msg.getRepeatStatus();
        shuffleStatus = msg.getShuffleStatus();
        return changed;
    }

    private boolean process(MenuStatusMsg msg)
    {
        final boolean changed = msg.getTimeSeek() != timeSeek;
        timeSeek = msg.getTimeSeek();
        return changed;
    }

    private boolean process(ListTitleInfoMsg msg)
    {
        boolean changed = false;
        if (serviceType != msg.getServiceType())
        {
            serviceType = msg.getServiceType();
            clearItems();
            changed = true;
        }
        if (layerInfo != msg.getLayerInfo())
        {
            layerInfo = msg.getLayerInfo();
            changed = true;
        }
        if (uiType != msg.getUiType())
        {
            uiType = msg.getUiType();
            changed = true;
        }
        if (!titleBar.equals(msg.getTitleBar()))
        {
            titleBar = msg.getTitleBar();
            changed = true;
        }
        if (numberOfLayers != msg.getNumberOfLayers())
        {
            numberOfLayers = msg.getNumberOfLayers();
            changed = true;
        }
        if (numberOfItems != msg.getNumberOfItems())
        {
            numberOfItems = msg.getNumberOfItems();
            changed = true;
        }
        if (uiType == ListTitleInfoMsg.UIType.MENU)
        {
            clearItems();
        }
        return changed;
    }

    private void clearItems()
    {
        mediaItems.clear();
        serviceItems.clear();
        itemsChanged = true;
    }

    private boolean process(XmlListInfoMsg msg)
    {
        try
        {
            Logging.info(msg, "processing XmlListInfoMsg");
            msg.parseXml(mediaItems, numberOfLayers);
            itemsChanged = true;
            return true;
        }
        catch (Exception e)
        {
            mediaItems.clear();
            Logging.info(msg, "Can not parse XML: " + e.getLocalizedMessage());
        }
        return false;
    }

    private boolean process(ListInfoMsg msg)
    {
        if (msg.getInformationType() == ListInfoMsg.InformationType.CURSOR)
        {
            return false;
        }
        if (serviceType == ListTitleInfoMsg.ServiceType.NET)
        {
            for (NetworkServiceMsg i : serviceItems)
            {
                if (i.getService().getCode().toUpperCase().equals(msg.getListedData().toUpperCase()))
                {
                    return false;
                }
            }
            final NetworkServiceMsg nsMsg = new NetworkServiceMsg(msg.getListedData());
            if (nsMsg.getService() != NetworkServiceMsg.Service.UNKNOWN)
            {
                serviceItems.add(nsMsg);
            }
            itemsChanged = true;
            return true;
        }
        return false;
    }

    ReceiverInformationMsg.Selector getActualSelector()
    {
        for (ReceiverInformationMsg.Selector s : deviceSelectors)
        {
            if (s.getId().equals(inputType.getCode()))
            {
                return s;
            }
        }
        return null;
    }

    boolean isTopLayer()
    {
        if (uiType != ListTitleInfoMsg.UIType.PLAYBACK)
        {
            if (serviceType == ListTitleInfoMsg.ServiceType.NET &&
                    layerInfo == ListTitleInfoMsg.LayerInfo.NET_TOP)
            {
                return true;
            }
            if (layerInfo == ListTitleInfoMsg.LayerInfo.SERVICE_TOP)
            {
                return serviceType == ListTitleInfoMsg.ServiceType.USB_FRONT
                        || serviceType == ListTitleInfoMsg.ServiceType.USB_REAR;
            }
        }
        return false;
    }

    public boolean isMediaEmpty()
    {
        return mediaItems.isEmpty() && serviceItems.isEmpty();
    }
}
