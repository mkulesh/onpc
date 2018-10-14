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
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v7.widget.AppCompatImageButton;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import com.mkulesh.onpc.utils.Utils;

public class DeviceFragment extends BaseFragment implements View.OnClickListener
{
    private ImageView deviceCover = null;

    public DeviceFragment()
    {
        // Empty constructor required for fragment subclasses
    }

    @SuppressLint("SetTextI18n")
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
    {
        initializeFragment(inflater, container, R.layout.device_fragment);

        final Button buttonServerConnect = rootView.findViewById(R.id.device_connect);
        buttonServerConnect.setOnClickListener(this);

        ((EditText) rootView.findViewById(R.id.device_name)).setText(preferences.getString(
                DeviceFragment.SERVER_NAME, "onkyo"));
        ((EditText) rootView.findViewById(R.id.device_port)).setText(Integer.toString(preferences.getInt(
                DeviceFragment.SERVER_PORT, 60128)));

        deviceCover = rootView.findViewById(R.id.device_cover);

        update(null);
        return rootView;
    }

    @SuppressLint("ApplySharedPref")
    @Override
    public void onClick(View v)
    {
        if (v.getId() == R.id.device_connect)
        {
            final String serverName = ((EditText) rootView.findViewById(R.id.device_name)).getText().toString();
            final String serverPortStr = ((EditText) rootView.findViewById(R.id.device_port)).getText()
                    .toString();
            final int serverPort = Integer.parseInt(serverPortStr);
            if (activity.connectToServer(serverName, serverPort))
            {
                SharedPreferences.Editor prefEditor = preferences.edit();
                prefEditor.putString(SERVER_NAME, serverName);
                prefEditor.putInt(SERVER_PORT, serverPort);
                prefEditor.commit();
            }
        }
    }

    @Override
    protected void updateStandbyView(@Nullable final State state)
    {
        updateDeviceCover(state);
        if (state != null)
        {
            updateDeviceProperties(state);
        }
    }

    @Override
    protected void updateActiveView(@NonNull final State state)
    {
        updateDeviceCover(state);
        updateDeviceProperties(state);
    }

    private void updateDeviceCover(@Nullable final State state)
    {
        if (state != null && state.deviceCover != null)
        {
            deviceCover.setVisibility(View.VISIBLE);
            deviceCover.setImageBitmap(state.deviceCover);
        }
        else
        {
            deviceCover.setVisibility(View.GONE);
            deviceCover.setImageBitmap(null);
        }
    }

    private void updateDeviceProperties(@NonNull final State state)
    {
        if (!state.deviceProperties.isEmpty())
        {
            ((TextView) rootView.findViewById(R.id.device_brand)).setText(state.deviceProperties.get("brand"));
            ((TextView) rootView.findViewById(R.id.device_model)).setText(state.deviceProperties.get("model"));
            ((TextView) rootView.findViewById(R.id.device_year)).setText(state.deviceProperties.get("year"));
            final StringBuilder firmware = new StringBuilder();
            firmware.append(state.deviceProperties.get("firmwareversion"));
            if (state.newFirmware)
            {
                firmware.append(", ").append(activity.getResources().getString(R.string.state_new_firmware));
                final AppCompatImageButton b = rootView.findViewById(R.id.btn_firmware_update);
                b.setVisibility(View.VISIBLE);
                b.setOnLongClickListener(new View.OnLongClickListener()
                {
                    @Override
                    public boolean onLongClick(View v)
                    {
                        return Utils.showButtonDescription(activity, v);
                    }
                });
                Utils.setImageButtonColorAttr(activity, b, R.attr.colorButtonEnabled);
                b.setOnClickListener(new View.OnClickListener()
                {
                    @Override
                    public void onClick(View v)
                    {
                        if (activity.getStateManager() != null)
                        {
                            activity.getStateManager().requestFirmwareUpdate();
                        }
                    }
                });
            }
            else
            {
                rootView.findViewById(R.id.btn_firmware_update).setVisibility(View.GONE);
            }
            ((TextView) rootView.findViewById(R.id.device_firmware)).setText(firmware.toString());
        }
    }
}
