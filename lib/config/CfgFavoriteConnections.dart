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
import "package:shared_preferences/shared_preferences.dart";

import "../iscp/ConnectionIf.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/BroadcastResponseMsg.dart";
import "../utils/Logging.dart";
import "../utils/Pair.dart";
import "CfgModule.dart";

class CfgFavoriteConnections extends CfgModule
{
    static String FAVORITE_CONNECTION_SEP = "<;>";
    static const Pair<String, int> FAVORITE_CONNECTION_NUMBER = Pair<String, int>("favorite_connection_number", 0);
    static String FAVORITE_CONNECTION_ITEM = "favorite_connection_item";

    final List<BroadcastResponseMsg> _devices = [];

    // methods
    CfgFavoriteConnections(SharedPreferences preferences) : super(preferences);

    @override
    void read()
    {
        _devices.clear();
        final int fcNumber = getInt(FAVORITE_CONNECTION_NUMBER, doLog: true);
        for (int i = 0; i < fcNumber; i++)
        {
            final Pair<String, String> key = Pair<String, String>(FAVORITE_CONNECTION_ITEM + "_" + i.toString(), "");
            final String val = getString(key, doLog: true);
            final List<String> tokens = val.split(FAVORITE_CONNECTION_SEP);
            if (tokens.length >= 3)
            {
                try
                {
                    _devices.add(BroadcastResponseMsg.alias(
                        tokens[0], /* host */
                        tokens[1], /* port */
                        tokens[2], /* alias */
                        tokens.length == 3 ? null : tokens[3])); /* identifier that is optional */
                }
                on Exception
                {
                    // nothing to do
                }
            }
        }
    }

    @override
    void setReceiverInformation(StateManager stateManager)
    {
        final String identifier = stateManager.state.receiverInformation.getIdentifier();
        if (identifier.isNotEmpty)
        {
            _updateIdentifier(stateManager.getConnection(), identifier);
        }
    }

    void write()
    {
        final int fcNumber = _devices.length;
        preferences.setInt(FAVORITE_CONNECTION_NUMBER.item1, fcNumber);
        for (int i = 0; i < fcNumber; i++)
        {
            final BroadcastResponseMsg msg = _devices[i];
            if (msg.alias != null)
            {
                final String key = FAVORITE_CONNECTION_ITEM + "_" + i.toString();
                String val = msg.getHost + FAVORITE_CONNECTION_SEP
                    + msg.getPort.toString() + FAVORITE_CONNECTION_SEP + msg.alias;
                // identifier is optional
                if (msg.getIdentifier.isNotEmpty)
                {
                    val += FAVORITE_CONNECTION_SEP + msg.getIdentifier;
                }
                preferences.setString(key, val);
            }
        }
    }

    List<BroadcastResponseMsg> get getDevices
    => _devices;

    int _find(final ConnectionIf connection)
    {
        for (int i = 0; i < _devices.length; i++)
        {
            final BroadcastResponseMsg msg = _devices[i];
            if (msg.fromHost(connection))
            {
                return i;
            }
        }
        return -1;
    }

    BroadcastResponseMsg updateDevice(final ConnectionIf connection, String alias, String identifier)
    {
        BroadcastResponseMsg newMsg;
        final int idx = _find(connection);
        if (idx >= 0)
        {
            final BroadcastResponseMsg oldMsg = _devices[idx];
            newMsg = BroadcastResponseMsg.connection(connection, alias, identifier);
            Logging.info(this, "Update favorite connection: " + oldMsg.toString() + " -> " + newMsg.toString());
            _devices[idx] = newMsg;
        }
        else
        {
            newMsg = BroadcastResponseMsg.connection(connection, alias, null);
            Logging.info(this, "Add favorite connection: " + newMsg.toString());
            _devices.add(newMsg);
        }
        write();
        return newMsg;
    }

    void deleteDevice(final ConnectionIf connection)
    {
        final int idx = _find(connection);
        if (idx >= 0)
        {
            final BroadcastResponseMsg oldMsg = _devices[idx];
            Logging.info(this, "Delete favorite connection: " + oldMsg.toString());
            _devices.remove(oldMsg);
            write();
        }
    }

    void _updateIdentifier(final ConnectionIf connection, final String identifier)
    {
        final int idx = _find(connection);
        if (idx >= 0)
        {
            final BroadcastResponseMsg oldMsg = _devices[idx];
            if (oldMsg.alias != null)
            {
                final BroadcastResponseMsg newMsg = BroadcastResponseMsg.connection(
                    oldMsg, oldMsg.alias, identifier);
                Logging.info(this, "Update favorite connection: " + oldMsg.toString() + " -> " + newMsg.toString());
                _devices[idx] = newMsg;
                write();
            }
        }
    }
}
