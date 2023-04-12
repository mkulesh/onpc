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

import com.mkulesh.onpc.iscp.messages.AudioMutingMsg;
import com.mkulesh.onpc.iscp.messages.DcpAudioRestorerMsg;
import com.mkulesh.onpc.iscp.messages.DcpEcoModeMsg;
import com.mkulesh.onpc.iscp.messages.PresetCommandMsg;
import com.mkulesh.onpc.iscp.messages.RadioStationNameMsg;
import com.mkulesh.onpc.iscp.messages.DcpReceiverInformationMsg;
import com.mkulesh.onpc.iscp.messages.DcpTunerModeMsg;
import com.mkulesh.onpc.iscp.messages.DimmerLevelMsg;
import com.mkulesh.onpc.iscp.messages.InputSelectorMsg;
import com.mkulesh.onpc.iscp.messages.ListeningModeMsg;
import com.mkulesh.onpc.iscp.messages.MasterVolumeMsg;
import com.mkulesh.onpc.iscp.messages.MessageFactory;
import com.mkulesh.onpc.iscp.messages.PowerStatusMsg;
import com.mkulesh.onpc.iscp.messages.SleepSetCommandMsg;
import com.mkulesh.onpc.iscp.messages.ToneCommandMsg;
import com.mkulesh.onpc.iscp.messages.TuningCommandMsg;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.util.ArrayList;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public class DCPMessage
{
    public final static int CR = 0x0D;

    private final ArrayList<ISCPMessage> messages = new ArrayList<>();

    @NonNull
    public ArrayList<ISCPMessage> convertInputMsg(@NonNull String dcpMsg)
    {
        messages.clear();

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
        addISCPMsg(TuningCommandMsg.processDcpMessage(dcpMsg));
        addISCPMsg(RadioStationNameMsg.processDcpMessage(dcpMsg));
        addISCPMsg(PresetCommandMsg.processDcpMessage(dcpMsg));

        // Settings
        addISCPMsg(DimmerLevelMsg.processDcpMessage(dcpMsg));
        addISCPMsg(SleepSetCommandMsg.processDcpMessage(dcpMsg));
        addISCPMsg(DcpEcoModeMsg.processDcpMessage(dcpMsg));
        addISCPMsg(DcpAudioRestorerMsg.processDcpMessage(dcpMsg));

        return messages;
    }

    @NonNull
    public ArrayList<byte[]> convertOutputMsg(@Nullable EISCPMessage raw, final String dest)
    {
        ArrayList<byte[]> retValue = new ArrayList<>();
        if (raw == null)
        {
            return retValue;
        }
        try
        {
            final String toSend = MessageFactory.create(raw).buildDcpMsg(raw.isQuery());
            if (toSend == null)
            {
                return retValue;
            }

            final String[] messages = toSend.split(ISCPMessage.DCP_MSG_SEP);
            for (String msg : messages)
            {
                Logging.info(this, ">> DCP sending: " + raw + " => " + msg + " to " + dest);
                final byte[] bytes = new byte[msg.length() + 1];
                byte[] msgBin = msg.getBytes(Utils.UTF_8);
                System.arraycopy(msgBin, 0, bytes, 0, msgBin.length);
                bytes[msgBin.length] = (byte) CR;
                retValue.add(bytes);
            }

            return retValue;
        }
        catch (Exception e)
        {
            return retValue;
        }
    }

    private void addISCPMsg(@Nullable ISCPMessage msg)
    {
        if (msg != null)
        {
            messages.add(msg);
        }
    }
}
