/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2023 by Mikhail Kulesh
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU
 * General License as published by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
 * even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General License for more details. You should have received a copy of the GNU General
 * License along with this program.
 */
// @dart=2.9
import 'dart:math';

import "../../utils/Logging.dart";
import "../DcpHeosMessage.dart";
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";
import "AlbumNameMsg.dart";
import "ArtistNameMsg.dart";
import "AudioMutingMsg.dart";
import "DcpAudioRestorerMsg.dart";
import "DcpEcoModeMsg.dart";
import "DcpMediaContainerMsg.dart";
import "DcpMediaItemMsg.dart";
import "DcpReceiverInformationMsg.dart";
import "DcpTunerModeMsg.dart";
import "DimmerLevelMsg.dart";
import "FirmwareUpdateMsg.dart";
import "HdmiCecMsg.dart";
import "InputSelectorMsg.dart";
import "JacketArtMsg.dart";
import "ListeningModeMsg.dart";
import "MasterVolumeMsg.dart";
import "NetworkServiceMsg.dart";
import "OperationCommandMsg.dart";
import "PlayStatusMsg.dart";
import "PowerStatusMsg.dart";
import "PresetCommandMsg.dart";
import "PresetMemoryMsg.dart";
import "RadioStationNameMsg.dart";
import "ReceiverInformationMsg.dart";
import "SetupOperationCommandMsg.dart";
import "SleepSetCommandMsg.dart";
import "TimeInfoMsg.dart";
import "TitleNameMsg.dart";
import "ToneCommandMsg.dart";
import "TuningCommandMsg.dart";

/*
 * Denon control protocol - Processing of DCP and HEOS messages
 */
class DCPMessageFactory
{
    int _zone = ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE;
    final List<ISCPMessage> _messages = [];
    final Set<String> _acceptedCodes = Set();

    set zone(int value)
    {
        _zone = value;
    }

    void prepare()
    {
        _acceptedCodes.addAll(DcpReceiverInformationMsg.getAcceptedDcpCodes());
        _acceptedCodes.addAll(PowerStatusMsg.getAcceptedDcpCodes());
        _acceptedCodes.addAll(InputSelectorMsg.getAcceptedDcpCodes());

        // Tone control
        _acceptedCodes.addAll(MasterVolumeMsg.getAcceptedDcpCodes());
        _acceptedCodes.addAll(ToneCommandMsg.getAcceptedDcpCodes());
        _acceptedCodes.addAll(AudioMutingMsg.getAcceptedDcpCodes());
        _acceptedCodes.addAll(ListeningModeMsg.getAcceptedDcpCodes());

        // Tuner
        _acceptedCodes.addAll(DcpTunerModeMsg.getAcceptedDcpCodes());
        _acceptedCodes.addAll(TuningCommandMsg.getAcceptedDcpCodes());
        _acceptedCodes.addAll(RadioStationNameMsg.getAcceptedDcpCodes());
        _acceptedCodes.addAll(PresetCommandMsg.getAcceptedDcpCodes());
        _acceptedCodes.addAll(PresetMemoryMsg.getAcceptedDcpCodes());

        // Settings
        _acceptedCodes.addAll(DimmerLevelMsg.getAcceptedDcpCodes());
        _acceptedCodes.addAll(SleepSetCommandMsg.getAcceptedDcpCodes());
        _acceptedCodes.addAll(DcpEcoModeMsg.getAcceptedDcpCodes());
        _acceptedCodes.addAll(DcpAudioRestorerMsg.getAcceptedDcpCodes());
        _acceptedCodes.addAll(HdmiCecMsg.getAcceptedDcpCodes());

        Logging.info(this, "Accepted DCP codes: " + _acceptedCodes.toString());
    }

    void convertDcpMsg(String dcpMsg)
    {
        addISCPMsg(DcpReceiverInformationMsg.processDcpMessage(dcpMsg));
        addISCPMsg(PowerStatusMsg.processDcpMessage(dcpMsg));
        addISCPMsg(InputSelectorMsg.processDcpMessage(dcpMsg));

        // Tone control
        addISCPMsg(MasterVolumeMsg.processDcpMessage(dcpMsg));
        addISCPMsg(ToneCommandMsg.processDcpMessage(dcpMsg));
        addISCPMsg(AudioMutingMsg.processDcpMessage(dcpMsg));
        addISCPMsg(ListeningModeMsg.processDcpMessage(dcpMsg));

        // Tuner
        addISCPMsg(DcpTunerModeMsg.processDcpMessage(dcpMsg));
        addISCPMsg(TuningCommandMsg.processDcpMessage(dcpMsg, _zone));
        addISCPMsg(RadioStationNameMsg.processDcpMessage(dcpMsg));
        addISCPMsg(PresetCommandMsg.processDcpMessage(dcpMsg, _zone));
        addISCPMsg(PresetMemoryMsg.processDcpMessage(dcpMsg));

        // Settings
        addISCPMsg(DimmerLevelMsg.processDcpMessage(dcpMsg));
        addISCPMsg(SleepSetCommandMsg.processDcpMessage(dcpMsg));
        addISCPMsg(DcpEcoModeMsg.processDcpMessage(dcpMsg));
        addISCPMsg(DcpAudioRestorerMsg.processDcpMessage(dcpMsg));
        addISCPMsg(HdmiCecMsg.processDcpMessage(dcpMsg));
    }

    void _convertHeosMsg(String heosMsg, int pid, DcpHeosMessage jsonMsg)
    {
        try
        {
            if (!jsonMsg.isValid(pid))
            {
                Logging.info(TimeInfoMsg, "HEOS message invalid, ignored: " + jsonMsg.toString());
                return;
            }

            addISCPMsg(DcpReceiverInformationMsg.processHeosMessage(jsonMsg));
            addISCPMsg(FirmwareUpdateMsg.processHeosMessage(jsonMsg));

            // Playback
            addISCPMsg(ArtistNameMsg.processHeosMessage(jsonMsg));
            addISCPMsg(AlbumNameMsg.processHeosMessage(jsonMsg));
            addISCPMsg(TitleNameMsg.processHeosMessage(jsonMsg));
            addISCPMsg(JacketArtMsg.processHeosMessage(jsonMsg));
            addISCPMsg(TimeInfoMsg.processHeosMessage(jsonMsg));
            addISCPMsg(PlayStatusMsg.processHeosMessage(jsonMsg));
            addISCPMsg(DcpMediaItemMsg.processHeosMessage(jsonMsg));

            // Media list
            addISCPMsg(DcpMediaContainerMsg.processHeosMessage(jsonMsg));
            //addISCPMsg(DcpMediaEventMsg.processHeosMessage(jsonMsg));
            //addISCPMsg(CustomPopupMsg.processHeosMessage(jsonMsg));
        }
        on Exception catch (e)
        {
            Logging.info(this, "DCP HEOS error: " + e.toString() + ", message=" + heosMsg);
        }
    }

    List<ISCPMessage> convertInputMsg(String dcpMsg, int pid, dynamic jsonMsg)
    {
        _messages.clear();

        if (jsonMsg != null)
        {
            _convertHeosMsg(dcpMsg, pid, jsonMsg);
        }
        else
        {
            if (dcpMsg.startsWith(DcpReceiverInformationMsg.DCP_COMMAND_PRESET))
            {
                // Process corner case: OPTPN has some time no end of message symbol
                // and, therefore, some messages can be joined in one string.
                // We need to split it before processing
                dcpMsg = _splitJoinedMessages(dcpMsg);
            }
            convertDcpMsg(dcpMsg);
        }
        return _messages;
    }

    String _splitJoinedMessages(String dcpMsg)
    {
        int startIndex = dcpMsg.length;
        while (true)
        {
            int maxIndex = 0;
            for (String code in _acceptedCodes)
            {
                maxIndex = max(maxIndex, dcpMsg.lastIndexOf(code, startIndex));
            }

            if (maxIndex > 0)
            {
                Logging.info(this, "DCP warning: detected message in the middle: " + dcpMsg + ", start index=" + maxIndex.toString());
                final String first = dcpMsg.substring(0, maxIndex);
                final String second = dcpMsg.substring(maxIndex);
                final int oldSize = _messages.length;
                convertDcpMsg(second);
                if (oldSize != _messages.length)
                {
                    dcpMsg = first;
                    startIndex = dcpMsg.length;
                    Logging.info(this, "DCP warning: split DCP message: " + first + "/" + second);
                }
                else
                {
                    startIndex = maxIndex - 1;
                }
                continue;
            }
            break;
        }
        return dcpMsg;
    }

    List<String> convertOutputMsg(EISCPMessage raw1, ISCPMessage raw2, final String dest)
    {
        final List<String> retValue = [];
        if (raw1 == null && raw2 == null)
        {
            return retValue;
        }
        try
        {
            final String toSend = (raw1 != null) ?
                createISCPMessage(raw1).buildDcpMsg(raw1.isQuery()) :
                raw2.buildDcpMsg(false);
            if (toSend == null)
            {
                return retValue;
            }
            final List<String> messages = toSend.split(ISCPMessage.DCP_MSG_SEP);
            for (String msg in messages)
            {
                retValue.add(msg);
            }
            return retValue;
        }
        on Exception catch (e)
        {
            Logging.info(this, ">> DCP sending error: " + e.toString());
            return retValue;
        }
    }

    void addISCPMsg(ISCPMessage msg)
    {
        if (msg != null)
        {
            if (_messages.isEmpty)
            {
                _messages.add(msg);
            }
            else
            {
                _messages.insert(0, msg);
            }
        }
    }

    ISCPMessage createISCPMessage(EISCPMessage raw)
    {
        switch (raw.getCode)
        {
        case PowerStatusMsg.CODE:
        case PowerStatusMsg.ZONE2_CODE:
        case PowerStatusMsg.ZONE3_CODE:
        case PowerStatusMsg.ZONE4_CODE:
            return PowerStatusMsg(raw);
        case InputSelectorMsg.CODE:
        case InputSelectorMsg.ZONE2_CODE:
        case InputSelectorMsg.ZONE3_CODE:
        case InputSelectorMsg.ZONE4_CODE:
            return InputSelectorMsg(raw);
        case TimeInfoMsg.CODE:
            return TimeInfoMsg(raw);
        case JacketArtMsg.CODE:
            return JacketArtMsg(raw);
        case TitleNameMsg.CODE:
            return TitleNameMsg(raw);
        case AlbumNameMsg.CODE:
            return AlbumNameMsg(raw);
        case ArtistNameMsg.CODE:
            return ArtistNameMsg(raw);
        case PlayStatusMsg.CODE:
        case PlayStatusMsg.CD_CODE:
            return PlayStatusMsg(raw);
        case DimmerLevelMsg.CODE:
            return DimmerLevelMsg(raw);
        case AudioMutingMsg.CODE:
        case AudioMutingMsg.ZONE2_CODE:
        case AudioMutingMsg.ZONE3_CODE:
        case AudioMutingMsg.ZONE4_CODE:
            return AudioMutingMsg(raw);
        case MasterVolumeMsg.CODE:
        case MasterVolumeMsg.ZONE2_CODE:
        case MasterVolumeMsg.ZONE3_CODE:
        case MasterVolumeMsg.ZONE4_CODE:
            return MasterVolumeMsg(raw);
        case ToneCommandMsg.CODE:
        case ToneCommandMsg.ZONE2_CODE:
        case ToneCommandMsg.ZONE3_CODE:
            return ToneCommandMsg(raw);
        case PresetCommandMsg.CODE:
        case PresetCommandMsg.ZONE2_CODE:
        case PresetCommandMsg.ZONE3_CODE:
        case PresetCommandMsg.ZONE4_CODE:
            return PresetCommandMsg(raw);
        case RadioStationNameMsg.CODE:
            return RadioStationNameMsg(raw);
        case PresetMemoryMsg.CODE:
            return PresetMemoryMsg(raw);
        case TuningCommandMsg.CODE:
        case TuningCommandMsg.ZONE2_CODE:
        case TuningCommandMsg.ZONE3_CODE:
        case TuningCommandMsg.ZONE4_CODE:
            return TuningCommandMsg(raw);
        case ListeningModeMsg.CODE:
            return ListeningModeMsg(raw);
        case HdmiCecMsg.CODE:
            return HdmiCecMsg(raw);
        case SleepSetCommandMsg.CODE:
            return SleepSetCommandMsg(raw);
        //case PlayQueueRemoveMsg.CODE:
        //    return PlayQueueRemoveMsg(raw);
        //case PlayQueueReorderMsg.CODE:
        //    return PlayQueueReorderMsg(raw);
        case FirmwareUpdateMsg.CODE:
            return FirmwareUpdateMsg(raw);
        // Denon control protocol
        case OperationCommandMsg.CODE:
            return OperationCommandMsg(raw);
        case SetupOperationCommandMsg.CODE:
            return SetupOperationCommandMsg(raw);
        case NetworkServiceMsg.CODE:
            return NetworkServiceMsg(raw);
        case DcpReceiverInformationMsg.CODE:
            return DcpReceiverInformationMsg(raw);
        case DcpTunerModeMsg.CODE:
            return DcpTunerModeMsg(raw);
        case DcpEcoModeMsg.CODE:
            return DcpEcoModeMsg(raw);
        case DcpAudioRestorerMsg.CODE:
            return DcpAudioRestorerMsg(raw);
        case DcpMediaItemMsg.CODE:
            return DcpMediaItemMsg(raw);
        default:
            throw Exception("No factory method for message " + raw.getCode);
        }
    }

}
