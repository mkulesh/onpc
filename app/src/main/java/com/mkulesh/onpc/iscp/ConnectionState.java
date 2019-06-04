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

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.DhcpInfo;
import android.net.NetworkInfo;
import android.net.wifi.WifiManager;
import android.widget.Toast;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.messages.BroadcastResponseMsg;
import com.mkulesh.onpc.utils.Logging;

import java.net.InetAddress;
import java.util.concurrent.atomic.AtomicBoolean;

import androidx.annotation.NonNull;
import androidx.annotation.StringRes;

public class ConnectionState
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

    public interface StateListener
    {
        void onDeviceFound(BroadcastResponseMsg response);

        void noDevice(FailureReason reason);
    }

    private final Context context;
    private final ConnectivityManager connectivity;
    private final WifiManager wifi;
    private final AtomicBoolean active = new AtomicBoolean();

    public ConnectionState(Context context)
    {
        this.context = context;
        this.connectivity = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        this.wifi = (WifiManager) context.getApplicationContext().getSystemService(Context.WIFI_SERVICE);
        active.set(true);
    }

    public void setActive(boolean a)
    {
        synchronized (active)
        {
            active.set(a);
        }
    }

    public boolean isActive()
    {
        synchronized (active)
        {
            return active.get();
        }
    }

    public Context getContext()
    {
        return context;
    }

    boolean isNetwork()
    {
        final NetworkInfo netInfo = connectivity.getActiveNetworkInfo();
        return netInfo != null && netInfo.isConnected();
    }

    boolean isWifi()
    {
        return wifi.isWifiEnabled() && wifi.getConnectionInfo() != null && wifi.getConnectionInfo().getNetworkId() != -1;
    }

    InetAddress getBroadcastAddress() throws Exception
    {
        final DhcpInfo dhcp = wifi.getDhcpInfo();
        if (dhcp == null)
        {
            throw new Exception("can not access DHCP");
        }
        int broadcast = (dhcp.ipAddress & dhcp.netmask) | ~dhcp.netmask;
        byte[] quads = new byte[4];
        for (int k = 0; k < 4; k++)
        {
            quads[k] = (byte) ((broadcast >> k * 8) & 0xFF);
        }
        return InetAddress.getByAddress(quads);
    }

    public void showFailure(@NonNull final FailureReason reason)
    {
        final String message = context.getResources().getString(reason.getDescriptionId());
        Logging.info(this, message);
        Toast.makeText(context, message, Toast.LENGTH_LONG).show();
    }
}
