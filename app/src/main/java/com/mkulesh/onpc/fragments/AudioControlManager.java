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

package com.mkulesh.onpc.fragments;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import com.mkulesh.onpc.MainActivity;
import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.State;
import com.mkulesh.onpc.iscp.messages.AudioMutingMsg;
import com.mkulesh.onpc.iscp.messages.CenterLevelCommandMsg;
import com.mkulesh.onpc.iscp.messages.DirectCommandMsg;
import com.mkulesh.onpc.iscp.messages.MasterVolumeMsg;
import com.mkulesh.onpc.iscp.messages.ReceiverInformationMsg;
import com.mkulesh.onpc.iscp.messages.SubwooferLevelCommandMsg;
import com.mkulesh.onpc.iscp.messages.ToneCommandMsg;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.view.ContextThemeWrapper;
import androidx.appcompat.widget.AppCompatButton;
import androidx.appcompat.widget.AppCompatImageButton;
import androidx.appcompat.widget.AppCompatSeekBar;

class AudioControlManager
{
    final static private String VOLUME_LEVEL = "volume_level";

    public interface MasterVolumeInterface
    {
        void onMasterVolumeMaxUpdate(@NonNull final State state);

        void onMasterVolumeChange(int progressChanged);
    }

    private MainActivity activity = null;
    private MasterVolumeInterface masterVolumeInterface = null;
    private boolean forceAudioControl = false;
    private AlertDialog audioControlDialog = null;
    private LinearLayout volumeGroup = null;
    private LinearLayout toneBassGroup = null;
    private LinearLayout toneTrebleGroup = null;
    private LinearLayout toneDirectGroup = null;
    private LinearLayout subwooferLevelGroup = null;
    private LinearLayout centerLevelGroup = null;

    void setActivity(MainActivity activity, MasterVolumeInterface masterVolumeInterface)
    {
        this.activity = activity;
        this.masterVolumeInterface = masterVolumeInterface;
        if (activity != null)
        {
            this.forceAudioControl = activity.getConfiguration().audioControl.isForceAudioControl();
        }
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

    private AlertDialog createDialog(@NonNull final FrameLayout frameView, @DrawableRes final int iconId, @StringRes final int titleId)
    {
        final Drawable icon = Utils.getDrawable(activity, iconId);
        Utils.setDrawableColorAttr(activity, icon, android.R.attr.textColorSecondary);
        return new AlertDialog.Builder(activity)
                .setTitle(titleId)
                .setIcon(icon)
                .setCancelable(true)
                .setView(frameView)
                .setPositiveButton(activity.getResources().getString(R.string.action_ok), (dialog1, which) -> dialog1.dismiss())
                .create();
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

        audioControlDialog = createDialog(frameView, R.drawable.volume_audio_control, R.string.app_control_audio_control);
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

    private void updateProgressLabel(@NonNull final ViewGroup group, @StringRes final int labelId, final String value)
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
        final AppCompatImageButton maxVolumeBtn = group.findViewWithTag("tone_extended_cmd");
        {
            maxVolumeBtn.setVisibility(View.VISIBLE);
            maxVolumeBtn.setImageResource(R.drawable.volume_max_limit);
            maxVolumeBtn.setContentDescription(activity.getString(R.string.master_volume_restrict));
            maxVolumeBtn.setLongClickable(true);
            maxVolumeBtn.setOnLongClickListener(v -> Utils.showButtonDescription(activity, v));
            maxVolumeBtn.setClickable(true);
            maxVolumeBtn.setOnClickListener(v -> showMasterVolumeMaxDialog(state));
            Utils.setButtonEnabled(activity, maxVolumeBtn, true);
        }

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

    public int getVolumeMax(@NonNull final State state, @Nullable final ReceiverInformationMsg.Zone zone)
    {
        final int scale = (zone != null && zone.getVolumeStep() == 0) ? 2 : 1;
        return (zone != null && zone.getVolMax() > 0) ?
                scale * zone.getVolMax() :
                Math.max(state.volumeLevel, scale * MasterVolumeMsg.MAX_VOLUME_1_STEP);
    }

    private void updateVolumeGroup(@NonNull final State state, @NonNull final LinearLayout group)
    {
        final AppCompatSeekBar progressBar = group.findViewWithTag("tone_progress_bar");
        final ReceiverInformationMsg.Zone zone = state.getActiveZoneInfo();
        final int maxVolume = Math.min(getVolumeMax(state, zone),
                activity.getConfiguration().audioControl.getMasterVolumeMax());

        updateProgressLabel(group, R.string.master_volume, State.getVolumeLevelStr(state.volumeLevel, zone));

        final TextView minValue = group.findViewWithTag("tone_min_value");
        minValue.setText("0");

        final TextView maxValue = group.findViewWithTag("tone_max_value");
        maxValue.setText(State.getVolumeLevelStr(maxVolume, zone));

        progressBar.setMax(maxVolume);
        progressBar.setProgress(Math.max(0, state.volumeLevel));
    }

    private void showMasterVolumeMaxDialog(@NonNull final State state)
    {
        final FrameLayout frameView = new FrameLayout(activity);
        activity.getLayoutInflater().inflate(R.layout.dialog_master_volume_max, frameView);

        final ReceiverInformationMsg.Zone zone = state.getActiveZoneInfo();
        final int maxVolume = getVolumeMax(state, zone);

        final TextView minValue = frameView.findViewWithTag("tone_min_value");
        minValue.setText("0");

        final TextView maxValue = frameView.findViewWithTag("tone_max_value");
        maxValue.setText(State.getVolumeLevelStr(maxVolume, zone));

        final AppCompatSeekBar progressBar = frameView.findViewWithTag("tone_progress_bar");
        progressBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener()
        {
            int progressChanged = 0;

            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser)
            {
                progressChanged = progress;
                updateProgressLabel(frameView, R.string.master_volume_max,
                        State.getVolumeLevelStr(progressChanged, state.getActiveZoneInfo()));
            }

            public void onStartTrackingTouch(SeekBar seekBar)
            {
                // empty
            }

            public void onStopTrackingTouch(SeekBar seekBar)
            {
                activity.getConfiguration().audioControl.setMasterVolumeMax(progressChanged);
            }
        });
        progressBar.setMax(maxVolume);
        progressBar.setProgress(Math.min(maxVolume,
                activity.getConfiguration().audioControl.getMasterVolumeMax()));

        final AlertDialog masterVolumeMaxDialog = createDialog(frameView, R.drawable.volume_max_limit, R.string.master_volume_restrict);
        masterVolumeMaxDialog.setOnDismissListener((d) ->
        {
            if (volumeGroup != null)
            {
                updateVolumeGroup(state, volumeGroup);
            }
            if (masterVolumeInterface != null)
            {
                masterVolumeInterface.onMasterVolumeMaxUpdate(state);
            }
        });

        masterVolumeMaxDialog.show();
        Utils.fixIconColor(masterVolumeMaxDialog, android.R.attr.textColorSecondary);
    }

    private void prepareToneControl(@NonNull final State state,
                                    @NonNull final String toneKey,
                                    @NonNull final LinearLayout group,
                                    @StringRes final int labelId)
    {
        final AppCompatSeekBar progressBar = group.findViewWithTag("tone_progress_bar");
        progressBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener()
        {
            final ReceiverInformationMsg.ToneControl toneControl = state.getToneControl(toneKey, forceAudioControl);
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
                        activity.getStateManager().sendMessage(new SubwooferLevelCommandMsg(getScaledProgress(), state.subwooferCmdLength));
                        break;
                    case CenterLevelCommandMsg.KEY:
                        activity.getStateManager().sendMessage(new CenterLevelCommandMsg(getScaledProgress(), state.centerCmdLength));
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
        final ReceiverInformationMsg.ToneControl toneControl = state.getToneControl(toneKey, forceAudioControl);
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

    void createButtonsSoundControl(
            @NonNull final BaseFragment fragment,
            @NonNull final LinearLayout layout)
    {
        // audio muting
        {
            final AudioMutingMsg.Status status = AudioMutingMsg.Status.TOGGLE;
            layout.addView(fragment.createButton(
                    R.drawable.volume_amp_muting, status.getDescriptionId(), null, status));
        }
        // volume down
        {
            final MasterVolumeMsg.Command cmd = MasterVolumeMsg.Command.DOWN;
            layout.addView(fragment.createButton(
                    cmd.getImageId(), cmd.getDescriptionId(), null, cmd));
        }
        // master volume label
        {
            final AppCompatButton b = fragment.createButton(
                    R.string.dashed_string, null, VOLUME_LEVEL, null);
            ((LinearLayout.LayoutParams) b.getLayoutParams()).setMargins(0, 0, 0, 0);
            b.setContentDescription(activity.getResources().getString(R.string.app_control_audio_control));
            fragment.prepareButtonListeners(b, null, this::showAudioControlDialog);
            layout.addView(b);
        }
        // volume up
        {
            final MasterVolumeMsg.Command cmd = MasterVolumeMsg.Command.UP;
            layout.addView(fragment.createButton(
                    cmd.getImageId(), cmd.getDescriptionId(), null, cmd));
        }
    }

    void createSliderSoundControl(
            @NonNull final BaseFragment fragment,
            @NonNull final LinearLayout layout,
            @NonNull final State state,
            final State.SoundControlType soundControl)
    {
        if (soundControl != State.SoundControlType.DEVICE_BTN_ABOVE_SLIDER)
        {
            final AppCompatButton b = fragment.createButton(
                    R.string.dashed_string, null, VOLUME_LEVEL, null);
            b.setContentDescription(activity.getResources().getString(R.string.app_control_audio_control));
            fragment.prepareButtonListeners(b, null, this::showAudioControlDialog);
            layout.addView(b);
        }
        if (soundControl == State.SoundControlType.DEVICE_BTN_AROUND_SLIDER) // volume down
        {
            final MasterVolumeMsg.Command cmd = MasterVolumeMsg.Command.DOWN;
            layout.addView(fragment.createButton(
                    cmd.getImageId(), cmd.getDescriptionId(), null, cmd));
        }
        if (soundControl == State.SoundControlType.DEVICE_BTN_ABOVE_SLIDER)
        {
            layout.addView(createTextView(fragment.getContext(),
                    null, "0", R.style.SecondaryTextViewStyle));
        }
        // slider
        {
            ContextThemeWrapper wrappedContext = new ContextThemeWrapper(activity, R.style.SegBarStyle);
            final AppCompatSeekBar b = new AppCompatSeekBar(wrappedContext, null, 0);
            final LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT);
            lp.weight = 1;
            lp.gravity = Gravity.CENTER;
            b.setLayoutParams(lp);
            b.setTag(VOLUME_LEVEL);
            b.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener()
            {
                int progressChanged = 0;

                public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser)
                {
                    progressChanged = progress;
                    if (masterVolumeInterface != null)
                    {
                        masterVolumeInterface.onMasterVolumeChange(progressChanged);
                    }
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
                                new MasterVolumeMsg(activity.getStateManager().getState().getActiveZone(), progressChanged));
                    }
                }
            });
            layout.addView(b);
        }
        if (soundControl == State.SoundControlType.DEVICE_BTN_ABOVE_SLIDER)
        {
            final ReceiverInformationMsg.Zone zone = state.getActiveZoneInfo();
            final int maxVolume = Math.min(getVolumeMax(state, zone),
                    activity.getConfiguration().audioControl.getMasterVolumeMax());
            layout.addView(createTextView(fragment.getContext(),
                    VOLUME_LEVEL, State.getVolumeLevelStr(maxVolume, zone), R.style.SecondaryTextViewStyle));
        }
        if (soundControl == State.SoundControlType.DEVICE_BTN_AROUND_SLIDER) // volume up
        {
            final MasterVolumeMsg.Command cmd = MasterVolumeMsg.Command.UP;
            layout.addView(fragment.createButton(
                    cmd.getImageId(), cmd.getDescriptionId(), null, cmd));
        }
        if (soundControl != State.SoundControlType.DEVICE_BTN_ABOVE_SLIDER)
        {
            final AudioMutingMsg.Status status = AudioMutingMsg.Status.TOGGLE;
            final AppCompatImageButton b = fragment.createButton(
                    R.drawable.volume_amp_muting, status.getDescriptionId(), null, status);
            layout.addView(b);
        }
    }

    @SuppressLint("NewApi")
    private TextView createTextView(final Context context, @Nullable final String tag, @NonNull final String text, final int style)
    {
        final TextView tv = new TextView(context);
        tv.setTag(tag);
        tv.setLayoutParams(new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
        {
            tv.setTextAppearance(style);
        }
        else
        {
            tv.setTextAppearance(context, style);
        }
        tv.setText(text);
        return tv;
    }
}
