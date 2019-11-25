/*
 * Copyright (C) 2019. Mikhail Kulesh
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

package com.mkulesh.onpc.iscp;

import android.annotation.SuppressLint;
import android.content.Context;
import android.net.ConnectivityManager;
import android.net.DhcpInfo;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.NetworkInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.widget.Toast;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.utils.AppTask;
import com.mkulesh.onpc.utils.Logging;

import java.net.InetAddress;

import androidx.annotation.NonNull;
import androidx.annotation.StringRes;

@SuppressLint("NewApi")
public class ConnectionState extends AppTask
{
    public enum FailureReason
    {
        NO_NETWORK(R.string.error_connection_no_network),
        NO_WIFI(R.string.error_connection_no_wifi),
        NO_DEVICE(R.string.error_connection_no_device);

        @StringRes
        final int descriptionId;

        FailureReason(@StringRes final int descriptionId)
        {
            this.descriptionId = descriptionId;
        }

        @StringRes
        int getDescriptionId()
        {
            return descriptionId;
        }
    }

    private final Context context;
    private final ConnectivityManager connectivity;
    private final WifiManager wifi;

    public ConnectionState(Context context)
    {
        super(true);
        this.context = context;
        this.connectivity = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        this.wifi = (WifiManager) context.getApplicationContext().getSystemService(Context.WIFI_SERVICE);
    }

    public Context getContext()
    {
        return context;
    }

    boolean isNetwork()
    {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
        {
            final Network net = connectivity.getActiveNetwork();
            if (net == null)
            {
                return false;
            }
            return connectivity.getNetworkCapabilities(net) != null;
        }
        else
        {
            final NetworkInfo netInfo = connectivity.getActiveNetworkInfo();
            return netInfo != null && netInfo.isConnected();
        }
    }

    boolean isWifi()
    {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
        {
            final Network net = connectivity.getActiveNetwork();
            if (net == null)
            {
                return false;
            }
            final NetworkCapabilities cap = connectivity.getNetworkCapabilities(net);
            if (cap == null)
            {
                return false;
            }
            return cap.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)
                    || cap.hasTransport(NetworkCapabilities.TRANSPORT_VPN);
        }
        else
        {
            return wifi != null &&
                    wifi.isWifiEnabled() &&
                    wifi.getConnectionInfo() != null &&
                    wifi.getConnectionInfo().getNetworkId() != -1;
        }
    }

    public void showFailure(@NonNull final FailureReason reason)
    {
        final String message = context.getResources().getString(reason.getDescriptionId());
        Logging.info(this, message);
        Toast.makeText(context, message, Toast.LENGTH_LONG).show();
    }
}
