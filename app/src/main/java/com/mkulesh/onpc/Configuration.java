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
import android.content.Context;
import android.content.SharedPreferences;
import android.content.res.TypedArray;
import android.preference.PreferenceManager;
import android.support.annotation.StyleRes;

import com.mkulesh.onpc.iscp.BroadcastSearch;

class Configuration
{
    static final boolean ENABLE_MOCKUP = false;

    static final String APP_THEME = "app_theme";

    private static final String SERVER_NAME = "server_name";
    private static final String SERVER_PORT = "server_port";
    static final String SOUND_CONTROL = "sound_control";
    private static final String EXIT_CONFIRM = "exit_confirm";

    /*********************************************************
     * Handling of themes
     *********************************************************/
    enum ThemeType
    {
        MAIN_THEME,
        SETTINGS_THEME
    }

    private final Context context;
    private final SharedPreferences preferences;

    private String deviceName;
    private int devicePort;
    private final boolean exitConfirm;
    private final String defaultSoundControl;


    Configuration(Context context)
    {
        this.context = context;
        preferences = PreferenceManager.getDefaultSharedPreferences(context);

        deviceName = preferences.getString(Configuration.SERVER_NAME, "");
        devicePort = preferences.getInt(Configuration.SERVER_PORT, BroadcastSearch.ISCP_PORT);

        exitConfirm = preferences.getBoolean(Configuration.EXIT_CONFIRM, false);

        defaultSoundControl = preferences.getString(Configuration.SOUND_CONTROL,
                context.getResources().getString(R.string.pref_default_sound_control));
    }

    @StyleRes
    int getTheme(ThemeType type)
    {
        final String themeCode = preferences.getString(Configuration.APP_THEME,
                context.getResources().getString(R.string.pref_default_theme_code));

        final CharSequence[] allThemes = context.getResources().getStringArray(R.array.pref_theme_codes);
        int themeIndex = 0;
        for (int i = 0; i < allThemes.length; i++)
        {
            if (allThemes[i].toString().equals(themeCode))
            {
                themeIndex = i;
                break;
            }
        }

        if (type == ThemeType.MAIN_THEME)
        {
            TypedArray mainThemes = context.getResources().obtainTypedArray(R.array.main_themes);
            final int resId = mainThemes.getResourceId(themeIndex, R.style.BaseThemeIndigoOrange);
            mainThemes.recycle();
            return resId;
        }
        else
        {
            TypedArray settingsThemes = context.getResources().obtainTypedArray(R.array.settings_themes);
            final int resId = settingsThemes.getResourceId(themeIndex, R.style.SettingsThemeIndigoOrange);
            settingsThemes.recycle();
            return resId;
        }
    }

    String getDeviceName()
    {
        return deviceName;
    }

    int getDevicePort()
    {
        return devicePort;
    }

    @SuppressLint("SetTextI18n")
    String getDevicePortAsString()
    {
        return Integer.toString(devicePort);
    }

    void saveDevice(final String device, final int port)
    {
        deviceName = device;
        devicePort = port;
        SharedPreferences.Editor prefEditor = preferences.edit();
        prefEditor.putString(SERVER_NAME, device);
        prefEditor.putInt(SERVER_PORT, port);
        prefEditor.apply();
    }

    boolean isExitConfirm()
    {
        return exitConfirm;
    }

    String getDefaultSoundControl()
    {
        return defaultSoundControl;
    }
}
