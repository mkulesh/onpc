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

package com.mkulesh.onpc.iscp;

import android.content.Context;
import android.os.AsyncTask;
import android.os.StrictMode;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.mkulesh.onpc.iscp.messages.AlbumNameMsg;
import com.mkulesh.onpc.iscp.messages.ArtistNameMsg;
import com.mkulesh.onpc.iscp.messages.AudioMutingMsg;
import com.mkulesh.onpc.iscp.messages.AutoPowerMsg;
import com.mkulesh.onpc.iscp.messages.DigitalFilterMsg;
import com.mkulesh.onpc.iscp.messages.DimmerLevelMsg;
import com.mkulesh.onpc.iscp.messages.DisplayModeMsg;
import com.mkulesh.onpc.iscp.messages.FileFormatMsg;
import com.mkulesh.onpc.iscp.messages.FirmwareUpdateMsg;
import com.mkulesh.onpc.iscp.messages.GoogleCastAnalyticsMsg;
import com.mkulesh.onpc.iscp.messages.GoogleCastVersionMsg;
import com.mkulesh.onpc.iscp.messages.HdmiCecMsg;
import com.mkulesh.onpc.iscp.messages.InputSelectorMsg;
import com.mkulesh.onpc.iscp.messages.JacketArtMsg;
import com.mkulesh.onpc.iscp.messages.ListInfoMsg;
import com.mkulesh.onpc.iscp.messages.ListTitleInfoMsg;
import com.mkulesh.onpc.iscp.messages.ListeningModeMsg;
import com.mkulesh.onpc.iscp.messages.MenuStatusMsg;
import com.mkulesh.onpc.iscp.messages.OperationCommandMsg;
import com.mkulesh.onpc.iscp.messages.PlayStatusMsg;
import com.mkulesh.onpc.iscp.messages.PowerStatusMsg;
import com.mkulesh.onpc.iscp.messages.PrivacyPolicyStatusMsg;
import com.mkulesh.onpc.iscp.messages.ReceiverInformationMsg;
import com.mkulesh.onpc.iscp.messages.ServiceType;
import com.mkulesh.onpc.iscp.messages.TimeInfoMsg;
import com.mkulesh.onpc.iscp.messages.TitleNameMsg;
import com.mkulesh.onpc.iscp.messages.TrackInfoMsg;
import com.mkulesh.onpc.iscp.messages.XmlListInfoMsg;
import com.mkulesh.onpc.utils.Logging;

import java.util.HashSet;
import java.util.Timer;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;

public class StateManager extends AsyncTask<Void, Void, Void>
{
    private static final long GUI_UPDATE_DELAY = 500;

    public interface StateListener
    {
        void onStateChanged(State state, @Nullable final HashSet<State.ChangeType> eventChanges);
    }

    private final StateListener stateListener;
    private final MessageChannel messageChannel;
    private final State state;

    private final AtomicBoolean active = new AtomicBoolean();
    private final AtomicBoolean requestXmlList = new AtomicBoolean();
    private final AtomicInteger skipNextTimeMsg = new AtomicInteger();
    private final HashSet<State.ChangeType> eventChanges = new HashSet<>();
    private int xmlReqId = 0;
    private ISCPMessage circlePlayQueueMsg = null;
    private final EISCPMessage commandListMsg = new EISCPMessage('1',
            OperationCommandMsg.CODE, OperationCommandMsg.Command.LIST.toString());

    // Queries for different states
    private final static String powerStateQueries [] = new String[] {
        PowerStatusMsg.CODE, FirmwareUpdateMsg.CODE, ReceiverInformationMsg.CODE,
        InputSelectorMsg.CODE, AudioMutingMsg.CODE, GoogleCastVersionMsg.CODE,
        PrivacyPolicyStatusMsg.CODE
    };

    private final static String settingsQueries [] = new String[] {
            DimmerLevelMsg.CODE, DigitalFilterMsg.CODE, AutoPowerMsg.CODE,
            HdmiCecMsg.CODE, GoogleCastAnalyticsMsg.CODE
    };

    private final static String playStateQueries [] = new String[] {
        PlayStatusMsg.CODE, ListeningModeMsg.CODE
    };

    private final static String trackStateQueries [] = new String[] {
        ArtistNameMsg.CODE, AlbumNameMsg.CODE, TitleNameMsg.CODE,
        FileFormatMsg.CODE, TrackInfoMsg.CODE, TimeInfoMsg.CODE,
        MenuStatusMsg.CODE
    };

    public StateManager(final Context context, final StateListener stateListener, final String device, final int port) throws Exception
    {
        this.stateListener = stateListener;

        messageChannel = new MessageChannel(context);
        state = new State();

        if (!messageChannel.connectToServer(device, port))
        {
            throw new Exception("Cannot connect to server");
        }

        messageChannel.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, (Void[]) null);
        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);
        executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, (Void[]) null);
    }

    public StateManager(final Context context, final StateListener stateListener)
    {
        this.stateListener = stateListener;

        messageChannel = new MessageChannel(context);
        state = new MockupState();

        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);
        executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, (Void[]) null);
    }

    public void stop()
    {
        synchronized (active)
        {
            active.set(false);
        }
        messageChannel.stop();
    }

    public @NonNull final State getState()
    {
        return state;
    }

    @Override
    protected Void doInBackground(Void... params)
    {
        Logging.info(this, "started: " + toString());
        active.set(true);

        messageChannel.sendMessage(
                new EISCPMessage('1', JacketArtMsg.CODE, JacketArtMsg.TYPE_LINK));
        sendQueries(powerStateQueries, "requesting power state...");
        sendQueries(settingsQueries, "requesting settings...");

        final BlockingQueue<Timer> timerQueue = new ArrayBlockingQueue<>(1, true);
        skipNextTimeMsg.set(0);
        requestXmlList.set(false);
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

                final ISCPMessage msg = messageChannel.getInputQueue().take();
                if (msg == null)
                {
                    continue;
                }

                boolean changed = false;

                try
                {
                    changed = processMessage(msg);
                }
                catch (Exception e)
                {
                    Logging.info(this, "cannot process message: " + e.getLocalizedMessage());
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
                    }, GUI_UPDATE_DELAY);
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
        Logging.info(this, "stopped: " + toString());
        return null;
    }

    private boolean processMessage(@NonNull ISCPMessage msg)
    {
        // skip time message, is necessary
        if (msg instanceof TimeInfoMsg && skipNextTimeMsg.get() > 0)
        {
            skipNextTimeMsg.set(Math.max(0, skipNextTimeMsg.get() - 1));
            return false;
        }

        final PlayStatusMsg.PlayStatus playStatus = state.playStatus;
        final State.ChangeType changed = state.update(msg);

        if (changed != State.ChangeType.NONE)
        {
            eventChanges.add(changed);
        }

        // no further message handling, if power off
        if (!state.isOn())
        {
            return changed != State.ChangeType.NONE;
        }

        // on TrackInfoMsg, always do XML state request upon the next ListTitleInfoMsg
        if (msg instanceof TrackInfoMsg)
        {
            requestXmlList.set(true);
            return true;
        }

        // corner case: delayed USB initialization at power on
        if (msg instanceof ListInfoMsg)
        {
            if (state.isUsb() && state.isTopLayer() && !state.listInfoConsistent())
            {
                Logging.info(this, "requesting XML list state for USB...");
                messageChannel.sendMessage(
                        new EISCPMessage('1', XmlListInfoMsg.CODE, XmlListInfoMsg.getListedData(
                                xmlReqId++, state.numberOfLayers, 0, state.numberOfItems)));
            }
        }

        if (msg instanceof PlayStatusMsg && state.isPlaybackMode() && state.isPlaying())
        {
            messageChannel.sendMessage(commandListMsg);
        }

        if (changed == State.ChangeType.NONE)
        {
            if (msg instanceof ListTitleInfoMsg && requestXmlList.get())
            {
                requestXmlListState((ListTitleInfoMsg) msg);
            }
            return false;
        }

        if (msg instanceof PowerStatusMsg)
        {
            sendQueries(settingsQueries, "requesting settings...");
            sendQueries(playStateQueries, "requesting play state...");
            requestListState();
            return true;
        }

        if (msg instanceof PlayStatusMsg && playStatus != state.playStatus)
        {
            if (state.isPlaying())
            {
                sendQueries(trackStateQueries, "requesting track state...");
                if (state.isMediaEmpty())
                {
                    requestListState();
                }
            }
            else
            {
                requestListState();
            }
            return true;
        }

        if (msg instanceof ListTitleInfoMsg)
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
            return true;
        }

        if (msg instanceof PrivacyPolicyStatusMsg)
        {
            final PrivacyPolicyStatusMsg pMsg = (PrivacyPolicyStatusMsg) msg;
            if (!pMsg.isPolicySet(PrivacyPolicyStatusMsg.Status.GOOGLE))
            {
                sendMessage(new PrivacyPolicyStatusMsg(PrivacyPolicyStatusMsg.Status.GOOGLE));
            }
            if (!pMsg.isPolicySet(PrivacyPolicyStatusMsg.Status.SUE))
            {
                sendMessage(new PrivacyPolicyStatusMsg(PrivacyPolicyStatusMsg.Status.SUE));
            }
        }

        return true;
    }

    @Override
    protected void onProgressUpdate(Void... result)
    {
        stateListener.onStateChanged(state, eventChanges);
        eventChanges.clear();
    }

    private void requestListState()
    {
        Logging.info(this, "requesting list state...");
        requestXmlList.set(true);
        messageChannel.sendMessage(
                new EISCPMessage('1', ListTitleInfoMsg.CODE, EISCPMessage.QUERY));
    }

    private void requestXmlListState(final ListTitleInfoMsg liMsg)
    {
        requestXmlList.set(false);
        if (liMsg.getServiceType() == ServiceType.NET
                && liMsg.getLayerInfo() == ListTitleInfoMsg.LayerInfo.NET_TOP)
        {
            Logging.info(this, "requesting XML list state skipped");
        }
        else if (liMsg.getUiType() == ListTitleInfoMsg.UIType.PLAYBACK
                 || liMsg.getUiType() == ListTitleInfoMsg.UIType.MENU)
        {
            Logging.info(this, "requesting XML list state skipped");
        }
        else if (liMsg.getNumberOfLayers() > 0)
        {
            Logging.info(this, "requesting XML list state");
            messageChannel.sendMessage(
                    new EISCPMessage('1', XmlListInfoMsg.CODE, XmlListInfoMsg.getListedData(
                            xmlReqId++, liMsg.getNumberOfLayers(), 0, liMsg.getNumberOfItems())));
        }
    }

    public void sendMessage(final ISCPMessage msg)
    {
        Logging.info(this, "sending message: " + msg.toString());
        circlePlayQueueMsg = null;
        if (msg.hasImpactOnMediaList() ||
                (msg instanceof DisplayModeMsg && !state.isPlaybackMode()))
        {
            requestXmlList.set(true);
        }
        final EISCPMessage cmdMsg = msg.getCmdMsg();
        if (cmdMsg != null)
        {
            messageChannel.sendMessage(cmdMsg);
        }
    }

    public void sendPlayQueueMsg(ISCPMessage msg, boolean repeat)
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
        requestXmlList.set(true);
        messageChannel.sendMessage(msg.getCmdMsg());
    }

    public void requestSkipNextTimeMsg(final int number)
    {
        skipNextTimeMsg.set(number);
    }

    private void sendQueries(final String[] queries, final String purpose)
    {
        Logging.info(this, purpose);
        for (String code : queries)
        {
            messageChannel.sendMessage(
                    new EISCPMessage('1', code, EISCPMessage.QUERY));
        }
    }

    public void sendTrackCmd(OperationCommandMsg.Command menu, boolean doReturn)
    {
        Logging.info(this, "sending track cmd: " + menu.toString());
        if (!state.isPlaybackMode())
        {
            messageChannel.sendMessage(commandListMsg);
        }
        messageChannel.sendMessage(new EISCPMessage('1',
                OperationCommandMsg.CODE, menu.getCode()));
        if (doReturn)
        {
            messageChannel.sendMessage(commandListMsg);
        }
    }
}
