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
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.FrameLayout;
import android.widget.HorizontalScrollView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import com.mkulesh.onpc.iscp.State;
import com.mkulesh.onpc.iscp.messages.AmpOperationCommandMsg;
import com.mkulesh.onpc.iscp.messages.AudioMutingMsg;
import com.mkulesh.onpc.iscp.messages.BroadcastResponseMsg;
import com.mkulesh.onpc.iscp.messages.CenterLevelCommandMsg;
import com.mkulesh.onpc.iscp.messages.DirectCommandMsg;
import com.mkulesh.onpc.iscp.messages.DisplayModeMsg;
import com.mkulesh.onpc.iscp.messages.ListeningModeMsg;
import com.mkulesh.onpc.iscp.messages.MasterVolumeMsg;
import com.mkulesh.onpc.iscp.messages.MenuStatusMsg;
import com.mkulesh.onpc.iscp.messages.MultiroomChannelSettingMsg;
import com.mkulesh.onpc.iscp.messages.MultiroomDeviceInformationMsg;
import com.mkulesh.onpc.iscp.messages.OperationCommandMsg;
import com.mkulesh.onpc.iscp.messages.PlayStatusMsg;
import com.mkulesh.onpc.iscp.messages.PresetCommandMsg;
import com.mkulesh.onpc.iscp.messages.ReceiverInformationMsg;
import com.mkulesh.onpc.iscp.messages.SubwooferLevelCommandMsg;
import com.mkulesh.onpc.iscp.messages.TimeInfoMsg;
import com.mkulesh.onpc.iscp.messages.TimeSeekMsg;
import com.mkulesh.onpc.iscp.messages.ToneCommandMsg;
import com.mkulesh.onpc.iscp.messages.TuningCommandMsg;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.widget.AppCompatButton;
import androidx.appcompat.widget.AppCompatImageButton;
import androidx.appcompat.widget.AppCompatSeekBar;

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
    private AppCompatImageButton btnMultiroomGroup;
    private AppCompatButton btnMultiroomChanel;
    private final List<AppCompatImageButton> playbackButtons = new ArrayList<>();
    private final List<AppCompatImageButton> fmDabButtons = new ArrayList<>();
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
        initializeFragment(inflater, container, R.layout.monitor_fragment_port, R.layout.monitor_fragment_land);
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

        // FM/DAB preset and tuning buttons
        fmDabButtons.add(rootView.findViewById(R.id.btn_preset_up));
        fmDabButtons.add(rootView.findViewById(R.id.btn_preset_down));
        fmDabButtons.add(rootView.findViewById(R.id.btn_tuning_up));
        fmDabButtons.add(rootView.findViewById(R.id.btn_tuning_down));
        prepareFmDabButtons();

        // Audio control buttons
        prepareDeviceSoundButtons();

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

        // Multiroom
        btnMultiroomGroup = rootView.findViewById(R.id.btn_multiroom_group);
        btnMultiroomChanel = rootView.findViewById(R.id.btn_multiroom_channel);

        // Feeds
        positiveFeed = rootView.findViewById(R.id.btn_positive_feed);
        prepareButtonListeners(positiveFeed, null, () ->
                activity.getStateManager().sendTrackCmd(OperationCommandMsg.Command.F1, true));
        negativeFeed = rootView.findViewById(R.id.btn_negative_feed);
        prepareButtonListeners(negativeFeed, null, () ->
                activity.getStateManager().sendTrackCmd(OperationCommandMsg.Command.F2, true));

        updateContent();
        return rootView;
    }

    private void prepareFmDabButtons()
    {
        for (AppCompatImageButton b : fmDabButtons)
        {
            String[] tokens = b.getTag().toString().split(":");
            if (tokens.length != 2)
            {
                continue;
            }
            final String msgName = tokens[0];
            switch (msgName)
            {
            case PresetCommandMsg.CODE:
                final PresetCommandMsg pMsg = new PresetCommandMsg(
                        ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE, tokens[1]);
                if (pMsg.getCommand() != null)
                {
                    prepareButton(b, pMsg, pMsg.getCommand().getImageId(), pMsg.getCommand().getDescriptionId());
                }
                break;
            case TuningCommandMsg.CODE:
                final TuningCommandMsg tMsg = new TuningCommandMsg(
                        ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE, tokens[1]);
                if (tMsg.getCommand() != null)
                {
                    prepareButton(b, tMsg, tMsg.getCommand().getImageId(), tMsg.getCommand().getDescriptionId());
                }
                break;
            }
        }
    }

    private void clearSoundVolumeButtons(final LinearLayout soundControlLayout)
    {
        amplifierButtons.clear();
        deviceSoundButtons.clear();
        soundControlLayout.removeAllViews();
    }

    private void prepareAmplifierButtons()
    {
        final LinearLayout soundControlLayout = rootView.findViewById(R.id.sound_control_layout);
        clearSoundVolumeButtons(soundControlLayout);
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
        clearSoundVolumeButtons(soundControlLayout);
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
            b.setContentDescription(activity.getResources().getString(R.string.audio_control));
            prepareButtonListeners(b, null, this::showMasterVolumeDialog);
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

    private void setButtonsEnabled(List<AppCompatImageButton> buttons, boolean flag)
    {
        for (AppCompatImageButton b : buttons)
        {
            setButtonEnabled(b, flag);
        }
    }

    private void setButtonsVisibility(List<AppCompatImageButton> buttons, int flag)
    {
        for (AppCompatImageButton b : buttons)
        {
            b.setVisibility(flag);
        }
    }

    @Override
    protected void updateStandbyView(@Nullable final State state, @NonNull final HashSet<State.ChangeType> eventChanges)
    {
        ((TextView) rootView.findViewById(R.id.tv_time_start)).setText(TimeInfoMsg.INVALID_TIME);
        ((TextView) rootView.findViewById(R.id.tv_time_end)).setText(TimeInfoMsg.INVALID_TIME);

        TextView track = rootView.findViewById(R.id.tv_track);
        track.setText("");
        track.setCompoundDrawables(null, null, null, null);

        ((TextView) rootView.findViewById(R.id.tv_album)).setText("");
        ((TextView) rootView.findViewById(R.id.tv_artist)).setText("");
        ((TextView) rootView.findViewById(R.id.tv_title)).setText("");
        ((TextView) rootView.findViewById(R.id.tv_file_format)).setText("");
        cover.setEnabled(false);
        cover.setImageResource(R.drawable.empty_cover);
        Utils.setImageViewColorAttr(activity, cover, android.R.attr.textColor);

        seekBar.setEnabled(false);
        seekBar.setProgress(0);
        setButtonsEnabled(amplifierButtons, state != null);
        for (View b : deviceSoundButtons)
        {
            if (isVolumeLevel(b))
            {
                updateVolumeLevel((AppCompatButton) b, state);
            }
            else
            {
                setButtonEnabled(b, false);
            }
        }
        setButtonsVisibility(playbackButtons, View.VISIBLE);
        setButtonsEnabled(playbackButtons, false);
        setButtonsVisibility(fmDabButtons, View.GONE);
        btnTrackMenu.setVisibility(View.GONE);
        updateMultiroomGroupBtn(btnMultiroomGroup, state);
        updateMultiroomChannelBtn(btnMultiroomChanel, state);
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

        // Auto volume control
        final State.SoundControlType soundControl = state.soundControlType(
                activity.getConfiguration().getSoundControl(), state.getActiveZoneInfo());
        switch (soundControl)
        {
            case RI_AMP:
                prepareAmplifierButtons();
                break;
            case DEVICE:
                prepareDeviceSoundButtons();
                break;
            default:
                // Nothing to do
                break;
        }

        // Text (album and artist)
        {
            ((TextView) rootView.findViewById(R.id.tv_album)).setText(state.album);
            ((TextView) rootView.findViewById(R.id.tv_artist)).setText(state.artist);

            final TextView title = rootView.findViewById(R.id.tv_title);
            final TextView format = rootView.findViewById(R.id.tv_file_format);
            if (state.isRadioInput())
            {
                final ReceiverInformationMsg.Preset preset = state.searchPreset();
                title.setText(preset != null ? preset.displayedString() : "");
                format.setText(state.getFrequencyInfo(activity));
            }
            else
            {
                title.setText(state.title);
                format.setText(state.fileFormat);
            }
        }

        // service icon and track
        {
            final TextView track = rootView.findViewById(R.id.tv_track);
            @DrawableRes int icon = state.getServiceIcon();
            final Drawable bg = Utils.getDrawable(activity, icon);
            Utils.setDrawableColorAttr(activity, bg, android.R.attr.textColorSecondary);
            track.setCompoundDrawablesWithIntrinsicBounds(bg, null, null, null);
            track.setText(state.getTrackInfo(activity));
        }

        // cover
        cover.setEnabled(true);
        if (state.cover == null || state.isSimpleInput())
        {
            cover.setImageResource(R.drawable.empty_cover);
            Utils.setImageViewColorAttr(activity, cover, android.R.attr.textColor);
        }
        else
        {
            cover.setColorFilter(null);
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
        setButtonsEnabled(amplifierButtons, true);
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
                if (isVolumeComandEnabled())
                {
                    b.setOnLongClickListener(v -> showMasterVolumeDialog());
                }
                else
                {
                    b.setOnLongClickListener(v -> Utils.showButtonDescription(activity, v));
                }
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
                updateVolumeLevel((AppCompatButton) b, state);
            }
        }

        updateListeningModeLayout();

        if (state.isRadioInput())
        {
            updatePresetButtons();
        }
        else
        {
            updatePlaybackButtons(state);
        }

        // Track menu
        {
            final boolean isTrackMenu = state.trackMenu == MenuStatusMsg.TrackMenu.ENABLE &&
                    state.playStatus != PlayStatusMsg.PlayStatus.STOP;
            btnTrackMenu.setVisibility(isTrackMenu ? View.VISIBLE : View.GONE);
            setButtonEnabled(btnTrackMenu, isTrackMenu);
        }

        // Multiroom groups
        updateMultiroomGroupBtn(btnMultiroomGroup, state);
        updateMultiroomChannelBtn(btnMultiroomChanel, state);

        // Feeds
        updateFeedButton(positiveFeed, state.positiveFeed);
        updateFeedButton(negativeFeed, state.negativeFeed);
    }

    private void updatePresetButtons()
    {
        setButtonsVisibility(playbackButtons, View.GONE);
        setButtonsVisibility(fmDabButtons, View.VISIBLE);
        setButtonsEnabled(fmDabButtons, true);
    }


    /*
     * Playback control
     */
    private void updatePlaybackButtons(@NonNull final State state)
    {
        setButtonsVisibility(fmDabButtons, View.GONE);
        setButtonsVisibility(playbackButtons, View.VISIBLE);
        setButtonsEnabled(playbackButtons, true);

        for (AppCompatImageButton b : playbackButtons)
        {
            final OperationCommandMsg msg = new OperationCommandMsg(state.getActiveZone(), (String) (b.getTag()));
            prepareButtonListeners(b, null, () ->
            {
                if (activity.getStateManager() != null)
                {
                    if (!state.isPlaybackMode() && state.isUsb() &&
                            (msg.getCommand() == OperationCommandMsg.Command.TRDN ||
                                    msg.getCommand() == OperationCommandMsg.Command.TRUP))
                    {
                        // Issue-44: on some receivers, "TRDN" and "TRUP" for USB only work
                        // in playback mode. Therefore, switch to this mode before
                        // send OperationCommandMsg if current mode is LIST
                        activity.getStateManager().sendTrackMsg(msg, false);
                    }
                    else
                    {
                        activity.getStateManager().sendMessage(msg);
                    }
                }
            });
        }

        btnRepeat.setImageResource(state.repeatStatus.getImageId());
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
        case PAUSE:
            btnPausePlay.setImageResource(R.drawable.cmd_play);
            break;
        case PLAY:
            btnPausePlay.setImageResource(R.drawable.cmd_pause);
            break;
        default:
            break;
        }
        setButtonEnabled(btnPausePlay, state.isOn());
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


    /*
     * Multiroom control
     */
    private void updateMultiroomGroupBtn(AppCompatImageButton b, @Nullable final State state)
    {
        final boolean isGroupMenu = activity.getDeviceList().getDevicesNumber() > 1;

        if (state != null && isGroupMenu)
        {
            final boolean isMaster = state.getMultiroomRole() == MultiroomDeviceInformationMsg.RoleType.SRC;
            b.setVisibility(View.VISIBLE);
            setButtonEnabled(b, true);
            setButtonSelected(b, isMaster);
            b.setContentDescription(activity.getString(R.string.cmd_multiroom_group));

            final List<BroadcastResponseMsg> devices = new ArrayList<>();
            for (BroadcastResponseMsg message : activity.getDeviceList().getDevices())
            {
                if (message.getIdentifier().equals(activity.myDeviceId()))
                {
                    devices.add(0, message);
                }
                else
                {
                    devices.add(message);
                }
            }

            prepareButtonListeners(b, null, () ->
            {
                if (activity.isConnected())
                {
                    final AlertDialog alertDialog = MultiroomManager.createDeviceSelectionDialog(
                            activity, b.getContentDescription(), devices);
                    alertDialog.show();
                    Utils.fixIconColor(alertDialog, android.R.attr.textColorSecondary);
                }
            });
        }
        else
        {
            b.setVisibility(View.GONE);
            setButtonEnabled(b, false);
        }
    }

    private void updateMultiroomChannelBtn(AppCompatButton b, @Nullable final State state)
    {
        final boolean isGroupMenu = activity.getDeviceList().getDevicesNumber() > 1;

        MultiroomDeviceInformationMsg.ChannelType ch = state != null ?
                state.multiroomChannel : MultiroomDeviceInformationMsg.ChannelType.NONE;

        if (ch != MultiroomDeviceInformationMsg.ChannelType.NONE && isGroupMenu)
        {
            final MultiroomChannelSettingMsg cmd = new MultiroomChannelSettingMsg(
                    state.getActiveZone() + 1, MultiroomChannelSettingMsg.getUpType(ch));
            b.setVisibility(View.VISIBLE);
            b.setText(ch.toString());
            setButtonEnabled(b, state.isOn());
            final Drawable icon = Utils.getDrawable(activity, R.drawable.cmd_multiroom_channel);
            Utils.setDrawableColorAttr(activity, icon,
                    state.isOn() ? R.attr.colorButtonEnabled : R.attr.colorButtonDisabled);
            b.setCompoundDrawablesWithIntrinsicBounds(icon, null, null, null);
            prepareButtonListeners(b, cmd, null);
        }
        else
        {
            b.setVisibility(View.GONE);
            setButtonEnabled(b, false);
            b.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
        }
    }


    /*
     * Volume control
     */
    private boolean isVolumeLevel(View b)
    {
        return b.getTag() != null && b.getTag() instanceof String && VOLUME_LEVEL.equals(b.getTag());
    }

    private void updateVolumeLevel(AppCompatButton b, @Nullable final State state)
    {
        if (state != null && state.isOn() && state.volumeLevel != MasterVolumeMsg.NO_LEVEL)
        {
            b.setVisibility(View.VISIBLE);
            b.setText(State.getVolumeLevelStr(state.volumeLevel, state.getActiveZoneInfo()));
            setButtonEnabled(b, true);
            final Drawable icon = Utils.getDrawable(activity, R.drawable.volume_amp_slider);
            Utils.setDrawableColorAttr(activity, icon, R.attr.colorButtonEnabled);
            b.setCompoundDrawablesWithIntrinsicBounds(icon, null, null, null);
        }
        else
        {
            b.setVisibility(View.GONE);
            setButtonEnabled(b, false);
            b.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
        }
    }

    private boolean isVolumeComandEnabled()
    {
        return activity != null && activity.isConnected() && activity.getStateManager().getState().isOn();
    }

    @SuppressLint("SetTextI18n")
    private boolean showMasterVolumeDialog()
    {
        if (!isVolumeComandEnabled())
        {
            return false;
        }

        final State state = activity.getStateManager().getState();
        final ReceiverInformationMsg.Zone zone = state.getActiveZoneInfo();
        final int scale = (zone != null && zone.getVolumeStep() == 0) ? 2 : 1;
        final int maxVolume = (zone != null && zone.getVolMax() > 0) ?
                scale * zone.getVolMax() :
                Math.max(state.volumeLevel, scale * MasterVolumeMsg.MAX_VOLUME_1_STEP);

        final FrameLayout frameView = new FrameLayout(activity);
        activity.getLayoutInflater().inflate(R.layout.dialog_master_volume_layout, frameView);

        // Master volume
        final LinearLayout volumeGroup = frameView.findViewById(R.id.volume_group);
        {
            final String labelText = activity.getString(R.string.master_volume);
            final TextView labelField = volumeGroup.findViewWithTag("tone_label");
            if (labelField != null)
            {
                labelField.setText(labelText + ": " + State.getVolumeLevelStr(state.volumeLevel, zone));
            }

            final TextView minValue = volumeGroup.findViewWithTag("tone_min_value");
            minValue.setText("0");

            final TextView maxValue = volumeGroup.findViewWithTag("tone_max_value");
            maxValue.setText(State.getVolumeLevelStr(maxVolume, zone));

            final AppCompatSeekBar progressBar = volumeGroup.findViewWithTag("tone_progress_bar");
            progressBar.setMax(maxVolume);
            progressBar.setProgress(Math.max(0, state.volumeLevel));
            progressBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener()
            {
                int progressChanged = 0;

                public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser)
                {
                    progressChanged = progress;
                    if (labelField != null)
                    {
                        labelField.setText(labelText + ": " + State.getVolumeLevelStr(progressChanged, zone));
                    }
                }

                public void onStartTrackingTouch(SeekBar seekBar)
                {
                    // empty
                }

                @SuppressLint("SetTextI18n")
                public void onStopTrackingTouch(SeekBar seekBar)
                {
                    if (isVolumeComandEnabled())
                    {
                        activity.getStateManager().sendMessage(
                                new MasterVolumeMsg(state.getActiveZone(), progressChanged));
                    }
                }
            });
        }

        // Tone control
        final LinearLayout toneDirectLayout = frameView.findViewById(R.id.tone_direct_layout);
        boolean isDirectCmdAvailable = state.toneDirect != DirectCommandMsg.Status.NONE;
        toneDirectLayout.setVisibility(isDirectCmdAvailable ? View.VISIBLE : View.GONE);
        if (isDirectCmdAvailable)
        {
            final boolean isDirectMode = state.toneDirect == DirectCommandMsg.Status.ON;

            final LinearLayout bassGroup = prepareToneControl(ToneCommandMsg.BASS_KEY, R.string.tone_bass,
                    frameView.findViewById(R.id.bass_group),
                    state.bassLevel,
                    ToneCommandMsg.NO_LEVEL, ToneCommandMsg.ZONE_COMMANDS.length);
            bassGroup.setVisibility(isDirectMode ? View.GONE : View.VISIBLE);

            final LinearLayout trebleGroup = prepareToneControl(ToneCommandMsg.TREBLE_KEY, R.string.tone_treble,
                    frameView.findViewById(R.id.treble_group),
                    state.trebleLevel,
                    ToneCommandMsg.NO_LEVEL, ToneCommandMsg.ZONE_COMMANDS.length);
            trebleGroup.setVisibility(isDirectMode ? View.GONE : View.VISIBLE);

            final CheckBox toneDirectCheckBox = frameView.findViewById(R.id.tone_direct_checkbox);
            toneDirectCheckBox.setChecked(isDirectMode);
            toneDirectCheckBox.setOnCheckedChangeListener((buttonView, isChecked) ->
            {
                bassGroup.setVisibility(isChecked ? View.GONE : View.VISIBLE);
                trebleGroup.setVisibility(isChecked ? View.GONE : View.VISIBLE);
                activity.getStateManager().sendMessage(new DirectCommandMsg(
                        isChecked ? DirectCommandMsg.Status.ON : DirectCommandMsg.Status.OFF));
            });
        }
        else
        {
            final boolean isDirectMode = state.listeningMode != null && state.listeningMode.isDirectMode();

            prepareToneControl(ToneCommandMsg.BASS_KEY, R.string.tone_bass,
                    frameView.findViewById(R.id.bass_group),
                    isDirectMode ? ToneCommandMsg.NO_LEVEL : state.bassLevel,
                    ToneCommandMsg.NO_LEVEL, ToneCommandMsg.ZONE_COMMANDS.length);

            prepareToneControl(ToneCommandMsg.TREBLE_KEY, R.string.tone_treble,
                    frameView.findViewById(R.id.treble_group),
                    isDirectMode ? ToneCommandMsg.NO_LEVEL : state.trebleLevel,
                    ToneCommandMsg.NO_LEVEL, ToneCommandMsg.ZONE_COMMANDS.length);
        }

        // Level for single channels
        prepareToneControl(SubwooferLevelCommandMsg.KEY, R.string.subwoofer_level,
                frameView.findViewById(R.id.subwoofer_level_group), state.subwooferLevel,
                SubwooferLevelCommandMsg.NO_LEVEL, 1);

        prepareToneControl(CenterLevelCommandMsg.KEY, R.string.center_level,
                frameView.findViewById(R.id.center_level_group), state.centerLevel,
                CenterLevelCommandMsg.NO_LEVEL, 1);

        final Drawable icon = Utils.getDrawable(activity, R.drawable.pref_volume_keys);
        Utils.setDrawableColorAttr(activity, icon, android.R.attr.textColorSecondary);

        final AlertDialog dialog = new AlertDialog.Builder(activity)
                .setTitle(R.string.audio_control)
                .setIcon(icon)
                .setCancelable(true)
                .setView(frameView).create();
        dialog.show();
        Utils.fixIconColor(dialog, android.R.attr.textColorSecondary);
        return true;
    }

    @SuppressLint("SetTextI18n")
    private LinearLayout prepareToneControl(final String toneKey, final int labelId, final LinearLayout toneGroup,
                                    int toneLevel, final int noLevel, final int maxZone)
    {
        final ReceiverInformationMsg.ToneControl toneControl =
                activity.getStateManager().getState().toneControls.get(toneKey);
        final int zone = activity.getStateManager().getState().getActiveZone();

        final boolean isTone = toneControl != null && toneLevel != noLevel && zone < maxZone;
        toneGroup.setVisibility(isTone ? View.VISIBLE : View.GONE);
        if (!isTone)
        {
            return toneGroup;
        }

        final String labelText = activity.getString(labelId);
        final TextView labelField = toneGroup.findViewWithTag("tone_label");
        if (labelField != null)
        {
            labelField.setText(labelText + ": " + toneLevel);
        }

        final TextView minText = toneGroup.findViewWithTag("tone_min_value");
        if (minText != null)
        {
            minText.setText(Integer.toString(toneControl.getMin()));
        }

        final TextView maxText = toneGroup.findViewWithTag("tone_max_value");
        if (maxText != null)
        {
            maxText.setText(Integer.toString(toneControl.getMax()));
        }

        final float step = toneControl.getStep() == 0 ? 0.5f : toneControl.getStep();
        final AppCompatSeekBar progressBar = toneGroup.findViewWithTag("tone_progress_bar");
        final int max = (int) ((float) (toneControl.getMax() - toneControl.getMin()) / step);
        progressBar.setMax(max);
        final int progress = (int) ((float) (toneLevel - toneControl.getMin()) / step);
        progressBar.setProgress(progress);
        progressBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener()
        {
            int progressChanged = 0;

            private int getScaledProgress()
            {
                return (int) ((float) progressChanged * step) + toneControl.getMin();
            }

            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser)
            {
                progressChanged = progress;
                if (labelField != null)
                {
                    labelField.setText(labelText + ": " + getScaledProgress());
                }
            }

            public void onStartTrackingTouch(SeekBar seekBar)
            {
                // empty
            }

            @SuppressLint("SetTextI18n")
            public void onStopTrackingTouch(SeekBar seekBar)
            {
                if (isVolumeComandEnabled())
                {
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

        return toneGroup;
    }


    /*
     * Timeseek control
     */
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
        final boolean sendHours = newSec >= 3600 || !state.getModel().equals("NT-503");
        if (currTime >= 0 && maxTime >= 0)
        {
            final int hour = newSec / 3600;
            final int min = (newSec - hour * 3600) / 60;
            final int sec = newSec - hour * 3600 - min * 60;
            activity.getStateManager().requestSkipNextTimeMsg(2);
            final TimeSeekMsg msg = new TimeSeekMsg(sendHours, hour, min, sec);
            state.currentTime = msg.getTimeAsString();
            ((TextView) rootView.findViewById(R.id.tv_time_start)).setText(state.currentTime);
            activity.getStateManager().sendMessage(msg);
        }
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
}
