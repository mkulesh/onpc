/*
 * Copyright (C) 2018. Mikhail Kulesh
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
 * CD Player Operation Command
 */
public class CdPlayerOperationCommandMsg extends ISCPMessage
{
    public final static String CODE = "CCD";

    // Controls that allow the control of build-in CD player via CCD command
    public final static String CONTROL_CD_INT1 = "CD Control";
    public final static String CONTROL_CD_INT2 = "CD Control(NewRemote)";

    public enum Command implements StringParameterIf
    {
        POWER(R.string.cd_cmd_power, R.drawable.menu_power_standby),
        TRACK(R.string.cd_cmd_track),
        PLAY(R.string.cd_cmd_play, R.drawable.cmd_play),
        STOP(R.string.cd_cmd_stop, R.drawable.cmd_stop),
        PAUSE(R.string.cd_cmd_pause, R.drawable.cmd_pause),
        SKIP_F(R.string.cd_cmd_skip_f, R.drawable.cmd_next, "SKIP.F"),
        SKIP_R(R.string.cd_cmd_skip_r, R.drawable.cmd_previous, "SKIP.R"),
        MEMORY(R.string.cd_cmd_memory),
        CLEAR(R.string.cd_cmd_clear),
        REPEAT(R.string.cd_cmd_repeat, R.drawable.repeat_all),
        RANDOM(R.string.cd_cmd_random, R.drawable.cmd_random),
        DISP(R.string.cd_cmd_disp),
        D_MODE(R.string.cd_cmd_d_mode),
        FF(R.string.cd_cmd_ff),
        REW(R.string.cd_cmd_rew),
        OP_CL(R.string.cd_cmd_op_cl, R.drawable.cd_eject, "OP/CL"),
        NUMBER_1(R.string.cd_cmd_number_1, "1"),
        NUMBER_2(R.string.cd_cmd_number_2, "2"),
        NUMBER_3(R.string.cd_cmd_number_3, "3"),
        NUMBER_4(R.string.cd_cmd_number_4, "4"),
        NUMBER_5(R.string.cd_cmd_number_5, "5"),
        NUMBER_6(R.string.cd_cmd_number_6, "6"),
        NUMBER_7(R.string.cd_cmd_number_7, "7"),
        NUMBER_8(R.string.cd_cmd_number_8, "8"),
        NUMBER_9(R.string.cd_cmd_number_9, "9"),
        NUMBER_0(R.string.cd_cmd_number_0, "0"),
        NUMBER_10(R.string.cd_cmd_number_10, "10"),
        NUMBER_GREATER_10(R.string.cd_cmd_number_greater_10, "+10"),
        DISC_F(R.string.cd_cmd_disc_f),
        DISC_R(R.string.cd_cmd_disc_r),
        DISC1(R.string.cd_cmd_disc1),
        DISC2(R.string.cd_cmd_disc2),
        DISC3(R.string.cd_cmd_disc3),
        DISC4(R.string.cd_cmd_disc4),
        DISC5(R.string.cd_cmd_disc5),
        DISC6(R.string.cd_cmd_disc6);

        @StringRes
        final int descriptionId;

        @DrawableRes
        final int imageId;
        final String cmd;

        Command(@StringRes final int descriptionId)
        {
            this.descriptionId = descriptionId;
            this.imageId = R.drawable.media_item_unknown;
            this.cmd = null;
        }

        Command(@StringRes final int descriptionId, @DrawableRes final int imageId)
        {
            this.descriptionId = descriptionId;
            this.imageId = imageId;
            this.cmd = null;
        }

        Command(@StringRes final int descriptionId, final String cmd)
        {
            this.descriptionId = descriptionId;
            this.imageId = R.drawable.media_item_unknown;
            this.cmd = cmd;
        }

        Command(@StringRes final int descriptionId, @DrawableRes final int imageId, final String cmd)
        {
            this.descriptionId = descriptionId;
            this.imageId = imageId;
            this.cmd = cmd;
        }

        public String getCode()
        {
            return toString();
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

        String getCmd()
        {
            return cmd != null ? cmd : getCode();
        }
    }

    private final Command command;

    CdPlayerOperationCommandMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        this.command = (Command) searchParameter(data, Command.values(), null);
    }

    public CdPlayerOperationCommandMsg(final String command)
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
                + "; CMD=" + (command == null ? "null" : command.getCmd())
                + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return command == null ? null : new EISCPMessage(CODE, command.getCmd());
    }

    @Override
    public boolean hasImpactOnMediaList()
    {
        return false;
    }

    @NonNull
    public static String convertOpCommand(@NonNull final String opCommand)
    {
        switch (opCommand)
        {
            case "TRDN":
                return Command.SKIP_R.getCode();
            case "TRUP":
                return Command.SKIP_F.getCode();
            default:
                return opCommand;
        }
    }
}
