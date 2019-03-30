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
import com.mkulesh.onpc.iscp.messages.FriendlyNameMsg;
import com.mkulesh.onpc.iscp.messages.GoogleCastAnalyticsMsg;
import com.mkulesh.onpc.iscp.messages.GoogleCastVersionMsg;
import com.mkulesh.onpc.iscp.messages.HdmiCecMsg;
import com.mkulesh.onpc.iscp.messages.InputSelectorMsg;
import com.mkulesh.onpc.iscp.messages.JacketArtMsg;
import com.mkulesh.onpc.iscp.messages.ListInfoMsg;
import com.mkulesh.onpc.iscp.messages.ListTitleInfoMsg;
import com.mkulesh.onpc.iscp.messages.ListeningModeMsg;
import com.mkulesh.onpc.iscp.messages.MasterVolumeMsg;
import com.mkulesh.onpc.iscp.messages.MenuStatusMsg;
import com.mkulesh.onpc.iscp.messages.OperationCommandMsg;
import com.mkulesh.onpc.iscp.messages.PlayStatusMsg;
import com.mkulesh.onpc.iscp.messages.PowerStatusMsg;
import com.mkulesh.onpc.iscp.messages.PresetCommandMsg;
import com.mkulesh.onpc.iscp.messages.PrivacyPolicyStatusMsg;
import com.mkulesh.onpc.iscp.messages.ReceiverInformationMsg;
import com.mkulesh.onpc.iscp.messages.ServiceType;
import com.mkulesh.onpc.iscp.messages.SpeakerACommandMsg;
import com.mkulesh.onpc.iscp.messages.SpeakerBCommandMsg;
import com.mkulesh.onpc.iscp.messages.TimeInfoMsg;
import com.mkulesh.onpc.iscp.messages.TitleNameMsg;
import com.mkulesh.onpc.iscp.messages.TrackInfoMsg;
import com.mkulesh.onpc.iscp.messages.TuningCommandMsg;
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

        void onManagerStopped();

        void onDeviceDisconnected();
    }

    private final StateListener stateListener;
    private final MessageChannel messageChannel;
    private final State state;

    private final AtomicBoolean requestXmlList = new AtomicBoolean();
    private final AtomicBoolean playbackMode = new AtomicBoolean();
    private final AtomicInteger skipNextTimeMsg = new AtomicInteger();
    private final HashSet<State.ChangeType> eventChanges = new HashSet<>();
    private int xmlReqId = 0;
    private ISCPMessage circlePlayQueueMsg = null;
    private final EISCPMessage commandListMsg = new EISCPMessage(
            OperationCommandMsg.CODE, OperationCommandMsg.Command.LIST.toString());

    private final static String trackStateQueries[] = new String[]{
            ArtistNameMsg.CODE, AlbumNameMsg.CODE, TitleNameMsg.CODE,
            FileFormatMsg.CODE, TrackInfoMsg.CODE, TimeInfoMsg.CODE,
            MenuStatusMsg.CODE
    };

    private boolean autoPower = false;
    private final boolean useBmpImages;

    public StateManager(final ConnectionState connectionState, final StateListener stateListener,
                        final String device, final int port, final int zone) throws Exception
    {
        this.stateListener = stateListener;

        messageChannel = new MessageChannel(connectionState);
        state = new State(zone);

        // In LTE mode, always use BMP images instead of links since direct links
        // can be not available
        useBmpImages = !connectionState.isWifi();

        if (!messageChannel.connectToServer(device, port))
        {
            throw new Exception("Cannot connect to server");
        }

        messageChannel.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, (Void[]) null);
        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);
        executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, (Void[]) null);
    }

    public StateManager(final ConnectionState connectionState, final StateListener stateListener, final int zone)
    {
        this.stateListener = stateListener;

        messageChannel = new MessageChannel(connectionState);
        state = new MockupState(zone);
        useBmpImages = false;
        messageChannel.start();

        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);
        executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, (Void[]) null);
    }

    public void stop()
    {
        messageChannel.stop();
    }

    @NonNull
    public final State getState()
    {
        return state;
    }

    public void setAutoPower(boolean autoPower)
    {
        this.autoPower = autoPower;
    }

    @Override
    protected Void doInBackground(Void... params)
    {
        Logging.info(this, "started: " + toString());

        messageChannel.sendMessage(
                new EISCPMessage(JacketArtMsg.CODE,
                        useBmpImages ? JacketArtMsg.TYPE_BMP : JacketArtMsg.TYPE_LINK));

        final String powerStateQueries[] = new String[]{
                ReceiverInformationMsg.CODE,
                FriendlyNameMsg.CODE,
                FirmwareUpdateMsg.CODE,
                GoogleCastVersionMsg.CODE,
                PrivacyPolicyStatusMsg.CODE,
                PowerStatusMsg.ZONE_COMMANDS[state.getActiveZone()],
                ListeningModeMsg.CODE
        };

        sendQueries(powerStateQueries, "requesting power state...");

        final BlockingQueue<Timer> timerQueue = new ArrayBlockingQueue<>(1, true);
        skipNextTimeMsg.set(0);
        requestXmlList.set(false);
        playbackMode.set(false);

        while (true)
        {
            try
            {
                if (!messageChannel.isActive())
                {
                    Logging.info(this, "message channel stopped");
                    break;
                }

                final ISCPMessage msg = messageChannel.getInputQueue().take();

                if (msg instanceof ZonedMessage)
                {
                    final ZonedMessage zMsg = (ZonedMessage) msg;
                    if (zMsg.zoneIndex != state.getActiveZone())
                    {
                        Logging.info(this, "message ignored: non active zone " + zMsg.zoneIndex);
                        continue;
                    }
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

        Logging.info(this, "stopped: " + toString());
        stateListener.onManagerStopped();
        return null;
    }

    @Override
    protected void onPostExecute(Void aVoid)
    {
        super.onPostExecute(aVoid);
        stateListener.onDeviceDisconnected();
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
            if (msg instanceof PowerStatusMsg && autoPower)
            {
                // Auto power-on once at first PowerStatusMsg
                sendMessage(new PowerStatusMsg(state.getActiveZone(), PowerStatusMsg.PowerStatus.ON));
                autoPower = false;
            }
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
                        new EISCPMessage(XmlListInfoMsg.CODE, XmlListInfoMsg.getListedData(
                                xmlReqId++, state.numberOfLayers, 0, state.numberOfItems)));
            }
        }

        // Issue LIST command upon PlayStatusMsg if PlaybackMode is active
        if (msg instanceof ListTitleInfoMsg)
        {
            playbackMode.set(state.isPlaybackMode());
        }
        if (msg instanceof PlayStatusMsg &&
            playbackMode.get() &&
            state.isPlaying() &&
            state.serviceType != ServiceType.TUNEIN_RADIO)
        {
            // Note: see Issue 51. Do not request list mode for TUNEIN_RADIO since it tops
            // playing for some models
            Logging.info(this, "requesting list mode...");
            messageChannel.sendMessage(commandListMsg);
            playbackMode.set(false);
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
            final String playStateQueries[] = new String[]{
                    DimmerLevelMsg.CODE,
                    DigitalFilterMsg.CODE,
                    AutoPowerMsg.CODE,
                    HdmiCecMsg.CODE,
                    GoogleCastAnalyticsMsg.CODE,
                    SpeakerACommandMsg.ZONE_COMMANDS[state.getActiveZone()],
                    SpeakerBCommandMsg.ZONE_COMMANDS[state.getActiveZone()],
                    InputSelectorMsg.ZONE_COMMANDS[state.getActiveZone()],
                    AudioMutingMsg.ZONE_COMMANDS[state.getActiveZone()],
                    MasterVolumeMsg.ZONE_COMMANDS[state.getActiveZone()],
                    PresetCommandMsg.ZONE_COMMANDS[state.getActiveZone()],
                    TuningCommandMsg.ZONE_COMMANDS[state.getActiveZone()],
                    ListeningModeMsg.CODE,
                    PlayStatusMsg.CODE,
            };
            sendQueries(playStateQueries, "requesting play state...");
            requestListState();
            return true;
        }

        if (msg instanceof PlayStatusMsg && playStatus != state.playStatus)
        {
            if (state.isPlaying())
            {
                sendQueries(trackStateQueries, "requesting track state...");
                // Some devices (like TX-8150) does not proved cover image;
                // we shall specially request it:
                if (state.getModel().equals("TX-8150"))
                {
                    messageChannel.sendMessage(
                            new EISCPMessage(JacketArtMsg.CODE, JacketArtMsg.REQUEST));
                }
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
                new EISCPMessage(ListTitleInfoMsg.CODE, EISCPMessage.QUERY));
    }

    private void requestXmlListState(final ListTitleInfoMsg liMsg)
    {
        requestXmlList.set(false);
        if (liMsg.isNetTopService())
        {
            Logging.info(this, "requesting XML list state skipped");
        }
        else if (liMsg.getUiType() == ListTitleInfoMsg.UIType.PLAYBACK
                || liMsg.getUiType() == ListTitleInfoMsg.UIType.MENU)
        {
            Logging.info(this, "requesting XML list state skipped");
        }
        else if (liMsg.isXmlListTopService() || liMsg.getNumberOfLayers() > 0)
        {
            Logging.info(this, "requesting XML list state");
            messageChannel.sendMessage(
                    new EISCPMessage(XmlListInfoMsg.CODE, XmlListInfoMsg.getListedData(
                            xmlReqId++, liMsg.getNumberOfLayers(), 0, liMsg.getNumberOfItems())));
        }
    }

    public void sendMessage(final ISCPMessage msg)
    {
        Logging.info(this, "sending message: " + msg.toString());
        if (msg.isMultiline())
        {
            msg.logParameters();
        }
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
                    new EISCPMessage(code, EISCPMessage.QUERY));
        }
    }

    public void sendTrackCmd(OperationCommandMsg.Command menu, boolean doReturn)
    {
        Logging.info(this, "sending track cmd: " + menu.toString());
        if (!state.isPlaybackMode())
        {
            messageChannel.sendMessage(commandListMsg);
        }
        messageChannel.sendMessage(new EISCPMessage(
                OperationCommandMsg.CODE, menu.getCode()));
        if (doReturn)
        {
            messageChannel.sendMessage(commandListMsg);
        }
    }
}
