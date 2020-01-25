/*
 * Copyright (C) 2020. Mikhail Kulesh
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

package com.mkulesh.onpc;

import android.annotation.SuppressLint;
import android.graphics.drawable.Drawable;
import android.view.View;
import android.widget.CheckBox;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.StringRes;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.widget.AppCompatSeekBar;

import com.mkulesh.onpc.iscp.State;
import com.mkulesh.onpc.iscp.messages.CenterLevelCommandMsg;
import com.mkulesh.onpc.iscp.messages.DirectCommandMsg;
import com.mkulesh.onpc.iscp.messages.MasterVolumeMsg;
import com.mkulesh.onpc.iscp.messages.ReceiverInformationMsg;
import com.mkulesh.onpc.iscp.messages.SubwooferLevelCommandMsg;
import com.mkulesh.onpc.iscp.messages.ToneCommandMsg;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

class AudioControlManager
{
    final static String VOLUME_LEVEL = "volume_level";

    private MainActivity activity = null;
    private AlertDialog audioControlDialog = null;
    private LinearLayout volumeGroup = null;
    private LinearLayout toneBassGroup = null;
    private LinearLayout toneTrebleGroup = null;
    private LinearLayout toneDirectGroup = null;
    private LinearLayout subwooferLevelGroup = null;
    private LinearLayout centerLevelGroup = null;

    void setActivity(MainActivity activity)
    {
        this.activity = activity;
    }

    boolean isAudioControlEnabled()
    {
        return activity != null && activity.isConnected() && activity.getStateManager().getState().isOn();
    }

    boolean isVolumeLevel(View b)
    {
        return b.getTag() != null && b.getTag() instanceof String && VOLUME_LEVEL.equals(b.getTag());
    }

    private boolean isDirectCmdAvailable(@NonNull final State state)
    {
        return state.toneDirect != DirectCommandMsg.Status.NONE;
    }

    private boolean isDirectMode(@NonNull final State state)
    {
        return (isDirectCmdAvailable(state) && state.toneDirect == DirectCommandMsg.Status.ON) ||
                (state.listeningMode != null && state.listeningMode.isDirectMode());
    }

    boolean showAudioControlDialog()
    {
        if (!isAudioControlEnabled())
        {
            return false;
        }

        Logging.info(this, "open audio control dialog");

        final State state = activity.getStateManager().getState();
        final FrameLayout frameView = new FrameLayout(activity);
        activity.getLayoutInflater().inflate(R.layout.dialog_master_volume_layout, frameView);

        // Master volume
        volumeGroup = frameView.findViewById(R.id.volume_group);
        prepareVolumeGroup(state, volumeGroup);

        // Tone direct
        toneDirectGroup = frameView.findViewById(R.id.tone_direct_layout);
        if (isDirectCmdAvailable(state))
        {
            final CheckBox checkBox = toneDirectGroup.findViewById(R.id.tone_direct_checkbox);
            checkBox.setOnCheckedChangeListener((buttonView, isChecked) ->
            {
                activity.getStateManager().sendMessage(new DirectCommandMsg(
                        isChecked ? DirectCommandMsg.Status.ON : DirectCommandMsg.Status.OFF));
                final String toneCommand = state.getActiveZone() < ToneCommandMsg.ZONE_COMMANDS.length ?
                        ToneCommandMsg.ZONE_COMMANDS[state.getActiveZone()] : null;
                if (toneCommand != null)
                {
                    activity.getStateManager().sendQueries(new String[]{ toneCommand }, "requesting tone state");
                }
            });
        }

        // Tone control
        toneBassGroup = frameView.findViewById(R.id.bass_group);
        prepareToneControl(
                state, ToneCommandMsg.BASS_KEY, toneBassGroup, R.string.tone_bass);

        toneTrebleGroup = frameView.findViewById(R.id.treble_group);
        prepareToneControl(
                state, ToneCommandMsg.TREBLE_KEY, toneTrebleGroup, R.string.tone_treble);

        // Level for single channels
        subwooferLevelGroup = frameView.findViewById(R.id.subwoofer_level_group);
        prepareToneControl(
                state, SubwooferLevelCommandMsg.KEY, subwooferLevelGroup, R.string.subwoofer_level);

        centerLevelGroup = frameView.findViewById(R.id.center_level_group);
        prepareToneControl(
                state, CenterLevelCommandMsg.KEY, centerLevelGroup, R.string.center_level);

        final Drawable icon = Utils.getDrawable(activity, R.drawable.pref_volume_keys);
        Utils.setDrawableColorAttr(activity, icon, android.R.attr.textColorSecondary);

        audioControlDialog = new AlertDialog.Builder(activity)
                .setTitle(R.string.audio_control)
                .setIcon(icon)
                .setCancelable(true)
                .setView(frameView).create();

        audioControlDialog.setOnDismissListener((d) ->
        {
            Logging.info(this, "closing audio control dialog");
            audioControlDialog = null;
            volumeGroup = null;
            toneBassGroup = null;
            toneTrebleGroup = null;
            toneDirectGroup = null;
            subwooferLevelGroup = null;
            centerLevelGroup = null;
        });

        updateActiveView(state);
        audioControlDialog.show();
        Utils.fixIconColor(audioControlDialog, android.R.attr.textColorSecondary);
        return true;
    }

    void updateActiveView(@NonNull final State state)
    {
        if (audioControlDialog == null)
        {
            return;
        }
        Logging.info(this, "Updating audio control dialog");

        if (volumeGroup != null)
        {
            updateVolumeGroup(state, volumeGroup);
        }
        if (toneDirectGroup != null)
        {
            updateToneDirect(state, toneDirectGroup);
        }
        if (toneBassGroup != null)
        {
            updateToneGroup(
                    state, ToneCommandMsg.BASS_KEY, toneBassGroup, R.string.tone_bass,
                    isDirectMode(state) ? ToneCommandMsg.NO_LEVEL : state.bassLevel,
                    ToneCommandMsg.NO_LEVEL, ToneCommandMsg.ZONE_COMMANDS.length);
        }
        if (toneTrebleGroup != null)
        {
            updateToneGroup(
                    state, ToneCommandMsg.TREBLE_KEY, toneTrebleGroup, R.string.tone_treble,
                    isDirectMode(state) ? ToneCommandMsg.NO_LEVEL : state.trebleLevel,
                    ToneCommandMsg.NO_LEVEL, ToneCommandMsg.ZONE_COMMANDS.length);
        }
        if (subwooferLevelGroup != null)
        {
            updateToneGroup(
                    state, SubwooferLevelCommandMsg.KEY, subwooferLevelGroup, R.string.subwoofer_level,
                    state.subwooferLevel, SubwooferLevelCommandMsg.NO_LEVEL, 1);

        }
        if (centerLevelGroup != null)
        {
            updateToneGroup(
                    state, CenterLevelCommandMsg.KEY, centerLevelGroup, R.string.center_level,
                    state.centerLevel, CenterLevelCommandMsg.NO_LEVEL, 1);
        }
    }

    private void updateProgressLabel(@NonNull final LinearLayout group, @StringRes final int labelId, final String value)
    {
        final TextView labelField = group.findViewWithTag("tone_label");
        try
        {
            if (labelField != null)
            {
                final String labelText = activity.getString(labelId) + ": " + value;
                labelField.setText(labelText);
            }
        }
        catch (Exception e)
        {
            labelField.setText("");
        }
    }

    private void prepareVolumeGroup(@NonNull final State state, @NonNull final LinearLayout group)
    {
        final AppCompatSeekBar progressBar = group.findViewWithTag("tone_progress_bar");
        progressBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener()
        {
            int progressChanged = 0;

            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser)
            {
                progressChanged = progress;
                updateProgressLabel(group, R.string.master_volume,
                        State.getVolumeLevelStr(progressChanged, state.getActiveZoneInfo()));
            }

            public void onStartTrackingTouch(SeekBar seekBar)
            {
                // empty
            }

            public void onStopTrackingTouch(SeekBar seekBar)
            {
                if (isAudioControlEnabled())
                {
                    activity.getStateManager().sendMessage(
                            new MasterVolumeMsg(state.getActiveZone(), progressChanged));
                }
            }
        });
    }

    private void updateVolumeGroup(@NonNull final State state, @NonNull final LinearLayout group)
    {
        final AppCompatSeekBar progressBar = group.findViewWithTag("tone_progress_bar");
        final ReceiverInformationMsg.Zone zone = state.getActiveZoneInfo();
        final int scale = (zone != null && zone.getVolumeStep() == 0) ? 2 : 1;
        final int maxVolume = (zone != null && zone.getVolMax() > 0) ?
                scale * zone.getVolMax() :
                Math.max(state.volumeLevel, scale * MasterVolumeMsg.MAX_VOLUME_1_STEP);

        updateProgressLabel(group, R.string.master_volume, State.getVolumeLevelStr(state.volumeLevel, zone));

        final TextView minValue = group.findViewWithTag("tone_min_value");
        minValue.setText("0");

        final TextView maxValue = group.findViewWithTag("tone_max_value");
        maxValue.setText(State.getVolumeLevelStr(maxVolume, zone));

        progressBar.setMax(maxVolume);
        progressBar.setProgress(Math.max(0, state.volumeLevel));
    }

    private void prepareToneControl(@NonNull final State state,
                                    @NonNull final String toneKey,
                                    @NonNull final LinearLayout group,
                                    @StringRes final int labelId)
    {
        final AppCompatSeekBar progressBar = group.findViewWithTag("tone_progress_bar");
        progressBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener()
        {
            final ReceiverInformationMsg.ToneControl toneControl = state.toneControls.get(toneKey);
            int progressChanged = 0;

            private int getScaledProgress()
            {
                if (toneControl == null)
                {
                    return 0;
                }
                final float step = toneControl.getStep() == 0 ? 0.5f : toneControl.getStep();
                return (int) ((float) progressChanged * step) + toneControl.getMin();
            }

            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser)
            {
                progressChanged = progress;
                updateProgressLabel(group, labelId, Integer.toString(getScaledProgress()));
            }

            public void onStartTrackingTouch(SeekBar seekBar)
            {
                // empty
            }

            public void onStopTrackingTouch(SeekBar seekBar)
            {
                if (isAudioControlEnabled())
                {
                    final int zone = state.getActiveZone();
                    switch (toneKey)
                    {
                    case ToneCommandMsg.BASS_KEY:
                        activity.getStateManager().sendMessage(
                                new ToneCommandMsg(zone, getScaledProgress(), ToneCommandMsg.NO_LEVEL));
                        break;
                    case ToneCommandMsg.TREBLE_KEY:
                        activity.getStateManager().sendMessage(
                                new ToneCommandMsg(zone, ToneCommandMsg.NO_LEVEL, getScaledProgress()));
                        break;
                    case SubwooferLevelCommandMsg.KEY:
                        activity.getStateManager().sendMessage(new SubwooferLevelCommandMsg(getScaledProgress(), 1));
                        activity.getStateManager().sendMessage(new SubwooferLevelCommandMsg(getScaledProgress(), 2));
                        break;
                    case CenterLevelCommandMsg.KEY:
                        activity.getStateManager().sendMessage(new CenterLevelCommandMsg(getScaledProgress(), 1));
                        activity.getStateManager().sendMessage(new CenterLevelCommandMsg(getScaledProgress(), 2));
                        break;
                    }
                }
            }
        });
    }

    @SuppressLint("SetTextI18n")
    private void updateToneGroup(@NonNull final State state,
                                 @NonNull final String toneKey,
                                 @NonNull final LinearLayout group,
                                 @StringRes final int labelId,
                                 int toneLevel, final int noLevel, final int maxZone)
    {
        final AppCompatSeekBar progressBar = group.findViewWithTag("tone_progress_bar");
        final ReceiverInformationMsg.ToneControl toneControl = state.toneControls.get(toneKey);
        final boolean isTone = toneControl != null && toneLevel != noLevel && state.getActiveZone() < maxZone;
        group.setVisibility(isTone ? View.VISIBLE : View.GONE);
        if (isTone)
        {
            updateProgressLabel(group, labelId, Integer.toString(toneLevel));

            final TextView minText = group.findViewWithTag("tone_min_value");
            if (minText != null)
            {
                minText.setText(Integer.toString(toneControl.getMin()));
            }

            final TextView maxText = group.findViewWithTag("tone_max_value");
            if (maxText != null)
            {
                maxText.setText(Integer.toString(toneControl.getMax()));
            }

            final float step = toneControl.getStep() == 0 ? 0.5f : toneControl.getStep();
            final int max = (int) ((float) (toneControl.getMax() - toneControl.getMin()) / step);
            final int progress = (int) ((float) (toneLevel - toneControl.getMin()) / step);
            progressBar.setMax(max);
            progressBar.setProgress(progress);
        }
    }

    private void updateToneDirect(@NonNull final State state, @NonNull LinearLayout group)
    {
        toneDirectGroup.setVisibility(isDirectCmdAvailable(state) || isDirectMode(state) ? View.VISIBLE : View.GONE);
        final CheckBox checkBox = group.findViewById(R.id.tone_direct_checkbox);
        checkBox.setChecked(isDirectMode(state));
        checkBox.setEnabled(isDirectCmdAvailable(state));
    }
}
