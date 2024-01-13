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

import "../config/CfgAudioControl.dart";
import "../utils/Logging.dart";
import "ConnectionIf.dart";
import "ISCPMessage.dart";
import "MessageChannel.dart";
import "StateManager.dart";
import "messages/AmpOperationCommandMsg.dart";
import "messages/AudioMutingMsg.dart";
import "messages/MasterVolumeMsg.dart";
import "messages/OperationCommandMsg.dart";
import "state/SoundControlState.dart";
import "State.dart";

class CommandHelper
{
    final State state;
    final MessageChannel _messageChannel;
    bool hasImpactOnMediaList = false;

    CommandHelper(this.state, this._messageChannel);

    void changeMasterVolume(final CfgAudioControl audioControl, int cmd)
    {
        hasImpactOnMediaList = false;
        final SoundControlType soundControl = SoundControlState.soundControlType(audioControl, state.getActiveZone);
        switch (soundControl)
        {
            case SoundControlType.DEVICE_BUTTONS:
            case SoundControlType.DEVICE_SLIDER:
            case SoundControlType.DEVICE_BTN_AROUND_SLIDER:
            case SoundControlType.DEVICE_BTN_ABOVE_SLIDER:
                {
                    final List<ISCPMessage> cmds = [
                        MasterVolumeMsg.output(state.getActiveZone, MasterVolume.UP),
                        MasterVolumeMsg.output(state.getActiveZone, MasterVolume.DOWN),
                        AudioMutingMsg.toggle(state.getActiveZone,
                            state.soundControlState.audioMuting, state.protoType)
                    ];
                    return sendMessage(cmds[cmd]);
                }
            case SoundControlType.RI_AMP:
                {
                    final List<ISCPMessage> cmds = [
                        AmpOperationCommandMsg.output(AmpOperationCommand.MVLUP),
                        AmpOperationCommandMsg.output(AmpOperationCommand.MVLDOWN),
                        AmpOperationCommandMsg.output(AmpOperationCommand.AMTTG)
                    ];
                    return sendMessage(cmds[cmd]);
                }
            default:
            // Nothing to do
                break;
        }
    }

    void changePlaybackState(OperationCommand key)
    {
        hasImpactOnMediaList = false;
        if (!state.mediaListState.isPlaybackMode
            && state.mediaListState.isUsb
            && [OperationCommand.TRDN, OperationCommand.TRUP].contains(key))
        {
            // Issue-44: on some receivers, "TRDN" and "TRUP" for USB only work
            // in playback mode. Therefore, switch to this mode before
            // send OperationCommandMsg if current mode is LIST
            sendMessage(StateManager.LIST_MSG);
            sendMessage(OperationCommandMsg.output(state.getActiveZone, key));
        }
        else if (state.protoType == ProtoType.ISCP && key == OperationCommand.PLAY)
        {
            // For Onkyo only: To start play in normal mode, PAUSE shall be issue instead of PLAY command
            sendMessage(OperationCommandMsg.output(state.getActiveZone, OperationCommand.PAUSE));
        }
        else if (key == OperationCommand.REPEAT)
        {
            sendMessage(OperationCommandMsg.output(state.getActiveZone,
                OperationCommandMsg.toggleRepeat(state.protoType, state.playbackState.repeatStatus.key)));
        }
        else if (key == OperationCommand.RANDOM)
        {
            sendMessage(OperationCommandMsg.output(state.getActiveZone,
                OperationCommandMsg.toggleShuffle(state.protoType, state.playbackState.shuffleStatus)));
        }
        else
        {
            sendMessage(OperationCommandMsg.output(state.getActiveZone, key));
        }
    }

    void sendMessage(final ISCPMessage msg)
    {
        Logging.info(this, "sending message: " + msg.toString());
        _messageChannel.sendMessage(msg.getCmdMsg());
        if (msg.hasImpactOnMediaList())
        {
            hasImpactOnMediaList = true;
        }
    }
}