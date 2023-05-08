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

package com.mkulesh.onpc.config;

import android.content.SharedPreferences;

import com.mkulesh.onpc.iscp.ConnectionIf;
import com.mkulesh.onpc.iscp.State;
import com.mkulesh.onpc.iscp.messages.BroadcastResponseMsg;
import com.mkulesh.onpc.utils.Logging;

import java.util.ArrayList;
import java.util.List;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import static com.mkulesh.onpc.utils.Utils.getStringPref;

public class CfgFavoriteConnections
{
    private static final String FAVORITE_CONNECTION_SEP = "<;>";
    private static final String FAVORITE_CONNECTION_NUMBER = "favorite_connection_number";
    private static final String FAVORITE_CONNECTION_ITEM = "favorite_connection_item";

    private final ArrayList<BroadcastResponseMsg> devices = new ArrayList<>();

    private SharedPreferences preferences;

    void setPreferences(SharedPreferences preferences)
    {
        this.preferences = preferences;
    }

    void read()
    {
        devices.clear();
        final int fcNumber = preferences.getInt(FAVORITE_CONNECTION_NUMBER, 0);
        for (int i = 0; i < fcNumber; i++)
        {
            final String key = FAVORITE_CONNECTION_ITEM + "_" + i;
            final String val = getStringPref(preferences, key, "");
            final String[] tokens = val.split(FAVORITE_CONNECTION_SEP);
            if (tokens.length >= 3)
            {
                try
                {
                    devices.add(new BroadcastResponseMsg(
                            tokens[0], /* host */
                            Integer.parseInt(tokens[1], 10), /* port */
                            tokens[2], /* alias */
                            tokens.length == 3 ? null : tokens[3])); /* identifier that is optional */
                }
                catch (Exception ex)
                {
                    // nothing to do
                }
            }
        }
    }

    private void write()
    {
        final int fcNumber = devices.size();
        SharedPreferences.Editor prefEditor = preferences.edit();
        prefEditor.putInt(FAVORITE_CONNECTION_NUMBER, fcNumber);
        for (int i = 0; i < fcNumber; i++)
        {
            final BroadcastResponseMsg msg = devices.get(i);
            if (msg.getAlias() != null)
            {
                final String key = FAVORITE_CONNECTION_ITEM + "_" + i;
                String val = msg.getHost() + FAVORITE_CONNECTION_SEP
                        + msg.getPort() + FAVORITE_CONNECTION_SEP + msg.getAlias();
                // identifier is optional
                if (!msg.getIdentifier().isEmpty())
                {
                    val += FAVORITE_CONNECTION_SEP + msg.getIdentifier();
                }
                prefEditor.putString(key, val);
            }
        }
        prefEditor.apply();
    }

    @NonNull
    public final List<BroadcastResponseMsg> getDevices()
    {
        return devices;
    }

    private int find(@NonNull final ConnectionIf connection)
    {
        for (int i = 0; i < devices.size(); i++)
        {
            final BroadcastResponseMsg msg = devices.get(i);
            if (msg.fromHost(connection))
            {
                return i;
            }
        }
        return -1;
    }

    public BroadcastResponseMsg updateDevice(@NonNull final ConnectionIf connection,
                                             @NonNull final String alias, @Nullable final String identifier)
    {
        BroadcastResponseMsg newMsg;
        int idx = find(connection);
        if (idx >= 0)
        {
            final BroadcastResponseMsg oldMsg = devices.get(idx);
            newMsg = new BroadcastResponseMsg(connection.getHost(), connection.getPort(), alias, identifier);
            Logging.info(this, "Update favorite connection: " + oldMsg.toString() + " -> " + newMsg);
            devices.set(idx, newMsg);
        }
        else
        {
            newMsg = new BroadcastResponseMsg(connection.getHost(), connection.getPort(), alias, null);
            Logging.info(this, "Add favorite connection: " + newMsg);
            devices.add(newMsg);
        }
        write();
        return newMsg;
    }

    public void deleteDevice(@NonNull final ConnectionIf connection)
    {
        int idx = find(connection);
        if (idx >= 0)
        {
            final BroadcastResponseMsg oldMsg = devices.get(idx);
            Logging.info(this, "Delete favorite connection: " + oldMsg.toString());
            devices.remove(oldMsg);
            write();
        }
    }

    void updateIdentifier(@NonNull State state)
    {
        String identifier = state.deviceProperties.get("macaddress");
        if (identifier == null)
        {
            identifier = state.deviceProperties.get("deviceserial");
        }
        if (identifier == null)
        {
            return;
        }
        int idx = find(state);
        if (idx >= 0)
        {
            final BroadcastResponseMsg oldMsg = devices.get(idx);
            if (oldMsg.getAlias() != null)
            {
                final BroadcastResponseMsg newMsg = new BroadcastResponseMsg(
                        oldMsg.getHost(), oldMsg.getPort(), oldMsg.getAlias(), identifier);
                Logging.info(this, "Update favorite connection: " + oldMsg + " -> " + newMsg);
                devices.set(idx, newMsg);
                write();
            }
        }
    }
}
