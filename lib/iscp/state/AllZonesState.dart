/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2025 by Mikhail Kulesh
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

import '../../utils/Convert.dart';
import '../../utils/Logging.dart';
import '../ConnectionIf.dart';
import '../ISCPMessage.dart';
import '../messages/MasterVolumeMsg.dart';
import '../messages/PowerStatusMsg.dart';
import 'ReceiverInformation.dart';

class ZoneState
{
    final int _zone;

    int get zone => _zone;

    ZoneState(this._zone);

    // Power status, from PowerStatusMsg
    PowerStatus _powerStatus = PowerStatus.NONE;

    PowerStatus get powerStatus
    => _powerStatus;

    // Master volume, from MasterVolumeMsg
    int _volumeLevel = MasterVolumeMsg.NO_LEVEL;

    int get volumeLevel
    => _volumeLevel;

    @override
    String toString()
    => _zone.toString()
        + ": PWR=" + Convert.enumToString(powerStatus)
        + ", VOL=" + volumeLevel.toString();

    String? processZonedMessage(ZonedMessage msg)
    {
        if (msg is PowerStatusMsg)
        {
            return _isChange(PowerStatusMsg.CODE, processPowerStatus(msg));
        }
        else if (msg is MasterVolumeMsg)
        {
            return _isChange(MasterVolumeMsg.CODE, processMasterVolume(msg));
        }
        return null;
    }

    String? _isChange(String type, bool change)
    => change ? type : null;

    bool processPowerStatus(PowerStatusMsg msg)
    {
        final bool changed = _powerStatus != msg.getValue.key;
        _powerStatus = msg.getValue.key;
        return changed;
    }

    bool processMasterVolume(MasterVolumeMsg msg)
    {
        final bool changed = _volumeLevel != msg.getVolumeLevel;
        if (msg.getVolumeLevel != MasterVolumeMsg.NO_LEVEL)
        {
            // Do not overwrite a valid value with an invalid value
            _volumeLevel = msg.getVolumeLevel;
        }
        return changed;
    }
}

class AllZonesState
{
    final List<ZoneState> _zoneState = [];

    List<ZoneState> get zoneState 
    => _zoneState;

  void clear()
    {
        _zoneState.clear();
    }

    List<String> getQueries(ProtoType proto, final ReceiverInformation ri, int activeZone)
    {
        Logging.info(this, "Requesting non-active zones state...");
        final List<String> cmd = [];
        for (int i = 0; i < ri.zones.length; i++)
        {
            if (i == activeZone)
            {
                // skip active zone since this zone already have actual information
                continue;
            }
            cmd.add(PowerStatusMsg.ZONE_COMMANDS[i]);
            if (proto == ProtoType.DCP && i > 0)
            {
                // no need to send MasterVolume request since it is equal to PowerStatus request in this case
                continue;
            }
            cmd.add(MasterVolumeMsg.ZONE_COMMANDS[i]);
        }
        return cmd;
    }

    String? processZonedMessage(ZonedMessage msg, final ReceiverInformation ri, int activeZone)
    {
        while (_zoneState.length < (msg.zoneIndex + 1))
        {
            final int length = _zoneState.length;
            _zoneState.add(ZoneState(length));
            Logging.info(this, "all zones state increased: " + _zoneState.length.toString());
        }
        final String? changed = _zoneState[msg.zoneIndex].processZonedMessage(msg);
        if (changed != null)
        {
            Logging.info(this, "changed state for zone " + _zoneState[msg.zoneIndex].toString());
        }
        return changed;
    }
}