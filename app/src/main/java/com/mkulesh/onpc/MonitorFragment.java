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

package com.mkulesh.onpc;

import android.annotation.SuppressLint;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v7.app.AlertDialog;
import android.support.v7.widget.AppCompatButton;
import android.support.v7.widget.AppCompatImageButton;
import android.support.v7.widget.AppCompatSeekBar;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.HorizontalScrollView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import com.mkulesh.onpc.iscp.State;
import com.mkulesh.onpc.iscp.messages.AmpOperationCommandMsg;
import com.mkulesh.onpc.iscp.messages.AudioMutingMsg;
import com.mkulesh.onpc.iscp.messages.DisplayModeMsg;
import com.mkulesh.onpc.iscp.messages.ListeningModeMsg;
import com.mkulesh.onpc.iscp.messages.MasterVolumeMsg;
import com.mkulesh.onpc.iscp.messages.MenuStatusMsg;
import com.mkulesh.onpc.iscp.messages.OperationCommandMsg;
import com.mkulesh.onpc.iscp.messages.PlayStatusMsg;
import com.mkulesh.onpc.iscp.messages.ReceiverInformationMsg;
import com.mkulesh.onpc.iscp.messages.TimeSeekMsg;
import com.mkulesh.onpc.iscp.messages.TrackInfoMsg;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

public class MonitorFragment extends BaseFragment
{
    private final static String VOLUME_LEVEL = "volume_level";

    private HorizontalScrollView listeningModeLayout;
    private AppCompatImageButton btnRepeat;
    private AppCompatImageButton btnPrevious;
    private AppCompatImageButton btnPausePlay;
    private AppCompatImageButton btnNext;
    private AppCompatImageButton btnRandom;
    private AppCompatImageButton btnTrackMenu;
    private final List<AppCompatImageButton> playbackButtons = new ArrayList<>();
    private final List<AppCompatImageButton> amplifierButtons = new ArrayList<>();
    private AppCompatImageButton positiveFeed, negativeFeed;
    private final List<View> deviceSoundButtons = new ArrayList<>();
    private ImageView cover;
    private AppCompatSeekBar seekBar;

    public MonitorFragment()
    {
        // Empty constructor required for fragment subclasses
    }

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
    {
        initializeFragment(inflater, container, R.layout.monitor_fragment);
        rootView.setLayerType(View.LAYER_TYPE_HARDWARE, null);

        listeningModeLayout = rootView.findViewById(R.id.listening_mode_layout);

        // Command Buttons
        btnRepeat = rootView.findViewById(R.id.btn_repeat);
        playbackButtons.add(btnRepeat);

        btnPrevious = rootView.findViewById(R.id.btn_previous);
        playbackButtons.add(btnPrevious);

        final AppCompatImageButton btnStop = rootView.findViewById(R.id.btn_stop);
        playbackButtons.add(btnStop);

        btnPausePlay = rootView.findViewById(R.id.btn_pause_play);
        playbackButtons.add(btnPausePlay);

        btnNext = rootView.findViewById(R.id.btn_next);
        playbackButtons.add(btnNext);

        btnRandom = rootView.findViewById(R.id.btn_random);
        playbackButtons.add(btnRandom);

        for (AppCompatImageButton b : playbackButtons)
        {
            final OperationCommandMsg msg = new OperationCommandMsg(
                    ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE, (String) (b.getTag()));
            prepareButton(b, msg, msg.getCommand().getImageId(), msg.getCommand().getDescriptionId());
        }

        // Amplifier command buttons
        switch (activity.getConfiguration().getSoundControl())
        {
        case "none":
            // nothing to do
            break;
        case "external-amplifier":
            prepareAmplifierButtons();
            break;
        case "device":
            prepareDeviceSoundButtons();
            break;
        }

        cover = rootView.findViewById(R.id.tv_cover);
        cover.setContentDescription(activity.getResources().getString(R.string.tv_display_mode));
        prepareButtonListeners(cover, new DisplayModeMsg(DisplayModeMsg.TOGGLE));

        seekBar = rootView.findViewById(R.id.progress_bar);
        seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener()
        {
            int progressChanged = 0;

            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser)
            {
                progressChanged = progress;
            }

            public void onStartTrackingTouch(SeekBar seekBar)
            {
                // empty
            }

            public void onStopTrackingTouch(SeekBar seekBar)
            {
                if (activity.isConnected())
                {
                    seekTime(progressChanged);
                }
            }
        });

        // Track menu
        {
            btnTrackMenu = rootView.findViewById(R.id.btn_track_menu);
            prepareButtonListeners(btnTrackMenu, null, () -> {
                activity.getStateManager().sendTrackCmd(OperationCommandMsg.Command.MENU, false);
                activity.selectRightTab();
            });
            setButtonEnabled(btnTrackMenu, false);
        }

        // Feeds
        positiveFeed = rootView.findViewById(R.id.btn_positive_feed);
        prepareButtonListeners(positiveFeed, null, () ->
            activity.getStateManager().sendTrackCmd(OperationCommandMsg.Command.F1, true));
        negativeFeed = rootView.findViewById(R.id.btn_negative_feed);
        prepareButtonListeners(negativeFeed, null, () ->
            activity.getStateManager().sendTrackCmd(OperationCommandMsg.Command.F2, true));

        update(null, null);
        return rootView;
    }

    private void prepareAmplifierButtons()
    {
        final LinearLayout soundControlLayout = rootView.findViewById(R.id.sound_control_layout);
        soundControlLayout.setVisibility(View.VISIBLE);

        final AmpOperationCommandMsg.Command[] commands = new AmpOperationCommandMsg.Command[]
        {
            AmpOperationCommandMsg.Command.AMTTG,
            AmpOperationCommandMsg.Command.MVLDOWN,
            AmpOperationCommandMsg.Command.MVLUP
        };
        for (AmpOperationCommandMsg.Command c : commands)
        {
            final AmpOperationCommandMsg msg = new AmpOperationCommandMsg(c.getCode());
            final AppCompatImageButton b = createButton(
                    msg.getCommand().getImageId(), msg.getCommand().getDescriptionId(),
                    msg, msg.getCommand().getCode());
            soundControlLayout.addView(b);
            amplifierButtons.add(b);
        }
    }

    private void prepareDeviceSoundButtons()
    {
        final LinearLayout soundControlLayout = rootView.findViewById(R.id.sound_control_layout);
        soundControlLayout.setVisibility(View.VISIBLE);

        // Here, we create zone-dependent buttons without command message.
        // The message for active zone will be assigned in updateActiveView

        // audio muting
        {
            final AudioMutingMsg.Status status = AudioMutingMsg.Status.TOGGLE;
            deviceSoundButtons.add(createButton(
                    R.drawable.volume_amp_muting, status.getDescriptionId(), null, status));
        }
        // volume down
        {
            final MasterVolumeMsg.Command cmd = MasterVolumeMsg.Command.DOWN;
            deviceSoundButtons.add(createButton(
                    cmd.getImageId(), cmd.getDescriptionId(), null, cmd));
        }
        // master volume label
        {
            final AppCompatButton b = createButton(R.string.dashed_string, null, VOLUME_LEVEL, null);
            ((LinearLayout.LayoutParams) b.getLayoutParams()).setMargins(0, 0, 0, 0);
            b.setPadding(0, 0, 0, 0);
            b.setVisibility(View.GONE);
            b.setContentDescription(activity.getResources().getString(R.string.master_volume));
            prepareButtonListeners(b, null, this::createMasterVolumeDialog);
            deviceSoundButtons.add(b);
        }
        // volume up
        {
            final MasterVolumeMsg.Command cmd = MasterVolumeMsg.Command.UP;
            deviceSoundButtons.add(createButton(
                    cmd.getImageId(), cmd.getDescriptionId(), null, cmd));
        }
        for (View b : deviceSoundButtons)
        {
            soundControlLayout.addView(b);
        }

        // fast selector for listening mode
        listeningModeLayout.setVisibility(View.VISIBLE);
        if (listeningModeLayout.getChildCount() == 1)
        {
            final LinearLayout l = (LinearLayout) listeningModeLayout.getChildAt(0);
            for (ListeningModeMsg.Mode m : activity.getConfiguration().getSortedListeningModes(true, null))
            {
                final ListeningModeMsg msg = new ListeningModeMsg(m);
                final AppCompatButton b = createButton(
                        msg.getMode().getDescriptionId(), msg, msg.getMode(), null);
                l.addView(b);
                b.setVisibility(View.GONE);
                deviceSoundButtons.add(b);
            }
        }
    }

    @SuppressLint("SetTextI18n")
    private void createMasterVolumeDialog()
    {
        if (!activity.isConnected())
        {
            return;
        }

        final State state = activity.getStateManager().getState();
        final ReceiverInformationMsg.Zone zone = state.getActiveZoneInfo();
        if (zone.getVolMax() == 0)
        {
            return;
        }

        final FrameLayout frameView = new FrameLayout(activity);
        activity.getLayoutInflater().inflate(R.layout.dialog_master_volume_layout, frameView);
        {
            final TextView minValue = frameView.findViewById(R.id.volume_min_value);
            minValue.setText("0");

            final TextView maxValue = frameView.findViewById(R.id.volume_max_value);
            maxValue.setText(Integer.toString(zone.getVolMax()));
        }

        final AppCompatSeekBar progressBar = frameView.findViewById(R.id.progress_bar);
        progressBar.setMax(zone.getVolMax());
        progressBar.setProgress((int)State.getVolumeLevelFloat(state.volumeLevel, state.getActiveZoneInfo()));
        progressBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener()
        {
            int progressChanged = 0;

            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser)
            {
                progressChanged = progress;
            }

            public void onStartTrackingTouch(SeekBar seekBar)
            {
                // empty
            }

            @SuppressLint("SetTextI18n")
            public void onStopTrackingTouch(SeekBar seekBar)
            {
                if (activity.isConnected())
                {
                    activity.getStateManager().sendMessage(
                            new MasterVolumeMsg(state.getActiveZone(), progressChanged));
                }
            }
        });

        final Drawable icon = Utils.getDrawable(activity, R.drawable.pref_volume_keys);
        Utils.setDrawableColorAttr(activity, icon, android.R.attr.textColorSecondary);

        final AlertDialog dialog = new AlertDialog.Builder(activity)
                .setTitle(R.string.master_volume)
                .setIcon(icon)
                .setCancelable(true)
                .setView(frameView).create();
        dialog.show();
        Utils.fixIconColor(dialog, android.R.attr.textColorSecondary);
    }

    @Override
    protected void updateStandbyView(@Nullable final State state, @NonNull final HashSet<State.ChangeType> eventChanges)
    {
        ((TextView) rootView.findViewById(R.id.tv_time_start)).setText(
                activity.getResources().getString(R.string.tv_time_default));
        ((TextView) rootView.findViewById(R.id.tv_time_end)).setText(
                activity.getResources().getString(R.string.tv_time_default));

        TextView track = rootView.findViewById(R.id.tv_track);
        track.setText("");
        track.setCompoundDrawables(null, null, null, null);

        ((TextView) rootView.findViewById(R.id.tv_album)).setText("");
        ((TextView) rootView.findViewById(R.id.tv_artist)).setText("");
        ((TextView) rootView.findViewById(R.id.tv_title)).setText("");
        ((TextView) rootView.findViewById(R.id.tv_file_format)).setText("");
        cover.setEnabled(false);
        cover.setImageResource(R.drawable.empty_cover);
        seekBar.setEnabled(false);
        seekBar.setProgress(0);
        for (AppCompatImageButton b : amplifierButtons)
        {
            setButtonEnabled(b, state != null);
        }
        for (View b : deviceSoundButtons)
        {
            if (isVolumeLevel(b))
            {
                updateVolumeLevel((AppCompatButton) b, MasterVolumeMsg.NO_LEVEL, null);
            }
            else
            {
                setButtonEnabled(b, false);
            }
        }
        for (AppCompatImageButton b : playbackButtons)
        {
            setButtonEnabled(b, false);
        }
        btnTrackMenu.setVisibility(View.INVISIBLE);
        positiveFeed.setVisibility(View.GONE);
        negativeFeed.setVisibility(View.GONE);
    }

    @Override
    protected void updateActiveView(@NonNull final State state, @NonNull final HashSet<State.ChangeType> eventChanges)
    {
        // time seek only
        if (eventChanges.size() == 1 && eventChanges.contains(State.ChangeType.TIME_SEEK))
        {
            updateProgressBar(state);
            return;
        }

        Logging.info(this, "Updating playback monitor");
        // Text
        ((TextView) rootView.findViewById(R.id.tv_album)).setText(state.album);
        ((TextView) rootView.findViewById(R.id.tv_artist)).setText(state.artist);
        ((TextView) rootView.findViewById(R.id.tv_title)).setText(state.title);
        ((TextView) rootView.findViewById(R.id.tv_file_format)).setText(state.fileFormat);

        // service icon and track
        {
            final TextView track = rootView.findViewById(R.id.tv_track);
            final Drawable bg = Utils.getDrawable(activity, state.serviceIcon.getImageId());
            Utils.setDrawableColorAttr(activity, bg, android.R.attr.textColorSecondary);
            track.setCompoundDrawablesWithIntrinsicBounds(bg, null, null, null);
            track.setText(TrackInfoMsg.getTrackInfo(state.currentTrack, state.maxTrack));
        }

        // cover
        cover.setEnabled(true);
        if (state.cover == null)
        {
            cover.setImageResource(R.drawable.empty_cover);
        }
        else
        {
            cover.setImageBitmap(state.cover);
        }

        // progress bar
        updateProgressBar(state);

        // buttons
        final ArrayList<String> selectedListeningModes = new ArrayList<>();
        for (ListeningModeMsg.Mode m : activity.getConfiguration().getSortedListeningModes(false, state.listeningMode))
        {
            selectedListeningModes.add(m.getCode());
        }
        for (AppCompatImageButton b : amplifierButtons)
        {
            setButtonEnabled(b, true);
        }
        for (View b : deviceSoundButtons)
        {
            setButtonEnabled(b, true);
            if (b.getTag() instanceof AudioMutingMsg.Status)
            {
                setButtonSelected(b, state.audioMuting == AudioMutingMsg.Status.ON);
                final AudioMutingMsg.Status cmd = (AudioMutingMsg.Status) (b.getTag());
                prepareButtonListeners(b, new AudioMutingMsg(state.getActiveZone(), cmd));
            }
            else if (b.getTag() instanceof MasterVolumeMsg.Command)
            {
                final MasterVolumeMsg.Command cmd = (MasterVolumeMsg.Command) (b.getTag());
                prepareButtonListeners(b, new MasterVolumeMsg(state.getActiveZone(), cmd));
            }
            else if (b.getTag() instanceof ListeningModeMsg.Mode)
            {
                final ListeningModeMsg.Mode s = (ListeningModeMsg.Mode) (b.getTag());
                if (selectedListeningModes.contains(s.getCode()))
                {
                    b.setVisibility(View.VISIBLE);
                    setButtonSelected(b, s == state.listeningMode);
                    if (b.isSelected())
                    {
                        b.getParent().requestChildFocus(b, b);
                    }
                }
                else
                {
                    b.setVisibility(View.GONE);
                }
            }
            else if (isVolumeLevel(b))
            {
                updateVolumeLevel((AppCompatButton) b, state.volumeLevel, state.getActiveZoneInfo());
            }
        }

        updateListeningModeLayout();

        for (AppCompatImageButton b : playbackButtons)
        {
            prepareButtonListeners(b, new OperationCommandMsg(state.getActiveZone(), (String) (b.getTag())));
            setButtonEnabled(b, true);
        }

        if (state.repeatStatus == PlayStatusMsg.RepeatStatus.DISABLE)
        {
            setButtonEnabled(btnRepeat, false);
        }
        else
        {
            setButtonEnabled(btnRepeat, true);
            setButtonSelected(btnRepeat, state.repeatStatus != PlayStatusMsg.RepeatStatus.OFF);
        }

        if (state.shuffleStatus == PlayStatusMsg.ShuffleStatus.DISABLE)
        {
            setButtonEnabled(btnRandom, false);
        }
        else
        {
            setButtonEnabled(btnRandom, true);
            setButtonSelected(btnRandom, state.shuffleStatus != PlayStatusMsg.ShuffleStatus.OFF);
        }

        setButtonEnabled(btnPrevious, state.isPlaying());
        setButtonEnabled(btnNext, state.isPlaying());

        switch (state.playStatus)
        {
        case STOP:
            btnPausePlay.setImageResource(R.drawable.cmd_play);
            break;
        case PLAY:
            btnPausePlay.setImageResource(R.drawable.cmd_pause);
            break;
        case PAUSE:
            btnPausePlay.setImageResource(R.drawable.cmd_play);
            break;
        default:
            break;
        }
        setButtonEnabled(btnPausePlay, state.isOn());

        // Track menu
        {
            final boolean isTrackMenu = state.trackMenu == MenuStatusMsg.TrackMenu.ENABLE &&
                    state.playStatus != PlayStatusMsg.PlayStatus.STOP;
            btnTrackMenu.setVisibility(isTrackMenu ? View.VISIBLE : View.INVISIBLE);
            setButtonEnabled(btnTrackMenu, isTrackMenu);
        }

        // Feeds
        updateFeedButton(positiveFeed, state.positiveFeed);
        updateFeedButton(negativeFeed, state.negativeFeed);
    }

    private void updateListeningModeLayout()
    {
        listeningModeLayout.requestLayout();
        if (listeningModeLayout.getChildCount() == 1)
        {
            final LinearLayout l = (LinearLayout) listeningModeLayout.getChildAt(0);
            FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT);
            if (l.getMeasuredWidth() < listeningModeLayout.getMeasuredWidth())
            {
                params.gravity = Gravity.CENTER;
            }
            l.setLayoutParams(params);
            l.requestLayout();
        }
    }

    private boolean isVolumeLevel(View b)
    {
        return b.getTag() != null && b.getTag() instanceof String && VOLUME_LEVEL.equals(b.getTag());
    }

    private void updateVolumeLevel(AppCompatButton b, final int volumeLevel, final ReceiverInformationMsg.Zone zone)
    {
        b.setVisibility(volumeLevel != MasterVolumeMsg.NO_LEVEL ? View.VISIBLE : View.GONE);
        b.setText(State.getVolumeLevelStr(volumeLevel, zone));
        setButtonEnabled(b, true);
    }

    private void updateFeedButton(final AppCompatImageButton btn, final MenuStatusMsg.Feed feed)
    {
        btn.setVisibility(feed.isImageValid() ? View.VISIBLE : View.GONE);
        if (feed.isImageValid())
        {
            btn.setImageResource(feed.getImageId());
            setButtonEnabled(btn, true);
            setButtonSelected(btn, feed == MenuStatusMsg.Feed.LOVE);
        }
    }

    private void updateProgressBar(@NonNull final State state)
    {
        ((TextView) rootView.findViewById(R.id.tv_time_start)).setText(state.currentTime);
        ((TextView) rootView.findViewById(R.id.tv_time_end)).setText(state.maxTime);
        final int currTime = Utils.timeToSeconds(state.currentTime);
        final int maxTime = Utils.timeToSeconds(state.maxTime);
        if (currTime >= 0 && maxTime >= 0)
        {
            seekBar.setMax(maxTime);
            seekBar.setProgress(currTime);
        }
        else
        {
            seekBar.setMax(1000);
            seekBar.setProgress(0);
        }
        seekBar.setEnabled(state.isPlaying() && state.timeSeek == MenuStatusMsg.TimeSeek.ENABLE);
    }

    private void seekTime(int newSec)
    {
        final State state = activity.getStateManager().getState();
        final int currTime = Utils.timeToSeconds(state.currentTime);
        final int maxTime = Utils.timeToSeconds(state.maxTime);
        if (currTime >= 0 && maxTime >= 0)
        {
            final int hour = newSec / 3600;
            final int min = (newSec - hour * 3600) / 60;
            final int sec = newSec - hour * 3600 - min * 60;
            activity.getStateManager().requestSkipNextTimeMsg(2);
            final TimeSeekMsg msg = new TimeSeekMsg(hour, min, sec);
            state.currentTime = msg.getTimeAsString();
            ((TextView) rootView.findViewById(R.id.tv_time_start)).setText(state.currentTime);
            activity.getStateManager().sendMessage(msg);
        }
    }
}
