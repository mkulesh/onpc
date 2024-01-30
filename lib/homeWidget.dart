/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2023 by Mikhail Kulesh
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

import "dart:async";
import 'dart:ui' as ui;

import "package:flutter/src/services/platform_channel.dart";
import "package:flutter/widgets.dart";

import "config/CfgAudioControl.dart";
import "iscp/ConnectionIf.dart";
import "iscp/messages/PowerStatusMsg.dart";
import "iscp/CommandHelper.dart";
import "iscp/ISCPMessage.dart";
import "iscp/MessageChannel.dart";
import "iscp/WidgetStateManager.dart";
import "iscp/messages/AudioMutingMsg.dart";
import "iscp/messages/ListTitleInfoMsg.dart";
import "iscp/messages/OperationCommandMsg.dart";
import "iscp/scripts/AutoPower.dart";
import "iscp/state/SoundControlState.dart";
import "utils/Logging.dart";
import "utils/Platform.dart";

final WidgetStateManager _stateManager = WidgetStateManager(Duration(seconds: 10));

@pragma("vm:entry-point")
Future<void> _widgetPlaybackPower() async
{
    Logging.info(_stateManager, "send power command");
    WidgetsFlutterBinding.ensureInitialized();
    await _stateManager.readConfiguration();
    AutoPower? script;
    _stateManager.start(
        (MessageChannel channel) // On initial state
        {
            final String msgCode = PowerStatusMsg.ZONE_COMMANDS[_stateManager.state.getActiveZone];
            channel.addAllowedMessage(msgCode);
            channel.sendQueries([msgCode]);
        },
        (MessageChannel channel, ISCPMessage msg) // On message
        {
            Logging.info(_stateManager, "Processing message: " + msg.toString());
            if (msg is PowerStatusMsg)
            {
                if (script == null)
                {
                    final AutoPowerMode mode = _stateManager.state.isOn ?
                        AutoPowerMode.ALL_STANDBY : AutoPowerMode.POWER_ON;
                    script = AutoPower(mode, closeOnDone: false);
                    script!.start(_stateManager.state, channel);
                }
                script!.processMessage(msg, _stateManager.state, channel);
                if (script!.done)
                {
                    _stateManager.stop();
                }
            }
            return false;
        }
    );
}

void _sendOperationCommand(OperationCommand op) async
{
    Logging.info(_stateManager, "send widget command: " + op.toString());
    WidgetsFlutterBinding.ensureInitialized();
    await _stateManager.readConfiguration();
    _stateManager.start(
        (MessageChannel channel) // On initial state
        {
            channel.addAllowedMessage(PowerStatusMsg.CODE);
            channel.addAllowedMessage(ListTitleInfoMsg.CODE);
            channel.sendQueries([PowerStatusMsg.CODE]);
        },
        (MessageChannel channel, ISCPMessage msg) // On message
        {
            Logging.info(_stateManager, "Processing message: " + msg.toString());
            bool wait = false;
            if (msg is PowerStatusMsg)
            {
                if (_stateManager.state.isOn)
                {
                    if (_stateManager.state.protoType == ProtoType.ISCP)
                    {
                        // Need ListTitleInfoMsg to properly handle changePlaybackState
                        channel.sendQueries([ListTitleInfoMsg.CODE]);
                        wait = true;
                    }
                    else
                    {
                        final CommandHelper helper = CommandHelper(_stateManager.state, channel);
                        helper.changePlaybackState(op);
                        _stateManager.stop();
                    }
                }
                else
                {
                    // Receiver OFF, no need to send command
                    _stateManager.stop();
                }
            }
            else if (msg is ListTitleInfoMsg)
            {
                final CommandHelper helper = CommandHelper(_stateManager.state, channel);
                helper.changePlaybackState(op);
                _stateManager.stop();
            }
            return wait;
        }
    );
}

@pragma("vm:entry-point")
Future<void> _widgetPlaybackPrevious() async
{
    _sendOperationCommand(OperationCommand.TRDN);
}

@pragma("vm:entry-point")
Future<void> _widgetPlaybackNext() async
{
    _sendOperationCommand(OperationCommand.TRUP);
}

@pragma("vm:entry-point")
Future<void> _widgetPlaybackStop() async
{
    _sendOperationCommand(OperationCommand.STOP);
}

@pragma("vm:entry-point")
Future<void> _widgetPlaybackPlay() async
{
    _sendOperationCommand(OperationCommand.PLAY);
}

void _sendMasterVolumeCommand(int cmd) async
{
    Logging.info(_stateManager, "send widget command: " + cmd.toString());
    WidgetsFlutterBinding.ensureInitialized();
    await _stateManager.readConfiguration();
    final CfgAudioControl audioControl = _stateManager.configuration!.audioControl;
    _stateManager.start(
        (MessageChannel channel) // On initial state
        {
            channel.addAllowedMessage(AudioMutingMsg.CODE);
            if (SoundControlState.soundControlType(audioControl, _stateManager.configuration!.activeZone) == SoundControlType.RI_AMP)
            {
                // For RI we can send command immediately
                final CommandHelper helper = CommandHelper(_stateManager.state, channel);
                helper.changeMasterVolume(audioControl, cmd);
                _stateManager.stop();
            }
            else
            {
                // Need AudioMutingMsg to properly handle changeMasterVolume
                channel.sendQueries([AudioMutingMsg.CODE]);
            }
        },
        (MessageChannel channel, ISCPMessage msg) // On message
        {
            Logging.info(_stateManager, "Processing message: " + msg.toString());
            if (msg is AudioMutingMsg)
            {
                final CommandHelper helper = CommandHelper(_stateManager.state, channel);
                helper.changeMasterVolume(audioControl, cmd);
                _stateManager.stop();
            }
            return false;
        }
    );
}

@pragma("vm:entry-point")
Future<void> _widgetPlaybackVolumeUp() async
{
    _sendMasterVolumeCommand(0);
}

@pragma("vm:entry-point")
Future<void> _widgetPlaybackVolumeDown() async
{
    _sendMasterVolumeCommand(1);
}

@pragma("vm:entry-point")
Future<void> _widgetPlaybackVolumeOff() async
{
    _sendMasterVolumeCommand(2);
}

void registerWidgetPlaybackCallback(MethodChannel methodChannel) async
{
    final arguments = <dynamic>[];
    [
        _widgetPlaybackPower, // "widget_playback_power"
        _widgetPlaybackPrevious, // "widget_playback_previous"
        _widgetPlaybackNext, // "widget_playback_next"
        _widgetPlaybackStop, // "widget_playback_stop"
        _widgetPlaybackPlay, // "widget_playback_play"
        _widgetPlaybackVolumeUp, // "widget_playback_volume_up"
        _widgetPlaybackVolumeDown, // "widget_playback_volume_down"
        _widgetPlaybackVolumeOff, // "widget_playback_volume_off"
    ].forEach((callback) => arguments.add(ui.PluginUtilities.getCallbackHandle(callback)?.toRawHandle()));

    await Platform.sendPlatformCommand(methodChannel, Platform.REGISTER_WIDGET_CALLBACK, arguments).then((res) =>
        Logging.info(_stateManager, Platform.REGISTER_WIDGET_CALLBACK + ": " + res.toString()));
}
