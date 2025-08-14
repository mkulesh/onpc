/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2025 by Mikhail Kulesh
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

package com.mkulesh.onpc.iscp.messages;

import com.jayway.jsonpath.JsonPath;
import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.iscp.MessageChannelDcp;
import com.mkulesh.onpc.utils.Logging;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public class DCPMessageFactory
{
    private int zone = ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE;
    private final ArrayList<ISCPMessage> messages = new ArrayList<>();
    private final Set<String> acceptedCodes = new HashSet<>();

    public void prepare(int zone)
    {
        this.zone = zone;

        acceptedCodes.addAll(DcpReceiverInformationMsg.getAcceptedDcpCodes());
        acceptedCodes.addAll(FriendlyNameMsg.getAcceptedDcpCodes());
        acceptedCodes.addAll(PowerStatusMsg.getAcceptedDcpCodes());
        acceptedCodes.addAll(InputSelectorMsg.getAcceptedDcpCodes());
        acceptedCodes.addAll(DcpPlaylistCmdMsg.getAcceptedDcpCodes());

        // Tone control
        acceptedCodes.addAll(MasterVolumeMsg.getAcceptedDcpCodes());
        acceptedCodes.addAll(ToneCommandMsg.getAcceptedDcpCodes());
        acceptedCodes.addAll(AudioMutingMsg.getAcceptedDcpCodes());
        acceptedCodes.addAll(ListeningModeMsg.getAcceptedDcpCodes());
        acceptedCodes.addAll(DcpAllZoneStereoMsg.getAcceptedDcpCodes());

        // Tuner
        acceptedCodes.addAll(DcpTunerModeMsg.getAcceptedDcpCodes());
        acceptedCodes.addAll(TuningCommandMsg.getAcceptedDcpCodes());
        acceptedCodes.addAll(RadioStationNameMsg.getAcceptedDcpCodes());
        acceptedCodes.addAll(PresetCommandMsg.getAcceptedDcpCodes());
        acceptedCodes.addAll(PresetMemoryMsg.getAcceptedDcpCodes());

        // Settings
        acceptedCodes.addAll(DimmerLevelMsg.getAcceptedDcpCodes());
        acceptedCodes.addAll(SleepSetCommandMsg.getAcceptedDcpCodes());
        acceptedCodes.addAll(DcpEcoModeMsg.getAcceptedDcpCodes());
        acceptedCodes.addAll(DcpAudioRestorerMsg.getAcceptedDcpCodes());
        acceptedCodes.addAll(HdmiCecMsg.getAcceptedDcpCodes());

        Logging.info(this, "Accepted DCP codes: " + acceptedCodes);
    }

    private void convertDcpMsg(@NonNull String dcpMsg)
    {
        addISCPMsg(DcpReceiverInformationMsg.processDcpMessage(dcpMsg));
        addISCPMsg(FriendlyNameMsg.processDcpMessage(dcpMsg));
        addISCPMsg(PowerStatusMsg.processDcpMessage(dcpMsg));
        addISCPMsg(InputSelectorMsg.processDcpMessage(dcpMsg));

        // Tone control
        addISCPMsg(MasterVolumeMsg.processDcpMessage(dcpMsg));
        addISCPMsg(ToneCommandMsg.processDcpMessage(dcpMsg));
        addISCPMsg(AudioMutingMsg.processDcpMessage(dcpMsg));
        addISCPMsg(ListeningModeMsg.processDcpMessage(dcpMsg));
        addISCPMsg(DcpAllZoneStereoMsg.processDcpMessage(dcpMsg));

        // Tuner
        addISCPMsg(DcpTunerModeMsg.processDcpMessage(dcpMsg));
        addISCPMsg(TuningCommandMsg.processDcpMessage(dcpMsg, zone));
        addISCPMsg(RadioStationNameMsg.processDcpMessage(dcpMsg));
        addISCPMsg(PresetCommandMsg.processDcpMessage(dcpMsg, zone));
        addISCPMsg(PresetMemoryMsg.processDcpMessage(dcpMsg));

        // Settings
        addISCPMsg(DimmerLevelMsg.processDcpMessage(dcpMsg));
        addISCPMsg(SleepSetCommandMsg.processDcpMessage(dcpMsg));
        addISCPMsg(DcpEcoModeMsg.processDcpMessage(dcpMsg));
        addISCPMsg(DcpAudioRestorerMsg.processDcpMessage(dcpMsg));
        addISCPMsg(HdmiCecMsg.processDcpMessage(dcpMsg));
    }

    private void convertHeosMsg(@NonNull String heosMsg, @Nullable Integer pid)
    {
        try
        {
            final String result = JsonPath.read(heosMsg, "$.heos.result");
            if (!"success".equals(result))
            {
                final Map<String, String> tokens =
                        ISCPMessage.parseHeosMessage(JsonPath.read(heosMsg, "$.heos.message"));
                Logging.info(this, "DCP HEOS message ignored due to wrong result: " + tokens);
                return;
            }
        }
        catch (Exception ex)
        {
            // nothing to do
        }

        try
        {
            final String cmd = JsonPath.read(heosMsg, "$.heos.command");
            final Map<String, String> tokens =
                    ISCPMessage.parseHeosMessage(JsonPath.read(heosMsg, "$.heos.message"));
            final String pidStr = tokens.get("pid");
            if (pidStr != null && pid != null && !pid.equals(Integer.valueOf(pidStr)))
            {
                Logging.info(this, "Received DCP HEOS message for different device. Ignored");
                return;
            }
            if (tokens.get("command under process") != null)
            {
                return;
            }

            addISCPMsg(DcpReceiverInformationMsg.processHeosMessage(cmd, heosMsg));
            addISCPMsg(FirmwareUpdateMsg.processHeosMessage(cmd, heosMsg));
            addISCPMsg(FriendlyNameMsg.processHeosMessage(cmd, heosMsg));
            addISCPMsg(DcpPlaylistCmdMsg.processHeosMessage(cmd));

            // Playback
            addISCPMsg(ArtistNameMsg.processHeosMessage(cmd, heosMsg));
            addISCPMsg(AlbumNameMsg.processHeosMessage(cmd, heosMsg));
            addISCPMsg(TitleNameMsg.processHeosMessage(cmd, heosMsg));
            addISCPMsg(JacketArtMsg.processHeosMessage(cmd, heosMsg));
            addISCPMsg(TimeInfoMsg.processHeosMessage(cmd, tokens));
            addISCPMsg(PlayStatusMsg.processHeosMessage(cmd, tokens));
            addISCPMsg(DcpMediaItemMsg.processHeosMessage(cmd, heosMsg));
            addISCPMsg(TrackInfoMsg.processHeosMessage(cmd, tokens));

            // Media list
            addISCPMsg(DcpMediaContainerMsg.processHeosMessage(cmd, heosMsg, tokens));
            addISCPMsg(DcpMediaEventMsg.processHeosMessage(cmd));
            addISCPMsg(CustomPopupMsg.processHeosMessage(cmd, tokens));
            addISCPMsg(DcpSearchCriteriaMsg.processHeosMessage(cmd, heosMsg, tokens));
        }
        catch (Exception ex)
        {
            Logging.info(this, "DCP HEOS error: " + ex.getLocalizedMessage() + ", message=" + heosMsg);
        }
    }

    @NonNull
    public ArrayList<ISCPMessage> convertInputMsg(@NonNull String dcpMsg, @Nullable Integer pid)
    {
        messages.clear();

        if (dcpMsg.startsWith(MessageChannelDcp.DCP_HEOS_RESPONSE))
        {
            convertHeosMsg(dcpMsg, pid);
        }
        else
        {
            if (dcpMsg.startsWith(DcpReceiverInformationMsg.DCP_COMMAND_PRESET))
            {
                // Process corner case: OPTPN has some time no end of message symbol
                // and, therefore, some messages can be joined in one string.
                // We need to split it before processing
                dcpMsg = splitJoinedMessages(dcpMsg);
            }
            convertDcpMsg(dcpMsg);
        }
        return messages;
    }

    @NonNull
    private String splitJoinedMessages(@NonNull String dcpMsg)
    {
        int startIndex = dcpMsg.length();
        while (true)
        {
            int maxIndex = 0;
            for (String code : acceptedCodes)
            {
                maxIndex = Math.max(maxIndex, dcpMsg.lastIndexOf(code, startIndex));
            }

            if (maxIndex > 0)
            {
                Logging.info(this, "DCP warning: detected message in the middle: " + dcpMsg + ", start index=" + maxIndex);
                final String first = dcpMsg.substring(0, maxIndex);
                final String second = dcpMsg.substring(maxIndex);
                final int oldSize = messages.size();
                convertDcpMsg(second);
                if (oldSize != messages.size())
                {
                    dcpMsg = first;
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

    @NonNull
    public ArrayList<String> convertOutputMsg(@Nullable EISCPMessage raw, final String dest)
    {
        ArrayList<String> retValue = new ArrayList<>();
        if (raw == null)
        {
            return retValue;
        }
        try
        {
            final String toSend = createISCPMessage(raw).buildDcpMsg(raw.isQuery());
            if (toSend == null)
            {
                return retValue;
            }

            final String[] messages = toSend.split(ISCPMessage.DCP_MSG_SEP);
            for (String msg : messages)
            {
                Logging.info(this, ">> DCP sending: " + raw + " => " + msg + " to " + dest);
                retValue.add(msg);
            }

            return retValue;
        }
        catch (Exception e)
        {
            Logging.info(this, ">> DCP sending error: " + e.getLocalizedMessage());
            return retValue;
        }
    }

    private void addISCPMsg(@Nullable ISCPMessage msg)
    {
        if (msg != null)
        {
            if (messages.isEmpty())
            {
                messages.add(msg);
            }
            else
            {
                messages.add(0, msg);
            }
        }
    }

    private ISCPMessage createISCPMessage(EISCPMessage raw) throws Exception
    {
        switch (raw.getCode().toUpperCase())
        {
        case FriendlyNameMsg.CODE:
            return new FriendlyNameMsg(raw);
        case PowerStatusMsg.CODE:
        case PowerStatusMsg.ZONE2_CODE:
        case PowerStatusMsg.ZONE3_CODE:
        case PowerStatusMsg.ZONE4_CODE:
            return new PowerStatusMsg(raw);
        case InputSelectorMsg.CODE:
        case InputSelectorMsg.ZONE2_CODE:
        case InputSelectorMsg.ZONE3_CODE:
        case InputSelectorMsg.ZONE4_CODE:
            return new InputSelectorMsg(raw);
        case DcpPlaylistCmdMsg.CODE:
            return new DcpPlaylistCmdMsg(raw);
        case TimeInfoMsg.CODE:
            return new TimeInfoMsg(raw);
        case TrackInfoMsg.CODE:
            return new TrackInfoMsg(raw);
        case JacketArtMsg.CODE:
            return new JacketArtMsg(raw);
        case TitleNameMsg.CODE:
            return new TitleNameMsg(raw);
        case AlbumNameMsg.CODE:
            return new AlbumNameMsg(raw);
        case ArtistNameMsg.CODE:
            return new ArtistNameMsg(raw);
        case PlayStatusMsg.CODE:
        case PlayStatusMsg.CD_CODE:
            return new PlayStatusMsg(raw);
        case DimmerLevelMsg.CODE:
            return new DimmerLevelMsg(raw);
        case AudioMutingMsg.CODE:
        case AudioMutingMsg.ZONE2_CODE:
        case AudioMutingMsg.ZONE3_CODE:
        case AudioMutingMsg.ZONE4_CODE:
            return new AudioMutingMsg(raw);
        case MasterVolumeMsg.CODE:
        case MasterVolumeMsg.ZONE2_CODE:
        case MasterVolumeMsg.ZONE3_CODE:
        case MasterVolumeMsg.ZONE4_CODE:
            return new MasterVolumeMsg(raw);
        case ToneCommandMsg.CODE:
        case ToneCommandMsg.ZONE2_CODE:
        case ToneCommandMsg.ZONE3_CODE:
            return new ToneCommandMsg(raw);
        case PresetCommandMsg.CODE:
        case PresetCommandMsg.ZONE2_CODE:
        case PresetCommandMsg.ZONE3_CODE:
        case PresetCommandMsg.ZONE4_CODE:
            return new PresetCommandMsg(raw);
        case RadioStationNameMsg.CODE:
            return new RadioStationNameMsg(raw);
        case PresetMemoryMsg.CODE:
            return new PresetMemoryMsg(raw);
        case TuningCommandMsg.CODE:
        case TuningCommandMsg.ZONE2_CODE:
        case TuningCommandMsg.ZONE3_CODE:
        case TuningCommandMsg.ZONE4_CODE:
            return new TuningCommandMsg(raw);
        case ListeningModeMsg.CODE:
            return new ListeningModeMsg(raw);
        case DcpAllZoneStereoMsg.CODE:
            return new DcpAllZoneStereoMsg(raw);
        case HdmiCecMsg.CODE:
            return new HdmiCecMsg(raw);
        case SleepSetCommandMsg.CODE:
            return new SleepSetCommandMsg(raw);
        case PlayQueueRemoveMsg.CODE:
            return new PlayQueueRemoveMsg(raw);
        case PlayQueueReorderMsg.CODE:
            return new PlayQueueReorderMsg(raw);
        case FirmwareUpdateMsg.CODE:
            return new FirmwareUpdateMsg(raw);
        // Denon control protocol
        case OperationCommandMsg.CODE:
        case OperationCommandMsg.ZONE2_CODE:
        case OperationCommandMsg.ZONE3_CODE:
        case OperationCommandMsg.ZONE4_CODE:
            return new OperationCommandMsg(raw);
        case SetupOperationCommandMsg.CODE:
            return new SetupOperationCommandMsg(raw);
        case NetworkServiceMsg.CODE:
            return new NetworkServiceMsg(raw);
        case DcpSearchCriteriaMsg.CODE:
            return new DcpSearchCriteriaMsg(raw);
        case DcpSearchMsg.CODE:
            return new DcpSearchMsg(raw);
        case DcpReceiverInformationMsg.CODE:
            return new DcpReceiverInformationMsg(raw);
        case DcpTunerModeMsg.CODE:
            return new DcpTunerModeMsg(raw);
        case DcpEcoModeMsg.CODE:
            return new DcpEcoModeMsg(raw);
        case DcpAudioRestorerMsg.CODE:
            return new DcpAudioRestorerMsg(raw);
        case DcpMediaContainerMsg.CODE:
            return new DcpMediaContainerMsg(raw);
        case DcpMediaItemMsg.CODE:
            return new DcpMediaItemMsg(raw);
        default:
            throw new Exception("No factory method for message " + raw.getCode());
        }
    }

}
