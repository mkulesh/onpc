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

import android.os.Build;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.iscp.State;
import com.mkulesh.onpc.iscp.messages.AutoPowerMsg;
import com.mkulesh.onpc.iscp.messages.DigitalFilterMsg;
import com.mkulesh.onpc.iscp.messages.DimmerLevelMsg;
import com.mkulesh.onpc.iscp.messages.FirmwareUpdateMsg;
import com.mkulesh.onpc.iscp.messages.FriendlyNameMsg;
import com.mkulesh.onpc.iscp.messages.GoogleCastAnalyticsMsg;
import com.mkulesh.onpc.iscp.messages.HdmiCecMsg;
import com.mkulesh.onpc.iscp.messages.MusicOptimizerMsg;
import com.mkulesh.onpc.iscp.messages.PhaseMatchingBassMsg;
import com.mkulesh.onpc.iscp.messages.SleepSetCommandMsg;
import com.mkulesh.onpc.iscp.messages.SpeakerACommandMsg;
import com.mkulesh.onpc.iscp.messages.SpeakerBCommandMsg;
import com.mkulesh.onpc.utils.Logging;

import java.util.HashSet;

import androidx.annotation.IdRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;
import androidx.appcompat.widget.AppCompatImageButton;

public class DeviceFragment extends BaseFragment
{
    private enum SpeakerABStatus
    {
        NONE(R.string.device_two_way_switch_none, SpeakerACommandMsg.Status.NONE, SpeakerBCommandMsg.Status.NONE),
        OFF(R.string.speaker_ab_command_ab_off, SpeakerACommandMsg.Status.OFF, SpeakerBCommandMsg.Status.OFF),
        ON(R.string.speaker_ab_command_ab_on, SpeakerACommandMsg.Status.ON, SpeakerBCommandMsg.Status.ON),
        A_ONLY(R.string.speaker_ab_command_a_only, SpeakerACommandMsg.Status.ON, null),
        B_ONLY(R.string.speaker_ab_command_b_only, null, SpeakerBCommandMsg.Status.ON);

        @StringRes
        final int descriptionId;

        final SpeakerACommandMsg.Status speakerA;
        final SpeakerBCommandMsg.Status speakerB;

        SpeakerABStatus(@StringRes final int descriptionId,
                        final SpeakerACommandMsg.Status speakerA,
                        final SpeakerBCommandMsg.Status speakerB)
        {
            this.descriptionId = descriptionId;
            this.speakerA = speakerA;
            this.speakerB = speakerB;
        }

        @StringRes
        int getDescriptionId()
        {
            return descriptionId;
        }
    }

    private EditText friendlyName = null;

    public DeviceFragment()
    {
        // Empty constructor required for fragment subclasses
    }

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
    {
        initializeFragment(inflater, container, R.layout.device_fragment);

        // Friendly name
        {
            friendlyName = rootView.findViewById(R.id.device_edit_friendly_name);
            final AppCompatImageButton b = rootView.findViewById(R.id.device_change_friendly_name);
            prepareButtonListeners(b, null, () ->
            {
                if (activity.isConnected())
                {
                    activity.getStateManager().sendMessage(
                            new FriendlyNameMsg(friendlyName.getText().toString()));
                    // #119: Improve clearing focus for friendly name edit field
                    friendlyName.clearFocus();
                }
            });
            setButtonEnabled(b, true);

            // #119: Improve clearing focus for friendly name edit field
            // OnClick for background layout: clear focus for friendly name text field
            {
                LinearLayout l = rootView.findViewById(R.id.device_background_layout);
                l.setClickable(true);
                l.setEnabled(true);
                l.setOnClickListener((v) -> friendlyName.clearFocus());
            }
        }

        prepareImageButton(R.id.btn_firmware_update, new FirmwareUpdateMsg(FirmwareUpdateMsg.Status.NET));
        prepareImageButton(R.id.device_dimmer_level_toggle, new DimmerLevelMsg(DimmerLevelMsg.Level.TOGGLE));
        prepareImageButton(R.id.device_digital_filter_toggle, new DigitalFilterMsg(DigitalFilterMsg.Filter.TOGGLE));
        prepareImageButton(R.id.music_optimizer_toggle, new MusicOptimizerMsg(MusicOptimizerMsg.Status.TOGGLE));
        prepareImageButton(R.id.device_auto_power_toggle, new AutoPowerMsg(AutoPowerMsg.Status.TOGGLE));
        prepareImageButton(R.id.hdmi_cec_toggle, new HdmiCecMsg(HdmiCecMsg.Status.TOGGLE));
        prepareImageButton(R.id.phase_matching_bass_toggle, new PhaseMatchingBassMsg(PhaseMatchingBassMsg.Status.TOGGLE));
        prepareImageButton(R.id.sleep_time_toggle, null);
        prepareImageButton(R.id.speaker_ab_command_toggle, null);
        prepareImageButton(R.id.google_cast_analytics_toggle, null);

        updateContent();
        return rootView;
    }

    @Override
    public void onResume()
    {
        if (friendlyName != null)
        {
            friendlyName.clearFocus();
        }
        super.onResume();
    }

    @Override
    protected void updateStandbyView(@Nullable final State state, @NonNull final HashSet<State.ChangeType> eventChanges)
    {
        if (state != null)
        {
            updateDeviceProperties(state);
        }
        else
        {
            final int[] settingsLayout = new int[]{
                    R.id.settings_title,
                    R.id.settings_divider,
                    R.id.device_dimmer_level_layout,
                    R.id.device_digital_filter_layout,
                    R.id.device_auto_power_layout,
                    R.id.hdmi_cec_layout,
                    R.id.phase_matching_bass_layout,
                    R.id.sleep_time_layout,
                    R.id.speaker_ab_layout,
                    R.id.google_cast_analytics_layout
            };
            for (int layoutId : settingsLayout)
            {
                rootView.findViewById(layoutId).setVisibility(View.GONE);
            }
        }
    }

    @Override
    protected void updateActiveView(@NonNull final State state, @NonNull final HashSet<State.ChangeType> eventChanges)
    {
        if (eventChanges.contains(State.ChangeType.COMMON) ||
                eventChanges.contains(State.ChangeType.RECEIVER_INFO))
        {
            Logging.info(this, "Updating device properties");
            updateDeviceProperties(state);
        }
    }

    private void updateDeviceProperties(@NonNull final State state)
    {
        friendlyName.setText(state.getDeviceName(true));

        if (!state.deviceProperties.isEmpty())
        {
            ((TextView) rootView.findViewById(R.id.device_brand)).setText(state.deviceProperties.get("brand"));
            ((TextView) rootView.findViewById(R.id.device_model)).setText(state.getModel());
            ((TextView) rootView.findViewById(R.id.device_year)).setText(state.deviceProperties.get("year"));
            // Firmware version
            {
                StringBuilder version = new StringBuilder();
                version.append(state.deviceProperties.get("firmwareversion"));
                if (state.firmwareStatus != FirmwareUpdateMsg.Status.NONE)
                {
                    version.append(", ").append(
                            activity.getResources().getString(state.firmwareStatus.getDescriptionId()));
                }
                ((TextView) rootView.findViewById(R.id.device_firmware)).setText(version.toString());
            }
            // Update button
            {
                final AppCompatImageButton b = rootView.findViewById(R.id.btn_firmware_update);
                b.setVisibility((state.firmwareStatus == FirmwareUpdateMsg.Status.NEW_VERSION ||
                                 state.firmwareStatus == FirmwareUpdateMsg.Status.NEW_VERSION_FORCE)?
                        View.VISIBLE : View.GONE);
                if (b.getVisibility() == View.VISIBLE)
                {
                    setButtonEnabled(b, true);
                }
            }
        }

        ((TextView) rootView.findViewById(R.id.google_cast_version)).setText(state.googleCastVersion);

        // Update settings
        rootView.findViewById(R.id.settings_title).setVisibility(View.GONE);
        rootView.findViewById(R.id.settings_divider).setVisibility(View.GONE);

        // Dimmer level
        prepareSettingPanel(state, state.dimmerLevel != DimmerLevelMsg.Level.NONE,
                R.id.device_dimmer_level_layout, state.dimmerLevel.getDescriptionId(), null);

        // Digital filter
        prepareSettingPanel(state, state.digitalFilter != DigitalFilterMsg.Filter.NONE,
                R.id.device_digital_filter_layout, state.digitalFilter.getDescriptionId(), null);

        // Music Optimizer
        prepareSettingPanel(state, state.musicOptimizer != MusicOptimizerMsg.Status.NONE,
                R.id.music_optimizer_layout, state.musicOptimizer.getDescriptionId(), null);

        // Auto power
        prepareSettingPanel(state, state.autoPower != AutoPowerMsg.Status.NONE,
                R.id.device_auto_power_layout, state.autoPower.getDescriptionId(), null);

        // HDMI CEC
        prepareSettingPanel(state, state.hdmiCec != HdmiCecMsg.Status.NONE,
                R.id.hdmi_cec_layout, state.hdmiCec.getDescriptionId(), null);

        // Phase Matching Bass Command
        prepareSettingPanel(state, state.phaseMatchingBass != PhaseMatchingBassMsg.Status.NONE,
                R.id.phase_matching_bass_layout, state.phaseMatchingBass.getDescriptionId(), null);

        // Sleep time
        {
            final String description = state.sleepTime == SleepSetCommandMsg.SLEEP_OFF ?
                    getString(R.string.device_two_way_switch_off) :
                    state.sleepTime + " " + getString(R.string.device_sleep_time_minutes);
            prepareSettingPanel(state, state.sleepTime != SleepSetCommandMsg.NOT_APPLICABLE,
                    R.id.sleep_time_layout, description,
                    new SleepSetCommandMsg(SleepSetCommandMsg.toggle(state.sleepTime)));
        }

        // Speaker A/B (For Main zone and Zone 2 only)
        {
            final int zone = state.getActiveZone();
            final boolean zoneAllowed = (zone < 2);
            final SpeakerABStatus spState = getSpeakerABStatus(state.speakerA, state.speakerB);
            prepareSettingPanel(state, zoneAllowed && spState != SpeakerABStatus.NONE,
                    R.id.speaker_ab_layout, spState.getDescriptionId(), null);
            final AppCompatImageButton b = rootView.findViewById(R.id.speaker_ab_command_toggle);
            // OFF -> A_ONLY -> B_ONLY -> ON -> A_ONLY -> B_ONLY -> ON -> A_ONLY -> ...
            switch (spState)
            {
            case NONE:
                // nothing to do
                break;
            case OFF:
            case B_ONLY:
                    prepareButtonListeners(b,
                        new SpeakerACommandMsg(zone, SpeakerACommandMsg.Status.ON),
                        () -> sendQueries(zone));
                break;
            case A_ONLY:
                prepareButtonListeners(b,
                        new SpeakerBCommandMsg(zone, SpeakerBCommandMsg.Status.ON),
                        () -> {
                            activity.getStateManager().sendMessage(
                                new SpeakerACommandMsg(zone, SpeakerACommandMsg.Status.OFF));
                            sendQueries(zone);
                        });
                break;
            case ON:
                prepareButtonListeners(b,
                        new SpeakerBCommandMsg(zone, SpeakerBCommandMsg.Status.OFF),
                        () -> sendQueries(zone));
                break;
            }
        }

        // Google Cast analytics
        prepareSettingPanel(state, state.googleCastAnalytics != GoogleCastAnalyticsMsg.Status.NONE,
                R.id.google_cast_analytics_layout, state.googleCastAnalytics.getDescriptionId(),
                new GoogleCastAnalyticsMsg(GoogleCastAnalyticsMsg.toggle(state.googleCastAnalytics)));
    }

    private void sendQueries(int zone)
    {
        final String[] speakerStateQueries = new String[]{
                SpeakerACommandMsg.ZONE_COMMANDS[zone],
                SpeakerBCommandMsg.ZONE_COMMANDS[zone]
        };
        activity.getStateManager().sendQueries(speakerStateQueries, "requesting speaker state...");
    }

    private void prepareSettingPanel(@NonNull final State state, boolean visible, @IdRes int layoutId,
                                     @StringRes int descriptionId, final ISCPMessage msg)
    {
        String value = "";
        try
        {
            value = getString(descriptionId);
        }
        catch (Exception ex)
        {
            // nothing to do
        }
        prepareSettingPanel(state, visible, layoutId, value, msg);
    }

    private void prepareSettingPanel(@NonNull final State state, boolean visible, @IdRes int layoutId,
                                     final String description, final ISCPMessage msg)
    {
        final LinearLayout layout = rootView.findViewById(layoutId);
        if (!visible || !state.isOn())
        {
            layout.setVisibility(View.GONE);
            return;
        }

        rootView.findViewById(R.id.settings_title).setVisibility(View.VISIBLE);
        rootView.findViewById(R.id.settings_divider).setVisibility(View.VISIBLE);
        layout.setVisibility(View.VISIBLE);
        TextView tv = null;
        AppCompatImageButton button = null;
        for (int i = 0; i < layout.getChildCount(); i++)
        {
            final View child = layout.getChildAt(i);
            if (child instanceof TextView)
            {
                tv = (TextView) child;
                if (tv.getTag() != null && "VALUE".equals(tv.getTag()))
                {
                    tv.setText(description);
                }
            }
            if (child instanceof AppCompatImageButton)
            {
                if (msg != null)
                {
                    // In order to avoid scrolling up if device name field is focused,
                    // clear its focus
                    prepareButtonListeners(child, msg, friendlyName::clearFocus);
                }
                setButtonEnabled(child, state.isOn());
                if (state.isOn())
                {
                    button = (AppCompatImageButton) child;
                }
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.ICE_CREAM_SANDWICH_MR1)
        {
            if (tv != null && button != null)
            {
                final AppCompatImageButton b = button;
                tv.setEnabled(true);
                tv.setClickable(true);
                tv.setOnClickListener((View v) -> b.callOnClick());
            }
        }
    }

    private void prepareImageButton(@IdRes int buttonId, final ISCPMessage msg)
    {
        final AppCompatImageButton b = rootView.findViewById(buttonId);
        prepareButtonListeners(b, msg, friendlyName::clearFocus);
        setButtonEnabled(b, false);
    }

    @NonNull
    private SpeakerABStatus getSpeakerABStatus(
            SpeakerACommandMsg.Status speakerA, SpeakerBCommandMsg.Status speakerB)
    {
        for (final SpeakerABStatus s : SpeakerABStatus.values())
        {
            if (speakerA == s.speakerA && speakerB == s.speakerB)
            {
                return s;
            }
        }
        if (speakerA == SpeakerACommandMsg.Status.ON
                && speakerB != SpeakerBCommandMsg.Status.ON)
        {
            return SpeakerABStatus.A_ONLY;
        }
        if (speakerA != SpeakerACommandMsg.Status.ON
                && speakerB == SpeakerBCommandMsg.Status.ON)
        {
            return SpeakerABStatus.B_ONLY;
        }
        return SpeakerABStatus.OFF;
    }

}
