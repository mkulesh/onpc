/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2023 by Mikhail Kulesh
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

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;

/*
 * Setup Operation Command
 */
public class SetupOperationCommandMsg extends ISCPMessage
{
    public final static String CODE = "OSD";

    public enum Command implements DcpStringParameterIf
    {
        MENU("MENU", "MEN ON", R.string.cmd_description_setup, R.drawable.cmd_setup),
        UP("UP", "CUP", R.string.cmd_description_up, R.drawable.cmd_up),
        DOWN("DOWN", "CDN", R.string.cmd_description_down, R.drawable.cmd_down),
        RIGHT("RIGHT", "CRT", R.string.cmd_description_right, R.drawable.cmd_right),
        LEFT("LEFT", "CLT", R.string.cmd_description_left, R.drawable.cmd_left),
        ENTER("ENTER", "ENT", R.string.cmd_description_select, R.drawable.cmd_select),
        EXIT("EXIT", "RTN", R.string.cmd_description_return, R.drawable.cmd_return),
        HOME("HOME", "N/A", R.string.cmd_description_home, R.drawable.cmd_home),
        QUICK("QUICK", "OPT", R.string.cmd_description_quick_menu, R.drawable.cmd_quick_menu);

        final String code, dcpCode;

        @StringRes
        final int descriptionId;

        @DrawableRes
        final int imageId;

        Command(final String code, final String dcpCode, @StringRes final int descriptionId, @DrawableRes final int imageId)
        {
            this.code = code;
            this.dcpCode = dcpCode;
            this.descriptionId = descriptionId;
            this.imageId = imageId;
        }

        public String getCode()
        {
            return code;
        }

        @NonNull
        public String getDcpCode()
        {
            return dcpCode;
        }

        @StringRes
        public int getDescriptionId()
        {
            return descriptionId;
        }

        @DrawableRes
        public int getImageId()
        {
            return imageId;
        }
    }

    private final Command command;

    SetupOperationCommandMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        this.command = (Command) searchParameter(data, Command.values(), Command.HOME);
    }

    public SetupOperationCommandMsg(final String command)
    {
        super(0, null);
        this.command = (Command) searchParameter(command, Command.values(), null);
    }

    public Command getCommand()
    {
        return command;
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + data
                + "; CMD=" + (command == null ? "null" : command.toString()) + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return command == null ? null : new EISCPMessage(CODE, command.getCode());
    }

    @Override
    public boolean hasImpactOnMediaList()
    {
        return false;
    }

    /*
     * Denon control protocol
     */
    private final static String DCP_COMMAND = "MN";

    @Nullable
    @Override
    public String buildDcpMsg(boolean isQuery)
    {
        return (command != null && !isQuery) ? DCP_COMMAND + command.getDcpCode() : null;
    }
}
