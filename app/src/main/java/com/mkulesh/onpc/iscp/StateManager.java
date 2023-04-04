/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2022 by Mikhail Kulesh
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

import com.mkulesh.onpc.config.CfgFavoriteShortcuts;
import com.mkulesh.onpc.iscp.messages.AlbumNameMsg;
import com.mkulesh.onpc.iscp.messages.AmpOperationCommandMsg;
import com.mkulesh.onpc.iscp.messages.ArtistNameMsg;
import com.mkulesh.onpc.iscp.messages.AudioInformationMsg;
import com.mkulesh.onpc.iscp.messages.AudioMutingMsg;
import com.mkulesh.onpc.iscp.messages.AutoPowerMsg;
import com.mkulesh.onpc.iscp.messages.BroadcastResponseMsg;
import com.mkulesh.onpc.iscp.messages.CenterLevelCommandMsg;
import com.mkulesh.onpc.iscp.messages.RadioStationNameMsg;
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
import com.mkulesh.onpc.iscp.messages.LateNightCommandMsg;
import com.mkulesh.onpc.iscp.messages.ListInfoMsg;
import com.mkulesh.onpc.iscp.messages.ListTitleInfoMsg;
import com.mkulesh.onpc.iscp.messages.ListeningModeMsg;
import com.mkulesh.onpc.iscp.messages.MasterVolumeMsg;
import com.mkulesh.onpc.iscp.messages.MenuStatusMsg;
import com.mkulesh.onpc.iscp.messages.MultiroomDeviceInformationMsg;
import com.mkulesh.onpc.iscp.messages.MusicOptimizerMsg;
import com.mkulesh.onpc.iscp.messages.NetworkStandByMsg;
import com.mkulesh.onpc.iscp.messages.OperationCommandMsg;
import com.mkulesh.onpc.iscp.messages.PhaseMatchingBassMsg;
import com.mkulesh.onpc.iscp.messages.PlayStatusMsg;
import com.mkulesh.onpc.iscp.messages.PowerStatusMsg;
import com.mkulesh.onpc.iscp.messages.PresetCommandMsg;
import com.mkulesh.onpc.iscp.messages.PresetMemoryMsg;
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
import com.mkulesh.onpc.iscp.messages.VideoInformationMsg;
import com.mkulesh.onpc.iscp.messages.XmlListInfoMsg;
import com.mkulesh.onpc.iscp.scripts.MessageScript;
import com.mkulesh.onpc.iscp.scripts.MessageScriptIf;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.util.ArrayList;
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
    private final AtomicBoolean requestRIonPreset = new AtomicBoolean();
    private final HashSet<State.ChangeType> eventChanges = new HashSet<>();
    private int xmlReqId = 0;
    private ISCPMessage circlePlayQueueMsg = null;

    private final static String[] trackStateQueries = new String[]{
            ArtistNameMsg.CODE, AlbumNameMsg.CODE, TitleNameMsg.CODE,
            FileFormatMsg.CODE, TrackInfoMsg.CODE, TimeInfoMsg.CODE,
            MenuStatusMsg.CODE
    };

    private final static String[] avInfoQueries = new String[]{
            AudioInformationMsg.CODE, VideoInformationMsg.CODE
    };

    private final static String[] multiroomQueries = new String[]{
            MultiroomDeviceInformationMsg.CODE,
            FriendlyNameMsg.CODE
    };

    private final AtomicBoolean keepPlaybackMode = new AtomicBoolean();
    private final boolean useBmpImages;

    private final BlockingQueue<ISCPMessage> inputQueue = new ArrayBlockingQueue<>(MessageChannel.QUEUE_SIZE, true);

    public final static OperationCommandMsg LIST_MSG =
            new OperationCommandMsg(OperationCommandMsg.Command.LIST);
    public final static OperationCommandMsg RETURN_MSG =
            new OperationCommandMsg(OperationCommandMsg.Command.RETURN);

    // MessageScript processor
    private final ArrayList<MessageScriptIf> messageScripts;

    public StateManager(final DeviceList deviceList,
                        final ConnectionState connectionState,
                        final StateListener stateListener,
                        final String host, final int port,
                        final int zone,
                        final boolean keepPlaybackMode,
                        final String savedReceiverInformation,
                        final @NonNull ArrayList<MessageScriptIf> messageScripts) throws Exception
    {
        this.deviceList = deviceList;
        this.connectionState = connectionState;
        this.stateListener = stateListener;

        messageChannel = new MessageChannel(connectionState, inputQueue);
        if (!messageChannel.connectToServer(host, port))
        {
            throw new Exception("Cannot connect to server");
        }

        state = new State(messageChannel.getProtoType(), messageChannel.getHost(), messageChannel.getPort(), zone);

        // In LTE mode, always use BMP images instead of links since direct links
        // can be not available
        useBmpImages = !connectionState.isWifi();

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

        this.messageScripts = messageScripts;

        messageChannel.start();
        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);
        executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, (Void[]) null);

        // initial call os the message scripts
        for (MessageScriptIf script : messageScripts)
        {
            if (script.isValid())
            {
                script.start(state, messageChannel);
            }
        }
    }

    private void activateScript(final MessageScript messageScript)
    {
        for (MessageScriptIf script : messageScripts)
        {
            if (script instanceof MessageScript)
            {
                messageScripts.remove(script);
            }
        }
        if (messageScript.isValid())
        {
            messageScripts.add(messageScript);
            messageScript.start(state, messageChannel);
        }
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
        messageScripts = new ArrayList<>();

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
        Logging.info(this, "started: " + this);

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
        requestRIonPreset.set(false);

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
                    changed = messageChannel.getProtoType() == Utils.ProtoType.ISCP ?
                            processIscpMessage(msg) : processDcpMessage(msg);
                    for (MessageScriptIf script : messageScripts)
                    {
                        if (script.isValid())
                        {
                            script.processMessage(msg, state, messageChannel);
                        }
                    }
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

        Logging.info(this, "stopped: " + this);
        stateListener.onManagerStopped();
        return null;
    }

    @Override
    protected void onPostExecute(Void aVoid)
    {
        super.onPostExecute(aVoid);
        stateListener.onDeviceDisconnected();
    }

    private boolean processIscpMessage(@NonNull ISCPMessage msg)
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

        // request receiver information after radio preset is memorized
        if ((msg instanceof PresetCommandMsg || msg instanceof PresetMemoryMsg) && requestRIonPreset.get())
        {
            requestRIonPreset.set(false);
            final String[] queries = new String[]{ ReceiverInformationMsg.CODE };
            sendQueries(queries, "requesting receiver information...");
        }

        // no further message handling, if no changes are detected
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
                    LateNightCommandMsg.CODE,
                    NetworkStandByMsg.CODE,
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
                    TuningCommandMsg.ZONE_COMMANDS[state.getActiveZone()],
                    RadioStationNameMsg.CODE
            };
            sendQueries(playStateQueries, "requesting play state...");
            sendQueries(avInfoQueries, "requesting audio/video info...");
            requestListState();
        }

        if (msg instanceof InputSelectorMsg)
        {
            if (state.isCdInput())
            {
                final String[] cdStateQueries = new String[]{ PlayStatusMsg.CD_CODE };
                sendQueries(cdStateQueries, "requesting CD state...");
            }
            sendQueries(avInfoQueries, "requesting audio/video info...");
        }

        if (msg instanceof PlayStatusMsg && playStatus != state.playStatus)
        {
            if (state.isPlaying())
            {
                sendQueries(trackStateQueries, "requesting track state...");
                sendQueries(avInfoQueries, "requesting audio/video info...");
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

    private boolean processDcpMessage(ISCPMessage msg)
    {
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

        if (msg instanceof PowerStatusMsg && changed != State.ChangeType.NONE)
        {
            final String[] playStateQueries = new String[]{
                    // PlaybackState
                    InputSelectorMsg.ZONE_COMMANDS[state.getActiveZone()],
            };
            sendQueries(playStateQueries, "DCP: requesting play state...");
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
        if (liMsg.isNetTopService() || state.isRadioInput())
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

    public void sendMessageToGroup(final ISCPMessage msg)
    {
        Logging.info(this, "sending message to group: " + msg.toString());
        for (MessageChannel m : multiroomChannels.values())
        {
            m.sendMessage(msg.getCmdMsg());
        }
        messageChannel.sendMessage(msg.getCmdMsg());
    }

    public void sendPlayQueueMsg(ISCPMessage msg, boolean repeat)
    {
        if (msg == null)
        {
            return;
        }
        if (repeat)
        {
            Logging.info(this, "starting repeat mode: " + msg);
            circlePlayQueueMsg = msg;
        }
        requestXmlList.set(true);
        messageChannel.sendMessage(msg.getCmdMsg());
    }

    public void requestSkipNextTimeMsg(final int number)
    {
        skipNextTimeMsg.set(number);
    }

    public void requestRIonPreset(final boolean flag)
    {
        requestRIonPreset.set(flag);
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
            if (!msg.isValidConnection())
            {
                continue;
            }
            if (msg.fromHost(messageChannel))
            {
                continue;
            }
            if (multiroomChannels.containsKey(msg.getHostAndPort()))
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
                multiroomChannels.put(msg.getHostAndPort(), m);
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
        case DEVICE_SLIDER:
        case DEVICE_BTN_SLIDER:
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

    public void applyShortcut(@NonNull final Context context, @NonNull final CfgFavoriteShortcuts.Shortcut shortcut)
    {
        Logging.info(this, "selected favorite shortcut: " + shortcut);
        final String data = shortcut.toScript(context, state);
        final MessageScript messageScript = new MessageScript(context, data);
        activateScript(messageScript);
    }
}
