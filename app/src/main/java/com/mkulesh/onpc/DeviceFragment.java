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

import android.os.AsyncTask;
import android.os.Bundle;
import android.support.annotation.IdRes;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.annotation.StringRes;
import android.support.v7.widget.AppCompatImageButton;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.mkulesh.onpc.iscp.BroadcastSearch;
import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.iscp.messages.AutoPowerMsg;
import com.mkulesh.onpc.iscp.messages.DigitalFilterMsg;
import com.mkulesh.onpc.iscp.messages.DimmerLevelMsg;
import com.mkulesh.onpc.iscp.messages.FirmwareUpdateMsg;
import com.mkulesh.onpc.iscp.messages.GoogleCastAnalyticsMsg;
import com.mkulesh.onpc.iscp.messages.HdmiCecMsg;
import com.mkulesh.onpc.utils.Logging;

import java.util.HashSet;

public class DeviceFragment extends BaseFragment implements View.OnClickListener
{
    private EditText deviceName, devicePort;

    public DeviceFragment()
    {
        // Empty constructor required for fragment subclasses
    }

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
    {
        initializeFragment(inflater, container, R.layout.device_fragment);

        final AppCompatImageButton btnConnect = prepareImageButton(R.id.device_connect, null);
        setButtonEnabled(btnConnect, true);
        btnConnect.setOnClickListener(this);

        deviceName = rootView.findViewById(R.id.device_name);
        devicePort = rootView.findViewById(R.id.device_port);

        final AppCompatImageButton btnSearchDevice = prepareImageButton(R.id.btn_search_device, null);
        setButtonEnabled(btnSearchDevice, true);
        btnSearchDevice.setOnClickListener(this);

        prepareImageButton(R.id.btn_firmware_update, new FirmwareUpdateMsg(FirmwareUpdateMsg.Status.NET));
        prepareImageButton(R.id.device_dimmer_level_toggle, new DimmerLevelMsg(DimmerLevelMsg.Level.TOGGLE));
        prepareImageButton(R.id.device_digital_filter_toggle, new DigitalFilterMsg(DigitalFilterMsg.Filter.TOGGLE));
        prepareImageButton(R.id.device_auto_power_toggle, new AutoPowerMsg(AutoPowerMsg.Status.TOGGLE));
        prepareImageButton(R.id.hdmi_cec_toggle, new HdmiCecMsg(HdmiCecMsg.Status.TOGGLE));
        prepareImageButton(R.id.google_cast_analytics_toggle, null);

        update(null, null);
        return rootView;
    }

    @Override
    public void onClick(View v)
    {
        if (v.getId() == R.id.device_connect)
        {
            final String device = deviceName.getText().toString();
            final int port = Integer.parseInt(devicePort.getText().toString());
            if (activity.connectToDevice(device, port))
            {
                activity.getConfiguration().saveDevice(device, port);
            }
        }
        if (v.getId() == R.id.btn_search_device)
        {
            final BroadcastSearch bs = new BroadcastSearch(activity,
                    new BroadcastSearch.SearchListener()
                    {
                        // These methods will be called from GUI thread
                        @Override
                        public void onDeviceFound(final String device, final int port, EISCPMessage response)
                        {
                            DeviceFragment.this.onDeviceFound(device, port, response);
                        }

                        @Override
                        public void noDevice()
                        {
                            DeviceFragment.this.noDevice();
                        }
                    }, 5000, 5);
            bs.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, (Void[]) null);
        }
    }

    void onDeviceFound(final String device, final int port, EISCPMessage response)
    {
        if (response != null && activity.connectToDevice(device, port))
        {
            activity.getConfiguration().saveDevice(device, port);
            deviceName.setText(activity.getConfiguration().getDeviceName());
            devicePort.setText(activity.getConfiguration().getDevicePortAsString());
        }
    }

    void noDevice()
    {
        Toast.makeText(activity, R.string.error_connection_timeout, Toast.LENGTH_LONG).show();
    }

    @Override
    protected void updateStandbyView(@Nullable final State state, @NonNull final HashSet<State.ChangeType> eventChanges)
    {
        if (state != null)
        {
            updateDeviceProperties(state);
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
        if (deviceName.getText().length() == 0)
        {
            deviceName.setText(activity.getConfiguration().getDeviceName());
        }
        if (devicePort.getText().length() == 0)
        {
            devicePort.setText(activity.getConfiguration().getDevicePortAsString());
        }

        if (!state.deviceProperties.isEmpty())
        {
            ((TextView) rootView.findViewById(R.id.device_brand)).setText(state.deviceProperties.get("brand"));
            ((TextView) rootView.findViewById(R.id.device_model)).setText(state.deviceProperties.get("model"));
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
                b.setVisibility(state.firmwareStatus == FirmwareUpdateMsg.Status.NEW_VERSION ?
                        View.VISIBLE : View.GONE);
                if (b.getVisibility() == View.VISIBLE)
                {
                    setButtonEnabled(b, true);
                }
            }
        }

        ((TextView) rootView.findViewById(R.id.google_cast_version)).setText(state.googleCastVersion);

        // Dimmer level
        prepareSettingPanel(state, state.dimmerLevel != DimmerLevelMsg.Level.NONE,
                R.id.device_dimmer_level_layout, state.dimmerLevel.getDescriptionId(), null);

        // Digital filter
        prepareSettingPanel(state, state.digitalFilter != DigitalFilterMsg.Filter.NONE,
                R.id.device_digital_filter_layout, state.digitalFilter.getDescriptionId(), null);

        // Auto power
        prepareSettingPanel(state, state.autoPower != AutoPowerMsg.Status.NONE,
                R.id.device_auto_power_layout, state.autoPower.getDescriptionId(), null);

        // HDMI CEC
        prepareSettingPanel(state, state.hdmiCec != HdmiCecMsg.Status.NONE,
                R.id.hdmi_cec_layout, state.hdmiCec.getDescriptionId(), null);

        // Google Cast analytics
        {
            final GoogleCastAnalyticsMsg toggleMsg = new GoogleCastAnalyticsMsg(
                    (state.googleCastAnalytics == GoogleCastAnalyticsMsg.Status.OFF) ?
                            GoogleCastAnalyticsMsg.Status.ON : GoogleCastAnalyticsMsg.Status.OFF);

            prepareSettingPanel(state, state.googleCastAnalytics != GoogleCastAnalyticsMsg.Status.NONE,
                    R.id.google_cast_analytics_layout, state.googleCastAnalytics.getDescriptionId(), toggleMsg);
        }
    }

    private void prepareSettingPanel(@NonNull final State state, boolean visible, @IdRes int layoutId,
                                     @StringRes int descriptionId, final ISCPMessage msg)
    {
        final LinearLayout layout = rootView.findViewById(layoutId);
        if (!visible)
        {
            layout.setVisibility(View.GONE);
            return;
        }

        layout.setVisibility(View.VISIBLE);
        for (int i = 0; i < layout.getChildCount(); i++)
        {
            final View child = layout.getChildAt(i);
            if (child instanceof TextView)
            {
                final TextView tv = (TextView) child;
                if (tv.getTag() != null && "VALUE".equals(tv.getTag()))
                {
                    tv.setText(descriptionId);
                }
            }
            if (child instanceof AppCompatImageButton)
            {
                if (msg != null)
                {
                    prepareButtonListeners(child, msg);
                }
                setButtonEnabled(child, state.isOn());
            }
        }
    }

    protected AppCompatImageButton prepareImageButton(@IdRes int buttonId, final ISCPMessage msg)
    {
        final AppCompatImageButton b = rootView.findViewById(buttonId);
        prepareButtonListeners(b, msg);
        setButtonEnabled(b, false);
        return b;
    }
}
