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

package com.mkulesh.onpc.fragments;

import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.config.CfgAppSettings;
import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.iscp.State;
import com.mkulesh.onpc.iscp.messages.AutoPowerMsg;
import com.mkulesh.onpc.iscp.messages.DcpAudioRestorerMsg;
import com.mkulesh.onpc.iscp.messages.DcpEcoModeMsg;
import com.mkulesh.onpc.iscp.messages.DigitalFilterMsg;
import com.mkulesh.onpc.iscp.messages.DimmerLevelMsg;
import com.mkulesh.onpc.iscp.messages.FirmwareUpdateMsg;
import com.mkulesh.onpc.iscp.messages.FriendlyNameMsg;
import com.mkulesh.onpc.iscp.messages.GoogleCastAnalyticsMsg;
import com.mkulesh.onpc.iscp.messages.HdmiCecMsg;
import com.mkulesh.onpc.iscp.messages.LateNightCommandMsg;
import com.mkulesh.onpc.iscp.messages.MusicOptimizerMsg;
import com.mkulesh.onpc.iscp.messages.NetworkStandByMsg;
import com.mkulesh.onpc.iscp.messages.PhaseMatchingBassMsg;
import com.mkulesh.onpc.iscp.messages.SleepSetCommandMsg;
import com.mkulesh.onpc.iscp.messages.SpeakerACommandMsg;
import com.mkulesh.onpc.iscp.messages.SpeakerBCommandMsg;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.util.HashSet;

import androidx.annotation.IdRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;
import androidx.appcompat.app.AlertDialog;
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
        initializeFragment(inflater, container, R.layout.device_fragment, CfgAppSettings.Tabs.DEVICE);

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

        prepareImageButton(R.id.btn_firmware_update, null);
        prepareImageButton(R.id.device_dimmer_level_toggle, new DimmerLevelMsg(DimmerLevelMsg.Level.TOGGLE));
        prepareImageButton(R.id.device_digital_filter_toggle, new DigitalFilterMsg(DigitalFilterMsg.Filter.TOGGLE));
        prepareImageButton(R.id.music_optimizer_toggle, new MusicOptimizerMsg(MusicOptimizerMsg.Status.TOGGLE));
        prepareImageButton(R.id.device_auto_power_toggle, new AutoPowerMsg(AutoPowerMsg.Status.TOGGLE));
        prepareImageButton(R.id.hdmi_cec_toggle, null);
        prepareImageButton(R.id.phase_matching_bass_toggle, new PhaseMatchingBassMsg(PhaseMatchingBassMsg.Status.TOGGLE));
        prepareImageButton(R.id.sleep_time_toggle, null);
        prepareImageButton(R.id.speaker_ab_command_toggle, null);
        prepareImageButton(R.id.google_cast_analytics_toggle, null);
        prepareImageButton(R.id.late_night_command_toggle, new LateNightCommandMsg(LateNightCommandMsg.Status.UP));
        prepareImageButton(R.id.network_standby_toggle, null);
        prepareImageButton(R.id.dcp_eco_mode_toggle, null);
        prepareImageButton(R.id.dcp_audio_restorer_toggle, null);

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
    protected void updateStandbyView(@Nullable final State state)
    {
        updateDeviceInformation(state);
        if (state != null)
        {
            updateDeviceSettings(state);
        }
        else
        {
            final int[] settingsLayout = new int[]{
                    R.id.settings_title,
                    R.id.settings_divider,
                    R.id.device_dimmer_level_layout,
                    R.id.device_digital_filter_layout,
                    R.id.music_optimizer_layout,
                    R.id.device_auto_power_layout,
                    R.id.hdmi_cec_layout,
                    R.id.phase_matching_bass_layout,
                    R.id.sleep_time_layout,
                    R.id.speaker_ab_layout,
                    R.id.google_cast_analytics_layout,
                    R.id.late_night_command_layout,
                    R.id.network_standby_layout,
                    R.id.dcp_eco_mode_layout,
                    R.id.dcp_audio_restorer_layout
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
            updateDeviceInformation(state);
            updateDeviceSettings(state);
        }
    }

    private void updateDeviceInformation(@Nullable final State state)
    {
        // Host
        ((TextView) rootView.findViewById(R.id.device_info_address)).setText(
                (state != null) ? state.getHostAndPort() : "");

        // Friendly name
        final boolean isFnValid = state != null
                && state.isFriendlyName();
        final LinearLayout fnLayout = rootView.findViewById(R.id.device_friendly_name);
        fnLayout.setVisibility(isFnValid ? View.VISIBLE : View.GONE);
        if (isFnValid)
        {
            // Friendly name
            friendlyName.setText(state.getDeviceName(true));
        }

        // Receiver information
        final boolean isRiValid = state != null
                && state.isReceiverInformation()
                && !state.deviceProperties.isEmpty();
        final LinearLayout riLayout = rootView.findViewById(R.id.device_receiver_information);
        riLayout.setVisibility(isRiValid ? View.VISIBLE : View.GONE);
        if (isRiValid)
        {
            // Common properties
            ((TextView) rootView.findViewById(R.id.device_brand)).setText(state.getBrand());
            ((TextView) rootView.findViewById(R.id.device_model)).setText(state.getModel());
            ((TextView) rootView.findViewById(R.id.device_year)).setText(state.deviceProperties.get("year"));
            // Firmware version
            {
                StringBuilder version = new StringBuilder();
                version.append(state.deviceProperties.get("firmwareversion"));
                final boolean isValidVersions =
                        state.firmwareStatus == FirmwareUpdateMsg.Status.ACTUAL ||
                                state.firmwareStatus == FirmwareUpdateMsg.Status.NEW_VERSION ||
                                state.firmwareStatus == FirmwareUpdateMsg.Status.NEW_VERSION_NORMAL ||
                                state.firmwareStatus == FirmwareUpdateMsg.Status.NEW_VERSION_FORCE;
                final boolean isUpdating =
                        state.firmwareStatus == FirmwareUpdateMsg.Status.UPDATE_STARTED ||
                                state.firmwareStatus == FirmwareUpdateMsg.Status.UPDATE_COMPLETE;
                if (isValidVersions || isUpdating)
                {
                    version.append(", ").append(getStringValue(state.firmwareStatus.getDescriptionId()));
                }
                if (isValidVersions)
                {
                    // Update button
                    final AppCompatImageButton b = rootView.findViewById(R.id.btn_firmware_update);
                    b.setVisibility(View.VISIBLE);
                    setButtonEnabled(b, state.isOn());
                    prepareButtonListeners(b, null, this::onFirmwareUpdateButton);
                }
                ((TextView) rootView.findViewById(R.id.device_firmware)).setText(version.toString());
            }
            // Google cast version
            ((TextView) rootView.findViewById(R.id.google_cast_version)).setText(state.googleCastVersion);
        }

        final int[] deviceInfoLayout = new int[]{
                R.id.device_info_layout,
                R.id.device_info_divider
        };
        for (int layoutId : deviceInfoLayout)
        {
            rootView.findViewById(layoutId).setVisibility(isFnValid || isRiValid ? View.VISIBLE : View.GONE);
        }

        if (state != null)
        {
            hidePlatformSpecificParameters(state.protoType);
        }
    }

    private void hidePlatformSpecificParameters(Utils.ProtoType protoType)
    {
        final int vis = protoType == Utils.ProtoType.ISCP ? View.VISIBLE : View.GONE;
        ((LinearLayout)(rootView.findViewById(R.id.device_year).getParent())).setVisibility(vis);
        ((LinearLayout)(rootView.findViewById(R.id.google_cast_version).getParent())).setVisibility(vis);
    }

    private void onFirmwareUpdateButton()
    {
        if (getContext() != null && activity.isConnected() && activity.getStateManager().getState().isOn())
        {
            final Drawable icon = Utils.getDrawable(getContext(), R.drawable.cmd_firmware_update);
            Utils.setDrawableColorAttr(getContext(), icon, android.R.attr.textColorSecondary);
            final AlertDialog dialog = new AlertDialog.Builder(getContext())
                    .setTitle(R.string.device_firmware)
                    .setIcon(icon)
                    .setCancelable(true)
                    .setMessage(R.string.device_firmware_confirm)
                    .setNeutralButton(R.string.action_cancel, (d, which) -> d.dismiss())
                    .setPositiveButton(R.string.action_ok, (d, which) ->
                    {
                        if (activity.isConnected())
                        {
                            activity.getStateManager().sendMessageToGroup(
                                    new FirmwareUpdateMsg(FirmwareUpdateMsg.Status.NET));
                        }
                        d.dismiss();
                    }).create();
            dialog.show();
            Utils.fixIconColor(dialog, android.R.attr.textColorSecondary);
        }
    }

    private void updateDeviceSettings(@NonNull final State state)
    {
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
                R.id.hdmi_cec_layout, state.hdmiCec.getDescriptionId(),
                new HdmiCecMsg(HdmiCecMsg.toggle(state.hdmiCec, state.protoType)));

        // Phase Matching Bass Command
        prepareSettingPanel(state, state.phaseMatchingBass != PhaseMatchingBassMsg.Status.NONE,
                R.id.phase_matching_bass_layout, state.phaseMatchingBass.getDescriptionId(), null);

        // Sleep time
        {
            final String description = state.sleepTime == SleepSetCommandMsg.SLEEP_OFF ?
                    getStringValue(R.string.device_two_way_switch_off) :
                    state.sleepTime + " " + getStringValue(R.string.device_sleep_time_minutes);
            prepareSettingPanel(state, state.sleepTime != SleepSetCommandMsg.NOT_APPLICABLE,
                    R.id.sleep_time_layout, description,
                    new SleepSetCommandMsg(SleepSetCommandMsg.toggle(state.sleepTime, state.protoType)));
        }

        // Speaker A/B (For Main zone and Zone 2 only)
        {
            final int zone = state.getActiveZone();
            final boolean zoneAllowed = (zone < 2);
            final SpeakerABStatus spState = getSpeakerABStatus(state.speakerA, state.speakerB);
            prepareSettingPanel(state, zoneAllowed && spState != SpeakerABStatus.NONE,
                    R.id.speaker_ab_layout, spState.getDescriptionId(), null);
            final AppCompatImageButton b = rootView.findViewById(R.id.speaker_ab_command_toggle);
            // OFF -> A_ONLY -> B_ONLY -> ON -> OFF (optional) -> A_ONLY -> B_ONLY -> ON -> ...
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
                if (state.getModel().equals("DTM-6"))
                {
                    // This feature allowed for DTM-6 only since some Onkyo models go to "Standby"
                    // power mode by accident when both zones are turned off at the same time.
                    prepareButtonListeners(b,
                            new SpeakerBCommandMsg(zone, SpeakerBCommandMsg.Status.OFF),
                            () -> {
                                activity.getStateManager().sendMessage(
                                        new SpeakerACommandMsg(zone, SpeakerACommandMsg.Status.OFF));
                                sendQueries(zone);
                            });
                }
                else
                {
                    prepareButtonListeners(b,
                            new SpeakerBCommandMsg(zone, SpeakerBCommandMsg.Status.OFF),
                            () -> sendQueries(zone));
                }
                break;
            }
        }

        // Google Cast analytics
        prepareSettingPanel(state, state.googleCastAnalytics != GoogleCastAnalyticsMsg.Status.NONE,
                R.id.google_cast_analytics_layout, state.googleCastAnalytics.getDescriptionId(),
                new GoogleCastAnalyticsMsg(GoogleCastAnalyticsMsg.toggle(state.googleCastAnalytics)));

        // Late Night Command
        prepareSettingPanel(state, state.lateNightMode != LateNightCommandMsg.Status.NONE,
                R.id.late_night_command_layout, state.lateNightMode.getDescriptionId(), null);

        // Network Standby Command
        prepareSettingPanel(state, state.networkStandBy != NetworkStandByMsg.Status.NONE,
                R.id.network_standby_layout, state.networkStandBy.getDescriptionId(), null);
        {
            final AppCompatImageButton b = rootView.findViewById(R.id.network_standby_toggle);
            prepareButtonListeners(b, null, this::onNetworkStandByToggle);
        }

        // DCP ECO mode
        prepareSettingPanel(state, state.dcpEcoMode != DcpEcoModeMsg.Status.NONE,
                R.id.dcp_eco_mode_layout, state.dcpEcoMode.getDescriptionId(),
                new DcpEcoModeMsg(DcpEcoModeMsg.toggle(state.dcpEcoMode)));

        // DCP audio restorer
        prepareSettingPanel(state, state.dcpAudioRestorer != DcpAudioRestorerMsg.Status.NONE,
                R.id.dcp_audio_restorer_layout, state.dcpAudioRestorer.getDescriptionId(),
                new DcpAudioRestorerMsg(DcpAudioRestorerMsg.toggle(state.dcpAudioRestorer)));
    }

    private void onNetworkStandByToggle()
    {
        if (getContext() == null || !activity.isConnected() || !activity.getStateManager().getState().isOn())
        {
            return;
        }
        final NetworkStandByMsg.Status networkStandBy = activity.getStateManager().getState().networkStandBy;
        if (networkStandBy == NetworkStandByMsg.Status.OFF)
        {
            activity.getStateManager().sendMessage(new NetworkStandByMsg(NetworkStandByMsg.Status.ON));
        }
        else
        {
            final Drawable icon = Utils.getDrawable(getContext(), R.drawable.menu_power_standby);
            Utils.setDrawableColorAttr(getContext(), icon, android.R.attr.textColorSecondary);
            final AlertDialog dialog = new AlertDialog.Builder(getContext())
                    .setTitle(R.string.device_network_standby)
                    .setIcon(icon)
                    .setCancelable(true)
                    .setMessage(R.string.device_network_standby_confirm)
                    .setNeutralButton(R.string.action_cancel, (d, which) -> d.dismiss())
                    .setPositiveButton(R.string.action_ok, (d, which) ->
                    {
                        if (activity.isConnected())
                        {
                            activity.getStateManager().sendMessage(new NetworkStandByMsg(NetworkStandByMsg.Status.OFF));
                        }
                        d.dismiss();
                    }).create();
            dialog.show();
            Utils.fixIconColor(dialog, android.R.attr.textColorSecondary);
        }
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
        prepareSettingPanel(state, visible, layoutId, getStringValue(descriptionId), msg);
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
