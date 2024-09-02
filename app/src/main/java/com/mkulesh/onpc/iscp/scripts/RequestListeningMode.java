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
import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.iscp.MessageChannel;
import com.mkulesh.onpc.iscp.State;
import com.mkulesh.onpc.iscp.messages.ListeningModeMsg;
import com.mkulesh.onpc.utils.Logging;

import java.util.Timer;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.atomic.AtomicInteger;

import androidx.annotation.NonNull;

/*
 * For some models, it does seem that the listening mode is enabled some
 * seconds after power on - as though it's got things to initialize before
 * turning on the audio circuits. The initialization time is unknown.
 * The solution is to periodically send a constant number of requests
 * (for example 5 requests) with time interval 1 second until listening
 * mode still be unknown.
 */
public class RequestListeningMode implements MessageScriptIf
{
    private static final long LISTENING_MODE_DELAY = 1000;
    private static final int MAX_LISTENING_MODE_REQUESTS = 5;
    private final AtomicInteger listeningModeRequests = new AtomicInteger();
    private final BlockingQueue<Timer> listeningModeQueue = new ArrayBlockingQueue<>(1, true);

    @Override
    public boolean isValid(ConnectionIf.ProtoType protoType)
    {
        return protoType == ConnectionIf.ProtoType.ISCP;
    }

    @Override
    public boolean initialize(@NonNull final State state)
    {
        return isValid(state.protoType);
    }

    @Override
    public void start(@NonNull State state, @NonNull MessageChannel channel)
    {
        Logging.info(this, "started script");
        listeningModeRequests.set(0);
    }

    @Override
    public void processMessage(@NonNull ISCPMessage msg, @NonNull State state, @NonNull MessageChannel channel)
    {
        if (msg instanceof ListeningModeMsg &&
                ((ListeningModeMsg) msg).getMode() == ListeningModeMsg.Mode.MODE_FF &&
                listeningModeRequests.get() < MAX_LISTENING_MODE_REQUESTS &&
                listeningModeQueue.isEmpty())
        {
            Logging.info(this, "scheduling listening mode request in " + LISTENING_MODE_DELAY + "ms");
            final Timer t = new Timer();
            listeningModeQueue.add(t);
            t.schedule(new java.util.TimerTask()
            {
                @Override
                public void run()
                {
                    listeningModeQueue.poll();
                    Logging.info(RequestListeningMode.this, "re-requesting LM state ["
                            + listeningModeRequests.addAndGet(1) + "]...");
                    channel.sendMessage(new EISCPMessage(ListeningModeMsg.CODE, EISCPMessage.QUERY));
                }
            }, LISTENING_MODE_DELAY);
        }
    }
}
