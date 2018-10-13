package com.mkulesh.onpc;

import android.annotation.SuppressLint;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

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
    }

    @Override
    protected void updateActiveView(@NonNull final State state)
    {
        updateDeviceCover(state);

        if (!state.deviceProperties.isEmpty())
        {
            ((TextView) rootView.findViewById(R.id.device_brand)).setText(state.deviceProperties.get("brand"));
            ((TextView) rootView.findViewById(R.id.device_model)).setText(state.deviceProperties.get("model"));
            ((TextView) rootView.findViewById(R.id.device_year)).setText(state.deviceProperties.get("year"));
            ((TextView) rootView.findViewById(R.id.device_firmware)).setText(state.deviceProperties.get("firmwareversion"));
        }
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
}
