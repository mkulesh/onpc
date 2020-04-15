/*
 * Copyright (C) 2019. Mikhail Kulesh
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

import 'dart:async';
import 'dart:collection';
import 'dart:math';

import "../iscp/BroadcastSearch.dart";
import "../utils/Logging.dart";
import "EISCPMessage.dart";
import "ISCPMessage.dart";
import "MessageChannel.dart";
import "State.dart";
import "messages/AmpOperationCommandMsg.dart";
import "messages/BroadcastResponseMsg.dart";
import "messages/DisplayModeMsg.dart";
import "messages/InputSelectorMsg.dart";
import "messages/JacketArtMsg.dart";
import "messages/ListInfoMsg.dart";
import "messages/ListTitleInfoMsg.dart";
import "messages/MasterVolumeMsg.dart";
import "messages/MenuStatusMsg.dart";
import "messages/MessageFactory.dart";
import "messages/OperationCommandMsg.dart";
import "messages/PlayStatusMsg.dart";
import "messages/PowerStatusMsg.dart";
import "messages/PrivacyPolicyStatusMsg.dart";
import "messages/TimeInfoMsg.dart";
import "messages/TimeSeekMsg.dart";
import "messages/TrackInfoMsg.dart";
import "messages/XmlListInfoMsg.dart";
import "state/MediaListState.dart";
import "state/MultiroomState.dart";
import "state/SoundControlState.dart";

typedef OnStateChanged = void Function(Set<String> changes);
typedef OnOutputMessage = void Function(ISCPMessage msg);
typedef OnConnectionError = void Function(String msg);

enum NetworkState
{
    NONE, CELLULAR, WIFI
}

class StateManager
{
    static const String CONNECTION_EVENT = "CONNECT";
    static const String ZONE_EVENT = "ZONE";
    static const String WAITING_FOR_DATA_EVENT = "WAITING_FOR_DATA";
    static const String BROADCAST_SEARCH_EVENT = "BROADCAST_SEARCH";
    static const String START_SEARCH_EVENT = "START_SEARCH";
    static const String ANY_DATA = "ANY_DATA";

    static const Duration GUI_UPDATE_DELAY = Duration(milliseconds: 500);

    // Broadcast search engine will be created on demand
    BroadcastSearch _searchEngine;

    bool get isSearching
    => _searchEngine != null;

    // Message channel
    MessageChannel _messageChannel;
    final Map<String, MessageChannel> _multiroomChannels = Map();

    // auto power on startup
    bool _autoPower = false;

    set autoPower(bool value)
    {
        _autoPower = value;
    }

    // keep playback mode
    bool _keepPlaybackMode = false;

    set keepPlaybackMode(bool value)
    {
        _keepPlaybackMode = value;
    }

    // Network state
    NetworkState _networkState;

    set networkState(NetworkState value)
    {
        Logging.info(this, "Network state: " + value.toString());
        _networkState = value;
    }

    // Events
    OnStateChanged _onStateChanged;
    OnConnectionError _onConnectionError;
    final Set<String> _eventChanges = HashSet<String>();

    String _waitingForData = "";

    bool get waitingForData
    => _waitingForData.isNotEmpty;

    // Helper attributes used for message processing
    Timer _updateTimer;
    int _skipNextTimeMsg = 0;
    bool _requestXmlList = false;
    bool _playbackMode = false;
    ISCPMessage _circlePlayRemoveMsg;
    int _xmlReqId = 0;

    // Device name as manually given by the user
    String _requestedHost;

    String get requestedHost
    => _requestedHost;

    // Common List commands
    static final OperationCommandMsg LIST_MSG = OperationCommandMsg.output(
        State.DEFAULT_ACTIVE_ZONE, OperationCommand.LIST);

    static final DisplayModeMsg DISPLAY_MSG = DisplayModeMsg.output(
        DisplayModeMsg.TOGGLE);

    // State
    final State _state = State();

    State get state
    => _state;

    StateManager(final int zoneId)
    {
        _messageChannel = MessageChannel(_onConnected, _onNewEISCPMessage, _onDisconnected);
        _state.activeZone = zoneId;
        _state.trackState.coverDownloadFinished = _onProcessFinished;
    }

    void addListeners(OnStateChanged onStateChanged, OnConnectionError onConnectionError)
    {
        _onStateChanged = onStateChanged;
        _onConnectionError = onConnectionError;
    }

    void connect(String server, int port, {bool saveRequestedHost = false})
    {
        _requestedHost = saveRequestedHost ? server : null;
        if (isConnected)
        {
            disconnect(true);
        }
        _messageChannel.start(server, port);
    }

    void disconnect(bool waitForDisconnect)
    {
        disconnectMultiroom(waitForDisconnect);
        _messageChannel.stop();
        if (waitForDisconnect)
        {
            while (_messageChannel.isConnected)
            {
                // empty
            };
        }
    }

    bool get isConnected
    => _messageChannel.isConnected;

    String get sourceHost
    => _messageChannel.sourceHost;

    int get sourcePort
    => _messageChannel.sourcePort;

    DeviceInfo get sourceDevice
    => state.multiroomState.deviceList.values.firstWhere((d) => isSourceHost(d.responseMsg), orElse: () => null);

    bool isSourceHost(final ISCPMessage msg)
    => msg.sourceHost == sourceHost;

    int changeZone(String getId)
    {
        if (_state.changeZone(getId))
        {
            sendQueries(_state.receiverInformation.getQueries(_state.getActiveZone));
            triggerStateEvent(ZONE_EVENT);
        }
        return _state.getActiveZone;
    }

    void _onConnected(MessageChannel channel, String server, int port)
    {
        Logging.info(this, "Connected to " + server + "/" + port.toString() + " via " + _networkState.toString());

        _state.updateConnection(true);
        if (_onStateChanged != null)
        {
            _onStateChanged(Set.from([CONNECTION_EVENT]));
        }

        // In CELLULAR mode, always use BMP images instead of links since direct links
        // can be not available
        _messageChannel.sendMessage(EISCPMessage.output(JacketArtMsg.CODE,
            _networkState == NetworkState.CELLULAR? JacketArtMsg.TYPE_BMP : JacketArtMsg.TYPE_LINK));
        sendQueries(_state.receiverInformation.getQueries(_state.getActiveZone));
    }

    Future<EISCPMessage> _registerMessage(EISCPMessage raw) async
    {
        // this is a dummy code necessary to transfer the incoming message into
        // the asynchronous scope
        return raw;
    }

    void _onNewEISCPMessage(EISCPMessage rawMsg, String host)
    {
        // call processing asynchronous after message is registered
        _registerMessage(rawMsg).then((EISCPMessage raw)
        {
            // Here the asynchronous scope begins
            // We do not generate any errors in this scope;
            // i.e the return value is always true

            if (raw.getCode != JacketArtMsg.CODE && raw.isMultiline)
            {
                raw.logParameters();
            }

            if (_waitingForData.isNotEmpty && raw.getCode != TimeInfoMsg.CODE)
            {
                if (_waitingForData == ANY_DATA || _waitingForData == raw.getCode)
                {
                    _waitingForData = "";
                }
            }

            try
            {
                final ISCPMessage msg = MessageFactory.create(raw);
                msg.sourceHost = host;
                final String changeCode = _processMessage(msg);
                _onProcessFinished(changeCode != null, changeCode);
            }
            on Exception catch (e)
            {
                Logging.info(this, "-> can not proccess message " + raw.toString() + ": " + e.toString());
                return true;
            }

            return true;
        });
    }

    String _processMessage(ISCPMessage msg)
    {
        if (![TimeInfoMsg.CODE, JacketArtMsg.CODE].contains(msg.getCode))
        {
            Logging.info(this, "-> processing message: " + msg.toString());
        }

        final String multiroomChange = state.multiroomState.process(msg);
        if (!isSourceHost(msg))
        {
            return multiroomChange;
        }

        if (msg is ZonedMessage && msg.zoneIndex != state.getActiveZone)
        {
            Logging.info(this, "message ignored: non active zone " + msg.zoneIndex.toString());
            return null;
        }

        // Ignore TimeInfoMsg if device is off
        if (msg is TimeInfoMsg && !state.isOn)
        {
            return null;
        }

        // skip time message, is necessary
        if (msg is TimeInfoMsg && _skipNextTimeMsg > 0)
        {
            _skipNextTimeMsg = max(0, _skipNextTimeMsg - 1);
            return null;
        }

        final PlayStatus playStatus = state.playbackState.playStatus;
        final String changed = state.update(msg) ?? multiroomChange;

        // no further message handling, if power off
        if (!state.isOn)
        {
            if (msg is PowerStatusMsg && _autoPower)
            {
                // Auto power-on once at first PowerStatusMsg
                sendMessage(PowerStatusMsg.output(state.getActiveZone, PowerStatus.ON));
                _autoPower = false;
            }
            return changed;
        }

        // check privacy policy but do not accept it automatically
        if (msg is PrivacyPolicyStatusMsg)
        {
            if (!msg.isPolicySet(PrivacyPolicyType.ONKYO))
            {
                Logging.info(this, "ONKYO policy is not accepted");
            }
            if (!msg.isPolicySet(PrivacyPolicyType.GOOGLE))
            {
                Logging.info(this, "GOOGLE policy is not accepted");
            }
            if (!msg.isPolicySet(PrivacyPolicyType.SUE))
            {
                Logging.info(this, "SUE policy is not accepted");
            }
        }

        // on TrackInfoMsg, always do XML state request upon the next ListTitleInfoMsg
        if (msg is TrackInfoMsg)
        {
            _requestXmlList = true;
            return changed;
        }

        // corner case: delayed USB initialization at power on
        if (msg is ListInfoMsg)
        {
            final MediaListState ms = state.mediaListState;
            if (ms.isUsb &&
                ms.isTopLayer() &&
                ms.listInfoNotConsistent())
            {
                Logging.info(this, "requesting XML list state for USB...");
                _messageChannel.sendMessage(XmlListInfoMsg.output(
                    _xmlReqId++, ms.numberOfLayers, 0, ms.numberOfTitles).getCmdMsg());
            }
        }

        // Issue LIST command upon PlayStatusMsg if PlaybackMode is active
        if (msg is ListTitleInfoMsg)
        {
            _playbackMode = state.mediaListState.isPlaybackMode;
        }
        if (!_keepPlaybackMode && msg is PlayStatusMsg && _playbackMode && state.isPlaying && !state.mediaListState.isTuneIn)
        {
            // Note: see Issue 51. Do not request list mode for TUNEIN_RADIO since it tops
            // playing for some models
            Logging.info(this, "requesting list mode...");
            _messageChannel.sendMessage(LIST_MSG.getCmdMsg());
            _playbackMode = false;
        }

        if (changed == null)
        {
            if (msg is ListTitleInfoMsg && _requestXmlList)
            {
                _requestXmlListState(msg);
            }
            return null;
        }

        if (msg is PowerStatusMsg)
        {
            // #58: delayed response for InputSelectorMsg was observed:
            // Send this request first
            sendQueries(_state.playbackState.getQueries(state.getActiveZone));
            sendQueries(_state.deviceSettingsState.getQueries(state.getActiveZone));
            sendQueries(_state.soundControlState.getQueries(state.getActiveZone, state.receiverInformation));
            sendQueries(_state.radioState.getQueries(state.getActiveZone));
            _requestListState();
            return changed;
        }

        // #118: CR-N575D allow to use play control buttons to control CD player
        if (msg is InputSelectorMsg && state.isCdInput)
        {
            sendQueries(_state.playbackState.getCdQueries());
        }

        if (msg is PlayStatusMsg && playStatus != state.playbackState.playStatus)
        {
            if (state.isPlaying)
            {
                final List<String> queries = List<String>();
                queries.addAll(state.trackState.getQueries());
                queries.add(MenuStatusMsg.CODE);
                sendQueries(queries);
                // Some devices (like TX-8150) does not proved cover image;
                // we shall specially request it:
                if (state.receiverInformation.model == "TX-8150")
                {
                    _messageChannel.sendMessage(
                        EISCPMessage.output(JacketArtMsg.CODE, JacketArtMsg.REQUEST));
                }
                if (state.mediaListState.isMediaEmpty)
                {
                    _requestListState();
                }
            }
            else if (!state.mediaListState.isPopupMode)
            {
                _requestListState();
            }
            return changed;
        }

        if (msg is ListTitleInfoMsg)
        {
            if (_circlePlayRemoveMsg != null && msg.getNumberOfItems > 0)
            {
                state.mediaListState.popFront(state.mediaListState.numberOfItems - msg.getNumberOfItems);
                sendPlayQueueMsg(_circlePlayRemoveMsg, true);
            }
            else
            {
                _circlePlayRemoveMsg = null;
                _requestXmlListState(msg);
            }
            return changed;
        }

        return changed;
    }

    void _onProcessFinished(bool changed, String changeCode)
    {
        if (changed)
        {
            _eventChanges.add(changeCode);
            if (_updateTimer == null)
            {
                _updateTimer = Timer(GUI_UPDATE_DELAY, ()
                {
                    final Set<String> changes = HashSet<String>();
                    changes.addAll(_eventChanges);
                    _eventChanges.clear();
                    _updateTimer = null;
                    if (_onStateChanged != null && changes.isNotEmpty)
                    {
                        _onStateChanged(changes);
                    }
                });
            }
        }
    }

    void _onDisconnected(ConnectionErrorType errorType, String result)
    {
        Logging.info(this, result);
        if (errorType == ConnectionErrorType.HOST_NOT_AVAILABLE && _onConnectionError != null)
        {
            _onConnectionError(result);
        }
        _onProcessFinished(state.updateConnection(false), CONNECTION_EVENT);
    }

    void _requestListState()
    {
        Logging.info(this, "requesting list state...");
        _requestXmlList = true;
        _messageChannel.sendMessage(EISCPMessage.query(ListTitleInfoMsg.CODE));
    }

    void _requestXmlListState(final ListTitleInfoMsg liMsg)
    {
        _requestXmlList = false;
        if (liMsg.isNetTopService)
        {
            Logging.info(this, "requesting XML list state skipped");
        }
        else if (liMsg.getUiType.key == UIType.PLAYBACK
            || liMsg.getUiType.key == UIType.POPUP)
        {
            Logging.info(this, "requesting XML list state skipped");
        }
        else if (liMsg.isXmlListTopService
            || liMsg.getNumberOfLayers > 0
            || liMsg.getUiType.key == UIType.MENU)
        {
            _xmlReqId++;
            Logging.info(this, "requesting XML list state (id: " + _xmlReqId.toString() + ")...");
            _messageChannel.sendMessage(XmlListInfoMsg.output(
                _xmlReqId, liMsg.getNumberOfLayers, 0, liMsg.getNumberOfItems).getCmdMsg());
            if (state.receiverInformation.isReceiverInformation)
            {
                _waitingForData = XmlListInfoMsg.CODE;
                state.mediaListState.clearItems();
            }
        }
    }

    void sendQueries(final List<String> queries)
    => _messageChannel.sendQueries(queries);

    void sendMessage(final ISCPMessage msg, {bool waitingForData = false, String waitingForMsg = ""})
    {
        Logging.info(this, "sending message: " + msg.toString());
        _circlePlayRemoveMsg = null;
        if (msg.hasImpactOnMediaList() || (msg is DisplayModeMsg && !state.mediaListState.isPlaybackMode))
        {
            _requestXmlList = true;
        }
        _messageChannel.sendMessage(msg.getCmdMsg());
        if (waitingForData || waitingForMsg.isNotEmpty)
        {
            _waitingForData = waitingForMsg.isEmpty ? ANY_DATA : waitingForMsg;
            triggerStateEvent(WAITING_FOR_DATA_EVENT);
        }
    }

    void sendPlayQueueMsg(ISCPMessage msg, bool repeat)
    {
        if (msg == null)
        {
            return;
        }
        if (repeat)
        {
            Logging.info(this, "starting repeat mode: " + msg.toString());
            _circlePlayRemoveMsg = msg;
        }
        _requestXmlList = true;
        _messageChannel.sendMessage(msg.getCmdMsg());
    }

    void sendTimeMsg(final TimeSeekMsg msg, final int number)
    {
        _skipNextTimeMsg = number;
        sendMessage(msg);
        state.trackState.currentTime = msg.getData;
    }

    void sendTrackCmd(int zone, OperationCommand menu, bool doReturn)
    {
        Logging.info(this, "sending track cmd: " + menu.toString() + " for zone " + zone.toString());
        if (!state.mediaListState.isPlaybackMode)
        {
            _messageChannel.sendMessage(LIST_MSG.getCmdMsg());
        }
        final OperationCommandMsg msg = OperationCommandMsg.output(zone, menu);
        _messageChannel.sendMessage(msg.getCmdMsg());
        if (doReturn)
        {
            _messageChannel.sendMessage(LIST_MSG.getCmdMsg());
        }
    }

    void changeMasterVolume(final String soundControlStr, bool isUp)
    {
        final SoundControlType soundControl = state.soundControlState.soundControlType(
            soundControlStr, state.getActiveZoneInfo);

        switch (soundControl)
        {
            case SoundControlType.DEVICE_BUTTONS:
                sendMessage(MasterVolumeMsg.output(state.getActiveZone, isUp ? MasterVolume.UP : MasterVolume.DOWN));
                break;
            case SoundControlType.RI_AMP:
                sendMessage(AmpOperationCommandMsg.output(isUp ? AmpOperationCommand.MVLUP : AmpOperationCommand.MVLDOWN));
                break;
            default:
                // Nothing to do
                break;
        }
    }

    void triggerStateEvent(String event)
    {
        if (_onStateChanged != null)
        {
            final Set<String> events = Set<String>();
            events.add(event);
            _onStateChanged(events);
        }
    }

    void disconnectMultiroom(bool waitForDisconnect)
    {
        _multiroomChannels.values.forEach((c) => c.stop());
        if (_multiroomChannels.isNotEmpty && waitForDisconnect)
        {
            while (_multiroomChannels.values.any((c) => c.isConnected))
            {
                // empty
            };
            Logging.info(this, "all multiroom devices disconnected");
        }
        _multiroomChannels.clear();
        state.multiroomState.deviceList.clear();
    }

    void startSearch({bool limited = true})
    {
        disconnectMultiroom(true);
        if (_networkState != NetworkState.WIFI)
        {
            return;
        }
        Logging.info(this, "Starting device search: limited=" + limited.toString());
        state.multiroomState.startSearch(limited: limited);
        if (_searchEngine == null)
        {
            _searchEngine = BroadcastSearch(_processDeviceResponse);
            triggerStateEvent(BROADCAST_SEARCH_EVENT);
        }
    }

    void stopSearch()
    {
        if (_searchEngine != null)
        {
            Logging.info(this, "Stopping device search...");
            _searchEngine.stop();
            _searchEngine = null;
            triggerStateEvent(BROADCAST_SEARCH_EVENT);
        }
    }

    void _processDeviceResponse(final BroadcastResponseMsg msg)
    {
        Logging.info(this, "<< device response " + msg.toString());
        if (state.multiroomState.processBroadcastResponse(msg))
        {
            triggerStateEvent(BroadcastResponseMsg.CODE);
            if (_messageChannel.isConnected && isSourceHost(msg))
            {
                _messageChannel.sendQueries(state.multiroomState.getQueries());
            }
        }
        if (state.multiroomState.isSearchFinished())
        {
            stopSearch();
        }
        if (!isSourceHost(msg) && !_multiroomChannels.containsKey(msg.sourceHost))
        {
            Logging.info(this, "connecting to multiroom device: " + msg.getDevice);
            final MessageChannel m = MessageChannel(_onMultiroomDeviceConnected, _onNewEISCPMessage, _onMultiroomDeviceDisconnected);
            _multiroomChannels[msg.sourceHost] = m;
            state.multiroomState.getQueries().forEach((code) => m.addAllowedMessage(code));
            m.start(msg.sourceHost, msg.getPort);
        }
    }

    void _onMultiroomDeviceConnected(MessageChannel channel, String server, int port)
    {
        Logging.info(this, "connected to " + server + "/" + port.toString());
        channel.sendQueries(state.multiroomState.getQueries());
    }

    void _onMultiroomDeviceDisconnected(ConnectionErrorType errorType, String result)
    {
        Logging.info(this, result);
    }

    bool isMultiroomAvailable()
    {
        final DeviceInfo di = sourceDevice;
        return state.multiroomState.deviceNumber > 1 && di != null && di.groupMsg != null;
    }
}
