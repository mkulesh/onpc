/*
 * Enhanced Controller for Onkyo and Pioneer Pro
 * Copyright (C) 2019-2021 by Mikhail Kulesh
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
// @dart=2.9
import 'dart:collection';

import "package:xml/xml.dart" as xml;

import "../../constants/Drawables.dart";
import "../../utils/Logging.dart";
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";

class NetworkService
{
    String _id;
    String _name;
    int _zone;
    bool _addToQueue;
    bool _sort;

    NetworkService.fromXml(xml.XmlElement e)
    {
        _id = e.getAttribute("id").toUpperCase();
        _name = ISCPMessage.nonNullString(e.getAttribute("name"));
        _zone = ISCPMessage.nonNullInteger(e.getAttribute("zone"), 10, 1);
        _addToQueue = ISCPMessage.nonNullInteger(e.getAttribute("addqueue"), 10, 0) == 1;
        _sort = ISCPMessage.nonNullInteger(e.getAttribute("sort"), 10, 0) == 1;
    }

    NetworkService(this._id, this._name, this._zone, this._addToQueue, this._sort);

    String get getId
    => _id;

    String get getName
    => _name;

    bool get isAddToQueue
    => _addToQueue;

    bool get isSort
    => _sort;

    @override
    String toString()
    {
        String res = _id + ": " + _name
            + ", addToQueue=" + _addToQueue.toString()
            + ", sort=" + _sort.toString()
            + ", zone=" + _zone.toString()
            + ", zones=[";
        for (int z = 0; z <= 3; z++)
        {
            res += (isActiveForZone(z) ? "1" : "0");
        }
        res += "]";
        return res;
    }

    bool isActiveForZone(int z)
    => ((1 << z) & _zone) != 0;
}


class Zone
{
    String _id;
    String _name;
    int _volumeStep;
    int _volMax;

    Zone.fromXml(xml.XmlElement e)
    {
        _id = e.getAttribute("id").toUpperCase();
        _name = ISCPMessage.nonNullString(e.getAttribute("name"));
        _volumeStep = ISCPMessage.nonNullInteger(e.getAttribute("volstep"), 10, 0);
        _volMax = ISCPMessage.nonNullInteger(e.getAttribute("volmax"), 10, 0);
    }

    Zone(this._id, this._name, this._volumeStep, this._volMax);

    String get getId
    => _id;

    String get getName
    => _name;

    int get getVolumeStep
    => _volumeStep;

    int get getVolMax
    => _volMax;

    @override
    String toString()
    => _id + ": " + _name + ", volumeStep=" + _volumeStep.toString() + ", volMax=" + _volMax.toString();
}


class Selector
{
    String _id;
    String _name;
    int _zone;
    String _iconId;
    bool _addToQueue;

    Selector.fromXml(xml.XmlElement e)
    {
        _id = e.getAttribute("id").toUpperCase();
        _name = ISCPMessage.nonNullString(e.getAttribute("name"));
        _zone = ISCPMessage.nonNullInteger(e.getAttribute("zone"), 10, 1);
        _iconId = ISCPMessage.nonNullString(e.getAttribute("iconid"));
        _addToQueue = ISCPMessage.nonNullInteger(e.getAttribute("addqueue"), 10, 0) == 1;
    }

    Selector(this._id, this._name, this._zone, this._iconId, this._addToQueue);

    String get getId
    => _id;

    String get getName
    => _name;

    bool get isAddToQueue
    => _addToQueue;

    @override
    String toString()
    {
        String res = _id + ": " + _name
            + ", addToQueue=" + _addToQueue.toString()
            + ", icon=" + _iconId
            + ", zone=" + _zone.toString()
            + ", zones=[";
        for (int z = 0; z <= 3; z++)
        {
            res += (isActiveForZone(z) ? "1" : "0");
        }
        res += "]";
        return res;
    }

    bool isActiveForZone(int z)
    => ((1 << z) & _zone) != 0;
}


class Preset
{
    int _id;
    int _band;
    String _freq;
    String _name;

    Preset(this._id, this._band, this._freq, this._name);

    Preset.fromXml(xml.XmlElement e)
    {
        _id = ISCPMessage.nonNullInteger(e.getAttribute("id"), 16, 0);
        _band = ISCPMessage.nonNullInteger(e.getAttribute("band"), 10, 0);
        _freq = ISCPMessage.nonNullString(e.getAttribute("freq"));
        _name = ISCPMessage.nonNullString(e.getAttribute("name"));
    }

    int get getId
    => _id;

    int get getBand
    => _band;

    bool get isEmpty
    => _band == 0 && !isFreqValid && _name.isEmpty;

    bool get isFreqValid
    => _freq != "0";

    bool get isFm
    => getBand == 1;

    bool get isAm
    => getBand == 2 && isFreqValid;

    bool get isDab
    => getBand == 2 && !isFreqValid;

    String get getName
    => _name;

    @override
    String toString()
    => _id.toString() + ": " + _name + ", band=" + _band.toString() + ", freq=" + _freq.toLowerCase();

    String get displayedString
    {
        String res = _name.trim();
        final String band = (isFm ? " MHz" : (isAm ? " kHz" : " "));
        if (res.isNotEmpty && isFreqValid)
        {
            res += " - " + _freq + band;
        }
        else if (res.isEmpty)
        {
            res = _freq + band;
        }
        return res;
    }

    String getImageId()
    {
        if (isAm)
        {
            return Drawables.media_item_radio_am;
        }
        else if (isFm)
        {
            return Drawables.media_item_radio_fm;
        }
        else if (isDab)
        {
            return Drawables.media_item_radio_dab;
        }
        return Drawables.media_item_unknown;
    }
}


class ToneControl
{
    String _id;
    int _min;
    int _max;
    int _step;

    ToneControl.fromXml(xml.XmlElement e)
    {
        _id = ISCPMessage.nonNullString(e.getAttribute("id"));
        _min = ISCPMessage.nonNullInteger(e.getAttribute("min"), 10, 0);
        _max = ISCPMessage.nonNullInteger(e.getAttribute("max"), 10, 0);
        _step = ISCPMessage.nonNullInteger(e.getAttribute("step"), 10, 0);
    }

    ToneControl(this._id, this._min, this._max, this._step);

    static bool isControl(xml.XmlElement e)
    {
        return e.getAttribute("min") != null && e.getAttribute("max") != null && e.getAttribute("step") != null;
    }

    String get getId
    => _id;

    int get getMin
    => _min;

    int get getMax
    => _max;

    int get getStep
    => _step;

    @override
    String toString()
    => "min=" + _min.toString() + ", max=" + _max.toString() + ", step=" + _step.toString();
}


class ReceiverInformationMsg extends ISCPMessage
{
    static const String CODE = "NRI";

    static const int DEFAULT_ACTIVE_ZONE = 0;
    static const int ALL_ZONE = 0xFF;

    String _deviceId;
    final Map<String, String> _deviceProperties = HashMap<String, String>();
    final List<NetworkService> _networkServices = [];
    final List<Zone> _zones = [];
    final List<Selector> _deviceSelectors = [];
    final List<Preset> _presetList = [];
    final List<String> _controlList = [];
    final Map<String, ToneControl> _toneControls = HashMap<String, ToneControl>();

    ReceiverInformationMsg(EISCPMessage raw) : super(CODE, raw)
    {
        _parseXml();
    }

    String get deviceId
    => _deviceId;

    Map<String, String> get deviceProperties
    => _deviceProperties;

    List<NetworkService> get networkServices
    => _networkServices;

    static List<Zone> get defaultZones
    => [Zone("1", "Main", 1, 0x82), Zone("2", "Zone2", 1, 0x82)];

    List<Zone> get zones
    => _zones;

    List<Selector> get deviceSelectors
    => _deviceSelectors;

    List<Preset> get presetList
    => _presetList;

    List<String> get controlList
    => _controlList;

    Map<String, ToneControl> get toneControls
    => _toneControls;

    void _parseXml()
    {
        final xml.XmlDocument document = xml.XmlDocument.parse(getData);

        // device properties
        document.findAllElements("device").forEach((xml.XmlElement e)
        {
            _deviceId = ISCPMessage.nonNullString(e.getAttribute("id"));
        });
        _deviceProperties["brand"] = ISCPMessage.getProperty(document, "brand");
        _deviceProperties["category"] = ISCPMessage.getProperty(document, "category");
        _deviceProperties["year"] = ISCPMessage.getProperty(document, "year");
        _deviceProperties["model"] = ISCPMessage.getProperty(document, "model");
        _deviceProperties["destination"] = ISCPMessage.getProperty(document, "destination");
        _deviceProperties["productid"] = ISCPMessage.getProperty(document, "productid");
        _deviceProperties["deviceserial"] = ISCPMessage.getProperty(document, "deviceserial");
        _deviceProperties["firmwareversion"] = ISCPMessage.getProperty(document, "firmwareversion");
        _deviceProperties["friendlyname"] = ISCPMessage.getProperty(document, "friendlyname");
        Logging.info(this, "  properties: " + _deviceProperties.toString());

        // network services
        document.findAllElements("netservice").forEach((element)
        {
            final String id = element.getAttribute("id");
            final String name = element.getAttribute("name");
            final int value = ISCPMessage.nonNullInteger(element.getAttribute("value"), 10, 0);
            if (id != null && name != null && value == 1)
            {
                _networkServices.add(NetworkService.fromXml(element));
            }
        });
        _networkServices.forEach((z)
        {
            Logging.info(this, "  service: " + z.toString());
        });

        // zones
        document.findAllElements("zone").forEach((element)
        {
            final String id = element.getAttribute("id");
            final String name = element.getAttribute("name");
            final int value = ISCPMessage.nonNullInteger(element.getAttribute("value"), 10, 0);
            if (id != null && name != null && value == 1)
            {
                _zones.add(Zone.fromXml(element));
            }
        });
        _zones.forEach((z)
        {
            Logging.info(this, "  zone: " + z.toString());
        });

        // device selectors
        document.findAllElements("selector").forEach((element)
        {
            final String id = element.getAttribute("id");
            final String name = element.getAttribute("name");
            final int value = ISCPMessage.nonNullInteger(element.getAttribute("value"), 10, 0);
            if (id != null && name != null && value == 1)
            {
                _deviceSelectors.add(Selector.fromXml(element));
            }
        });
        _deviceSelectors.forEach((z)
        {
            Logging.info(this, "  selector: " + z.toString());
        });

        // presets
        document.findAllElements("preset").forEach((element)
        {
            final String id = element.getAttribute("id");
            final String band = element.getAttribute("band");
            if (id != null && band != null)
            {
                _presetList.add(Preset.fromXml(element));
            }
        });
        _presetList.forEach((z)
        {
            Logging.info(this, "  preset: " + z.toString());
        });

        // Control list
        document.findAllElements("control").forEach((element)
        {
            final String id = element.getAttribute("id");
            final int value = ISCPMessage.nonNullInteger(element.getAttribute("value"), 10, 0);
            if (id != null && value == 1)
            {
                _controlList.add(id);
                if (ToneControl.isControl(element))
                {
                    final ToneControl n = ToneControl.fromXml(element);
                    _toneControls[n.getId] = n;
                }
            }
        });
        Logging.info(this, "  controls: " + _controlList.toString());
        Logging.info(this, "  tone controls: " + _toneControls.toString());

        // Tone controls
    }
}