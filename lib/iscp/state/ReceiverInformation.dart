/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2024 by Mikhail Kulesh
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

import 'dart:collection';

import "package:collection/collection.dart";

import "../../constants/Strings.dart";
import "../../utils/Logging.dart";
import "../../utils/Pair.dart";
import "../ConnectionIf.dart";
import "../messages/CenterLevelCommandMsg.dart";
import "../messages/DcpReceiverInformationMsg.dart";
import "../messages/DeviceNameMsg.dart";
import "../messages/EnumParameterMsg.dart";
import "../messages/FirmwareUpdateMsg.dart";
import "../messages/FriendlyNameMsg.dart";
import "../messages/GoogleCastVersionMsg.dart";
import "../messages/InputSelectorMsg.dart";
import "../messages/ListeningModeMsg.dart";
import "../messages/PowerStatusMsg.dart";
import "../messages/ReceiverInformationMsg.dart";
import "../messages/SubwooferLevelCommandMsg.dart";
import "../messages/ToneCommandMsg.dart";

class ReceiverInformation
{
    static const String BRAND_PIONEER = "Pioneer";

    // From ReceiverInformationMsg
    late String _xml;

    String get xml
    => _xml;

    final Map<String, String> _deviceProperties = HashMap<String, String>();

    Map<String, String> get deviceProperties
    => _deviceProperties;

    final List<NetworkService> _networkServices = [];

    List<NetworkService> get networkServices
    => _networkServices;

    final List<Zone> _zones = [];

    List<Zone> get zones
    => _zones;

    final List<Selector> _deviceSelectors = [];

    List<Selector> get deviceSelectors
    => _deviceSelectors;

    final List<Preset> _presetList = [];

    List<Preset> get presetList
    => _presetList;

    final List<String> _controlList = [];
    final Map<String, ToneControl> _toneControls = HashMap<String, ToneControl>();

    Map<String, ToneControl> get toneControls
    => _toneControls;

    // Audio balance
    Pair<int, int>? _balanceRange;

    Pair<int, int>? get balanceRange
    => _balanceRange;

    // From FriendlyNameMsg, DeviceNameMsg
    String? _friendlyName;
    late String _deviceName;

    // Power status, from PowerStatusMsg
    late PowerStatus _powerStatus;

    PowerStatus get powerStatus
    => _powerStatus;

    // Firmware, from FirmwareUpdateMsg
    late EnumItem<FirmwareUpdate> _firmwareStatus;

    EnumItem<FirmwareUpdate> get firmwareStatus
    => _firmwareStatus;

    // Google cast version, from GoogleCastVersionMsg
    late String _googleCastVersion;

    String get googleCastVersion
    => _googleCastVersion;

    // Default tone control
    static final ToneControl DEFAULT_BASS_CONTROL = ToneControl(ToneCommandMsg.BASS_KEY, -10, 10, 2);
    static final ToneControl DEFAULT_TREBLE_CONTROL = ToneControl(ToneCommandMsg.TREBLE_KEY, -10, 10, 2);

    ReceiverInformation()
    {
        clear();
    }

    List<String> getQueriesIscp(int zone)
    {
        Logging.info(this, "Requesting ISCP data for zone " + zone.toString() + "...");
        return [
            ReceiverInformationMsg.CODE,
            FriendlyNameMsg.CODE,
            DeviceNameMsg.CODE,
            PowerStatusMsg.ZONE_COMMANDS[zone],
            FirmwareUpdateMsg.CODE,
            GoogleCastVersionMsg.CODE
        ];
    }

    List<String> getQueriesDcp(int zone)
    {
        Logging.info(this, "Requesting DCP data for zone " + zone.toString() + "...");
        return [
            PowerStatusMsg.ZONE_COMMANDS[zone],
            FriendlyNameMsg.CODE,
            FirmwareUpdateMsg.CODE
        ];
    }

    void clear()
    {
        _xml = "";
        _deviceProperties.clear();
        _networkServices.clear();
        _zones.clear();
        _deviceSelectors.clear();
        _presetList.clear();
        _controlList.clear();
        _balanceRange = null;
        _friendlyName = null;
        _deviceName = "";
        _powerStatus = PowerStatus.NONE;
        _firmwareStatus = FirmwareUpdateMsg.ValueEnum.defValue;
        _googleCastVersion = Strings.dashed_string;
    }

    void createDefaultReceiverInfo(ProtoType protoType)
    {
        Logging.info(this, "Created default receiver information");

        // By default, add all possible device selectors
        _deviceSelectors.clear();
        InputSelectorMsg.ValueEnum.values.where((e) => e.key != InputSelector.NONE).forEach((it)
        {
            if (protoType == InputSelectorMsg.getProtoType(it.key))
            {
                // #265 Add new input selector "SOURCE":
                // "SOURCE" input not allowed for the main zone
                final int zones = it.key == InputSelector.SOURCE ?
                ReceiverInformationMsg.EXT_ZONES : ReceiverInformationMsg.ALL_ZONES;
                final Selector s = Selector(it.getCode, it.description, zones, it.getCode, false);
                _deviceSelectors.add(s);
            }
        });

        // Add default bass and treble limits
        _toneControls.clear();
        _toneControls[ToneCommandMsg.BASS_KEY] = DEFAULT_BASS_CONTROL;
        _toneControls[ToneCommandMsg.TREBLE_KEY] = DEFAULT_TREBLE_CONTROL;
        _toneControls[SubwooferLevelCommandMsg.KEY] =
            ToneControl(SubwooferLevelCommandMsg.KEY, -15, 12, 1);
        _toneControls[CenterLevelCommandMsg.KEY] =
            ToneControl(CenterLevelCommandMsg.KEY, -12, 12, 1);
        // Default zones:
        _zones.clear();
        _zones.addAll(ReceiverInformationMsg.defaultZones);
        // Settings
        if (protoType == ProtoType.DCP)
        {
            _controlList.addAll(ReceiverInformationMsg.defaultDcpControls);
        }
    }

    bool processReceiverInformation(ReceiverInformationMsg msg, int activeZone)
    {
        _xml = msg.getData;

        _deviceProperties.clear();
        _deviceProperties.addAll(msg.deviceProperties);

        _networkServices.clear();
        _networkServices.addAll(msg.networkServices);

        _zones.clear();
        _zones.addAll(msg.zones);

        _deviceSelectors.clear();
        msg.deviceSelectors.forEach((s)
        {
            if (s.isActiveForZone(activeZone))
            {
                _deviceSelectors.add(s);
            }
        });

        _presetList.clear();
        _presetList.addAll(msg.presetList);

        _controlList.clear();
        _controlList.addAll(msg.controlList);

        _toneControls.clear();
        _toneControls.addAll(msg.toneControls);

        _balanceRange = msg.balanceRange != null ? Pair<int, int>(msg.balanceRange!.item1, msg.balanceRange!.item2) : null;

        return true;
    }

    bool processFriendlyName(FriendlyNameMsg msg)
    {
        if (_friendlyName == null)
        {
            _friendlyName = "";
        }
        final bool changed = _friendlyName != msg.getFriendlyName;
        _friendlyName = msg.getFriendlyName;
        return changed;
    }

    bool processDeviceName(DeviceNameMsg msg)
    {
        final bool changed = _deviceName != msg.getData;
        _deviceName = msg.getData;
        return changed;
    }

    bool processPowerStatus(PowerStatusMsg msg)
    {
        final bool changed = _powerStatus != msg.getValue.key;
        _powerStatus = msg.getValue.key;
        return changed;
    }

    bool processFirmwareUpdate(FirmwareUpdateMsg msg)
    {
        final bool changed = _firmwareStatus.key != msg.getStatus.key;
        _firmwareStatus = msg.getStatus;
        return changed;
    }

    bool processGoogleCastVersion(GoogleCastVersionMsg msg)
    {
        final bool changed = _googleCastVersion != msg.getData;
        _googleCastVersion = msg.getData;
        return changed;
    }

    String _getProperty(final String prop)
    {
        final String? m = _deviceProperties[prop];
        return m == null ? "" : m;
    }

    String get brand
    => _getProperty("brand");

    String get model
    => _getProperty("model");

    String get year
    => _getProperty("year");

    String get firmaware
    => _getProperty("firmwareversion");

    String getIdentifier()
    {
        String identifier = _getProperty("macaddress");
        if (identifier.isEmpty)
        {
            identifier = _getProperty("deviceserial");
        }
        return identifier;
    }

    String getDeviceName(bool useFriendlyName)
    {
        if (useFriendlyName)
        {
            // name from FriendlyNameMsg (NFN)
            if (_friendlyName != null && _friendlyName!.isNotEmpty)
            {
                return _friendlyName!;
            }
            // fallback to ReceiverInformationMsg
            final String? name = _deviceProperties["friendlyname"];
            if (name != null && name.isNotEmpty)
            {
                return name;
            }
        }
        // fallback to model from ReceiverInformationMsg
        return model;
    }

    bool get isOn
    => powerStatus == PowerStatus.ON;

    NetworkService? getNetworkService(String id)
    => _networkServices.firstWhereOrNull((s) => s.getId == id);

    Preset? getPreset(int preset)
    => _presetList.firstWhereOrNull((p) => p.getId == preset);

    int nextEmptyPreset()
    => _presetList.firstWhere((p) => p.isEmpty, orElse: () => Preset(presetList.length + 1, 0, "0", "")).getId;

    bool isControlExists(final String control)
    => _controlList.isNotEmpty && _controlList.contains(control);

    bool isListeningModeControl()
    => _controlList.firstWhereOrNull((s) => s.startsWith(ListeningModeMsg.CODE)) != null;

    bool get isReceiverInformation
    => _xml.isNotEmpty;

    bool get isFriendlyName
    => _friendlyName != null;

    /*
     * Denon control protocol
     */
    DcpUpdateType? processDcpReceiverInformation(DcpReceiverInformationMsg msg)
    {
        // Input Selector
        if (msg.updateType == DcpUpdateType.SELECTOR && msg.getSelector != null)
        {
            DcpUpdateType? _changed;
            Selector? oldSelector;
            for (Selector s in _deviceSelectors)
            {
                if (s.getId == msg.getSelector!.getId)
                {
                    oldSelector = s;
                    break;
                }
            }
            if (oldSelector == null)
            {
                Logging.info(this, "    Received friendly name for not configured selector. Ignored.");
            }
            else
            {
                final Selector newSelector = Selector.rename(oldSelector, msg.getSelector!.getName);
                Logging.info(this, "    DCP selector " + newSelector.toString());
                _deviceSelectors.remove(oldSelector);
                _deviceSelectors.add(newSelector);
                _changed = msg.updateType;
            }
            return _changed;
        }

        // Max. volume
        if (msg.updateType == DcpUpdateType.MAX_VOLUME && msg.getMaxVolumeZone != null)
        {
            DcpUpdateType? _changed;
            for (int i = 0; i < _zones.length; i++)
            {
                if (_zones[i].getVolMax != msg.getMaxVolumeZone!.getVolMax)
                {
                    _zones[i].setVolMax(msg.getMaxVolumeZone!.getVolMax);
                    Logging.info(this, "    DCP zone " + _zones[i].toString());
                    _changed = msg.updateType;
                }
            }
            return _changed;
        }

        // Tone control
        final ToneControl? toneControl = msg.getToneControl;
        if (msg.updateType == DcpUpdateType.TONE_CONTROL && toneControl != null)
        {
            final bool _changed = !toneControl.equals(_toneControls[toneControl.getId]);
            _toneControls[toneControl.getId] = toneControl;
            Logging.info(this, "    DCP tone control " + toneControl.toString());
            return _changed ? msg.updateType : null;
        }

        // Radio presets
        final Preset? preset = msg.getPreset;
        if (msg.updateType == DcpUpdateType.PRESET && preset != null)
        {
            bool _changed = false;
            int oldPresetIdx = -1;
            for (int i = 0; i < _presetList.length; i++)
            {
                if (_presetList[i].getId == preset.getId)
                {
                    oldPresetIdx = i;
                    break;
                }
            }
            if (oldPresetIdx >= 0)
            {
                _changed = !preset.equals(_presetList[oldPresetIdx]);
                _presetList[oldPresetIdx] = preset;
                Logging.info(this, "    DCP Preset updated: " + preset.toString());
            }
            else if (_presetList.isEmpty || !preset.equals(_presetList[_presetList.length - 1]))
            {
                _changed = true;
                _presetList.add(preset);
                Logging.info(this, "    DCP Preset added: " + preset.toString());
            }
            return _changed ? msg.updateType : null;
        }

        // Network services
        if (msg.updateType == DcpUpdateType.NETWORK_SERVICES)
        {
            if (_networkServices.isEmpty)
            {
                Logging.info(this, "    Updating network services: " + msg.getNetworkServices.length.toString());
                _networkServices.clear();
                _networkServices.addAll(msg.getNetworkServices);
                return msg.updateType;
            }
            else
            {
                return DcpUpdateType.NET_TOP;
            }
        }

        // Firmware version
        if (msg.updateType == DcpUpdateType.FIRMWARE_VER && msg.getFirmwareVer != null)
        {
            _deviceProperties["firmwareversion"] = msg.getFirmwareVer!;
            Logging.info(this, "    DCP firmware " + msg.getFirmwareVer!);
            return msg.updateType;
        }

        return null;
    }
}

