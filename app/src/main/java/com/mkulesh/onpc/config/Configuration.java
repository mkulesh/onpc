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

package com.mkulesh.onpc.config;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.res.TypedArray;
import android.preference.PreferenceManager;
import android.support.annotation.StyleRes;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.BroadcastSearch;
import com.mkulesh.onpc.iscp.messages.ListeningModeMsg;
import com.mkulesh.onpc.iscp.messages.ReceiverInformationMsg;
import com.mkulesh.onpc.utils.Logging;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Configuration
{
    public static final boolean ENABLE_MOCKUP = false;

    static final String APP_THEME = "app_theme";

    private static final String SERVER_NAME = "server_name";
    private static final String SERVER_PORT = "server_port";
    static final String SOUND_CONTROL = "sound_control";

    private static final String KEEP_SCREEN_ON = "keep_screen_on";
    private static final String EXIT_CONFIRM = "exit_confirm";

    static final String DEVICE_SELECTORS = "device_selectors";
    static final String NETWORK_SERVICES = "network_services";
    static final String LISTENING_MODES = "listening_modes";

    private static final String REMOTE_INTERFACE = "remote_interface";
    private static final String REMOTE_INTERFACE_AMP = "remote_interface_amp";
    private static final String REMOTE_INTERFACE_CD = "remote_interface_cd";

    private final static ListeningModeMsg.Mode listeningModes[] = new ListeningModeMsg.Mode[]
    {
        ListeningModeMsg.Mode.MODE_00,
        ListeningModeMsg.Mode.MODE_01,
        ListeningModeMsg.Mode.MODE_09,
        ListeningModeMsg.Mode.MODE_08,
        ListeningModeMsg.Mode.MODE_0A,
        ListeningModeMsg.Mode.MODE_11,
        ListeningModeMsg.Mode.MODE_0C
    };

    /*********************************************************
     * Handling of themes
     *********************************************************/
    public enum ThemeType
    {
        MAIN_THEME,
        SETTINGS_THEME
    }

    private final Context context;
    private final SharedPreferences preferences;

    private String deviceName;
    private int devicePort;
    private final boolean keepScreenOn, exitConfirm;
    private final String defaultSoundControl;

    private final boolean remoteInterface, remoteInterfaceAmp, remoteInterfaceCd;

    public Configuration(Context context)
    {
        this.context = context;
        preferences = PreferenceManager.getDefaultSharedPreferences(context);

        deviceName = preferences.getString(Configuration.SERVER_NAME, "");
        devicePort = preferences.getInt(Configuration.SERVER_PORT, BroadcastSearch.ISCP_PORT);

        keepScreenOn = preferences.getBoolean(Configuration.KEEP_SCREEN_ON, false);
        exitConfirm = preferences.getBoolean(Configuration.EXIT_CONFIRM, false);

        defaultSoundControl = preferences.getString(Configuration.SOUND_CONTROL,
                context.getResources().getString(R.string.pref_default_sound_control));

        remoteInterface = preferences.getBoolean(Configuration.REMOTE_INTERFACE, false);
        remoteInterfaceAmp = preferences.getBoolean(Configuration.REMOTE_INTERFACE_AMP, false);
        remoteInterfaceCd = preferences.getBoolean(Configuration.REMOTE_INTERFACE_CD, false);
    }

    @StyleRes
    public int getTheme(ThemeType type)
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

    public String getDeviceName()
    {
        return deviceName;
    }

    public int getDevicePort()
    {
        return devicePort;
    }

    @SuppressLint("SetTextI18n")
    public String getDevicePortAsString()
    {
        return Integer.toString(devicePort);
    }

    public void saveDevice(final String device, final int port)
    {
        deviceName = device;
        devicePort = port;
        SharedPreferences.Editor prefEditor = preferences.edit();
        prefEditor.putString(SERVER_NAME, device);
        prefEditor.putInt(SERVER_PORT, port);
        prefEditor.apply();
    }

    public boolean isKeepScreenOn()
    {
        return keepScreenOn;
    }

    public boolean isExitConfirm()
    {
        return exitConfirm;
    }

    public String getDefaultSoundControl()
    {
        return defaultSoundControl;
    }

    public void setDeviceSelectors(List<ReceiverInformationMsg.Selector> deviceSelectors)
    {
        final StringBuilder str = new StringBuilder();
        for (ReceiverInformationMsg.Selector d : deviceSelectors)
        {
            if (!str.toString().isEmpty())
            {
                str.append(",");
            }
            str.append(d.getId());
        }
        String selectors = str.toString();

        Logging.info(this, "Device selectors: " + selectors);
        SharedPreferences.Editor prefEditor = preferences.edit();
        prefEditor.putString(DEVICE_SELECTORS, selectors);
        prefEditor.apply();
    }

    public boolean isSelectorVisible(final String code)
    {
        return preferences.getBoolean(DEVICE_SELECTORS + "_" + code, true);
    }

    public void setNetworkServices(HashMap<String, String> networkServices)
    {
        final StringBuilder str = new StringBuilder();
        for (Map.Entry<String, String> p : networkServices.entrySet())
        {
            if (!str.toString().isEmpty())
            {
                str.append(",");
            }
            str.append(p.getKey());
        }
        String selectors = str.toString();

        Logging.info(this, "Network services: " + selectors);
        SharedPreferences.Editor prefEditor = preferences.edit();
        prefEditor.putString(NETWORK_SERVICES, selectors);
        prefEditor.apply();
    }

    public boolean isNetworkServiceVisible(final String code)
    {
        return preferences.getBoolean(NETWORK_SERVICES + "_" + code, true);
    }

    public static ListeningModeMsg.Mode[] getListeningModes()
    {
        return listeningModes;
    }

    public boolean isListeningModeVisible(final String code)
    {
        return preferences.getBoolean(LISTENING_MODES + "_" + code, true);
    }

    public boolean isRemoteInterface()
    {
        return isRemoteInterfaceAmp() || isRemoteInterfaceCd();
    }

    public boolean isRemoteInterfaceAmp()
    {
        return remoteInterface && remoteInterfaceAmp;
    }

    public boolean isRemoteInterfaceCd()
    {
        return remoteInterface && remoteInterfaceCd;
    }
}
