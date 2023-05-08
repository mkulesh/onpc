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

import java.util.Map;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/*
 * NET/USB/CD Play Status (3 letters)
 */
public class PlayStatusMsg extends ISCPMessage
{
    public final static String CODE = "NST";
    public final static String CD_CODE = "CST";

    public enum UpdateType
    {
        ALL,
        PLAY_STATE,
        PLAY_MODE,
        REPEAT,
        SHUFFLE
    }

    final private UpdateType updateType;

    /*
     * Play Status: "S": STOP, "P": Play, "p": Pause, "F": FF, "R": FR, "E": EOF
     */
    public enum PlayStatus implements DcpCharParameterIf
    {
        STOP('S'), PLAY('P'), PAUSE('p'), FF('F'), FR('R'), EOF('E');
        final Character code;

        PlayStatus(Character code)
        {
            this.code = code;
        }

        public Character getCode()
        {
            return code;
        }

        @NonNull
        @Override
        public String getDcpCode()
        {
            return name();
        }
    }

    private PlayStatus playStatus = PlayStatus.EOF;

    /*
     * Repeat Status: "-": Off, "R": All, "F": Folder, "1": Repeat 1, "x": disable
     */
    public enum RepeatStatus implements DcpCharParameterIf
    {
        OFF('-', "off", R.drawable.repeat_off),
        ALL('R', "on_all", R.drawable.repeat_all),
        FOLDER('F', "NONE", R.drawable.repeat_folder),
        REPEAT_1('1', "on_one", R.drawable.repeat_once),
        DISABLE('x', "NONE", R.drawable.repeat_off);

        final Character code;
        final String dcpCode;

        @DrawableRes
        final int imageId;

        RepeatStatus(Character code, String dcpCode, @DrawableRes final int imageId)
        {
            this.code = code;
            this.dcpCode = dcpCode;
            this.imageId = imageId;
        }

        public Character getCode()
        {
            return code;
        }

        @DrawableRes
        public int getImageId()
        {
            return imageId;
        }

        @NonNull
        @Override
        public String getDcpCode()
        {
            return dcpCode;
        }
    }

    private RepeatStatus repeatStatus = RepeatStatus.DISABLE;

    /*
     * Shuffle Status: "-": Off, "S": All , "A": Album, "F": Folder, "x": disable
     */
    public enum ShuffleStatus implements DcpCharParameterIf
    {
        OFF('-', "off"),
        ALL('S', "on"),
        ALBUM('A', "NONE"),
        FOLDER('F', "NONE"),
        DISABLE('x', "NONE");

        final Character code;
        final String dcpCode;

        ShuffleStatus(Character code, String dcpCode)
        {
            this.code = code;
            this.dcpCode = dcpCode;
        }

        public Character getCode()
        {
            return code;
        }

        @NonNull
        @Override
        public String getDcpCode()
        {
            return dcpCode;
        }
    }

    private ShuffleStatus shuffleStatus = ShuffleStatus.DISABLE;

    PlayStatusMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        updateType = UpdateType.ALL;
        if (data.length() > 0)
        {
            playStatus = (PlayStatus) searchParameter(data.charAt(0), PlayStatus.values(), playStatus);
        }
        if (data.length() > 1)
        {
            repeatStatus = (RepeatStatus) searchParameter(data.charAt(1), RepeatStatus.values(), repeatStatus);
        }
        if (data.length() > 2)
        {
            shuffleStatus = (ShuffleStatus) searchParameter(data.charAt(2), ShuffleStatus.values(), shuffleStatus);
        }
    }

    PlayStatusMsg(PlayStatus playStatus)
    {
        super(0, null);
        this.updateType = UpdateType.PLAY_STATE;
        this.playStatus = playStatus;
    }

    PlayStatusMsg(RepeatStatus repeatStatus, ShuffleStatus shuffleStatus)
    {
        super(0, null);
        this.updateType = UpdateType.PLAY_MODE;
        this.repeatStatus = repeatStatus;
        this.shuffleStatus = shuffleStatus;
    }

    PlayStatusMsg(RepeatStatus repeatStatus)
    {
        super(0, null);
        this.updateType = UpdateType.REPEAT;
        this.repeatStatus = repeatStatus;
    }

    PlayStatusMsg(ShuffleStatus shuffleStatus)
    {
        super(0, null);
        this.updateType = UpdateType.SHUFFLE;
        this.shuffleStatus = shuffleStatus;
    }

    public UpdateType getUpdateType()
    {
        return updateType;
    }

    public PlayStatus getPlayStatus()
    {
        return playStatus;
    }

    public RepeatStatus getRepeatStatus()
    {
        return repeatStatus;
    }

    public ShuffleStatus getShuffleStatus()
    {
        return shuffleStatus;
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + data
                + "; PLAY=" + playStatus.toString()
                + "; REPEAT=" + repeatStatus.toString()
                + "; SHUFFLE=" + shuffleStatus.toString()
                + "]";
    }

    /*
     * Denon control protocol
     * - Player State Changed
     * {
     * "heos": {
     *     "command": "event/player_state_changed",
     *     "message": "pid='player_id'&state='play_state'"
     *     }
     * }
     * - Get Play State: heos://player/get_play_state?pid=player_id
     * {
     * "heos": {
     *     "command": "player/get_play_state",
     *     "result": "success",
     *     "message": "pid='player_id'&state='play_state'"
     *     }
     * }
     * - Get Play Mode: heos://player/get_play_mode?pid=player_id
     * - Player Repeat Mode Changed
     * {
     * "heos": {
     *     "command": "event/repeat_mode_changed",
     *     "message": "pid=’player_id’&repeat='on_all_or_on_one_or_off'”
     *     }
     * }
     * -  Player Shuffle Mode Changed
     * {
     *     "heos": {
     *     "command": "event/shuffle_mode_changed",
     *     "message": "pid=’player_id’&shuffle='on_or_off'”
     *     }
     * }
     */
    private final static String HEOS_EVENT_STATE = "event/player_state_changed";
    private final static String HEOS_EVENT_REPEAT = "event/repeat_mode_changed";
    private final static String HEOS_EVENT_SHUFFLE = "event/shuffle_mode_changed";
    private final static String HEOS_COMMAND_STATE = "player/get_play_state";
    private final static String HEOS_COMMAND_MODE = "player/get_play_mode";

    @Nullable
    public static PlayStatusMsg processHeosMessage(@NonNull final String command, @NonNull final Map<String, String> tokens)
    {
        if (HEOS_EVENT_STATE.equals(command) ||
                HEOS_EVENT_REPEAT.equals(command) ||
                HEOS_EVENT_SHUFFLE.equals(command) ||
                HEOS_COMMAND_STATE.equals(command) ||
                HEOS_COMMAND_MODE.equals(command))
        {
            if (HEOS_EVENT_STATE.equals(command) || HEOS_COMMAND_STATE.equals(command))
            {
                final PlayStatus s = (PlayStatus) searchDcpParameter(tokens.get("state"), PlayStatus.values());
                if (s != null)
                {
                    return new PlayStatusMsg(s);
                }
            }
            if (HEOS_COMMAND_MODE.equals(command))
            {
                final RepeatStatus r = (RepeatStatus) searchDcpParameter(tokens.get("repeat"), RepeatStatus.values());
                final ShuffleStatus s = (ShuffleStatus) searchDcpParameter(tokens.get("shuffle"), ShuffleStatus.values());
                if (r != null && s != null)
                {
                    return new PlayStatusMsg(r, s);
                }
            }
            if (HEOS_EVENT_REPEAT.equals(command))
            {
                final RepeatStatus r = (RepeatStatus) searchDcpParameter(tokens.get("repeat"), RepeatStatus.values());
                if (r != null)
                {
                    return new PlayStatusMsg(r);
                }
            }
            if (HEOS_EVENT_SHUFFLE.equals(command))
            {
                final ShuffleStatus s = (ShuffleStatus) searchDcpParameter(tokens.get("shuffle"), ShuffleStatus.values());
                if (s != null)
                {
                    return new PlayStatusMsg(s);
                }
            }
        }
        return null;
    }

    @Nullable
    @Override
    public String buildDcpMsg(boolean isQuery)
    {
        if (isQuery)
        {
            return "heos://" + HEOS_COMMAND_STATE + "?pid=" + DCP_HEOS_PID +
                    DCP_MSG_SEP +
                    "heos://" + HEOS_COMMAND_MODE + "?pid=" + DCP_HEOS_PID;
        }
        return null;
    }
}
