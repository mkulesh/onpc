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

package com.mkulesh.onpc.iscp.messages;

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Arrays;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/*
 * Denon control protocol - maximum volume and input selectors
 */
public class DcpReceiverInformationMsg extends ISCPMessage
{
    public final static String CODE = "D01";

    // Input selectors
    public final static String DCP_COMMAND_INPUT_SEL = "SSFUN";
    private final static String DCP_COMMAND_END = "END";

    // Max. Volume
    public final static String DCP_COMMAND_MAXVOL = "MVMAX";
    public final static String DCP_COMMAND_ALIMIT = "SSVCTZMALIM";
    // Tone control
    public final static String[] DCP_COMMANDS_BASS = new String[]{ "PSBAS", "Z2PSBAS", "Z3PSBAS" };
    public final static String[] DCP_COMMANDS_TREBLE = new String[]{ "PSTRE", "Z2PSTRE", "Z3PSTRE" };
    public final static int[] DCP_TON_MAX = new int[]{ 6, 10, 10 };
    public final static int[] DCP_TON_SHIFT = new int[]{ 50, 50, 50 };

    // Radio presets
    public final static String DCP_COMMAND_PRESET = "OPTPN";

    // Firmware
    public final static String DCP_COMMAND_FIRMWARE_VER = "SSINFFRM";

    @NonNull
    public static ArrayList<String> getAcceptedDcpCodes()
    {
        final ArrayList<String> out = new ArrayList<>(Arrays.asList(
                DCP_COMMAND_INPUT_SEL, DCP_COMMAND_MAXVOL, DCP_COMMAND_ALIMIT,
                DCP_COMMAND_PRESET, DCP_COMMAND_FIRMWARE_VER));
        out.addAll(Arrays.asList(DCP_COMMANDS_BASS));
        out.addAll(Arrays.asList(DCP_COMMANDS_TREBLE));
        return out;
    }

    public enum UpdateType
    {
        NONE,
        SELECTOR,
        MAX_VOLUME,
        TONE_CONTROL,
        PRESET,
        FIRMWARE_VER
    }

    public final UpdateType updateType;
    private ReceiverInformationMsg.Selector selector = null;
    private ReceiverInformationMsg.Zone maxVolumeZone = null;
    private ReceiverInformationMsg.ToneControl toneControl = null;
    private ReceiverInformationMsg.Preset preset = null;
    private String firmwareVer = null;

    DcpReceiverInformationMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        this.updateType = UpdateType.NONE;
    }

    public DcpReceiverInformationMsg(final ReceiverInformationMsg.Selector selector)
    {
        super(-1, "");
        this.updateType = UpdateType.SELECTOR;
        this.selector = selector;
    }

    public DcpReceiverInformationMsg(ReceiverInformationMsg.Zone zone)
    {
        super(-1, "");
        this.updateType = UpdateType.MAX_VOLUME;
        maxVolumeZone = zone;
    }

    public DcpReceiverInformationMsg(final ReceiverInformationMsg.ToneControl toneControl)
    {
        super(-1, "");
        this.updateType = UpdateType.TONE_CONTROL;
        this.toneControl = toneControl;
    }

    public DcpReceiverInformationMsg(final ReceiverInformationMsg.Preset preset)
    {
        super(-1, "");
        this.updateType = UpdateType.PRESET;
        this.preset = preset;
    }

    public DcpReceiverInformationMsg(final UpdateType type, final String par)
    {
        super(-1, "");
        this.updateType = type;
        this.firmwareVer = par;
    }

    public ReceiverInformationMsg.Selector getSelector()
    {
        return selector;
    }

    public ReceiverInformationMsg.Zone getMaxVolumeZone()
    {
        return maxVolumeZone;
    }

    public ReceiverInformationMsg.ToneControl getToneControl()
    {
        return toneControl;
    }

    public ReceiverInformationMsg.Preset getPreset()
    {
        return preset;
    }

    public String getFirmwareVer()
    {
        return firmwareVer;
    }

    @NonNull
    @Override
    public String toString()
    {
        return "DCP receiver configuration: " +
                (selector != null ? "Selector=" + selector + " " : "") +
                (maxVolumeZone != null ? "MaxVol=" + maxVolumeZone.volMax + " " : "") +
                (toneControl != null ? "ToneCtrl=" + toneControl + " " : "") +
                (preset != null ? "Preset=" + preset + " " : "") +
                (firmwareVer != null ? "Firmware=" + firmwareVer + " " : "");
    }

    @Nullable
    public static DcpReceiverInformationMsg processDcpMessage(@NonNull String dcpMsg)
    {
        // Input Selector
        if (dcpMsg.startsWith(DCP_COMMAND_INPUT_SEL))
        {
            final String par = dcpMsg.substring(DCP_COMMAND_INPUT_SEL.length()).trim();
            if (DCP_COMMAND_END.equalsIgnoreCase(par))
            {
                return null;
            }
            final int sepIdx = par.indexOf(' ');
            if (sepIdx < 0)
            {
                Logging.info(DcpReceiverInformationMsg.class, "DCP selector " + par + ": separator not found");
            }
            final String code = par.substring(0, sepIdx).trim();
            final String name = par.substring(sepIdx).trim();
            final InputSelectorMsg.InputType item =
                    (InputSelectorMsg.InputType) InputSelectorMsg.searchParameter(
                            code, InputSelectorMsg.InputType.values(), InputSelectorMsg.InputType.NONE);
            if (item == InputSelectorMsg.InputType.NONE)
            {
                Logging.info(DcpReceiverInformationMsg.class, "DCP input selector not known: " + par);
                return null;
            }
            return new DcpReceiverInformationMsg(
                    new ReceiverInformationMsg.Selector(
                            item.getCode(), name, ReceiverInformationMsg.ALL_ZONES, "", false));
        }

        // Max Volume
        if (dcpMsg.startsWith(DCP_COMMAND_MAXVOL))
        {
            return processMaxVolume(dcpMsg.substring(DCP_COMMAND_MAXVOL.length()).trim(), true);
        }
        if (dcpMsg.startsWith(DCP_COMMAND_ALIMIT))
        {
            return processMaxVolume(dcpMsg.substring(DCP_COMMAND_ALIMIT.length()).trim(), false);
        }

        // Bass
        for (int i = 0; i < DCP_COMMANDS_BASS.length; i++)
        {
            if (dcpMsg.startsWith(DCP_COMMANDS_BASS[i]))
            {
                return new DcpReceiverInformationMsg(
                        new ReceiverInformationMsg.ToneControl(
                                ToneCommandMsg.BASS_KEY, -DCP_TON_MAX[i], DCP_TON_MAX[i], 1));
            }
        }

        // Treble
        for (int i = 0; i < DCP_COMMANDS_TREBLE.length; i++)
        {
            if (dcpMsg.startsWith(DCP_COMMANDS_TREBLE[i]))
            {
                return new DcpReceiverInformationMsg(
                        new ReceiverInformationMsg.ToneControl(
                                ToneCommandMsg.TREBLE_KEY, -DCP_TON_MAX[i], DCP_TON_MAX[i], 1));
            }
        }

        // Radio Preset
        if (dcpMsg.startsWith(DCP_COMMAND_PRESET))
        {
            final String par = dcpMsg.substring(DCP_COMMAND_PRESET.length()).trim();
            if (par.length() > 2)
            {
                try
                {
                    final int num = Integer.parseInt(par.substring(0, 2));
                    final String name = par.substring(2).trim();
                    if (Utils.isInteger(name))
                    {
                        final float f = (float) Integer.parseInt(name) / 100.0f;
                        final DecimalFormat df = Utils.getDecimalFormat("0.00");
                        return new DcpReceiverInformationMsg(
                                new ReceiverInformationMsg.Preset(
                                        num, /*band FM*/ 1, df.format(f), ""));
                    }
                    else
                    {
                        return new DcpReceiverInformationMsg(
                                new ReceiverInformationMsg.Preset(
                                        num, /*band DAB*/ 2, "0", name));
                    }
                }
                catch (Exception nfe)
                {
                    // nothing to do
                }
            }
            Logging.info(DcpReceiverInformationMsg.class, "DCP preset invalid: " + par);
        }

        // Firmware version
        if (dcpMsg.startsWith(DCP_COMMAND_FIRMWARE_VER))
        {
            final String par = dcpMsg.substring(DCP_COMMAND_FIRMWARE_VER.length()).trim();
            if (!DCP_COMMAND_END.equalsIgnoreCase(par))
            {
                return new DcpReceiverInformationMsg(UpdateType.FIRMWARE_VER, par);
            }
        }

        return null;
    }

    static DcpReceiverInformationMsg processMaxVolume(final String par, boolean scale)
    {
        try
        {
            int maxVolume = Integer.parseInt(par);
            if (scale && par.length() > 2)
            {
                maxVolume = maxVolume / 10;
            }
            // Create a zone with max volume received in the message
            return new DcpReceiverInformationMsg(new ReceiverInformationMsg.Zone(
                    "", "", 0, maxVolume));
        }
        catch (Exception e)
        {
            Logging.info(DcpReceiverInformationMsg.class, "Unable to parse max. volume level " + par);
            return null;
        }
    }

    @Nullable
    @Override
    public String buildDcpMsg(boolean isQuery)
    {
        return "heos://system/register_for_change_events?enable=on" + DCP_MSG_SEP
                + DCP_COMMAND_INPUT_SEL + " ?" + DCP_MSG_SEP
                + DCP_COMMAND_PRESET + " ?" + DCP_MSG_SEP
                + DCP_COMMAND_FIRMWARE_VER + " ?";
    }
}
