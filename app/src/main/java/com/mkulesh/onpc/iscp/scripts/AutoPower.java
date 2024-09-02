/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2024 by Mikhail Kulesh
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

import com.mkulesh.onpc.iscp.ConnectionIf;
import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.iscp.MessageChannel;
import com.mkulesh.onpc.iscp.State;
import com.mkulesh.onpc.iscp.messages.PowerStatusMsg;
import com.mkulesh.onpc.iscp.messages.ReceiverInformationMsg;
import com.mkulesh.onpc.utils.Logging;

import androidx.annotation.NonNull;

/**
 * The class performs receiver auto-power on startup
 **/
public class AutoPower implements MessageScriptIf
{
    public enum AutoPowerMode
    {
        POWER_ON,
        ALL_STANDBY
    }

    enum AllStandbyStep
    {
        NONE,
        ALL_STB_SEND,
        STB_SEND
    }

    private final AutoPowerMode autoPowerMode;
    private boolean done = false;
    AllStandbyStep allStandbyStep = AllStandbyStep.NONE;

    public AutoPower(final AutoPowerMode autoPowerMode)
    {
        this.autoPowerMode = autoPowerMode;
    }

    @Override
    public boolean isValid(ConnectionIf.ProtoType protoType)
    {
        return true;
    }

    @Override
    public boolean initialize(@NonNull final State state)
    {
        return isValid(state.protoType);
    }

    @Override
    public void start(@NonNull final State state, @NonNull MessageChannel channel)
    {
        Logging.info(this, "started script: " + autoPowerMode);
        done = false;
        allStandbyStep = AllStandbyStep.NONE;
    }

    @Override
    public void processMessage(@NonNull ISCPMessage msg, @NonNull final State state, @NonNull MessageChannel channel)
    {
        // Auto power-on once at first PowerStatusMsg
        if (msg instanceof PowerStatusMsg && !done)
        {
            final PowerStatusMsg pwrMsg = (PowerStatusMsg) msg;
            if (autoPowerMode == AutoPowerMode.POWER_ON && !state.isOn())
            {
                Logging.info(this, "request auto-power on startup");
                final PowerStatusMsg cmd = new PowerStatusMsg(state.getActiveZone(), PowerStatusMsg.PowerStatus.ON);
                channel.sendMessage(cmd.getCmdMsg());
                done = true;
            }
            else if (autoPowerMode == AutoPowerMode.ALL_STANDBY)
            {
                switch (allStandbyStep)
                {
                case NONE:
                {
                    Logging.info(this, "request all-standby on startup");
                    final PowerStatusMsg cmd = new PowerStatusMsg(
                            ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE, PowerStatusMsg.PowerStatus.ALL_STB);
                    channel.sendMessage(cmd.getCmdMsg());
                    allStandbyStep = AllStandbyStep.ALL_STB_SEND;
                    break;
                }
                case ALL_STB_SEND:
                {
                    if (pwrMsg.getPowerStatus() == PowerStatusMsg.PowerStatus.STB ||
                            pwrMsg.getPowerStatus() == PowerStatusMsg.PowerStatus.ALL_STB)
                    {
                        done = true;
                    }
                    else
                    {
                        Logging.info(this, "request standby on startup");
                        final PowerStatusMsg cmd = new PowerStatusMsg(
                                ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE, PowerStatusMsg.PowerStatus.STB);
                        channel.sendMessage(cmd.getCmdMsg());
                        allStandbyStep = AllStandbyStep.STB_SEND;
                    }
                    break;
                }
                case STB_SEND:
                    done = true;
                    break;
                }
                if (done)
                {
                    Logging.info(this, "close app after all-standby on startup");
                    System.exit(0);
                }
            }
        }
    }
}
