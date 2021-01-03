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

import "../EISCPMessage.dart";
import "../ISCPMessage.dart";

enum MultiroomGroupCommand
{
    ADD_SLAVE,
    GROUP_DISSOLUTION,
    REMOVE_SLAVE
}

/*
 * Multiroom Group Setting Command
 */
class MultiroomGroupSettingMsg extends ISCPMessage
{
    static const String CODE = "MGS";
    static const int TARGET_ZONE_ID = 1;

    final MultiroomGroupCommand _command;
    final int _zone, _groupId, _maxDelay;
    final List<String> _devices = List();

    MultiroomGroupSettingMsg.output(this._command, this._zone, this._groupId, this._maxDelay) :
            super.output(CODE, "");

    List<String> get devices
    => _devices;

    @override
    String toString()
    => super.toString() + "[" + _command.toString()
            + ", zone=" + _zone.toString()
            + ", groupId=" + _groupId.toString()
            + ", maxDelay=" + _maxDelay.toString()
            + "]";

    @override
    EISCPMessage getCmdMsg()
    {
        switch (_command)
        {
            case MultiroomGroupCommand.ADD_SLAVE:
            {
                String cmd = "";
                cmd += "<mgs zone=\"";
                cmd += _zone.toString();
                cmd += "\"><groupid>";
                cmd += _groupId.toString();
                cmd += "</groupid><maxdelay>";
                cmd += _maxDelay.toString();
                cmd += "</maxdelay><devices>";
                for (String d in _devices)
                {
                    cmd += "<device id=\"" + d + "\" zoneid=\"1\"/>";
                }
                cmd += "</devices></mgs>";
                return EISCPMessage.output(CODE, cmd.toString());
            }
            case MultiroomGroupCommand.GROUP_DISSOLUTION:
            {
                String cmd = "";
                cmd += "<mgs zone=\"";
                cmd += _zone.toString();
                cmd += "\"><groupid>";
                cmd += _groupId.toString();
                cmd += "</groupid></mgs>";
                return EISCPMessage.output(CODE, cmd.toString());
            }
            case MultiroomGroupCommand.REMOVE_SLAVE:
            {
                String cmd = "";
                cmd += "<mgs zone=\"";
                cmd += _zone.toString();
                cmd += "\"><groupid>";
                cmd += _groupId.toString();
                cmd += "</groupid><maxdelay>";
                cmd += _maxDelay.toString();
                cmd += "</maxdelay><devices>";
                for (String d in _devices)
                {
                    cmd += "<device id=\"" + d + "\" zoneid=\"" + TARGET_ZONE_ID.toString() + "\"/>";
                }
                cmd += "</devices></mgs>";
                return EISCPMessage.output(CODE, cmd.toString());
            }
        }
        return null;
    }

    @override
    bool hasImpactOnMediaList()
    {
        return false;
    }
}
