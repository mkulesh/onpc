/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2022 by Mikhail Kulesh
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
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;

/*
 * Gets the Receiver Information Status
 */
public class ReceiverInformationMsg extends ISCPMessage
{
    public final static String CODE = "NRI";
    public final static int DEFAULT_ACTIVE_ZONE = 0;
    public final static int ALL_ZONES = 0xFF;
    public final static int EXT_ZONES = 14; // 1110 - all zones except main

    public static class NetworkService
    {
        final String id;
        final String name;
        final int zone;
        final boolean addToQueue;
        final boolean sort;

        NetworkService(Element e)
        {
            id = e.getAttribute("id").toUpperCase();
            name = e.getAttribute("name");
            zone = e.hasAttribute("zone") ? Integer.parseInt(e.getAttribute("zone")) : 1;
            addToQueue = e.hasAttribute("addqueue") && (Integer.parseInt(e.getAttribute("addqueue")) == 1);
            sort = e.hasAttribute("sort") && (Integer.parseInt(e.getAttribute("sort")) == 1);
        }

        public NetworkService(final String id, final String name, final int zone,
                              final boolean addToQueue, final boolean sort)
        {
            this.id = id;
            this.name = name;
            this.zone = zone;
            this.addToQueue = addToQueue;
            this.sort = sort;
        }

        String getId()
        {
            return id;
        }

        @SuppressWarnings("unused")
        public String getName()
        {
            return name;
        }

        public boolean isAddToQueue()
        {
            return addToQueue;
        }

        public boolean isSort()
        {
            return sort;
        }

        @NonNull
        @Override
        public String toString()
        {
            StringBuilder res = new StringBuilder();
            res.append(id)
                    .append(": ").append(name)
                    .append(", addToQueue=").append(addToQueue)
                    .append(", sort=").append(sort)
                    .append(", zone=").append(zone)
                    .append(", zones=[");
            for (int z = 0; z <= 3; z++)
            {
                res.append(Integer.valueOf((isActiveForZone(z) ? 1 : 0)).toString());
            }
            res.append("]");
            return res.toString();
        }

        boolean isActiveForZone(int z)
        {
            return ((1 << z) & zone) != 0;
        }
    }

    public static class Zone
    {
        final String id;
        final String name;
        final int volumeStep;
        final int volMax;

        Zone(Element e)
        {
            id = e.getAttribute("id").toUpperCase();
            name = e.getAttribute("name");
            volumeStep = e.hasAttribute("volstep") ? Integer.parseInt(e.getAttribute("volstep")) : 0;
            volMax = e.hasAttribute("volmax") ? Integer.parseInt(e.getAttribute("volmax")) : 0;
        }

        @SuppressWarnings("SameParameterValue")
        Zone(final String id, final String name, final int volumeStep, final int volMax)
        {
            this.id = id;
            this.name = name;
            this.volumeStep = volumeStep;
            this.volMax = volMax;
        }

        public String getName()
        {
            return name;
        }

        public int getVolumeStep()
        {
            return volumeStep;
        }

        public int getVolMax()
        {
            return volMax;
        }

        @NonNull
        @Override
        public String toString()
        {
            return id + ": " + name +
                    ", volumeStep=" + volumeStep
                    + ", volMax=" + volMax;
        }
    }

    public static class Selector
    {
        final String id;
        final String name;
        final int zone;
        final String iconId;
        final boolean addToQueue;

        Selector(Element e)
        {
            id = e.getAttribute("id").toUpperCase();
            name = e.getAttribute("name");
            zone = e.hasAttribute("zone") ? Integer.parseInt(e.getAttribute("zone")) : 1;
            iconId = e.getAttribute("iconid");
            addToQueue = e.hasAttribute("addqueue") && (Integer.parseInt(e.getAttribute("addqueue")) == 1);
        }

        public Selector(final String id, final String name, final int zone,
                        final String iconId, final boolean addToQueue)
        {
            this.id = id;
            this.name = name;
            this.zone = zone;
            this.iconId = iconId;
            this.addToQueue = addToQueue;
        }

        public String getId()
        {
            return id;
        }

        public String getName()
        {
            return name;
        }

        public boolean isAddToQueue()
        {
            return addToQueue;
        }

        @NonNull
        @Override
        public String toString()
        {
            StringBuilder res = new StringBuilder();
            res.append(id)
                    .append(": ").append(name)
                    .append(", icon=").append(iconId)
                    .append(", addToQueue=").append(addToQueue)
                    .append(", zone=").append(zone)
                    .append(", zones=[");
            for (int z = 0; z <= 3; z++)
            {
                res.append(Integer.valueOf((isActiveForZone(z) ? 1 : 0)).toString());
            }
            res.append("]");
            return res.toString();
        }

        public boolean isActiveForZone(int z)
        {
            return ((1 << z) & zone) != 0;
        }
    }

    public static class Preset
    {
        final int id;
        final int band;
        final String freq;
        final String name;

        Preset(Element e)
        {
            id = Integer.parseInt(e.getAttribute("id"), 16);
            band = Integer.parseInt(e.getAttribute("band"));
            freq = e.getAttribute("freq");
            name = e.getAttribute("name").trim();
        }

        @SuppressWarnings("unused")
        public Preset(final int id, final int band, final String freq, final String name)
        {
            this.id = id;
            this.band = band;
            this.freq = freq;
            this.name = name;
        }

        public int getId()
        {
            return id;
        }

        int getBand()
        {
            return band;
        }

        public String getName()
        {
            return name;
        }

        public boolean isEmpty()
        {
            return band == 0 && !isFreqValid() && name.isEmpty();
        }

        boolean isFreqValid()
        {
            return freq != null && !freq.equals("0");
        }

        public boolean isFm()
        {
            return getBand() == 1;
        }

        public boolean isAm()
        {
            return getBand() == 2 && isFreqValid();
        }

        public boolean isDab()
        {
            return getBand() == 2 && !isFreqValid();
        }

        @NonNull
        @Override
        public String toString()
        {
            return id + ": " + name + ", band=" + band + ", freq=" + freq;
        }

        @NonNull
        public String displayedString(boolean withId)
        {
            String res = name.trim();
            final String band = (isFm() ? " MHz" : (isAm() ? " kHz" : " "));
            if (!res.isEmpty() && isFreqValid())
            {
                res += " - " + freq + band;
            }
            else if (res.isEmpty())
            {
                res = freq + band;
            }
            return withId ? getId() + " - " + res : res;
        }

        @DrawableRes
        public int getImageId()
        {
            if (isAm())
            {
                return R.drawable.media_item_radio_am;
            }
            else if (isFm())
            {
                return R.drawable.media_item_radio_fm;
            }
            else if (isDab())
            {
                return R.drawable.media_item_radio_dab;
            }
            return R.drawable.media_item_unknown;
        }
    }

    public static class ToneControl
    {
        final String id;
        final int min, max, step;

        ToneControl(Element e)
        {
            id = e.getAttribute("id");
            min = Integer.parseInt(e.getAttribute("min"));
            max = Integer.parseInt(e.getAttribute("max"));
            step = Integer.parseInt(e.getAttribute("step"));
        }

        public ToneControl(final String id, final int min, final int max, final int step)
        {
            this.id = id;
            this.min = min;
            this.max = max;
            this.step = step;
        }

        static boolean isControl(Element e)
        {
            return e.hasAttribute("min") && e.hasAttribute("max") && e.hasAttribute("step");
        }

        public String getId()
        {
            return id;
        }

        public int getMin()
        {
            return min;
        }

        public int getMax()
        {
            return max;
        }

        public int getStep()
        {
            return step;
        }

        @NonNull
        @Override
        public String toString()
        {
            return getId() + ": min=" + getMin() + ", max=" + getMax() + ", step=" + getStep();
        }
    }

    private String deviceId;
    private final HashMap<String, String> deviceProperties = new HashMap<>();
    private final HashMap<String, NetworkService> networkServices = new HashMap<>();
    private final List<Zone> zones = new ArrayList<>();
    private final List<Selector> deviceSelectors = new ArrayList<>();
    private final List<Preset> presetList = new ArrayList<>();
    private final Set<String> controlList = new HashSet<>();
    private final HashMap<String, ToneControl> toneControls = new HashMap<>();

    public ReceiverInformationMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        deviceId = "";
    }

    @NonNull
    public Map<String, String> getDeviceProperties()
    {
        return deviceProperties;
    }

    @NonNull
    public HashMap<String, NetworkService> getNetworkServices()
    {
        return networkServices;
    }

    public static List<Zone> getDefaultZones()
    {
        List<ReceiverInformationMsg.Zone> defaultZones = new ArrayList<>();
        defaultZones.add(new Zone("1", "Main", 1, 0x82));
        defaultZones.add(new Zone("2", "Zone2", 1, 0x82));
        defaultZones.add(new Zone("3", "Zone3", 1, 0x82));
        defaultZones.add(new Zone("4", "Zone4", 1, 0x82));
        return defaultZones;
    }

    @NonNull
    public List<Zone> getZones()
    {
        return zones;
    }

    @NonNull
    public List<Selector> getDeviceSelectors()
    {
        return deviceSelectors;
    }

    @NonNull
    public List<Preset> getPresetList()
    {
        return presetList;
    }

    @NonNull
    public HashMap<String, ToneControl> getToneControls()
    {
        return toneControls;
    }

    @NonNull
    public Set<String> getControlList()
    {
        return controlList;
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "["
                + (isMultiline() ? ("XML<" + data.length() + "B>") : ("XML=" + data))
                + "]";
    }

    public void parseXml(boolean showInfo) throws Exception
    {
        deviceProperties.clear();
        networkServices.clear();
        zones.clear();
        deviceSelectors.clear();
        presetList.clear();
        controlList.clear();
        toneControls.clear();
        InputStream stream = new ByteArrayInputStream(data.getBytes(Utils.UTF_8));
        final DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        final DocumentBuilder builder = factory.newDocumentBuilder();
        final Document doc = builder.parse(stream);
        for (Node object = doc.getDocumentElement(); object != null; object = object.getNextSibling())
        {
            if (object instanceof Element)
            {
                final Element response = (Element) object;
                if (!response.getTagName().equals("response") || !Utils.ensureAttribute(response, "status", "ok"))
                {
                    continue;
                }

                final List<Element> device = Utils.getElements(response, "device");
                if (device.isEmpty())
                {
                    continue;
                }

                // Only process the first "items" element
                Element deviceInfo = device.get(0);
                if (deviceInfo == null)
                {
                    continue;
                }

                deviceId = deviceInfo.getAttribute("id");

                for (Node prop = deviceInfo.getFirstChild(); prop != null; prop = prop.getNextSibling())
                {
                    if (prop instanceof Element)
                    {
                        final Element en = (Element) prop;
                        if (en.getChildNodes().getLength() == 1)
                        {
                            deviceProperties.put(en.getTagName(), en.getChildNodes().item(0).getNodeValue());
                        }
                        else if ("netservicelist".equals(en.getTagName()))
                        {
                            final List<Element> elService = Utils.getElements(en, "netservice");
                            for (Element element : elService)
                            {
                                final String id = element.getAttribute("id");
                                final String value = element.getAttribute("value");
                                final String name = element.getAttribute("name");
                                if (id != null && value != null && Integer.parseInt(value) == 1 && name != null)
                                {
                                    final NetworkService n = new NetworkService(element);
                                    networkServices.put(n.getId(), n);
                                }
                            }
                        }
                        else if ("zonelist".equals(en.getTagName()))
                        {
                            final List<Element> elZone = Utils.getElements(en, "zone");
                            for (Element element : elZone)
                            {
                                final String id = element.getAttribute("id");
                                final String value = element.getAttribute("value");
                                if (id != null && value != null && Integer.parseInt(value) == 1)
                                {
                                    zones.add(new Zone(element));
                                }
                            }
                        }
                        else if ("selectorlist".equals(en.getTagName()))
                        {
                            final List<Element> elSelectors = Utils.getElements(en, "selector");
                            for (Element element : elSelectors)
                            {
                                deviceSelectors.add(new Selector(element));
                            }
                        }
                        else if ("presetlist".equals(en.getTagName()))
                        {
                            final List<Element> elPresets = Utils.getElements(en, "preset");
                            for (Element element : elPresets)
                            {
                                final String id = element.getAttribute("id");
                                final String band = element.getAttribute("band");
                                final String name = element.getAttribute("name");
                                if (id != null && band != null && name != null)
                                {
                                    presetList.add(new Preset(element));
                                }
                            }
                        }
                        else if ("controllist".equals(en.getTagName()))
                        {
                            final List<Element> elControls = Utils.getElements(en, "control");
                            for (Element element : elControls)
                            {
                                final String id = element.getAttribute("id");
                                final String value = element.getAttribute("value");
                                if (id != null && value != null && Integer.parseInt(value) == 1)
                                {
                                    controlList.add(id);
                                    if (ToneControl.isControl(element))
                                    {
                                        final ToneControl n = new ToneControl(element);
                                        toneControls.put(n.getId(), n);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        if (showInfo)
        {
            Logging.info(this, "    deviceId=" + deviceId);
            for (Map.Entry<String, String> p : deviceProperties.entrySet())
            {
                Logging.info(this, "    Property: " + p.getKey() + "=" + p.getValue());
            }
            for (NetworkService s : networkServices.values())
            {
                Logging.info(this, "    Service " + s.toString());
            }
            for (Zone s : zones)
            {
                Logging.info(this, "    Zone " + s.toString());
            }
            for (Selector s : deviceSelectors)
            {
                Logging.info(this, "    Selector " + s.toString());
            }
            for (Preset p : presetList)
            {
                Logging.info(this, "    Preset " + p.toString());
            }
            for (String s : controlList)
            {
                Logging.info(this, "    Control: " + s);
            }
            for (ToneControl s : toneControls.values())
            {
                Logging.info(this, "    Tone control " + s.toString());
            }
        }
        else
        {
            Logging.info(this, "receiver information parsed");
        }

        stream.close();
    }
}
