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

/*
 * Network/USB Operation Command (Network Model Only after TX-NR905)
 */
public class OperationCommandMsg extends ISCPMessage
{
    public final static String CODE = "NTC";

    public enum Command implements StringParameterIf
    {
        PLAY("PLAY", R.string.cmd_description_play, R.drawable.cmd_play),
        STOP("STOP", R.string.cmd_description_stop, R.drawable.cmd_stop),
        PAUSE("PAUSE", R.string.cmd_description_pause, R.drawable.cmd_pause),
        P_P("P/P", R.string.cmd_description_p_p),
        TRUP("TRUP", R.string.cmd_description_trup, R.drawable.cmd_next),
        TRDN("TRDN", R.string.cmd_description_trdn, R.drawable.cmd_previous),
        FF("FF", R.string.cmd_description_ff),
        REW("REW", R.string.cmd_description_rew),
        REPEAT("REPEAT", R.string.cmd_description_repeat, R.drawable.cmd_repeat),
        RANDOM("RANDOM", R.string.cmd_description_random, R.drawable.cmd_random),
        REP_SHF("REP/SHF", R.string.cmd_description_rep_shf),
        DISPLAY("DISPLAY", R.string.cmd_description_display),
        ALBUM("ALBUM", R.string.cmd_description_album),
        ARTIST("ARTIST", R.string.cmd_description_artist),
        GENRE("GENRE", R.string.cmd_description_genre),
        PLAYLIST("PLAYLIST", R.string.cmd_description_playlist),
        RIGHT("RIGHT", R.string.cmd_description_right),
        LEFT("LEFT", R.string.cmd_description_left),
        UP("UP", R.string.cmd_description_up),
        DOWN("DOWN", R.string.cmd_description_down),
        SELECT("SELECT", R.string.cmd_description_select),
        KEY_0("0", R.string.cmd_description_key_0),
        KEY_1("1", R.string.cmd_description_key_1),
        KEY_2("2", R.string.cmd_description_key_2),
        KEY_3("3", R.string.cmd_description_key_3),
        KEY_4("4", R.string.cmd_description_key_4),
        KEY_5("5", R.string.cmd_description_key_5),
        KEY_6("6", R.string.cmd_description_key_6),
        KEY_7("7", R.string.cmd_description_key_7),
        KEY_8("8", R.string.cmd_description_key_8),
        KEY_9("9", R.string.cmd_description_key_9),
        DELETE("DELETE", R.string.cmd_description_delete),
        CAPS("CAPS", R.string.cmd_description_caps),
        LOCATION("LOCATION", R.string.cmd_description_location),
        LANGUAGE("LANGUAGE", R.string.cmd_description_language),
        SETUP("SETUP", R.string.cmd_description_setup),
        RETURN("RETURN", R.string.cmd_description_return, R.drawable.cmd_return),
        CHUP("CHUP", R.string.cmd_description_chup),
        CHDN("CHDN", R.string.cmd_description_chdn),
        MENU("MENU", R.string.cmd_description_menu),
        TOP("TOP", R.string.cmd_description_top, R.drawable.cmd_top),
        MODE("MODE", R.string.cmd_description_mode),
        LIST("LIST", R.string.cmd_description_list),
        MEMORY("MEMORY", R.string.cmd_description_memory),
        F1("F1", R.string.cmd_description_f1),
        F2("F2", R.string.cmd_description_f2);

        final String code;
        final int descriptionId;
        final int imageId;

        Command(final String code, final int descriptionId)
        {
            this.code = code;
            this.descriptionId = descriptionId;
            this.imageId = -1;
        }

        Command(final String code, final int descriptionId, final int imageId)
        {
            this.code = code;
            this.descriptionId = descriptionId;
            this.imageId = imageId;
        }

        public String getCode()
        {
            return code;
        }

        public int getDescriptionId()
        {
            return descriptionId;
        }

        public int getImageId()
        {
            return imageId;
        }

        public boolean isImageValid()
        {
            return imageId != -1;
        }
    }

    private final Command command;

    public OperationCommandMsg(final String command)
    {
        super(0, null);
        this.command = (Command) OperationCommandMsg.searchParameter(command, Command.values(), null);
    }

    public OperationCommandMsg(final Command command)
    {
        super(0, null);
        this.command = command;
    }

    public Command getCommand()
    {
        return command;
    }

    @Override
    public String toString()
    {
        return CODE + "[" + (command == null ? "null" : command.toString()) + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return command == null ? null : new EISCPMessage('1', CODE, command.getCode());
    }
}
