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

import com.mkulesh.onpc.iscp.messages.AlbumNameMsg;
import com.mkulesh.onpc.iscp.messages.AmpOperationCommandMsg;
import com.mkulesh.onpc.iscp.messages.ArtistNameMsg;
import com.mkulesh.onpc.iscp.messages.AudioMutingMsg;
import com.mkulesh.onpc.iscp.messages.AutoPowerMsg;
import com.mkulesh.onpc.iscp.messages.BroadcastResponseMsg;
import com.mkulesh.onpc.iscp.messages.CenterLevelCommandMsg;
import com.mkulesh.onpc.iscp.messages.DigitalFilterMsg;
import com.mkulesh.onpc.iscp.messages.DimmerLevelMsg;
import com.mkulesh.onpc.iscp.messages.DirectCommandMsg;
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
import com.mkulesh.onpc.iscp.messages.MultiroomDeviceInformationMsg;
import com.mkulesh.onpc.iscp.messages.MusicOptimizerMsg;
import com.mkulesh.onpc.iscp.messages.OperationCommandMsg;
import com.mkulesh.onpc.iscp.messages.PhaseMatchingBassMsg;
import com.mkulesh.onpc.iscp.messages.PlayStatusMsg;
import com.mkulesh.onpc.iscp.messages.PowerStatusMsg;
import com.mkulesh.onpc.iscp.messages.PresetCommandMsg;
import com.mkulesh.onpc.iscp.messages.PrivacyPolicyStatusMsg;
import com.mkulesh.onpc.iscp.messages.ReceiverInformationMsg;
import com.mkulesh.onpc.iscp.messages.ServiceType;
import com.mkulesh.onpc.iscp.messages.SleepSetCommandMsg;
import com.mkulesh.onpc.iscp.messages.SpeakerACommandMsg;
import com.mkulesh.onpc.iscp.messages.SpeakerBCommandMsg;
import com.mkulesh.onpc.iscp.messages.SubwooferLevelCommandMsg;
import com.mkulesh.onpc.iscp.messages.TimeInfoMsg;
import com.mkulesh.onpc.iscp.messages.TitleNameMsg;
import com.mkulesh.onpc.iscp.messages.ToneCommandMsg;
import com.mkulesh.onpc.iscp.messages.TrackInfoMsg;
import com.mkulesh.onpc.iscp.messages.TuningCommandMsg;
import com.mkulesh.onpc.iscp.messages.XmlListInfoMsg;
import com.mkulesh.onpc.utils.Logging;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Timer;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public class StateManager extends AsyncTask<Void, Void, Void>
{
    private static final long GUI_UPDATE_DELAY = 500;

    public interface StateListener
    {
        void onStateChanged(State state, @Nullable final HashSet<State.ChangeType> eventChanges);

        void onManagerStopped();

        void onDeviceDisconnected();
    }

    private final DeviceList deviceList;
    private final ConnectionState connectionState;
    private final Map<String, MessageChannel> multiroomChannels = new HashMap<>();

    private final StateListener stateListener;
    private final MessageChannel messageChannel;
    private final State state;

    private final AtomicBoolean requestXmlList = new AtomicBoolean();
    private final AtomicBoolean playbackMode = new AtomicBoolean();
    private final AtomicInteger skipNextTimeMsg = new AtomicInteger();
    private final HashSet<State.ChangeType> eventChanges = new HashSet<>();
    private int xmlReqId = 0;
    private ISCPMessage circlePlayQueueMsg = null;

    private final static String[] trackStateQueries = new String[]{
            ArtistNameMsg.CODE, AlbumNameMsg.CODE, TitleNameMsg.CODE,
            FileFormatMsg.CODE, TrackInfoMsg.CODE, TimeInfoMsg.CODE,
            MenuStatusMsg.CODE
    };

    private final static String[] multiroomQueries = new String[]{
            MultiroomDeviceInformationMsg.CODE,
            FriendlyNameMsg.CODE
    };

    private boolean autoPower = false;
    private final AtomicBoolean keepPlaybackMode = new AtomicBoolean();
    private final boolean useBmpImages;

    private final BlockingQueue<ISCPMessage> inputQueue = new ArrayBlockingQueue<>(MessageChannel.QUEUE_SIZE, true);

    public final static OperationCommandMsg LIST_MSG =
            new OperationCommandMsg(OperationCommandMsg.Command.LIST);
    public final static OperationCommandMsg RETURN_MSG =
            new OperationCommandMsg(OperationCommandMsg.Command.RETURN);

    // The handling of delayed listening mode requests
    private static final long LISTENING_MODE_DELAY = 1000;
    private static final int MAX_LISTENING_MODE_REQUESTS = 5;
    private AtomicInteger listeningModeRequests = new AtomicInteger();
    private final BlockingQueue<Timer> listeningModeQueue = new ArrayBlockingQueue<>(1, true);

    public StateManager(final DeviceList deviceList,
                        final ConnectionState connectionState,
                        final StateListener stateListener,
                        final String host, final int port,
                        final int zone,
                        final boolean autoPower,
                        final boolean keepPlaybackMode,
                        String savedReceiverInformation) throws Exception
    {
        this.deviceList = deviceList;
        this.connectionState = connectionState;
        this.stateListener = stateListener;

        messageChannel = new MessageChannel(connectionState, inputQueue);
        if (!messageChannel.connectToServer(host, port))
        {
            throw new Exception("Cannot connect to server");
        }

        state = new State(messageChannel.getSourceHost(), port, zone);

        // In LTE mode, always use BMP images instead of links since direct links
        // can be not available
        useBmpImages = !connectionState.isWifi();

        this.autoPower = autoPower;
        setPlaybackMode(keepPlaybackMode);

        if (savedReceiverInformation != null)
        {
            try
            {
                state.process(new ReceiverInformationMsg(
                        new EISCPMessage(ReceiverInformationMsg.CODE, savedReceiverInformation)),
                        /*showInfo=*/ false);
            }
            catch (Exception ex)
            {
                // nothing to do
            }
        }

        messageChannel.start();
        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);
        executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, (Void[]) null);
    }

    public StateManager(final ConnectionState connectionState, final StateListener stateListener, final int zone)
    {
        this.deviceList = null;
        this.connectionState = connectionState;
        this.stateListener = stateListener;

        messageChannel = new MessageChannel(connectionState, inputQueue);
        state = new MockupState(zone);
        useBmpImages = false;
        setPlaybackMode(false);
        messageChannel.start();

        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);
        executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, (Void[]) null);
    }

    public void setPlaybackMode(boolean flag)
    {
        keepPlaybackMode.set(flag);
    }

    public void stop()
    {
        messageChannel.stop();
        for (MessageChannel m : multiroomChannels.values())
        {
            m.stop();
        }
    }

    @NonNull
    public final State getState()
    {
        return state;
    }

    @Override
    protected Void doInBackground(Void... params)
    {
        Logging.info(this, "started: " + toString());

        messageChannel.sendMessage(
                new EISCPMessage(JacketArtMsg.CODE,
                        useBmpImages ? JacketArtMsg.TYPE_BMP : JacketArtMsg.TYPE_LINK));

        final String[] powerStateQueries = new String[]{
                ReceiverInformationMsg.CODE,
                MultiroomDeviceInformationMsg.CODE,
                PowerStatusMsg.ZONE_COMMANDS[state.getActiveZone()],
                FriendlyNameMsg.CODE,
                FirmwareUpdateMsg.CODE,
                GoogleCastVersionMsg.CODE,
                PrivacyPolicyStatusMsg.CODE,
                ListeningModeMsg.CODE
        };

        sendQueries(powerStateQueries, "requesting power state...");

        final BlockingQueue<Timer> timerQueue = new ArrayBlockingQueue<>(1, true);
        skipNextTimeMsg.set(0);
        requestXmlList.set(false);
        playbackMode.set(false);
        listeningModeRequests.set(0);

        while (true)
        {
            try
            {
                if (!messageChannel.isActive())
                {
                    Logging.info(this, "message channel stopped");
                    break;
                }

                final ISCPMessage msg = inputQueue.take();

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

                if (msg instanceof BroadcastResponseMsg && deviceList != null)
                {
                    handleMultiroom();
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

        while (true)
        {
            int activeCount = 0;
            for (MessageChannel m : multiroomChannels.values())
            {
                if (m.isActive())
                {
                    activeCount++;
                }
            }
            if (activeCount == 0)
            {
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
        if (!keepPlaybackMode.get() &&
                msg instanceof PlayStatusMsg &&
                playbackMode.get() &&
                state.isPlaying() &&
                state.serviceType != ServiceType.TUNEIN_RADIO)
        {
            // Notes for not requesting list mode for some service Types:
            // #51: List mode stops playing TUNEIN_RADIO for some models
            Logging.info(this, "requesting list mode...");
            messageChannel.sendMessage(LIST_MSG.getCmdMsg());
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
            // #58: delayed response for InputSelectorMsg was observed:
            // Send this request first
            final String toneCommand = state.getActiveZone() < ToneCommandMsg.ZONE_COMMANDS.length ?
                    ToneCommandMsg.ZONE_COMMANDS[state.getActiveZone()] : null;
            final String[] playStateQueries = new String[]{
                    // PlaybackState
                    InputSelectorMsg.ZONE_COMMANDS[state.getActiveZone()],
                    PlayStatusMsg.CODE,
                    // DeviceSettingsState
                    DimmerLevelMsg.CODE,
                    DigitalFilterMsg.CODE,
                    MusicOptimizerMsg.CODE,
                    AutoPowerMsg.CODE,
                    HdmiCecMsg.CODE,
                    PhaseMatchingBassMsg.CODE,
                    SleepSetCommandMsg.CODE,
                    GoogleCastAnalyticsMsg.CODE,
                    SpeakerACommandMsg.ZONE_COMMANDS[state.getActiveZone()],
                    SpeakerBCommandMsg.ZONE_COMMANDS[state.getActiveZone()],
                    // SoundControlState
                    AudioMutingMsg.ZONE_COMMANDS[state.getActiveZone()],
                    MasterVolumeMsg.ZONE_COMMANDS[state.getActiveZone()],
                    toneCommand,
                    SubwooferLevelCommandMsg.CODE,
                    CenterLevelCommandMsg.CODE,
                    ListeningModeMsg.CODE,
                    DirectCommandMsg.CODE,
                    // RadioState
                    PresetCommandMsg.ZONE_COMMANDS[state.getActiveZone()],
                    TuningCommandMsg.ZONE_COMMANDS[state.getActiveZone()]
            };
            sendQueries(playStateQueries, "requesting play state...");
            requestListState();
            return true;
        }

        // For some models, it does seem that the listening mode is enabled some
        // seconds after power on - as though it's got things to initialize before
        // turning on the audio circuits. The initialization time is unknown.
        // The solution is to periodically send a constant number of requests
        // (for example 5 requests) with time interval 1 second until listening
        // mode still be unknown.
        if (msg instanceof ListeningModeMsg &&
                ((ListeningModeMsg) msg).getMode() == ListeningModeMsg.Mode.MODE_FF &&
                listeningModeRequests.get() < MAX_LISTENING_MODE_REQUESTS &&
                listeningModeQueue.isEmpty())
        {
            final Timer t = new Timer();
            listeningModeQueue.add(t);
            t.schedule(new java.util.TimerTask()
            {
                @Override
                public void run()
                {
                    listeningModeQueue.poll();
                    final String[] lmQueries = new String[]{ ListeningModeMsg.CODE };
                    sendQueries(lmQueries, "re-requesting LM state ["
                            + listeningModeRequests.addAndGet(1) + "]...");
                }
            }, LISTENING_MODE_DELAY);
        }

        if (msg instanceof InputSelectorMsg && state.isCdInput())
        {
            final String[] cdStateQueries = new String[]{ PlayStatusMsg.CD_CODE };
            sendQueries(cdStateQueries, "requesting CD state...");
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
            else if (!state.isPopupMode())
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

        // check privacy policy but do not accept it automatically
        if (msg instanceof PrivacyPolicyStatusMsg)
        {
            final PrivacyPolicyStatusMsg ppMsg = (PrivacyPolicyStatusMsg) msg;
            if (!ppMsg.isPolicySet(PrivacyPolicyStatusMsg.Status.ONKYO))
            {
                Logging.info(this, "ONKYO policy is not accepted");
            }
            if (!ppMsg.isPolicySet(PrivacyPolicyStatusMsg.Status.GOOGLE))
            {
                Logging.info(this, "GOOGLE policy is not accepted");
            }
            if (!ppMsg.isPolicySet(PrivacyPolicyStatusMsg.Status.SUE))
            {
                Logging.info(this, "SUE policy is not accepted");
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
                || liMsg.getUiType() == ListTitleInfoMsg.UIType.POPUP)
        {
            Logging.info(this, "requesting XML list state skipped");
        }
        else if (liMsg.isXmlListTopService()
                || liMsg.getNumberOfLayers() > 0
                || liMsg.getUiType() == ListTitleInfoMsg.UIType.MENU)
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

    public void sendQueries(final String[] queries, final String purpose)
    {
        Logging.info(this, purpose);
        for (String code : queries)
        {
            if (code == null)
            {
                continue;
            }
            messageChannel.sendMessage(
                    new EISCPMessage(code, EISCPMessage.QUERY));
        }
    }

    public void sendTrackCmd(OperationCommandMsg.Command cmd, boolean doReturn)
    {
        final OperationCommandMsg msg = new OperationCommandMsg(
                ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE, cmd.toString());
        sendTrackMsg(msg, doReturn);
    }

    public void sendTrackMsg(final OperationCommandMsg msg, boolean doReturn)
    {
        Logging.info(this, "sending track cmd: " + msg.toString());
        if (!state.isPlaybackMode())
        {
            messageChannel.sendMessage(LIST_MSG.getCmdMsg());
        }
        messageChannel.sendMessage(msg.getCmdMsg());
        if (doReturn)
        {
            messageChannel.sendMessage(LIST_MSG.getCmdMsg());
        }
    }

    public void inform(BroadcastResponseMsg message)
    {
        inputQueue.add(message);
    }

    private void handleMultiroom()
    {
        for (BroadcastResponseMsg msg : deviceList.getDevices())
        {
            if (msg.getHost() == null)
            {
                continue;
            }
            if (msg.getHost().equals(messageChannel.getSourceHost()))
            {
                continue;
            }
            if (multiroomChannels.containsKey(msg.getHost()))
            {
                continue;
            }
            Logging.info(this, "connecting to multiroom device: " + msg.getHostAndPort());
            final MessageChannel m = new MessageChannel(connectionState, inputQueue);
            for (String code : multiroomQueries)
            {
                m.addAllowedMessage(code);
                m.sendMessage(new EISCPMessage(code, EISCPMessage.QUERY));
            }

            if (m.connectToServer(msg.getHost(), msg.getPort()))
            {
                multiroomChannels.put(msg.getHost(), m);
                m.start();
            }
        }
    }

    public void changeMasterVolume(@NonNull final String soundControlStr, boolean isUp)
    {
        final State.SoundControlType soundControl = state.soundControlType(
                soundControlStr, state.getActiveZoneInfo());

        switch (soundControl)
        {
        case DEVICE_BUTTONS:
            sendMessage(new MasterVolumeMsg(getState().getActiveZone(), isUp ?
                    MasterVolumeMsg.Command.UP :
                    MasterVolumeMsg.Command.DOWN));
            break;
        case RI_AMP:
            sendMessage(new AmpOperationCommandMsg(isUp ?
                    AmpOperationCommandMsg.Command.MVLUP.getCode() :
                    AmpOperationCommandMsg.Command.MVLDOWN.getCode()));
            break;
        default:
            // Nothing to do
            break;
        }
    }
}
