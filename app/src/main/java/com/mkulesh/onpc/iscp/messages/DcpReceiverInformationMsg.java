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
    public final static String DCP_COMMAND_INPUT_SEL_END = "END";

    private ReceiverInformationMsg.Selector selector;

    public DcpReceiverInformationMsg(final ReceiverInformationMsg.Selector selector)
    {
        super(-1, "");
        this.selector = selector;
    }

    public ReceiverInformationMsg.Selector getSelector()
    {
        return selector;
    }

    @NonNull
    @Override
    public String toString()
    {
        return "DCP receiver configuration: " +
                (selector != null ? "Selector=" + selector + " " : "");
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

        return null;
    }
}
