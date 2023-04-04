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

package com.mkulesh.onpc.config;

import android.content.Context;
import android.content.SharedPreferences;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.messages.ListeningModeMsg;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.util.ArrayList;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public class CfgAudioControl
{
    static final String SOUND_CONTROL = "sound_control";
    private static final String FORCE_AUDIO_CONTROL = "force_audio_control";
    private static final String SELECTED_LISTENING_MODES = "selected_listening_modes";
    private static final String MASTER_VOLUME_MAX = "master_volume_max";
    private static final String VOLUME_KEYS = "volume_keys";

    private static final ListeningModeMsg.Mode[] ISCP_LISTENING_MODES = new ListeningModeMsg.Mode[]{
            ListeningModeMsg.Mode.MODE_0F, // MONO
            ListeningModeMsg.Mode.MODE_00, // STEREO
            ListeningModeMsg.Mode.MODE_01, // DIRECT
            ListeningModeMsg.Mode.MODE_09, // UNPLUGGED
            ListeningModeMsg.Mode.MODE_08, // ORCHESTRA
            ListeningModeMsg.Mode.MODE_0A, // STUDIO-MIX
            ListeningModeMsg.Mode.MODE_11, // PURE AUDIO
            ListeningModeMsg.Mode.MODE_0C, // ALL CH STEREO
            ListeningModeMsg.Mode.MODE_0B, // TV Logic
            ListeningModeMsg.Mode.MODE_0D, // Theater-Dimensional
            ListeningModeMsg.Mode.MODE_40, // DOLBY DIGITAL
            ListeningModeMsg.Mode.MODE_80, // DOLBY SURROUND
            ListeningModeMsg.Mode.MODE_84, // Dolby THX Cinema
            ListeningModeMsg.Mode.MODE_8B, // Dolby THX Music
            ListeningModeMsg.Mode.MODE_89, // Dolby THX Games
            ListeningModeMsg.Mode.MODE_03, // Game-RPG
            ListeningModeMsg.Mode.MODE_05, // Game-Action
            ListeningModeMsg.Mode.MODE_06, // Game-Rock
            ListeningModeMsg.Mode.MODE_0E, // Game-Sports
            ListeningModeMsg.Mode.MODE_82, // DTS NEURAL:X
            ListeningModeMsg.Mode.MODE_17  // DTS Virtual:X
    };

    private static final ListeningModeMsg.Mode[] DCP_LISTENING_MODES = new ListeningModeMsg.Mode[]{
            ListeningModeMsg.Mode.DCP_DIRECT,
            ListeningModeMsg.Mode.DCP_PURE_DIRECT,
            ListeningModeMsg.Mode.DCP_STEREO,
            ListeningModeMsg.Mode.DCP_AUTO,
            ListeningModeMsg.Mode.DCP_DOLBY_DIGITAL,
            ListeningModeMsg.Mode.DCP_DTS_SURROUND,
            ListeningModeMsg.Mode.DCP_AURO3D,
            ListeningModeMsg.Mode.DCP_AURO2DSURR,
            ListeningModeMsg.Mode.DCP_MCH_STEREO,
            ListeningModeMsg.Mode.DCP_WIDE_SCREEN,
            ListeningModeMsg.Mode.DCP_SUPER_STADIUM,
            ListeningModeMsg.Mode.DCP_ROCK_ARENA,
            ListeningModeMsg.Mode.DCP_JAZZ_CLUB,
            ListeningModeMsg.Mode.DCP_CLASSIC_CONCERT,
            ListeningModeMsg.Mode.DCP_MONO_MOVIE,
            ListeningModeMsg.Mode.DCP_MATRIX,
            ListeningModeMsg.Mode.DCP_VIDEO_GAME,
            ListeningModeMsg.Mode.DCP_VIRTUAL
    };

    private SharedPreferences preferences;
    private String soundControl;

    void setPreferences(SharedPreferences preferences)
    {
        this.preferences = preferences;
    }

    void read(final Context context)
    {
        soundControl = preferences.getString(CfgAudioControl.SOUND_CONTROL,
                context.getResources().getString(R.string.pref_sound_control_default));
    }

    public String getSoundControl()
    {
        return soundControl;
    }

    public boolean isForceAudioControl()
    {
        return preferences.getBoolean(FORCE_AUDIO_CONTROL, false);
    }

    @NonNull
    private String getMasterVolumeMaxParameter()
    {
        return MASTER_VOLUME_MAX + "_" + preferences.getString(Configuration.MODEL, "NONE");
    }

    public int getMasterVolumeMax()
    {
        return preferences.getInt(getMasterVolumeMaxParameter(), Integer.MAX_VALUE);
    }

    public void setMasterVolumeMax(int limit)
    {
        Logging.info(this, "Save volume max limit: " + limit);
        SharedPreferences.Editor prefEditor = preferences.edit();
        prefEditor.putInt(getMasterVolumeMaxParameter(), limit);
        prefEditor.apply();
    }

    @NonNull
    public ArrayList<ListeningModeMsg.Mode> getSortedListeningModes(
            boolean allItems,
            @Nullable ListeningModeMsg.Mode activeItem,
            @NonNull Utils.ProtoType protoType)
    {
        final ArrayList<ListeningModeMsg.Mode> result = new ArrayList<>();
        final ArrayList<String> defItems = new ArrayList<>();
        for (ListeningModeMsg.Mode i : getListeningModes(protoType))
        {
            defItems.add(i.getCode());
        }
        final String par = getSelectedListeningModePar(protoType);
        for (CheckableItem sp : CheckableItem.readFromPreference(preferences, par, defItems))
        {
            final boolean visible = allItems || sp.checked ||
                    (activeItem != null && activeItem.getCode().equals(sp.code));
            for (ListeningModeMsg.Mode i : getListeningModes(protoType))
            {
                if (visible && i.getCode().equals(sp.code))
                {
                    result.add(i);
                }
            }
        }
        return result;
    }

    public boolean isVolumeKeys()
    {
        return preferences.getBoolean(VOLUME_KEYS, false);
    }

    public static ListeningModeMsg.Mode[] getListeningModes(@NonNull Utils.ProtoType protoType)
    {
        return protoType == Utils.ProtoType.ISCP ? ISCP_LISTENING_MODES : DCP_LISTENING_MODES;
    }

    public static String getSelectedListeningModePar(@NonNull Utils.ProtoType protoType)
    {
        String par = SELECTED_LISTENING_MODES;
        if (protoType == Utils.ProtoType.DCP)
        {
            par += "_DCP";
        }
        return par;
    }
}
