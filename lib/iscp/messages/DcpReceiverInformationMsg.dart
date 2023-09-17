/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2023 by Mikhail Kulesh
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

import 'package:sprintf/sprintf.dart';

import "../../Platform.dart";
import "../../utils/Convert.dart";
import "../../utils/Logging.dart";
import "../DcpHeosMessage.dart";
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";
import "EnumParameterMsg.dart";
import "InputSelectorMsg.dart";
import "MasterVolumeMsg.dart";
import "ReceiverInformationMsg.dart";
import "ServiceType.dart";
import "ToneCommandMsg.dart";

enum DcpUpdateType
{
    NONE,
    SELECTOR,
    MAX_VOLUME,
    TONE_CONTROL,
    PRESET,
    NETWORK_SERVICES,
    FIRMWARE_VER,
    NET_TOP
}

enum DcpQueryType
{
    NONE,
    FULL,
    SHORT
}

/*
 * Denon control protocol - DCP receiver configuration
 */
class DcpReceiverInformationMsg extends ISCPMessage
{
    static const String CODE = "D01";

    // Input selectors
    static const String DCP_COMMAND_INPUT_SEL = "SSFUN";
    static const String DCP_COMMAND_END = "END";

    // Max. Volume
    static const String DCP_COMMAND_MAXVOL = "MVMAX";
    static const String DCP_COMMAND_ALIMIT = "SSVCTZMALIM";
    // Tone control
    static const List<String> DCP_COMMANDS_BASS = [ "PSBAS", "Z2PSBAS", "Z3PSBAS" ];
    static const List<String> DCP_COMMANDS_TREBLE = [ "PSTRE", "Z2PSTRE", "Z3PSTRE" ];
    static const List<int> DCP_TON_MAX = [ 6, 10, 10 ];
    static const List<int> DCP_TON_SHIFT = [ 50, 50, 50 ];

    // Radio presets
    static const String DCP_COMMAND_PRESET = "OPTPN";

    // Firmware
    static const String DCP_COMMAND_FIRMWARE_VER = "SSINFFRM";

    // Get Music Sources Command: heos://browse/get_music_sources
    static const String HEOS_COMMAND_NET = "browse/get_music_sources";

    static List<String> getAcceptedDcpCodes()
    {
        final List<String> out = [
            DCP_COMMAND_INPUT_SEL, DCP_COMMAND_MAXVOL, DCP_COMMAND_ALIMIT,
            DCP_COMMAND_PRESET, DCP_COMMAND_FIRMWARE_VER
        ];
        out.addAll(DCP_COMMANDS_BASS);
        out.addAll(DCP_COMMANDS_TREBLE);
        return out;
    }

    DcpUpdateType _updateType;

    DcpUpdateType get updateType
    => _updateType;

    Selector _selector;

    Selector get getSelector
    => _selector;

    Zone _maxVolumeZone;

    Zone get getMaxVolumeZone
    => _maxVolumeZone;

    ToneControl _toneControl;

    ToneControl get getToneControl
    => _toneControl;

    Preset _preset;

    Preset get getPreset
    => _preset;

    List<NetworkService> _networkServices = [];

    List<NetworkService> get getNetworkServices
    => _networkServices;

    String _firmwareVer;

    String get getFirmwareVer
    => _firmwareVer;

    // Query interface
    static const ExtEnum<DcpQueryType> QueryTypeEnum = ExtEnum<DcpQueryType>([
        EnumItem.code(DcpQueryType.NONE, "NONE", defValue: true),
        EnumItem.code(DcpQueryType.FULL, "FULL"),
        EnumItem.code(DcpQueryType.SHORT, "SHORT")
    ]);
    EnumItem<DcpQueryType> _queryType = QueryTypeEnum.defValue;

    DcpReceiverInformationMsg(EISCPMessage raw) : super(CODE, raw)
    {
        _updateType = DcpUpdateType.NONE;
        _queryType = QueryTypeEnum.valueByCode(raw.getParameters);
    }

    DcpReceiverInformationMsg.output(DcpQueryType q) :
            super.output(CODE, QueryTypeEnum.valueByKey(q).code)
    {
        _updateType = DcpUpdateType.NONE;
        _queryType = QueryTypeEnum.valueByKey(q);
    }

    // Data message interface
    DcpReceiverInformationMsg.selector(final Selector selector) : super.output(CODE, "")
    {
        _updateType = DcpUpdateType.SELECTOR;
        _selector = selector;
    }

    DcpReceiverInformationMsg.zone(final Zone zone) : super.output(CODE, "")
    {
        _updateType = DcpUpdateType.MAX_VOLUME;
        _maxVolumeZone = zone;
    }

    DcpReceiverInformationMsg.toneControl(final ToneControl toneControl) : super.output(CODE, "")
    {
        _updateType = DcpUpdateType.TONE_CONTROL;
        _toneControl = toneControl;
    }

    DcpReceiverInformationMsg.preset(final Preset preset) : super.output(CODE, "")
    {
        _updateType = DcpUpdateType.PRESET;
        _preset = preset;
    }

    DcpReceiverInformationMsg.networkServices(final List<NetworkService> networkServices) : super.output(CODE, "")
    {
        _updateType = DcpUpdateType.NETWORK_SERVICES;
        _networkServices = networkServices;
    }

    DcpReceiverInformationMsg.firmwareVer(final DcpUpdateType type, final String par) : super.output(CODE, "")
    {
        _updateType = type;
        _firmwareVer = par;
    }

    @override
    String toString()
    {
        return "DCP receiver configuration: " +
                (_updateType != DcpUpdateType.NONE ? "UpdateType=" + Convert.enumToString(_updateType) + " " : "") +
                (_queryType.key != DcpQueryType.NONE ? "Query=" + _queryType.toString() + " " : "") +
                (_selector != null ? "Selector=" + _selector.toString() + " " : "") +
                (_maxVolumeZone != null ? "MaxVol=" + _maxVolumeZone.getVolMax.toString() + " " : "") +
                (_toneControl != null ? "ToneCtrl=" + _toneControl.toString() + " " : "") +
                (_preset != null ? "Preset=" + _preset.toString() + " " : "") +
                (_networkServices.isNotEmpty ? "NetworkServices=" + _networkServices.length.toString() + " " : "") +
                (_firmwareVer != null ? "Firmware=" + _firmwareVer + " " : "");
    }

    static DcpReceiverInformationMsg processDcpMessage(String dcpMsg)
    {
        // Input Selector
        if (dcpMsg.startsWith(DCP_COMMAND_INPUT_SEL))
        {
            final String par = dcpMsg.substring(DCP_COMMAND_INPUT_SEL.length).trim();
            if (DCP_COMMAND_END == par.toUpperCase())
            {
                return null;
            }
            final int sepIdx = par.indexOf(' ');
            if (sepIdx < 0)
            {
                Logging.info(DcpReceiverInformationMsg, "DCP selector " + par + ": separator not found");
            }
            final String code = par.substring(0, sepIdx).trim();
            final String name = par.substring(sepIdx).trim();
            final EnumItem<InputSelector> item = InputSelectorMsg.ValueEnum.valueByCode(code);
            if (item.key == InputSelector.NONE)
            {
                Logging.info(DcpReceiverInformationMsg, "DCP input selector not known: " + par);
                return null;
            }
            return DcpReceiverInformationMsg.selector(
                    Selector(item.getCode,
                        name, ReceiverInformationMsg.ALL_ZONES, "", false));
        }

        // Max Volume
        if (dcpMsg.startsWith(DCP_COMMAND_MAXVOL))
        {
            return processMaxVolume(dcpMsg.substring(DCP_COMMAND_MAXVOL.length).trim(), true);
        }
        if (dcpMsg.startsWith(DCP_COMMAND_ALIMIT))
        {
            return processMaxVolume(dcpMsg.substring(DCP_COMMAND_ALIMIT.length).trim(), false);
        }

        // Bass
        for (int i = 0; i < DCP_COMMANDS_BASS.length; i++)
        {
            if (dcpMsg.startsWith(DCP_COMMANDS_BASS[i]))
            {
                return DcpReceiverInformationMsg.toneControl(
                    ToneControl(ToneCommandMsg.BASS_KEY,
                        -DCP_TON_MAX[i], DCP_TON_MAX[i], 1));
            }
        }

        // Treble
        for (int i = 0; i < DCP_COMMANDS_TREBLE.length; i++)
        {
            if (dcpMsg.startsWith(DCP_COMMANDS_TREBLE[i]))
            {
                return DcpReceiverInformationMsg.toneControl(
                    ToneControl(ToneCommandMsg.TREBLE_KEY,
                        -DCP_TON_MAX[i], DCP_TON_MAX[i], 1));
            }
        }

        // Radio Preset
        if (dcpMsg.startsWith(DCP_COMMAND_PRESET))
        {
            final String par = dcpMsg.substring(DCP_COMMAND_PRESET.length).trim();
            if (par.length > 2)
            {
                final int num = ISCPMessage.nonNullInteger(par.substring(0, 2), 10, -1);
                final String name = par.substring(2).trim();
                if (int.tryParse(name) != null)
                {
                    final double f = ISCPMessage.nonNullInteger(name, 10, 0) / 100.0;
                    return DcpReceiverInformationMsg.preset(
                            Preset(num, /*band FM*/ 1, sprintf("%.2f", [f]), ""));
                }
                else
                {
                    return DcpReceiverInformationMsg.preset(
                            Preset(num, /*band DAB*/ 2, "0", name));
                }
            }
            Logging.info(DcpReceiverInformationMsg, "DCP preset invalid: " + par);
        }

        // Firmware version
        if (dcpMsg.startsWith(DCP_COMMAND_FIRMWARE_VER))
        {
            final String par = dcpMsg.substring(DCP_COMMAND_FIRMWARE_VER.length).trim();
            if (DCP_COMMAND_END != par.toUpperCase())
            {
                return DcpReceiverInformationMsg.firmwareVer(DcpUpdateType.FIRMWARE_VER, par);
            }
        }

        return null;
    }

    static DcpReceiverInformationMsg processMaxVolume(final String par, bool scale)
    {
        try
        {
            int maxVolume = ISCPMessage.nonNullInteger(par, 10, MasterVolumeMsg.NO_LEVEL);
            if (maxVolume != MasterVolumeMsg.NO_LEVEL && scale && par.length > 2)
            {
                maxVolume = (maxVolume / 10.0).floor();
            }
            // Create a zone with max volume received in the message
            return DcpReceiverInformationMsg.zone(Zone("", "", 0, maxVolume));
        }
        on Exception
        {
            Logging.info(DcpReceiverInformationMsg, "Unable to parse max. volume level " + par);
            return null;
        }
    }

    static DcpReceiverInformationMsg processHeosMessage(DcpHeosMessage jsonMsg)
    {
        if (HEOS_COMMAND_NET == jsonMsg.command)
        {
            final List<String> names = jsonMsg.getStringList("payload[*].name");
            final List<String> sids = jsonMsg.getStringList("payload[*].sid");
            if (names.length != sids.length)
            {
                Logging.info(DcpReceiverInformationMsg, "Inconsistent size of names and sids");
                return null;
            }
            final List<NetworkService> networkServices = [];
            for (int i = 0; i < names.length; i++)
            {
                final String id = "HS" + sids[i];
                final EnumItem<ServiceType> s = Services.ServiceTypeEnum.valueByCode(id);
                if (s.key == ServiceType.UNKNOWN)
                {
                    Logging.info(DcpReceiverInformationMsg, "Service " + names[i] + " is not supported");
                    continue;
                }
                networkServices.add(NetworkService(id, names[i], ReceiverInformationMsg.ALL_ZONES, false, false));
            }
            if (networkServices.isNotEmpty)
            {
                _ensureNetworkService(networkServices, ServiceType.DCP_PLAYQUEUE);
                if (Platform.isMobile)
                {
                    _ensureNetworkService(networkServices, ServiceType.DCP_SPOTIFY);
                }
                return DcpReceiverInformationMsg.networkServices(networkServices);
            }
        }
        return null;
    }

    static void _ensureNetworkService(final List<NetworkService> nsList, final ServiceType s)
    {
        final EnumItem<ServiceType> sEnum = Services.ServiceTypeEnum.valueByKey(s);
        if (sEnum.key == s)
        {
            final bool missing = nsList.firstWhere((ns) => ns.getId == sEnum.getDcpCode, orElse: () => null) == null;
            if (missing)
            {
                final NetworkService ns = NetworkService(
                    sEnum.code, sEnum.name, ReceiverInformationMsg.ALL_ZONES, false, false);
                Logging.info(s, "Enforced missing network service " + ns.toString());
                nsList.add(ns);
            }
        }
    }

@override
    String buildDcpMsg(bool isQuery)
    {
        String res = "";
        res += "heos://system/register_for_change_events?enable=on";
        res += ISCPMessage.DCP_MSG_SEP + "heos://" + HEOS_COMMAND_NET;
        res += ISCPMessage.DCP_MSG_SEP + DCP_COMMAND_INPUT_SEL + " ?";
        res += ISCPMessage.DCP_MSG_SEP + DCP_COMMAND_FIRMWARE_VER + " ?";
        if (_queryType.key == DcpQueryType.FULL)
        {
            res += ISCPMessage.DCP_MSG_SEP + DCP_COMMAND_PRESET + " ?";
        }
        return res;
    }
}
