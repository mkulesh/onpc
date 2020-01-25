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

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.messages.AlbumNameMsg;
import com.mkulesh.onpc.iscp.messages.ArtistNameMsg;
import com.mkulesh.onpc.iscp.messages.AudioMutingMsg;
import com.mkulesh.onpc.iscp.messages.AutoPowerMsg;
import com.mkulesh.onpc.iscp.messages.CdPlayerOperationCommandMsg;
import com.mkulesh.onpc.iscp.messages.CenterLevelCommandMsg;
import com.mkulesh.onpc.iscp.messages.CustomPopupMsg;
import com.mkulesh.onpc.iscp.messages.DigitalFilterMsg;
import com.mkulesh.onpc.iscp.messages.DimmerLevelMsg;
import com.mkulesh.onpc.iscp.messages.DirectCommandMsg;
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
import com.mkulesh.onpc.iscp.messages.MultiroomChannelSettingMsg;
import com.mkulesh.onpc.iscp.messages.MultiroomDeviceInformationMsg;
import com.mkulesh.onpc.iscp.messages.MusicOptimizerMsg;
import com.mkulesh.onpc.iscp.messages.NetworkServiceMsg;
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
import com.mkulesh.onpc.iscp.messages.XmlListItemMsg;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.io.ByteArrayOutputStream;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;

public class State
{
    // Changes
    public enum ChangeType
    {
        NONE,
        COMMON,
        TIME_SEEK,
        MEDIA_ITEMS,
        RECEIVER_INFO,
        MULTIROOM_INFO
    }

    // main host
    private final String host;
    private final int port;

    // Receiver Information
    public String receiverInformation = "";
    String friendlyName = "";
    public Map<String, String> deviceProperties = new HashMap<>();
    public HashMap<String, ReceiverInformationMsg.NetworkService> networkServices = new HashMap<>();
    private final int activeZone;
    List<ReceiverInformationMsg.Zone> zones = new ArrayList<>();
    public final List<ReceiverInformationMsg.Selector> deviceSelectors = new ArrayList<>();
    private Set<String> controlList = new HashSet<>();
    public HashMap<String, ReceiverInformationMsg.ToneControl> toneControls = new HashMap<>();

    //Common
    PowerStatusMsg.PowerStatus powerStatus = PowerStatusMsg.PowerStatus.STB;
    public FirmwareUpdateMsg.Status firmwareStatus = FirmwareUpdateMsg.Status.NONE;
    public InputSelectorMsg.InputType inputType = InputSelectorMsg.InputType.NONE;

    // Settings
    public DimmerLevelMsg.Level dimmerLevel = DimmerLevelMsg.Level.NONE;
    public DigitalFilterMsg.Filter digitalFilter = DigitalFilterMsg.Filter.NONE;
    public AudioMutingMsg.Status audioMuting = AudioMutingMsg.Status.NONE;
    public MusicOptimizerMsg.Status musicOptimizer = MusicOptimizerMsg.Status.NONE;
    public AutoPowerMsg.Status autoPower = AutoPowerMsg.Status.NONE;
    public HdmiCecMsg.Status hdmiCec = HdmiCecMsg.Status.NONE;
    public DirectCommandMsg.Status toneDirect = DirectCommandMsg.Status.NONE;
    public PhaseMatchingBassMsg.Status phaseMatchingBass = PhaseMatchingBassMsg.Status.NONE;
    public int sleepTime = SleepSetCommandMsg.NOT_APPLICABLE;
    public SpeakerACommandMsg.Status speakerA = SpeakerACommandMsg.Status.NONE;
    public SpeakerBCommandMsg.Status speakerB = SpeakerBCommandMsg.Status.NONE;

    // Sound control
    public enum SoundControlType
    {
        DEVICE,
        RI_AMP,
        NONE
    }

    public ListeningModeMsg.Mode listeningMode = ListeningModeMsg.Mode.MODE_FF;
    public int volumeLevel = MasterVolumeMsg.NO_LEVEL;
    public int bassLevel = ToneCommandMsg.NO_LEVEL;
    public int trebleLevel = ToneCommandMsg.NO_LEVEL;
    public int subwooferLevel = SubwooferLevelCommandMsg.NO_LEVEL;
    public int centerLevel = CenterLevelCommandMsg.NO_LEVEL;

    // Google cast
    public String googleCastVersion = "N/A";
    public GoogleCastAnalyticsMsg.Status googleCastAnalytics = GoogleCastAnalyticsMsg.Status.NONE;
    private String privacyPolicy = PrivacyPolicyStatusMsg.Status.NONE.getCode();

    // Track info (default values are set in clearTrackInfo method)
    public Bitmap cover;
    public String album, artist, title, currentTime, maxTime, fileFormat;
    Integer currentTrack = null, maxTrack = null;
    private ByteArrayOutputStream coverBuffer = null;

    // Radio
    public List<ReceiverInformationMsg.Preset> presetList = new ArrayList<>();
    public int preset = PresetCommandMsg.NO_PRESET;
    private String frequency = "";

    // Playback
    public PlayStatusMsg.PlayStatus playStatus = PlayStatusMsg.PlayStatus.STOP;
    public PlayStatusMsg.RepeatStatus repeatStatus = PlayStatusMsg.RepeatStatus.OFF;
    public PlayStatusMsg.ShuffleStatus shuffleStatus = PlayStatusMsg.ShuffleStatus.OFF;
    public MenuStatusMsg.TimeSeek timeSeek = MenuStatusMsg.TimeSeek.ENABLE;
    public MenuStatusMsg.TrackMenu trackMenu = MenuStatusMsg.TrackMenu.ENABLE;
    private boolean trackMenuReceived = false;
    public MenuStatusMsg.Feed positiveFeed = MenuStatusMsg.Feed.DISABLE;
    public MenuStatusMsg.Feed negativeFeed = MenuStatusMsg.Feed.DISABLE;
    public ServiceType serviceIcon = ServiceType.UNKNOWN; // service that is currently playing

    // Navigation
    public ServiceType serviceType = null; // service that is currently selected (may differs from currently playing)
    ListTitleInfoMsg.LayerInfo layerInfo = null;
    private ListTitleInfoMsg.UIType uiType = null;
    int numberOfLayers = 0;
    public int numberOfItems = 0;
    public String titleBar = "";
    private final List<XmlListItemMsg> mediaItems = new ArrayList<>();
    final List<NetworkServiceMsg> serviceItems = new ArrayList<>();
    private final List<String> listInfoItems = new ArrayList<>();

    // Multiroom
    public String multiroomDeviceId = "";
    public final Map<String, MultiroomDeviceInformationMsg> multiroomLayout = new HashMap<>();
    public final Map<String, String> multiroomNames = new HashMap<>();
    public MultiroomDeviceInformationMsg.ChannelType multiroomChannel = MultiroomDeviceInformationMsg.ChannelType.NONE;

    // Popup
    public CustomPopupMsg popup = null;

    State(final String host, int activeZone)
    {
        this(host, activeZone, 0);  // TODO check if port should be part of state in general
    }

    State(final String host, int activeZone, int port){
        this.host = host;
        this.activeZone = activeZone;
        this.port = port;
        clearTrackInfo();
    }

    @NonNull
    @Override
    public String toString()
    {
        return powerStatus.toString() + "; activeZone=" + activeZone;
    }

    public List<ReceiverInformationMsg.Zone> getZones()
    {
        return zones;
    }

    public int getActiveZone()
    {
        return activeZone;
    }

    public int getPort() {
        return port;
    }

    public String getHost(){
        return host; // TODO we should probably use the MAC instead
    }


    public boolean isExtendedZone()
    {
        return activeZone < zones.size() && activeZone != ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE;
    }

    public ReceiverInformationMsg.Zone getActiveZoneInfo()
    {
        return activeZone < zones.size() ? zones.get(activeZone) : null;
    }

    public boolean isOn()
    {
        return powerStatus == PowerStatusMsg.PowerStatus.ON;
    }

    public boolean isPlaying()
    {
        return playStatus != PlayStatusMsg.PlayStatus.STOP;
    }

    public boolean isPlaybackMode()
    {
        return uiType == ListTitleInfoMsg.UIType.PLAYBACK;
    }

    private boolean isPopupMode()
    {
        return uiType == ListTitleInfoMsg.UIType.POPUP;
    }

    public boolean isMenuMode()
    {
        return uiType == ListTitleInfoMsg.UIType.MENU;
    }

    @NonNull
    public String getModel()
    {
        final String m = deviceProperties.get("model");
        return m == null ? "" : m;
    }

    @NonNull
    public String getDeviceName(boolean useFriendlyName)
    {
        if (useFriendlyName)
        {
            // name from FriendlyNameMsg (NFN)
            if (friendlyName != null && !friendlyName.isEmpty())
            {
                return friendlyName;
            }
            // fallback to ReceiverInformationMsg
            final String name = deviceProperties.get("friendlyname");
            if (name != null)
            {
                return name;
            }
        }
        // fallback to model from ReceiverInformationMsg
        {
            final String name = deviceProperties.get("model");
            if (name != null)
            {
                return name;
            }
        }
        return "";
    }

    public void createDefaultReceiverInfo(final Context context)
    {
        // By default, add all possible device selectors
        deviceSelectors.clear();
        for (InputSelectorMsg.InputType it : InputSelectorMsg.InputType.values())
        {
            if (it != InputSelectorMsg.InputType.NONE)
            {
                final ReceiverInformationMsg.Selector s = new ReceiverInformationMsg.Selector(
                        it.getCode(), context.getString(it.getDescriptionId()),
                        ReceiverInformationMsg.ALL_ZONE, it.getCode(), false);
                deviceSelectors.add(s);
            }
        }
        // Add default bass and treble limits
        toneControls.clear();
        toneControls.put(ToneCommandMsg.BASS_KEY,
                new ReceiverInformationMsg.ToneControl(ToneCommandMsg.BASS_KEY, -10, 10, 2));
        toneControls.put(ToneCommandMsg.TREBLE_KEY,
                new ReceiverInformationMsg.ToneControl(ToneCommandMsg.TREBLE_KEY, -10, 10, 2));
        toneControls.put(SubwooferLevelCommandMsg.KEY,
                new ReceiverInformationMsg.ToneControl(SubwooferLevelCommandMsg.KEY, -15, 12, 1));
        toneControls.put(CenterLevelCommandMsg.KEY,
                new ReceiverInformationMsg.ToneControl(CenterLevelCommandMsg.KEY, -12, 12, 1));
        // Default zones:
        zones = ReceiverInformationMsg.getDefaultZones();
    }

    boolean isControlExists(@NonNull final String control)
    {
        return controlList != null && controlList.contains(control);
    }

    private void clearTrackInfo()
    {
        cover = null;
        album = "";
        artist = "";
        title = "";
        fileFormat = "";
        currentTime = TimeInfoMsg.INVALID_TIME;
        maxTime = TimeInfoMsg.INVALID_TIME;
        currentTrack = null;
        maxTrack = null;
    }

    private boolean isAnotherHost(final ISCPMessage msg)
    {
        return msg.sourceHost != null && !msg.sourceHost.equals(host);
    }

    public ChangeType update(ISCPMessage msg)
    {
        if (!(msg instanceof TimeInfoMsg) && !(msg instanceof JacketArtMsg))
        {
            Logging.info(msg, "<< " + msg.toString());
            if (msg.isMultiline())
            {
                msg.logParameters();
            }
        }
        else if (msg instanceof TimeInfoMsg && Logging.isTimeMsgEnabled())
        {
            Logging.info(msg, "<< " + msg.toString());
        }

        //Common
        if (msg instanceof PowerStatusMsg)
        {
            return isCommonChange(process((PowerStatusMsg) msg));
        }
        if (msg instanceof FirmwareUpdateMsg)
        {
            return isCommonChange(process((FirmwareUpdateMsg) msg));
        }
        if (msg instanceof ReceiverInformationMsg)
        {
            return process((ReceiverInformationMsg) msg, true) ? ChangeType.RECEIVER_INFO : ChangeType.NONE;
        }
        if (msg instanceof FriendlyNameMsg)
        {
            return isCommonChange(process((FriendlyNameMsg) msg));
        }

        // Settings
        if (msg instanceof DimmerLevelMsg)
        {
            return isCommonChange(process((DimmerLevelMsg) msg));
        }
        if (msg instanceof DigitalFilterMsg)
        {
            return isCommonChange(process((DigitalFilterMsg) msg));
        }
        if (msg instanceof AudioMutingMsg)
        {
            return isCommonChange(process((AudioMutingMsg) msg));
        }
        if (msg instanceof MusicOptimizerMsg)
        {
            return isCommonChange(process((MusicOptimizerMsg) msg));
        }
        if (msg instanceof AutoPowerMsg)
        {
            return isCommonChange(process((AutoPowerMsg) msg));
        }
        if (msg instanceof PhaseMatchingBassMsg)
        {
            return isCommonChange(process((PhaseMatchingBassMsg) msg));
        }
        if (msg instanceof SleepSetCommandMsg)
        {
            return isCommonChange(process((SleepSetCommandMsg) msg));
        }
        if (msg instanceof HdmiCecMsg)
        {
            return isCommonChange(process((HdmiCecMsg) msg));
        }
        if (msg instanceof DirectCommandMsg)
        {
            return isCommonChange(process((DirectCommandMsg) msg));
        }
        if (msg instanceof SpeakerACommandMsg)
        {
            return isCommonChange(process((SpeakerACommandMsg) msg));
        }
        if (msg instanceof SpeakerBCommandMsg)
        {
            return isCommonChange(process((SpeakerBCommandMsg) msg));
        }

        // Sound control
        if (msg instanceof ListeningModeMsg)
        {
            return isCommonChange(process((ListeningModeMsg) msg));
        }
        if (msg instanceof MasterVolumeMsg)
        {
            return isCommonChange(process((MasterVolumeMsg) msg));
        }
        if (msg instanceof ToneCommandMsg)
        {
            return isCommonChange(process((ToneCommandMsg) msg));
        }
        if (msg instanceof SubwooferLevelCommandMsg)
        {
            return isCommonChange(process((SubwooferLevelCommandMsg) msg));
        }
        if (msg instanceof CenterLevelCommandMsg)
        {
            return isCommonChange(process((CenterLevelCommandMsg) msg));
        }

        // Google cast
        if (msg instanceof GoogleCastVersionMsg)
        {
            return isCommonChange(process((GoogleCastVersionMsg) msg));
        }
        if (msg instanceof GoogleCastAnalyticsMsg)
        {
            return isCommonChange(process((GoogleCastAnalyticsMsg) msg));
        }
        if (msg instanceof PrivacyPolicyStatusMsg)
        {
            return isCommonChange(process((PrivacyPolicyStatusMsg) msg));
        }

        // Track info
        if (msg instanceof JacketArtMsg)
        {
            return isCommonChange(process((JacketArtMsg) msg));
        }
        if (msg instanceof AlbumNameMsg)
        {
            return isCommonChange(process((AlbumNameMsg) msg));
        }
        if (msg instanceof ArtistNameMsg)
        {
            return isCommonChange(process((ArtistNameMsg) msg));
        }
        if (msg instanceof TitleNameMsg)
        {
            return isCommonChange(process((TitleNameMsg) msg));
        }
        if (msg instanceof FileFormatMsg)
        {
            return isCommonChange(process((FileFormatMsg) msg));
        }
        if (msg instanceof TimeInfoMsg)
        {
            return process((TimeInfoMsg) msg) ? ChangeType.TIME_SEEK : ChangeType.NONE;
        }
        if (msg instanceof TrackInfoMsg)
        {
            return isCommonChange(process((TrackInfoMsg) msg));
        }

        // Radio
        if (msg instanceof PresetCommandMsg)
        {
            return process((PresetCommandMsg) msg) ? ChangeType.MEDIA_ITEMS : ChangeType.NONE;
        }
        if (msg instanceof TuningCommandMsg)
        {
            return isCommonChange(process((TuningCommandMsg) msg));
        }

        // Playback
        if (msg instanceof PlayStatusMsg)
        {
            return isCommonChange(process((PlayStatusMsg) msg));
        }
        if (msg instanceof MenuStatusMsg)
        {
            return isCommonChange(process((MenuStatusMsg) msg));
        }

        // Navigation
        if (msg instanceof CustomPopupMsg)
        {
            return isCommonChange(process((CustomPopupMsg) msg));
        }
        if (msg instanceof InputSelectorMsg)
        {
            return process((InputSelectorMsg) msg) ? ChangeType.MEDIA_ITEMS : ChangeType.NONE;
        }
        if (msg instanceof ListTitleInfoMsg)
        {
            return process((ListTitleInfoMsg) msg) ? ChangeType.MEDIA_ITEMS : ChangeType.NONE;
        }
        if (msg instanceof XmlListInfoMsg)
        {
            return process((XmlListInfoMsg) msg) ? ChangeType.MEDIA_ITEMS : ChangeType.NONE;
        }
        if (msg instanceof ListInfoMsg)
        {
            return process((ListInfoMsg) msg) ? ChangeType.MEDIA_ITEMS : ChangeType.NONE;
        }

        // Multiroom
        if (msg instanceof MultiroomDeviceInformationMsg)
        {
            return process((MultiroomDeviceInformationMsg) msg) ? ChangeType.MULTIROOM_INFO : ChangeType.NONE;
        }
        if (msg instanceof MultiroomChannelSettingMsg)
        {
            return isCommonChange(process((MultiroomChannelSettingMsg) msg));
        }

        return ChangeType.NONE;
    }

    private ChangeType isCommonChange(boolean change)
    {
        return change ? ChangeType.COMMON : ChangeType.NONE;
    }

    private boolean process(PowerStatusMsg msg)
    {
        final boolean changed = msg.getPowerStatus() != powerStatus;
        powerStatus = msg.getPowerStatus();
        if (changed && !isOn())
        {
            clearItems();
        }
        return changed;
    }

    private boolean process(FirmwareUpdateMsg msg)
    {
        final boolean changed = firmwareStatus != msg.getStatus();
        firmwareStatus = msg.getStatus();
        return changed;
    }

    boolean process(ReceiverInformationMsg msg, boolean showInfo)
    {
        try
        {
            msg.parseXml(showInfo);
            receiverInformation = msg.getData();
            deviceProperties = msg.getDeviceProperties();
            networkServices = msg.getNetworkServices();
            zones = msg.getZones();
            deviceSelectors.clear();
            for (ReceiverInformationMsg.Selector s : msg.getDeviceSelectors())
            {
                if (s.isActiveForZone(activeZone))
                {
                    deviceSelectors.add(s);
                }
            }
            controlList = msg.getControlList();
            toneControls = msg.getToneControls();
            presetList = msg.getPresetList();

            return true;
        }
        catch (Exception e)
        {
            Logging.info(msg, "Can not parse XML: " + e.getLocalizedMessage());
        }
        return false;
    }

    private boolean process(FriendlyNameMsg msg)
    {
        multiroomNames.put(msg.sourceHost, msg.getFriendlyName());
        if (!isAnotherHost(msg))
        {
            final boolean changed = !friendlyName.equals(msg.getFriendlyName());
            friendlyName = msg.getFriendlyName();
            return changed;
        }
        return false;
    }

    private boolean process(InputSelectorMsg msg)
    {
        final boolean changed = inputType != msg.getInputType();
        inputType = msg.getInputType();
        if (!inputType.isMediaList())
        {
            Logging.info(msg, "New selector is not a media list. Clearing...");
            clearTrackInfo();
            serviceType = null;
            clearItems();
        }

        if (isSimpleInput())
        {
            timeSeek = MenuStatusMsg.TimeSeek.DISABLE;
            serviceIcon = ServiceType.UNKNOWN;
        }

        return changed;
    }

    private boolean process(DimmerLevelMsg msg)
    {
        final boolean changed = dimmerLevel != msg.getLevel();
        dimmerLevel = msg.getLevel();
        return changed;
    }

    private boolean process(DigitalFilterMsg msg)
    {
        final boolean changed = digitalFilter != msg.getFilter();
        digitalFilter = msg.getFilter();
        return changed;
    }

    private boolean process(AudioMutingMsg msg)
    {
        final boolean changed = audioMuting != msg.getStatus();
        audioMuting = msg.getStatus();
        return changed;
    }

    private boolean process(ListeningModeMsg msg)
    {
        final boolean changed = listeningMode != msg.getMode();
        listeningMode = msg.getMode();
        return changed;
    }

    private boolean process(MasterVolumeMsg msg)
    {
        final boolean changed = volumeLevel != msg.getVolumeLevel();
        volumeLevel = msg.getVolumeLevel();
        return changed;
    }

    private boolean process(ToneCommandMsg msg)
    {
        final boolean changed =
                (msg.getBassLevel() != ToneCommandMsg.NO_LEVEL && bassLevel != msg.getBassLevel()) ||
                (msg.getTrebleLevel() != ToneCommandMsg.NO_LEVEL && trebleLevel != msg.getTrebleLevel());
        bassLevel = msg.getBassLevel();
        trebleLevel = msg.getTrebleLevel();
        return changed;
    }

    private boolean process(SubwooferLevelCommandMsg msg)
    {
        final boolean changed = subwooferLevel != msg.getLevel();
        subwooferLevel = msg.getLevel();
        return changed;
    }

    private boolean process(CenterLevelCommandMsg msg)
    {
        final boolean changed = centerLevel != msg.getLevel();
        centerLevel = msg.getLevel();
        return changed;
    }

    private boolean process(PresetCommandMsg msg)
    {
        final boolean changed = preset != msg.getPreset();
        preset = msg.getPreset();
        return changed;
    }

    private boolean process(TuningCommandMsg msg)
    {
        final boolean changed = !msg.getFrequency().equals(frequency);
        frequency = msg.getFrequency();
        return changed;
    }

    private boolean process(MusicOptimizerMsg msg)
    {
        final boolean changed = musicOptimizer != msg.getStatus();
        musicOptimizer = msg.getStatus();
        return changed;
    }

    private boolean process(AutoPowerMsg msg)
    {
        final boolean changed = autoPower != msg.getStatus();
        autoPower = msg.getStatus();
        return changed;
    }

    private boolean process(HdmiCecMsg msg)
    {
        final boolean changed = hdmiCec != msg.getStatus();
        hdmiCec = msg.getStatus();
        return changed;
    }

    private boolean process(DirectCommandMsg msg)
    {
        final boolean changed = toneDirect != msg.getStatus();
        toneDirect = msg.getStatus();
        return changed;
    }

    private boolean process(PhaseMatchingBassMsg msg)
    {
        final boolean changed = phaseMatchingBass != msg.getStatus();
        phaseMatchingBass = msg.getStatus();
        return changed;
    }

    private boolean process(SleepSetCommandMsg msg)
    {
        final boolean changed = sleepTime != msg.getSleepTime();
        sleepTime = msg.getSleepTime();
        return changed;
    }

    private boolean process(SpeakerACommandMsg msg)
    {
        final boolean changed = speakerA != msg.getStatus();
        speakerA = msg.getStatus();
        return changed;
    }

    private boolean process(SpeakerBCommandMsg msg)
    {
        final boolean changed = speakerB != msg.getStatus();
        speakerB = msg.getStatus();
        return changed;
    }

    private boolean process(GoogleCastVersionMsg msg)
    {
        final boolean changed = !msg.getData().equals(googleCastVersion);
        googleCastVersion = msg.getData();
        return changed;
    }

    private boolean process(GoogleCastAnalyticsMsg msg)
    {
        final boolean changed = googleCastAnalytics != msg.getStatus();
        googleCastAnalytics = msg.getStatus();
        return changed;
    }

    private boolean process(PrivacyPolicyStatusMsg msg)
    {
        final boolean changed = !msg.getData().equals(privacyPolicy);
        privacyPolicy = msg.getData();
        return changed;
    }

    private boolean process(JacketArtMsg msg)
    {
        if (msg.getImageType() == JacketArtMsg.ImageType.URL)
        {
            Logging.info(msg, "<< " + msg.toString());
            cover = msg.loadFromUrl();
            return true;
        }
        else if (msg.getRawData() != null)
        {
            final byte[] in = msg.getRawData();
            if (msg.getPacketFlag() == JacketArtMsg.PacketFlag.START)
            {
                Logging.info(msg, "<< " + msg.toString());
                coverBuffer = new ByteArrayOutputStream();
            }
            if (coverBuffer != null)
            {
                coverBuffer.write(in, 0, in.length);
            }
            if (msg.getPacketFlag() == JacketArtMsg.PacketFlag.END)
            {
                Logging.info(msg, "<< " + msg.toString());
                cover = msg.loadFromBuffer(coverBuffer);
                coverBuffer = null;
                return true;
            }
        }
        else
        {
            Logging.info(msg, "<< " + msg.toString());
        }
        return false;
    }

    private boolean process(AlbumNameMsg msg)
    {
        final boolean changed = !msg.getData().equals(album);
        album = msg.getData();
        return changed;
    }

    private boolean process(ArtistNameMsg msg)
    {
        final boolean changed = !msg.getData().equals(artist);
        artist = msg.getData();
        return changed;
    }

    private boolean process(TitleNameMsg msg)
    {
        final boolean changed = !msg.getData().equals(title);
        title = msg.getData();
        return changed;
    }

    private boolean process(TimeInfoMsg msg)
    {
        final boolean changed = !msg.getCurrentTime().equals(currentTime)
                || !msg.getMaxTime().equals(maxTime);
        currentTime = msg.getCurrentTime();
        maxTime = msg.getMaxTime();
        return changed;
    }

    private boolean process(TrackInfoMsg msg)
    {
        final boolean changed = !isEqual(currentTrack, msg.getCurrentTrack())
                || !isEqual(maxTrack, msg.getMaxTrack());
        currentTrack = msg.getCurrentTrack();
        maxTrack = msg.getMaxTrack();
        return changed;
    }

    private boolean isEqual(Integer a, Integer b)
    {
        if (a == null && b == null)
        {
            return true;
        }
        if ((a == null && b != null) || (a != null && b == null))
        {
            return false;
        }
        return a.equals(b);
    }

    private boolean process(FileFormatMsg msg)
    {
        final boolean changed = !msg.getFullFormat().equals(fileFormat);
        fileFormat = msg.getFullFormat();
        return changed;
    }

    private boolean process(PlayStatusMsg msg)
    {
        final boolean changed = msg.getPlayStatus() != playStatus
                || msg.getRepeatStatus() != repeatStatus
                || msg.getShuffleStatus() != shuffleStatus;
        playStatus = msg.getPlayStatus();
        repeatStatus = msg.getRepeatStatus();
        shuffleStatus = msg.getShuffleStatus();
        return changed;
    }

    private boolean process(MenuStatusMsg msg)
    {
        final boolean changed = timeSeek != msg.getTimeSeek()
                || trackMenu != msg.getTrackMenu()
                || serviceIcon != msg.getServiceIcon()
                || positiveFeed != msg.getPositiveFeed()
                || negativeFeed != msg.getNegativeFeed();
        timeSeek = msg.getTimeSeek();
        trackMenu = msg.getTrackMenu();
        serviceIcon = msg.getServiceIcon();
        positiveFeed = msg.getPositiveFeed();
        negativeFeed = msg.getNegativeFeed();
        return changed;
    }

    private boolean process(ListTitleInfoMsg msg)
    {
        boolean changed = false;
        if (serviceType != msg.getServiceType())
        {
            serviceType = msg.getServiceType();
            clearItems();
            changed = true;
        }
        if (layerInfo != msg.getLayerInfo())
        {
            layerInfo = msg.getLayerInfo();
            changed = true;
        }
        if (uiType != msg.getUiType())
        {
            uiType = msg.getUiType();
            clearItems();
            changed = true;
        }
        if (!titleBar.equals(msg.getTitleBar()))
        {
            titleBar = msg.getTitleBar();
            changed = true;
        }
        if (numberOfLayers != msg.getNumberOfLayers())
        {
            numberOfLayers = msg.getNumberOfLayers();
            changed = true;
        }
        if (numberOfItems != msg.getNumberOfItems())
        {
            numberOfItems = msg.getNumberOfItems();
            changed = true;
        }
        return changed;
    }

    private void clearItems()
    {
        synchronized (mediaItems)
        {
            trackMenuReceived = false;
            mediaItems.clear();
        }
        synchronized (serviceItems)
        {
            serviceItems.clear();
        }
    }

    public List<XmlListItemMsg> cloneMediaItems()
    {
        synchronized (mediaItems)
        {
            trackMenuReceived = false;
            return new ArrayList<>(mediaItems);
        }
    }

    private boolean process(XmlListInfoMsg msg)
    {
        synchronized (mediaItems)
        {
            if (!inputType.isMediaList())
            {
                mediaItems.clear();
                Logging.info(msg, "skipped: input channel " + inputType.toString() + " is not a media list");
                return true;
            }
            if (isPopupMode())
            {
                clearItems();
                Logging.info(msg, "skipped: it is a POPUP message");
                return true;
            }
            try
            {
                Logging.info(msg, "processing XmlListInfoMsg");
                msg.parseXml(mediaItems, numberOfLayers);
                if (serviceType == ServiceType.PLAYQUEUE &&
                        (currentTrack == null || maxTrack == null))
                {
                    trackInfoFromList(mediaItems);
                }
                if (uiType == ListTitleInfoMsg.UIType.MENU_LIST)
                {
                    Logging.info(this, "received track menu list with " + mediaItems.size() + " items");
                    trackMenuReceived = true;
                }
                return true;
            }
            catch (Exception e)
            {
                mediaItems.clear();
                Logging.info(msg, "Can not parse XML: " + e.getLocalizedMessage());
            }
        }
        return false;
    }

    private void trackInfoFromList(final List<XmlListItemMsg> list)
    {
        for (int i = 0; i < list.size(); i++)
        {
            final XmlListItemMsg m = list.get(i);
            if (m.getIcon() == XmlListItemMsg.Icon.PLAY)
            {
                currentTrack = i + 1;
                maxTrack = list.size();
                return;
            }
        }
    }

    public List<NetworkServiceMsg> cloneServiceItems()
    {
        synchronized (serviceItems)
        {
            return new ArrayList<>(serviceItems);
        }
    }

    private boolean process(ListInfoMsg msg)
    {
        if (msg.getInformationType() == ListInfoMsg.InformationType.CURSOR)
        {
            listInfoItems.clear();
            return false;
        }
        if (serviceType == ServiceType.NET)
        {
            synchronized (serviceItems)
            {
                // Since the names in ListInfoMsg and ReceiverInformationMsg are
                // not consistent for some services (see https://github.com/mkulesh/onpc/issues/35)
                // we just clone here networkServices provided by ReceiverInformationMsg
                // into serviceItems list by any NET ListInfoMsg (is ReceiverInformationMsg exists)
                if (!networkServices.isEmpty())
                {
                    serviceItems.clear();
                    for (final String code : networkServices.keySet())
                    {
                        final ServiceType service =
                                (ServiceType) ISCPMessage.searchParameter(code, ServiceType.values(), ServiceType.UNKNOWN);
                        if (service != ServiceType.UNKNOWN)
                        {
                            serviceItems.add(new NetworkServiceMsg(service));
                        }
                    }
                }
                else // fallback: parse listData from ListInfoMsg
                {
                    for (NetworkServiceMsg i : serviceItems)
                    {
                        if (i.getService().getName().toUpperCase().equals(msg.getListedData().toUpperCase()))
                        {
                            return false;
                        }
                    }
                    final NetworkServiceMsg nsMsg = new NetworkServiceMsg(msg.getListedData());
                    if (nsMsg.getService() != ServiceType.UNKNOWN)
                    {
                        serviceItems.add(nsMsg);
                    }
                }
            }
            return !serviceItems.isEmpty();
        }
        else if (isUsb())
        {
            final String name = msg.getListedData();
            if (!listInfoItems.contains(name))
            {
                listInfoItems.add(name);
            }
            return false;
        }
        else if (isMenuMode())
        {
            synchronized (mediaItems)
            {
                for (XmlListItemMsg i : mediaItems)
                {
                    if (i.getTitle().toUpperCase().equals(msg.getListedData().toUpperCase())
                            && i.getMessageId() == msg.getLineInfo())
                    {
                        return false;
                    }
                }
                final XmlListItemMsg nsMsg = new XmlListItemMsg(
                        msg.getLineInfo(), 0, msg.getListedData(), XmlListItemMsg.Icon.UNKNOWN, true);
                mediaItems.add(nsMsg);
                if (mediaItems.size() == numberOfItems)
                {
                    Logging.info(this, "received track menu with " + mediaItems.size() + " items");
                    trackMenuReceived = true;
                }
            }
            return true;
        }
        return false;
    }

    private boolean process(CustomPopupMsg msg)
    {
        popup = msg;
        return popup != null;
    }

    public ReceiverInformationMsg.Selector getActualSelector()
    {
        for (ReceiverInformationMsg.Selector s : deviceSelectors)
        {
            if (s.getId().equals(inputType.getCode()))
            {
                return s;
            }
        }
        return null;
    }

    public boolean isRadioInput()
    {
        return inputType == InputSelectorMsg.InputType.FM
                || inputType == InputSelectorMsg.InputType.AM
                || inputType == InputSelectorMsg.InputType.DAB;
    }

    /**
     * Simple inputs do not have time or cover
     *
     * @return boolean
     */
    public boolean isSimpleInput()
    {
        return inputType == InputSelectorMsg.InputType.TAPE1 || inputType == InputSelectorMsg.InputType.TV ||
                inputType == InputSelectorMsg.InputType.VIDEO4 || inputType == InputSelectorMsg.InputType.VIDEO5 ||isRadioInput();
    }

    public boolean isUsb()
    {
        return serviceType == ServiceType.USB_FRONT
                || serviceType == ServiceType.USB_REAR;
    }

    public boolean isTopLayer()
    {
        if (!isPlaybackMode())
        {
            if (isRadioInput())
            {
                return true;
            }
            if (serviceType == ServiceType.NET &&
                    layerInfo == ListTitleInfoMsg.LayerInfo.NET_TOP)
            {
                return true;
            }
            if (layerInfo == ListTitleInfoMsg.LayerInfo.SERVICE_TOP)
            {
                return isUsb() || serviceType == ServiceType.UNKNOWN;
            }
        }
        return false;
    }

    public boolean isMediaEmpty()
    {
        return mediaItems.isEmpty() && serviceItems.isEmpty();
    }

    boolean listInfoConsistent()
    {
        if (numberOfItems == 0 || numberOfLayers == 0 || listInfoItems.isEmpty())
        {
            return true;
        }
        synchronized (mediaItems)
        {
            for (String s : listInfoItems)
            {
                for (XmlListItemMsg i : mediaItems)
                {
                    if (i.getTitle().toUpperCase().equals(s.toUpperCase()))
                    {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    @SuppressLint("SetTextI18n")
    public static String getVolumeLevelStr(int volumeLevel, ReceiverInformationMsg.Zone zone)
    {
        if (zone != null && zone.getVolumeStep() == 0)
        {
            final float f = (float) volumeLevel / 2.0f;
            final DecimalFormat df = Utils.getDecimalFormat("0.0");
            return df.format(f);
        }
        else
        {
            return Integer.toString(volumeLevel, 10);
        }
    }

    public ReceiverInformationMsg.Preset searchPreset()
    {
        for (ReceiverInformationMsg.Preset p : presetList)
        {
            if (p.getId() == preset)
            {
                return p;
            }
        }
        return null;
    }

    public String getTrackInfo(final Context context)
    {
        final StringBuilder str = new StringBuilder();
        final String dashedString = context.getString(R.string.dashed_string);
        if (isRadioInput())
        {
            str.append(preset != PresetCommandMsg.NO_PRESET ? Integer.toString(preset) : dashedString);
            str.append("/");
            str.append(!presetList.isEmpty() ? Integer.toString(presetList.size()) : dashedString);
        }
        else
        {
            str.append(currentTrack != null ? Integer.toString(currentTrack) : dashedString);
            str.append("/");
            str.append(maxTrack != null ? Integer.toString(maxTrack) : dashedString);
        }
        return str.toString();
    }

    @NonNull
    public String getFrequencyInfo(final Context context)
    {
        final String dashedString = context.getString(R.string.dashed_string);
        if (frequency == null)
        {
            return dashedString;
        }
        if (inputType != InputSelectorMsg.InputType.FM)
        {
            return frequency;
        }
        try
        {
            final float f = (float) Integer.parseInt(frequency) / 100.0f;
            final DecimalFormat df = Utils.getDecimalFormat("0.00 MHz");
            return df.format(f);
        }
        catch (Exception e)
        {
            return dashedString;
        }
    }

    public ReceiverInformationMsg.NetworkService getNetworkService()
    {
        if (serviceType != null)
        {
            return networkServices.get(serviceType.getCode());
        }
        return null;
    }

    private boolean process(MultiroomDeviceInformationMsg msg)
    {
        try
        {
            msg.parseXml(true);
            final String id = msg.getProperty("deviceid");
            if (!id.isEmpty())
            {
                multiroomLayout.put(id, msg);
            }
            if (isAnotherHost(msg))
            {
                Logging.info(msg, "Multiroom device information for another host");
            }
            else
            {
                multiroomDeviceId = id;
                multiroomChannel = getMultiroomChannelType();
            }
            return true;
        }
        catch (Exception e)
        {
            Logging.info(msg, "Can not parse XML: " + e.getLocalizedMessage());
        }
        return false;
    }

    public MultiroomDeviceInformationMsg.RoleType getMultiroomRole()
    {
        final MultiroomDeviceInformationMsg msg = multiroomLayout.get(multiroomDeviceId);
        return (msg == null) ? MultiroomDeviceInformationMsg.RoleType.NONE : msg.getRole(getActiveZone() + 1);
    }

    private MultiroomDeviceInformationMsg.ChannelType getMultiroomChannelType()
    {
        final MultiroomDeviceInformationMsg msg = multiroomLayout.get(multiroomDeviceId);
        return (msg == null) ? MultiroomDeviceInformationMsg.ChannelType.NONE : msg.getChannelType(getActiveZone() + 1);
    }

    public int getMultiroomGroupId()
    {
        final MultiroomDeviceInformationMsg msg = multiroomLayout.get(multiroomDeviceId);
        return (msg == null) ? MultiroomDeviceInformationMsg.NO_GROUP : msg.getGroupId(getActiveZone() + 1);
    }

    private boolean process(MultiroomChannelSettingMsg msg)
    {
        final boolean changed = multiroomChannel != msg.getChannelType();
        multiroomChannel = msg.getChannelType();
        return changed;
    }

    @DrawableRes
    public int getServiceIcon()
    {
        @DrawableRes int serviceIcon = isPlaying() ? this.serviceIcon.getImageId() :
                (this.serviceType != null ? this.serviceType.getImageId() : R.drawable.media_item_unknown);
        if (serviceIcon == R.drawable.media_item_unknown)
        {
            serviceIcon = inputType.getImageId();
        }
        return serviceIcon;
    }

    public SoundControlType soundControlType(final String config, ReceiverInformationMsg.Zone zone)
    {
        switch (config)
        {
            case "auto":
                return (zone != null && zone.getVolMax() == 0) ? SoundControlType.RI_AMP : SoundControlType.DEVICE;
            case "device":
                return SoundControlType.DEVICE;
            case "external-amplifier":
                return SoundControlType.RI_AMP;
            default:
                return SoundControlType.NONE;
        }
    }

    public boolean isCdInput()
    {
        return (inputType == InputSelectorMsg.InputType.TV_CD) &&
                (isControlExists(CdPlayerOperationCommandMsg.CONTROL_CD_INT1) ||
                        isControlExists(CdPlayerOperationCommandMsg.CONTROL_CD_INT2));
    }

    public boolean isTrackMenuReceived()
    {
        return trackMenuReceived;
    }
}
