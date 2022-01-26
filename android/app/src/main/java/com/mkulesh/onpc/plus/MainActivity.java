/*
 * Enhanced Controller for Onkyo and Pioneer Pro
 * Copyright (C) 2019-2021 by Mikhail Kulesh
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

package com.mkulesh.onpc.plus;

import android.annotation.SuppressLint;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.NetworkInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.WindowManager;

import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodChannel;

interface NetworkStateListener
{
    void onNetworkStateChanged(boolean isConnected, boolean isWiFi);
}

public class MainActivity extends FlutterActivity implements NetworkStateListener
{
    private static final String METHOD_CHANNEL = "platform_method_channel";
    private static final String SHARED_PREFERENCES_NAME = "FlutterSharedPreferences";

    // dart -> platform
    private static final String GET_NETWORK_STATE = "getNetworkState";
    private static final String VOLUME_KEYS_ENABLED = "setVolumeKeysEnabled";
    private static final String VOLUME_KEYS_DISABLED = "setVolumeKeysDisabled";
    private static final String KEEP_SCREEN_ON_ENABLED = "setKeepScreenOnEnabled";
    private static final String KEEP_SCREEN_ON_DISABLED = "setKeepScreenOnEnabled";
    private static final  String GET_INTENT = "getIntent";

    // platform -> dart
    private static final String VOLUME_UP = "volumeUp";
    private static final String VOLUME_DOWN = "volumeDown";
    private static final String NETWORK_STATE_CHANGE = "networkStateChange";

    @SuppressLint("NewApi")
    @SuppressWarnings("deprecation")
    class ConnectivityChangeReceiver extends BroadcastReceiver
    {
        private final NetworkStateListener listener;
        private final ConnectivityManager connectivity;
        private final Context context;

        ConnectivityChangeReceiver(NetworkStateListener listener, Context context)
        {
            this.listener = listener;
            this.connectivity = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
            this.context = context;
        }

        @Override
        public void onReceive(Context context, Intent intent)
        {
            listener.onNetworkStateChanged(isConnected(), isWifi());
        }

        boolean isConnected()
        {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
            {
                // getActiveNetwork Added in API level 23
                final Network net = connectivity.getActiveNetwork();
                if (net == null)
                {
                    return false;
                }
                // getNetworkCapabilities Added in API level 21
                return connectivity.getNetworkCapabilities(net) != null;
            }
            else
            {
                // getActiveNetworkInfo, Added in API level 1, Deprecated in API level 29
                final NetworkInfo netInfo = connectivity.getActiveNetworkInfo();
                return netInfo != null && netInfo.isConnected();
            }
        }

        boolean isWifi()
        {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
            {
                // getActiveNetwork Added in API level 23
                final Network net = connectivity.getActiveNetwork();
                if (net == null)
                {
                    return false;
                }
                // getNetworkCapabilities Added in API level 21
                final NetworkCapabilities cap = connectivity.getNetworkCapabilities(net);
                if (cap == null)
                {
                    return false;
                }
                // hasTransport Added in API level 21
                return cap.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)
                        || cap.hasTransport(NetworkCapabilities.TRANSPORT_VPN);
            }
            else
            {
                // If app targets Android 10 or higher, it must have the ACCESS_FINE_LOCATION permission
                // in order to use getConnectionInfo(), see
                // https://developer.android.com/about/versions/10/privacy/changes
                final WifiManager wifi = (WifiManager) context.getApplicationContext().getSystemService(Context.WIFI_SERVICE);
                if (wifi == null)
                {
                    return false;
                }
                return wifi.isWifiEnabled() &&
                       wifi.getConnectionInfo() != null &&
                       wifi.getConnectionInfo().getNetworkId() != -1;
            }
        }
    }

    private ConnectivityChangeReceiver receiver;
    private boolean volumeKeys = true;
    private boolean keepScreenOn = false;
    private String intentData = null;
    private MethodChannel platformChannel = null;

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine)
    {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        // read preferences stored in Flutter code
        readPreferences();
        if (keepScreenOn)
        {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        }

        receiver = new ConnectivityChangeReceiver(this, this);

        // Message channel to Flutter code
        platformChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), METHOD_CHANNEL);
        platformChannel.setMethodCallHandler(this::onPlatformMethodCall);
    }

    @Override
    protected void onStart()
    {
        try
        {
            // avoid NullPointerException in io.flutter.embedding.android.FlutterActivity
            super.onStart();
        }
        catch (NullPointerException ex)
        {
            // nothing to do
        }
    }

    @Override
    public void onSaveInstanceState(Bundle outState)
    {
        try
        {
            // avoid NullPointerException in io.flutter.embedding.android.FlutterActivity
            super.onSaveInstanceState(outState);
        }
        catch (NullPointerException ex)
        {
            // nothing to do
        }
    }

    @Override
    public void onDestroy()
    {
        try
        {
            // avoid NullPointerException in io.flutter.embedding.android.FlutterActivity
            super.onDestroy();
        }
        catch (NullPointerException ex)
        {
            // nothing to do
        }
    }

    @Override
    public void onNetworkStateChanged(boolean isConnected, boolean isWiFi)
    {
        if (platformChannel != null)
        {
            final int state = !receiver.isConnected() ? 0 : (!receiver.isWifi() ? 1 : 2);
            platformChannel.invokeMethod(NETWORK_STATE_CHANGE, String.valueOf(state));
        }
    }

    @Override
    @SuppressWarnings("deprecation")
    protected void onResume()
    {
        super.onResume();
        registerReceiver(receiver, new IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION));
        handleIntent(getIntent());
    }

    @Override
    protected void onNewIntent(Intent intent)
    {
        super.onNewIntent(intent);
        handleIntent(intent);
    }

    private void handleIntent(Intent intent)
    {
        if (intent != null)
        {
            if (intent.getDataString() != null)
            {
                intentData = intent.getDataString();
            }
            else
            {
                intentData = intent.getAction();
            }
            setIntent(null);
        }
    }

    @Override
    protected void onPause()
    {
        super.onPause();
        unregisterReceiver(receiver);
    }

    private void readPreferences()
    {
        final SharedPreferences preferences = getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
        Map<String, ?> allPrefs = preferences.getAll();
        volumeKeys = readBooleanPreference(allPrefs, "flutter.volume_keys");
        keepScreenOn = readBooleanPreference(allPrefs, "flutter.keep_screen_on");
    }

    private boolean readBooleanPreference(final Map<String, ?> allPrefs, final String name)
    {
        Object val = allPrefs.get(name);
        if (val instanceof Boolean)
        {
            return (Boolean)val;
        }
        return false;
    }

    public void restartActivity()
    {
        PackageManager pm = getPackageManager();
        Intent intent = pm.getLaunchIntentForPackage(getPackageName());
        if (intent == null)
        {
            intent = getIntent();
        }
        finish();
        startActivity(intent);
    }

    void onPlatformMethodCall(MethodCall methodCall, MethodChannel.Result result)
    {
        boolean newKeepScreenOn = keepScreenOn;
        if (methodCall.method.equals(VOLUME_KEYS_ENABLED))
        {
            volumeKeys = true;
            result.success("volume keys enabled");
        }
        else if (methodCall.method.equals(VOLUME_KEYS_DISABLED))
        {
            volumeKeys = false;
            result.success("volume keys disabled");
        }
        else if (methodCall.method.equals(KEEP_SCREEN_ON_ENABLED))
        {
            newKeepScreenOn = true;
            result.success("keep screen on enabled");
        }
        else if (methodCall.method.equals(KEEP_SCREEN_ON_DISABLED))
        {
            newKeepScreenOn = false;
            result.success("keep screen on disabled");
        }
        else if (methodCall.method.equals(GET_NETWORK_STATE))
        {
            final int state = !receiver.isConnected() ? 0 : (!receiver.isWifi() ? 1 : 2);
            result.success(String.valueOf(state));
        }
        else if (methodCall.method.equals(GET_INTENT))
        {
            result.success(intentData != null ? intentData : "");
        }
        else
        {
            result.success("nothing to do");
        }

        if (newKeepScreenOn != keepScreenOn)
        {
            restartActivity();
        }
    }

    @Override
    public boolean dispatchKeyEvent(KeyEvent event)
    {
        if (volumeKeys)
        {
            if (event.getKeyCode() == KeyEvent.KEYCODE_VOLUME_UP || event.getKeyCode() == KeyEvent.KEYCODE_VOLUME_DOWN)
            {
                if (event.getAction() == KeyEvent.ACTION_DOWN)
                {
                    platformChannel.invokeMethod(event.getKeyCode() == KeyEvent.KEYCODE_VOLUME_UP ?
                            VOLUME_UP : VOLUME_DOWN, "");
                    return true;
                }
                else if (event.getAction() == KeyEvent.ACTION_UP)
                {
                    // Report to the OS that event is fully processed
                    return true;
                }
            }
        }
        return super.dispatchKeyEvent(event);
    }
}
