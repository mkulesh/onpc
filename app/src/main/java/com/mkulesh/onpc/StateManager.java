/*
 * Copyright (C) 2018. Mikhail Kulesh
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

package com.mkulesh.onpc;

import android.os.AsyncTask;
import android.os.StrictMode;

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.iscp.MessageChannel;
import com.mkulesh.onpc.iscp.messages.AlbumNameMsg;
import com.mkulesh.onpc.iscp.messages.ArtistNameMsg;
import com.mkulesh.onpc.iscp.messages.FileFormatMsg;
import com.mkulesh.onpc.iscp.messages.FirmwareUpdateMsg;
import com.mkulesh.onpc.iscp.messages.InputSelectorMsg;
import com.mkulesh.onpc.iscp.messages.JacketArtMsg;
import com.mkulesh.onpc.iscp.messages.ListTitleInfoMsg;
import com.mkulesh.onpc.iscp.messages.MenuStatusMsg;
import com.mkulesh.onpc.iscp.messages.OperationCommandMsg;
import com.mkulesh.onpc.iscp.messages.PlayStatusMsg;
import com.mkulesh.onpc.iscp.messages.PowerStatusMsg;
import com.mkulesh.onpc.iscp.messages.ReceiverInformationMsg;
import com.mkulesh.onpc.iscp.messages.TimeInfoMsg;
import com.mkulesh.onpc.iscp.messages.TitleNameMsg;
import com.mkulesh.onpc.iscp.messages.TrackInfoMsg;
import com.mkulesh.onpc.iscp.messages.XmlListInfoMsg;
import com.mkulesh.onpc.utils.Logging;

import java.util.Timer;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;

class StateManager extends AsyncTask<Void, Void, Void>
{
    private static final long GUI_UPDATE_DELAY = 500;
    private final State state;
    private final MainActivity activity;
    private final AtomicBoolean active = new AtomicBoolean();
    private AtomicBoolean returnFromPlayback = new AtomicBoolean();
    private final AtomicInteger skipNextTimeMsg = new AtomicInteger();
    private final MessageChannel messageChannel;
    private int xmlReqId = 0;
    private ISCPMessage circlePlayQueueMsg = null;

    StateManager(MainActivity activity, MessageChannel messageChannel, boolean mockup)
    {
        this.activity = activity;
        this.messageChannel = messageChannel;
        state = mockup ? new MockupState(activity) : new State();
        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);
    }

    void stop()
    {
        synchronized (active)
        {
            active.set(false);
        }
    }

    State getState()
    {
        return state;
    }

    @Override
    protected Void doInBackground(Void... params)
    {
        Logging.info(this, "started");
        active.set(true);

        requestPowerState();
        final BlockingQueue<Timer> timerQueue = new ArrayBlockingQueue<>(1, true);
        skipNextTimeMsg.set(0);
        while (true)
        {
            try
            {
                synchronized (active)
                {
                    if (!active.get() || isCancelled())
                    {
                        Logging.info(this, "cancelled");
                        break;
                    }
                }

                final PlayStatusMsg.PlayStatus playStatus = state.playStatus;
                final ISCPMessage msg = messageChannel.getInputQueue().take();
                boolean changed = false;
                if (msg != null)
                {
                    if (msg instanceof TimeInfoMsg && skipNextTimeMsg.get() > 0)
                    {
                        // skip time message
                        skipNextTimeMsg.set(Math.max(0, skipNextTimeMsg.get() - 1));
                    }
                    else
                    {
                        changed = state.update(msg);
                    }
                }

                if (changed && state.isOn())
                {
                    if (msg instanceof PowerStatusMsg)
                    {
                        requestPlayState();
                        requestListState();
                    }
                    else if (msg instanceof PlayStatusMsg && playStatus != state.playStatus)
                    {
                        if (state.isPlaying())
                        {
                            requestTrackState();
                        }
                        else
                        {
                            requestListState();
                        }
                    }
                    else if (msg instanceof TrackInfoMsg)
                    {
                        if (((TrackInfoMsg) msg).isValidTrack())
                        {
                            requestListState();
                        }
                    }
                    else if (msg instanceof ListTitleInfoMsg)
                    {
                        final ListTitleInfoMsg liMsg = (ListTitleInfoMsg) msg;
                        if (circlePlayQueueMsg != null && liMsg.getNumberOfItems() > 0)
                        {
                            sendPlayQueueMsg(circlePlayQueueMsg, true);
                        }
                        else
                        {
                            circlePlayQueueMsg = null;
                            requestXmlListState(liMsg);
                        }
                    }
                }

                if (changed && timerQueue.isEmpty())
                {
                    final Timer t = new Timer();
                    timerQueue.add(t);
                    t.schedule(new java.util.TimerTask()
                               {
                                   @Override
                                   public void run()
                                   {
                                       timerQueue.poll();
                                       publishProgress();
                                   }
                               },
                            GUI_UPDATE_DELAY
                    );
                }
            }
            catch (Exception e)
            {
                Logging.info(this, "interrupted: " + e.getLocalizedMessage());
                break;
            }
        }

        synchronized (active)
        {
            active.set(false);
        }
        Logging.info(this, "stopped");
        return null;
    }

    @Override
    protected void onProgressUpdate(Void... result)
    {
        activity.updateCurrentFragment(state);
    }

    private void requestPowerState()
    {
        Logging.info(this, "requesting power state...");
        messageChannel.sendMessage(
                new EISCPMessage('1', JacketArtMsg.CODE, JacketArtMsg.TYPE_LINK));
        messageChannel.sendMessage(
                new EISCPMessage('1', PowerStatusMsg.CODE, EISCPMessage.QUERY));
        messageChannel.sendMessage(
                new EISCPMessage('1', FirmwareUpdateMsg.CODE, EISCPMessage.QUERY));
        messageChannel.sendMessage(
                new EISCPMessage('1', ReceiverInformationMsg.CODE, EISCPMessage.QUERY));
        messageChannel.sendMessage(
                new EISCPMessage('1', InputSelectorMsg.CODE, EISCPMessage.QUERY));
    }

    void requestFirmwareUpdate()
    {
        Logging.info(this, "requesting firmware update...");
        messageChannel.sendMessage(
                new EISCPMessage('1', FirmwareUpdateMsg.CODE, FirmwareUpdateMsg.UPD_NET));
    }

    private void requestPlayState()
    {
        Logging.info(this, "requesting play state...");
        messageChannel.sendMessage(
                new EISCPMessage('1', PlayStatusMsg.CODE, EISCPMessage.QUERY));
    }

    private void requestTrackState()
    {
        Logging.info(this, "requesting track state...");
        messageChannel.sendMessage(
                new EISCPMessage('1', ArtistNameMsg.CODE, EISCPMessage.QUERY));
        messageChannel.sendMessage(
                new EISCPMessage('1', AlbumNameMsg.CODE, EISCPMessage.QUERY));
        messageChannel.sendMessage(
                new EISCPMessage('1', TitleNameMsg.CODE, EISCPMessage.QUERY));
        messageChannel.sendMessage(
                new EISCPMessage('1', FileFormatMsg.CODE, EISCPMessage.QUERY));
        messageChannel.sendMessage(
                new EISCPMessage('1', TrackInfoMsg.CODE, EISCPMessage.QUERY));
        messageChannel.sendMessage(
                new EISCPMessage('1', TimeInfoMsg.CODE, EISCPMessage.QUERY));
        messageChannel.sendMessage(
                new EISCPMessage('1', MenuStatusMsg.CODE, EISCPMessage.QUERY));
        if (state.isMediaEmpty())
        {
            requestListState();
        }
    }

    private void requestListState()
    {
        Logging.info(this, "requesting list state...");
        state.serviceType = null; // request update of List Title Info
        messageChannel.sendMessage(
                new EISCPMessage('1', ListTitleInfoMsg.CODE, EISCPMessage.QUERY));
    }

    private void requestXmlListState(final ListTitleInfoMsg liMsg)
    {
        if (liMsg.getServiceType() == ListTitleInfoMsg.ServiceType.NET
                && liMsg.getLayerInfo() == ListTitleInfoMsg.LayerInfo.NET_TOP)
        {
            Logging.info(this, "requesting XML list state skipped");
            return;
        }
        Logging.info(this, "requesting XML list state");
        if (liMsg.getUiType() == ListTitleInfoMsg.UIType.PLAYBACK)
        {
            if (returnFromPlayback.get())
            {
                sendMessage(new OperationCommandMsg(OperationCommandMsg.Command.RETURN));
            }
        }
        else if (liMsg.getNumberOfLayers() > 0)
        {
            messageChannel.sendMessage(
                    new EISCPMessage('1', XmlListInfoMsg.CODE, XmlListInfoMsg.getListedData(
                            xmlReqId++, liMsg.getNumberOfLayers(), 0, liMsg.getNumberOfItems())));
        }
        returnFromPlayback.set(false);
    }

    void sendMessage(final ISCPMessage msg)
    {
        returnFromPlayback.set(true);
        circlePlayQueueMsg = null;
        Logging.info(this, "sending message: " + msg.toString());
        final EISCPMessage cmdMsg = msg.getCmdMsg();
        if (cmdMsg != null)
        {
            messageChannel.sendMessage(cmdMsg);
        }
    }

    void sendPlayQueueMsg(ISCPMessage msg, boolean repeat)
    {
        if (msg == null)
        {
            return;
        }
        if (repeat)
        {
            Logging.info(this, "starting repeat mode: " + msg.toString());
            circlePlayQueueMsg = msg;
        }
        state.serviceType = null; // request update of List Title Info
        messageChannel.sendMessage(msg.getCmdMsg());
    }

    void requestSkipNextTimeMsg(final int number)
    {
        skipNextTimeMsg.set(number);
    }
}
