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

package com.mkulesh.onpc;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;
import android.util.Pair;
import android.view.KeyEvent;
import android.view.WindowManager;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.GeneratedPluginRegistrant;

interface NetworkStateListener
{
    void onNetworkStateChanged(boolean isConnected, boolean isWiFi);
}

public class MainActivity extends FlutterActivity implements BinaryMessenger.BinaryMessageHandler, NetworkStateListener
{
    private static final String PLATFORM_CHANNEL = "platform_channel";
    private static final String SHARED_PREFERENCES_NAME = "FlutterSharedPreferences";
    private static final String VERSION_NAME = "version_name";
    private static final String MODEL = "model";

    private enum PlatformCmd
    {
        NETWORK_STATE           (0),
        VOLUME_UP               (1),
        VOLUME_DOWN             (2),
        VOLUME_KEYS_ENABLED     (3),
        VOLUME_KEYS_DISABLED    (4),
        KEEP_SCREEN_ON_ENABLED  (5),
        KEEP_SCREEN_ON_DISABLED (6),
        INVALID                 (7);

        final int code;

        PlatformCmd(int code)
        {
            this.code = code;
        }

        byte getByteCode()
        {
            return (byte)code;
        }
    }

    class ConnectivityChangeReceiver extends BroadcastReceiver
    {
        private final NetworkStateListener listener;
        private final ConnectivityManager connectivity;
        private final WifiManager wifi;

        ConnectivityChangeReceiver(NetworkStateListener listener, Context context)
        {
            this.listener = listener;
            this.connectivity = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
            this.wifi = (WifiManager) context.getApplicationContext().getSystemService(Context.WIFI_SERVICE);
        }

        @Override
        public void onReceive(Context context, Intent intent)
        {
            listener.onNetworkStateChanged(isConnected(), isWifi());
        }

        boolean isConnected()
        {
            final NetworkInfo netInfo = connectivity.getActiveNetworkInfo();
            return netInfo != null && netInfo.isConnected();
        }

        boolean isWifi()
        {
            return wifi.isWifiEnabled() &&
                   wifi.getConnectionInfo() != null &&
                   wifi.getConnectionInfo().getNetworkId() != -1;
        }
    }

    private ConnectivityChangeReceiver receiver;
    private boolean volumeKeys = false;
    private boolean keepScreenOn = false;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        // If necessary, export preferences from previous versions
        try
        {
            final SharedPreferences oldPrefs = PreferenceManager.getDefaultSharedPreferences(this);
            final String oldVer = oldPrefs.getString(VERSION_NAME, "1.0");
            final String oldModel = oldPrefs.getString(MODEL, "");
            final PackageInfo pi = getPackageManager().getPackageInfo(getPackageName(), 0);
            if (oldVer.startsWith("1.0") && !oldModel.isEmpty() && pi.versionName.startsWith("2"))
            {
                exportPreferences1xTo2x();
            }
            oldPrefs.edit().putString(VERSION_NAME, pi.versionName).apply();
        }
        catch (Exception e)
        {
            // nothing to do
        }

        // read preferences stored in Flutter code
        readPreferences();
        if (keepScreenOn)
        {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        }

        // Message channel to Flutter code
        getFlutterView().setMessageHandler(PLATFORM_CHANNEL, this);

        receiver = new ConnectivityChangeReceiver(this, this);
    }

    @Override
    public void onNetworkStateChanged(boolean isConnected, boolean isWiFi)
    {
        getFlutterView().send(PLATFORM_CHANNEL, getNetworkStateMsg(isConnected, isWiFi));
    }

    private ByteBuffer getNetworkStateMsg(boolean isConnected, boolean isWiFi)
    {
        final ByteBuffer message = ByteBuffer.allocateDirect(4);
        final int state = !isConnected ? 0 : (!isWiFi ? 1 : 2);
        message.put(PlatformCmd.NETWORK_STATE.getByteCode());
        message.put((byte)state);
        return message;
    }

    @Override
    protected void onResume()
    {
        super.onResume();
        registerReceiver(receiver, new IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION));
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

    private void restartActivity()
    {
        Intent intent = getIntent();
        finish();
        startActivity(intent);
    }

    @Override
    public void onMessage(ByteBuffer byteBuffer, BinaryMessenger.BinaryReply binaryReply)
    {
        byteBuffer.order(ByteOrder.nativeOrder());
        int input = byteBuffer.getInt();
        PlatformCmd cmd = input >= 0 && input < PlatformCmd.values().length ?
                PlatformCmd.values()[input] : PlatformCmd.INVALID;

        Log.d("onpc", "platform command from dart code: " + cmd.toString());
        ByteBuffer r = null;
        boolean newKeepScreenOn = keepScreenOn;
        switch (cmd)
        {
            case VOLUME_UP:
            case VOLUME_DOWN:
            case INVALID:
                // nothing to do
                break;
            case VOLUME_KEYS_ENABLED:
                volumeKeys = true;
                break;
            case VOLUME_KEYS_DISABLED:
                volumeKeys = false;
                break;
            case KEEP_SCREEN_ON_ENABLED:
                newKeepScreenOn = true;
                break;
            case KEEP_SCREEN_ON_DISABLED:
                newKeepScreenOn = false;
                break;
            case NETWORK_STATE:
                r = getNetworkStateMsg(receiver.isConnected(), receiver.isWifi());
                break;
        }

        binaryReply.reply(r);
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
                    final ByteBuffer message = ByteBuffer.allocateDirect(4);
                    final byte code = event.getKeyCode() == KeyEvent.KEYCODE_VOLUME_UP ?
                            PlatformCmd.VOLUME_UP.getByteCode() : PlatformCmd.VOLUME_DOWN.getByteCode();
                    message.put(code);
                    getFlutterView().send(PLATFORM_CHANNEL, message);
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

    private void exportPreferences1xTo2x()
    {
        final SharedPreferences oldPrefs = PreferenceManager.getDefaultSharedPreferences(this);
        final SharedPreferences newPrefs = getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);

        SharedPreferences.Editor editor = newPrefs.edit();

        final List<Pair<String, String>> stringsParameters = new ArrayList<>();
        {
            final String model = "_" + oldPrefs.getString("model", "");
            stringsParameters.add(new Pair<>("app_theme", "flutter.theme"));
            stringsParameters.add(new Pair<>("app_language", "flutter.language"));
            stringsParameters.add(new Pair<>("server_name", "flutter.server_name"));
            stringsParameters.add(new Pair<>("sound_control", "flutter.sound_control"));
            stringsParameters.add(new Pair<>("selected_listening_modes", "flutter.selected_listening_modes" + model));
            stringsParameters.add(new Pair<>("selected_network_services" + model, "flutter.selected_network_services" + model));
            stringsParameters.add(new Pair<>("selected_device_selectors" + model, "flutter.selected_device_selectors" + model));
            for (Pair<String, String> par : stringsParameters)
            {
                String val = oldPrefs.getString(par.first, "");
                if (val.isEmpty())
                {
                    continue;
                }
                editor.putString(par.second, val);
            }
        }

        final List<Pair<String, String>> boolParameters = new ArrayList<>();
        {
            boolParameters.add(new Pair<>("auto_power", "flutter.auto_power"));
            boolParameters.add(new Pair<>("pref_friendly_names", "flutter.friendly_names"));
            boolParameters.add(new Pair<>("remote_interface_amp", "flutter.remote_interface_amp"));
            boolParameters.add(new Pair<>("remote_interface_cd", "flutter.remote_interface_cd"));
            boolParameters.add(new Pair<>("volume_keys", "flutter.volume_keys"));
            boolParameters.add(new Pair<>("keep_screen_on", "flutter.keep_screen_on"));
            boolParameters.add(new Pair<>("back_as_return", "flutter.back_as_return"));
            boolParameters.add(new Pair<>("keep_playback_mode", "flutter.keep_playback_mode"));
            boolParameters.add(new Pair<>("exit_confirm",  "flutter.exit_confirm"));
            for (Pair<String, String> par : boolParameters)
            {
                boolean val = oldPrefs.getBoolean(par.first, par.first.equals("pref_friendly_names"));
                editor.putBoolean(par.second, val);
            }
        }
        editor.apply();
    }
}
