/*
 * Copyright (C) 2020. Mikhail Kulesh
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
package com.mkulesh.onpc.iscp.scripts;

import android.content.Intent;

import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.iscp.MessageChannel;
import com.mkulesh.onpc.iscp.State;
import com.mkulesh.onpc.iscp.messages.PowerStatusMsg;
import com.mkulesh.onpc.utils.Logging;

import androidx.annotation.NonNull;

/**
 * The class performs receiver auto-power on startup
 **/
public class AutoPower implements MessageScriptIf
{
    private boolean done = false;

    @Override
    public boolean isValid()
    {
        return true;
    }

    @Override
    public void initialize(@NonNull Intent intent)
    {
        // nothing to do
    }

    @Override
    public void start()
    {
        // nothing to do
    }

    @Override
    public void processMessage(@NonNull ISCPMessage msg, @NonNull final State state, @NonNull MessageChannel channel)
    {
        if (!state.isOn() && msg instanceof PowerStatusMsg && !done)
        {
            Logging.info(this, "request auto-power on startup");
            // Auto power-on once at first PowerStatusMsg
            PowerStatusMsg cmd = new PowerStatusMsg(state.getActiveZone(), PowerStatusMsg.PowerStatus.ON);
            channel.sendMessage(cmd.getCmdMsg());
            done = true;
        }
    }
}
