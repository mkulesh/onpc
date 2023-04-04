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

import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/*
 * Denon control protocol - maximum volume and input selectors
 */
public class DcpReceiverInformationMsg extends ISCPMessage
{
    public final static String CODE = "D01";

    public final static int NO_LEVEL = -1;

    // Input selectors
    public final static String DCP_COMMAND_INPUT_SEL = "SSFUN";
    public final static String DCP_COMMAND_INPUT_SEL_END = "END";

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

    private ReceiverInformationMsg.Selector selector = null;
    private int maxVolume = NO_LEVEL;
    private final List<ReceiverInformationMsg.Zone> zones = new ArrayList<>();

    private ReceiverInformationMsg.ToneControl toneControl;

    private ReceiverInformationMsg.Preset preset;

    public DcpReceiverInformationMsg(final ReceiverInformationMsg.Selector selector)
    {
        super(-1, "");
        this.selector = selector;
    }

    public DcpReceiverInformationMsg(int maxVolume, final List<ReceiverInformationMsg.Zone> zones)
    {
        super(-1, "");
        this.maxVolume = maxVolume;
        this.zones.addAll(zones);
    }

    public DcpReceiverInformationMsg(final ReceiverInformationMsg.ToneControl toneControl)
    {
        super(-1, "");
        this.toneControl = toneControl;
    }

    public DcpReceiverInformationMsg(final ReceiverInformationMsg.Preset preset)
    {
        super(-1, "");
        this.preset = preset;
    }

    public ReceiverInformationMsg.Selector getSelector()
    {
        return selector;
    }

    public List<ReceiverInformationMsg.Zone> getZones()
    {
        return zones;
    }

    public ReceiverInformationMsg.ToneControl getToneControl()
    {
        return toneControl;
    }

    public ReceiverInformationMsg.Preset getPreset()
    {
        return preset;
    }

    @NonNull
    @Override
    public String toString()
    {
        return "DCP receiver configuration: " +
                (selector != null ? "Selector=" + selector + " " : "") +
                (maxVolume != NO_LEVEL ? "MaxVol=" + maxVolume + " " : "") +
                (toneControl != null ? "ToneCtrl=" + toneControl + " " : "") +
                (preset != null ? "Preset=" + preset + " " : "");
    }

    @Nullable
    public static DcpReceiverInformationMsg processDcpMessage(@NonNull String dcpMsg)
    {
        // Input Selector
        if (dcpMsg.startsWith(DCP_COMMAND_INPUT_SEL))
        {
            final String par = dcpMsg.substring(DCP_COMMAND_INPUT_SEL.length()).trim();
            if (DCP_COMMAND_INPUT_SEL_END.equalsIgnoreCase(par))
            {
                // End of list
                return new DcpReceiverInformationMsg(
                        new ReceiverInformationMsg.Selector(
                                DCP_COMMAND_INPUT_SEL_END, DCP_COMMAND_INPUT_SEL_END, 0xFF, "", false));
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
            // Add 3 zones with volume step 0.5 and max volume received in the message
            List<ReceiverInformationMsg.Zone> zones = new ArrayList<>();
            zones.add(new ReceiverInformationMsg.Zone("1", "Main", 0, maxVolume));
            zones.add(new ReceiverInformationMsg.Zone("2", "Zone2", 0, maxVolume));
            zones.add(new ReceiverInformationMsg.Zone("3", "Zone3", 0, maxVolume));
            return new DcpReceiverInformationMsg(maxVolume, zones);
        }
        catch (Exception e)
        {
            Logging.info(DcpReceiverInformationMsg.class, "Unable to parse max. volume level " + par);
            return null;
        }
    }
}
