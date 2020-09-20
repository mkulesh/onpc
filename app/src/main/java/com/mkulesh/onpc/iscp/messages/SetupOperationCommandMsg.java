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

package com.mkulesh.onpc.iscp.messages;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;
import androidx.annotation.StringRes;

/*
 * Setup Operation Command
 */
public class SetupOperationCommandMsg extends ISCPMessage
{
    public final static String CODE = "OSD";

    public enum Command implements StringParameterIf
    {
        MENU("MENU", R.string.cmd_description_setup, R.drawable.cmd_setup),
        UP("UP", R.string.cmd_description_up, R.drawable.cmd_up),
        DOWN("DOWN", R.string.cmd_description_down, R.drawable.cmd_down),
        RIGHT("RIGHT", R.string.cmd_description_right, R.drawable.cmd_right),
        LEFT("LEFT", R.string.cmd_description_left, R.drawable.cmd_left),
        ENTER("ENTER", R.string.cmd_description_select, R.drawable.cmd_select),
        EXIT("EXIT", R.string.cmd_description_return, R.drawable.cmd_return),
        HOME("HOME", R.string.cmd_description_home, R.drawable.cmd_home),
        QUICK("QUICK", R.string.cmd_description_quick_menu, R.drawable.cmd_quick_menu);

        final String code;

        @StringRes
        final int descriptionId;

        @DrawableRes
        final int imageId;

        Command(final String code, @StringRes final int descriptionId, @DrawableRes final int imageId)
        {
            this.code = code;
            this.descriptionId = descriptionId;
            this.imageId = imageId;
        }

        public String getCode()
        {
            return code;
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
}
