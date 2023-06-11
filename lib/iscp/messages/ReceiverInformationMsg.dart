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
// @dart=2.9
import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:sprintf/sprintf.dart';
import 'package:xml/xml.dart' as xml;

import "../../constants/Drawables.dart";
import "../../utils/Logging.dart";
import "../../utils/UrlLoader.dart";
import "../ConnectionIf.dart";
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";
import "EnumParameterMsg.dart";
import "InputSelectorMsg.dart";

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

    // Step = 0: scaled by 2
    // Step = 1: use not scaled (as is)
    int get getVolumeStep
    => _volumeStep;

    int get getVolMax
    => _volMax;

    void setVolMax(int value)
    {
        _volMax = value;
    }

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

    Selector.rename(final Selector old, final String name)
    {
        _id = old._id;
        _name = name;
        _zone = old._zone;
        _iconId = old._iconId;
        _addToQueue = old._addToQueue;
    }

    Selector.updZone(final Selector old, final int zone)
    {
        _id = old._id;
        _name = old._name;
        _zone = zone;
        _iconId = old._iconId;
        _addToQueue = old._addToQueue;
    }

    String get getId
    => _id;

    String get getName
    => _name;

    int get getZone
    => _zone;

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

    Preset.fromXml(xml.XmlElement e, ProtoType protoType)
    {
        if (protoType == ProtoType.ISCP)
        {
            _id = ISCPMessage.nonNullInteger(e.getAttribute("id"), 16, 0);
            _band = ISCPMessage.nonNullInteger(e.getAttribute("band"), 10, 0);
            _freq = ISCPMessage.nonNullString(e.getAttribute("freq"));
            _name = ISCPMessage.nonNullString(e.getAttribute("name"));
        }
        else
        {
            // <value index="1" skip="OFF" table="01" band="FM" param=" 008830"/>
            final String par = ISCPMessage.nonNullString(e.getAttribute("param")).trim();
            final bool freqValid = int.tryParse(par) != null;
            _id = int.tryParse(e.getAttribute("index"));
            _band = "FM" == ISCPMessage.nonNullString(e.getAttribute("band")) ? 1 : 2;
            _freq = _band == 1 && freqValid ? sprintf("%.2f", [int.tryParse(par) / 100.0]) : "0";
            _name = _band == 1 ? "" : par;
        }
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
    => _id.toString() + ": band=" + _band.toString() + ", freq=" + _freq + ", name=" + _name;

    String displayedString({bool withId = true})
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
        return withId ? getId.toString() + " - " + res : res;
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

    bool equals(Preset other)
    {
        return other != null &&
            _band == other._band &&
            _freq == other._freq &&
            _name == other._name;
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

    bool equals(ToneControl other)
    {
        return other != null &&
            _id == other._id &&
            _min == other._min &&
            _max == other._max &&
            _step == other._step;
    }
}

typedef OnReceiverInfo = void Function(ReceiverInformationMsg msg);

class ReceiverInformationMsg extends ISCPMessage with ProtoTypeMix
{
    static const String CODE = "NRI";

    static const int DEFAULT_ACTIVE_ZONE = 0;
    static const int ALL_ZONES = 0xFF;
    static const int EXT_ZONES = 14; // 1110 - all zones except main

    String _deviceId;
    final Map<String, String> _deviceProperties = HashMap<String, String>();
    final List<NetworkService> _networkServices = [];
    final List<Zone> _zones = [];
    final List<Selector> _deviceSelectors = [];
    final List<Preset> _presetList = [];
    final List<String> _controlList = [];
    final Map<String, ToneControl> _toneControls = HashMap<String, ToneControl>();
    String _dcpPresetData;

    ReceiverInformationMsg(EISCPMessage raw) : super(CODE, raw)
    {
        setProtoType(ProtoType.ISCP);
        _parseIscpXml();
    }

    String get deviceId
    => _deviceId;

    Map<String, String> get deviceProperties
    => _deviceProperties;

    List<NetworkService> get networkServices
    => _networkServices;

    static List<Zone> get defaultZones
    => [Zone("1", "Main", 1, 0x82), Zone("2", "Zone2", 1, 0x82), Zone("3", "Zone3", 1, 0x82), Zone("4", "Zone4", 1, 0x82)];

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

    void _parseIscpXml()
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
            if (id != null && name != null && value > 0)
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
                _presetList.add(Preset.fromXml(element, ProtoType.ISCP));
            }
        });
        _presetList.forEach((z)
        {
            Logging.info(this, "  preset: " + z.toString());
        });

        // Control list and Tone controls
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
    }

    /*
     * Denon control protocol - XML-based receiver configuration and presets
     */
    static final Map<String, InputSelector> _dcpFuncNameMap = <String, InputSelector>{
        "PHONO" : InputSelector.DCP_PHONO,
        "CD" : InputSelector.DCP_CD,
        "DVD" : InputSelector.DCP_DVD,
        "BLU-RAY" : InputSelector.DCP_BD,
        "TV AUDIO" : InputSelector.DCP_TV,
        "CBL/SAT" : InputSelector.DCP_SAT_CBL,
        "MEDIA PLAYER" : InputSelector.DCP_MPLAY,
        "GAME" : InputSelector.DCP_GAME,
        "TUNER" : InputSelector.DCP_TUNER,
        "AUX1" : InputSelector.DCP_AUX1,
        "AUX2" : InputSelector.DCP_AUX2,
        "AUX3" : InputSelector.DCP_AUX3,
        "AUX4" : InputSelector.DCP_AUX4,
        "AUX5" : InputSelector.DCP_AUX5,
        "AUX6" : InputSelector.DCP_AUX6,
        "AUX7" : InputSelector.DCP_AUX7,
        "NETWORK" : InputSelector.DCP_NET,
        "BLUETOOTH" : InputSelector.DCP_BT,
        "SOURCE" : InputSelector.DCP_SOURCE
    };

    static final List<String> defaultDcpControls = ["LMD Movie/TV", "LMD Music", "LMD Game", "Setup", "Quick"];

    ReceiverInformationMsg.dcp(final String receiverData, final String presetData, final String host, final String port) :
            _dcpPresetData = presetData,
            super.output(CODE, receiverData)
    {
        setProtoType(ProtoType.DCP);
        Logging.info(this, "DCP Receiver information from " + host + ":" + port +
            (_dcpPresetData != null ? ", presets available" : ", presets not available"));
        _parseDcpXml();
    }

    static void requestDcpReceiverInformation(final String host, OnReceiverInfo onReceiverInfo)
    {
        final String port1 = DCP_HTTP_PORT.toString();
        final String port2 = "80";
        _requestDcpXml(host, port1, "Deviceinfo.xml").then((ri1)
        {
            if (ri1 != null)
            {
                _requestDcpXml(host, port1, "formiPhoneAppTunerPreset.xml").then((ps1)
                {
                    onReceiverInfo(ReceiverInformationMsg.dcp(ri1, ps1, host, port1));
                });
            }
            else
            {
                _requestDcpXml(host, port2, "Deviceinfo.xml").then((ri2)
                {
                    if (ri2 != null)
                    {
                        _requestDcpXml(host, port2, "formiPhoneAppTunerPreset.xml").then((ps2)
                        {
                            onReceiverInfo(ReceiverInformationMsg.dcp(ri2, ps2, host, port2));
                        });
                    }
                    else
                    {
                        onReceiverInfo(null);
                    }
                });
            }
        });
    }

    static Future<String> _requestDcpXml(final String host, final String port, final String path)
    {
        final String url = ISCPMessage.getDcpGoformUrl(host, port, path);
        return UrlLoader().loadFromUrl(url).then((Uint8List receiverData)
        {
            if (receiverData != null)
            {
                return utf8.decode(receiverData);
            }
            return null;
        });
    }

    void _parseDcpXml()
    {
        final xml.XmlDocument document = xml.XmlDocument.parse(getData);

        // device properties
        _deviceId = ISCPMessage.getProperty(document, "ModelName");
        _deviceProperties["brand"] = ISCPMessage.getProperty(document, "BrandCode") == "0" ? "Denon" : "Marantz";
        _deviceProperties["category"] = ISCPMessage.getProperty(document, "CategoryName");
        _deviceProperties["model"] = ISCPMessage.getProperty(document, "ModelName");
        _deviceProperties["macaddress"] = ISCPMessage.getProperty(document, "MacAddress");
        _deviceProperties["friendlyname"] = ISCPMessage.getProperty(document, "ManualModelName");
        Logging.info(this, "  properties: " + _deviceProperties.toString());

        // zones and selectors
        document.findAllElements("DeviceZoneCapabilities").forEach((e1)
        => _parseDcpZoneCapabilities(e1));
        _zones.forEach((z)
        {
            Logging.info(this, "  zone: " + z.toString());
        });
        _deviceSelectors.forEach((z)
        {
            Logging.info(this, "  selector: " + z.toString());
        });

        // presets
        if (_dcpPresetData != null)
        {
            try
            {
                _parseDcpPresets(xml.XmlDocument.parse(_dcpPresetData));
            }
            on Exception catch (ex)
            {
                Logging.info(this, "  cannot parse presets: " + ex.toString());
            }
        }
        _presetList.forEach((z)
        {
            Logging.info(this, "  preset: " + z.toString());
        });

        // device capabilities
        document.findAllElements("DeviceCapabilities").forEach((e1)
        => e1.findAllElements("Setup").forEach((e2)
        => e2.childElements.forEach((e3)
        => _parseDcpDeviceCapabilities(e3))));
        // Buttons for RC tab
        _controlList.addAll(defaultDcpControls);
        Logging.info(this, "  controls: " + _controlList.toString());
    }
    
    void _parseDcpZoneCapabilities(xml.XmlElement zoneCapabilities)
    {
        final Iterable<xml.XmlElement> zones = zoneCapabilities.findAllElements("Zone");
        final Iterable<xml.XmlElement> volumes = zoneCapabilities.findAllElements("Volume");
        final Iterable<xml.XmlElement> input = zoneCapabilities.findAllElements("InputSource");
        if (zones.length != 1)
        {
            return;
        }

        if (zones.length == volumes.length)
        {
            final String no = ISCPMessage.getElementProperty(zones.first, "No", null);
            final String maxVolume = ISCPMessage.getElementProperty(volumes.first, "MaxValue", null);
            final String step = ISCPMessage.getElementProperty(volumes.first, "StepValue", null);
            if (no != null && int.tryParse(no) != null &&
                step != null && double.tryParse(step) != null &&
                maxVolume != null && double.tryParse(maxVolume) != null)
            {
                final int noInt = int.tryParse(no) + 1;
                final String name = noInt == 1 ? "Main" : "Zone" + noInt.toString();
                // Volume for zone 1 is ***:00 to 98 -> scale can be 0
                // Volume for zone 2/3 is **:00 to 98 -> scale shall be 1
                final int stepInt = noInt == 1 ? double.tryParse(step).floor() : 1;
                final int maxVolumeInt = double.tryParse(maxVolume).floor();
                this.zones.add(Zone(noInt.toString(), name, stepInt, maxVolumeInt));
            }
        }

        if (zones.length == input.length)
        {
            final String no = ISCPMessage.getElementProperty(zones.first, "No", null);
            final String ctrl = ISCPMessage.getElementProperty(input.first, "Control", "0");
            final Iterable<xml.XmlElement> list = input.first.findAllElements("List");
            if (no != null && int.tryParse(no) != null
                && ctrl != null && ctrl == "1"
                && list.length == 1)
            {
                list.first.findAllElements("Source").forEach((source)
                {
                    _parseDcpInput(int.tryParse(no),
                        ISCPMessage.getElementProperty(source, "FuncName", null),
                        ISCPMessage.getElementProperty(source, "DefaultName", null),
                        ISCPMessage.getElementProperty(source, "IconId", ""));
                });
            }
        }
    }

    void _parseDcpInput(int zone, String name, String defName, String iconId)
    {
        if (name == null || iconId == null)
        {
            return;
        }
        final InputSelector inputSel = _dcpFuncNameMap[name.toUpperCase()];
        final EnumItem<InputSelector> inputType =
            inputSel != null ? InputSelectorMsg.ValueEnum.valueByKey(inputSel) : null;
        if (inputType != null)
        {
            Selector oldSelector;
            for (Selector s in _deviceSelectors)
            {
                if (s.getId == inputType.getCode)
                {
                    oldSelector = s;
                }
            }
            Selector newSelector;
            if (oldSelector == null)
            {
                // Add new selector
                newSelector = Selector(
                    inputType.getCode,
                    defName != null ? defName : name,
                    pow(2, zone), iconId, false);
            }
            else
            {
                // Update zone of the existing selector
                newSelector = Selector.updZone(oldSelector, oldSelector.getZone + pow(2, zone));
                _deviceSelectors.remove(oldSelector);
            }
            _deviceSelectors.add(newSelector);
        }
        else
        {
            Logging.info(this, "Input source " + name + " for zone " + zone.toString() + " is not implemented");
        }
    }

    void _parseDcpDeviceCapabilities(xml.XmlElement element)
    {
        final Iterable<xml.XmlElement> valList = element.findAllElements("Control");
        final String val = valList.isEmpty ? "0" : valList.first.text;
        if (val == "1")
        {
            _controlList.add(element.name.local);
        }
    }

    void _parseDcpPresets(xml.XmlDocument document)
    {
        document.findAllElements("value").forEach((v)
        {
            // <value index="1" skip="OFF" table="01" band="FM" param=" 008830"/>
            if ("OFF" == v.getAttribute("skip") && "OFF" != v.getAttribute("table"))
            {
                presetList.add(Preset.fromXml(v, ProtoType.DCP));
            }
        });
    }
}