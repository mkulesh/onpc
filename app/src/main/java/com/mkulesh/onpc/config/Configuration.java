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
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.annotation.StyleRes;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.BroadcastSearch;
import com.mkulesh.onpc.iscp.State;
import com.mkulesh.onpc.iscp.messages.InputSelectorMsg;
import com.mkulesh.onpc.iscp.messages.ListeningModeMsg;
import com.mkulesh.onpc.iscp.messages.NetworkServiceMsg;
import com.mkulesh.onpc.iscp.messages.ReceiverInformationMsg;
import com.mkulesh.onpc.iscp.messages.ServiceType;
import com.mkulesh.onpc.utils.Logging;

import java.util.ArrayList;
import java.util.List;

public class Configuration
{
    public static final boolean ENABLE_MOCKUP = false;

    static final String APP_THEME = "app_theme";
    static final String APP_LANGUAGE = "app_language";

    private static final String SERVER_NAME = "server_name";
    private static final String SERVER_PORT = "server_port";
    static final String SOUND_CONTROL = "sound_control";

    private static final String MODEL = "model";
    private static final String ACTIVE_ZONE = "active_zone";

    static final String DEVICE_SELECTORS = "device_selectors";
    private static final String SELECTED_DEVICE_SELECTORS = "selected_device_selectors";

    private static final String AUTO_POWER = "auto_power";
    static final String FRIENDLY_NAMES = "pref_friendly_names";
    static final String NETWORK_SERVICES = "network_services";
    private static final String SELECTED_NETWORK_SERVICES = "selected_network_services";
    static final String SELECTED_LISTENING_MODES = "selected_listening_modes";

    private static final String REMOTE_INTERFACE = "remote_interface";
    private static final String REMOTE_INTERFACE_AMP = "remote_interface_amp";
    private static final String REMOTE_INTERFACE_CD = "remote_interface_cd";

    private static final String VOLUME_KEYS = "volume_keys";
    private static final String KEEP_SCREEN_ON = "keep_screen_on";
    private static final String BACK_AS_RETURN = "back_as_return";
    private static final String ADVANCED_QUEUE = "advanced_queue";
    private static final String EXIT_CONFIRM = "exit_confirm";
    private static final String DEVELOPER_MODE = "developer_mode";

    static final ListeningModeMsg.Mode DEFAULT_LISTENING_MODES[] = new ListeningModeMsg.Mode[]
    {
        ListeningModeMsg.Mode.MODE_00,
        ListeningModeMsg.Mode.MODE_01,
        ListeningModeMsg.Mode.MODE_09,
        ListeningModeMsg.Mode.MODE_08,
        ListeningModeMsg.Mode.MODE_0A,
        ListeningModeMsg.Mode.MODE_11,
        ListeningModeMsg.Mode.MODE_0C,
        ListeningModeMsg.Mode.MODE_80,
        ListeningModeMsg.Mode.MODE_82
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
    private final String soundControl;

    private final boolean remoteInterface, remoteInterfaceAmp, remoteInterfaceCd;

    public Configuration(Context context)
    {
        this.context = context;
        preferences = PreferenceManager.getDefaultSharedPreferences(context);

        deviceName = preferences.getString(Configuration.SERVER_NAME, "");
        devicePort = preferences.getInt(Configuration.SERVER_PORT, BroadcastSearch.ISCP_PORT);

        soundControl = preferences.getString(Configuration.SOUND_CONTROL,
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

    public String getSoundControl()
    {
        return soundControl;
    }

    public void initActiveZone(int defaultActiveZone)
    {
        final String activeZone = preferences.getString(ACTIVE_ZONE, "");
        if (activeZone.isEmpty())
        {
            setActiveZone(defaultActiveZone);
        }
    }

    @SuppressLint("ApplySharedPref")
    public void setActiveZone(int zone)
    {
        SharedPreferences.Editor prefEditor = preferences.edit();
        prefEditor.putString(ACTIVE_ZONE, Integer.toString(zone));
        prefEditor.commit();
    }

    public int getZone()
    {
        try
        {
            final String activeZone = preferences.getString(ACTIVE_ZONE, "");
            return (activeZone.isEmpty()) ? ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE : Integer.parseInt(activeZone);
        }
        catch (Exception e)
        {
            return ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE;
        }
    }

    public void setReceiverInformation(@NonNull State state)
    {
        SharedPreferences.Editor prefEditor = preferences.edit();

        final String model = state.deviceProperties.get("model");
        if (model != null)
        {
            prefEditor.putString(MODEL, model);
        }
        if (!state.networkServices.isEmpty())
        {
            final StringBuilder str = new StringBuilder();
            for (final String p : state.networkServices.keySet())
            {
                if (!str.toString().isEmpty())
                {
                    str.append(",");
                }
                str.append(p);
            }
            Logging.info(this, "Network services: " + str.toString());
            prefEditor.putString(NETWORK_SERVICES, str.toString());
        }
        if (!state.deviceSelectors.isEmpty())
        {
            final StringBuilder str = new StringBuilder();
            for (ReceiverInformationMsg.Selector d : state.deviceSelectors)
            {
                if (!str.toString().isEmpty())
                {
                    str.append(",");
                }
                str.append(d.getId());
                prefEditor.putString(DEVICE_SELECTORS + "_" + d.getId(), d.getName());
            }
            Logging.info(this, "Device selectors: " + str.toString());
            prefEditor.putString(DEVICE_SELECTORS, str.toString());
        }

        prefEditor.apply();
    }

    @NonNull
    static String getSelectedDeviceSelectorsParameter(final SharedPreferences p)
    {
        return Configuration.SELECTED_DEVICE_SELECTORS + "_" + p.getString(MODEL, "NONE");
    }

    @NonNull
    public ArrayList<ReceiverInformationMsg.Selector> getSortedDeviceSelectors(
            boolean allItems,
            @NonNull InputSelectorMsg.InputType activeItem,
            @NonNull final List<ReceiverInformationMsg.Selector> defaultItems)
    {
        final ArrayList<ReceiverInformationMsg.Selector> result = new ArrayList<>();
        final ArrayList<String> defItems = new ArrayList<>();
        for (ReceiverInformationMsg.Selector i : defaultItems)
        {
            defItems.add(i.getId());
        }
        final String par = getSelectedDeviceSelectorsParameter(preferences);
        for (CheckableItem sp : CheckableItem.readFromPreference(preferences, par, defItems))
        {
            final boolean visible = allItems || sp.checked ||
                    (activeItem != InputSelectorMsg.InputType.NONE && activeItem.getCode().equals(sp.code));
            for (ReceiverInformationMsg.Selector i : defaultItems)
            {
                if (visible && i.getId().equals(sp.code))
                {
                    result.add(i);
                }
            }
        }
        return result;
    }

    public boolean isAutoPower()
    {
        return preferences.getBoolean(AUTO_POWER, false);
    }

    public boolean isFriendlyNames()
    {
        return preferences.getBoolean(FRIENDLY_NAMES, true);
    }

    @NonNull
    static String getSelectedNetworkServicesParameter(final SharedPreferences p)
    {
        return Configuration.SELECTED_NETWORK_SERVICES + "_" + p.getString(MODEL, "NONE");
    }

    @NonNull
    public ArrayList<NetworkServiceMsg> getSortedNetworkServices(
            @NonNull ServiceType activeItem,
            @NonNull final List<NetworkServiceMsg> defaultItems)
    {
        final ArrayList<NetworkServiceMsg> result = new ArrayList<>();
        final ArrayList<String> defItems = new ArrayList<>();
        for (NetworkServiceMsg i : defaultItems)
        {
            defItems.add(i.getService().getCode());
        }
        final String par = getSelectedNetworkServicesParameter(preferences);
        for (CheckableItem sp : CheckableItem.readFromPreference(preferences, par, defItems))
        {
            final boolean visible = sp.checked ||
                    (activeItem != ServiceType.UNKNOWN && activeItem.getCode().equals(sp.code));
            for (NetworkServiceMsg i : defaultItems)
            {
                if (visible && i.getService().getCode().equals(sp.code))
                {
                    result.add(new NetworkServiceMsg(i));
                }
            }
        }
        return result;
    }

    @NonNull
    public ArrayList<ListeningModeMsg.Mode> getSortedListeningModes(
            boolean allItems,
            @Nullable ListeningModeMsg.Mode activeItem)
    {
        final ArrayList<ListeningModeMsg.Mode> result = new ArrayList<>();
        final ArrayList<String> defItems = new ArrayList<>();
        for (ListeningModeMsg.Mode i : DEFAULT_LISTENING_MODES)
        {
            defItems.add(i.getCode());
        }
        for (CheckableItem sp : CheckableItem.readFromPreference(preferences, SELECTED_LISTENING_MODES, defItems))
        {
            final boolean visible = allItems || sp.checked ||
                    (activeItem != null && activeItem.getCode().equals(sp.code));
            for (ListeningModeMsg.Mode i : DEFAULT_LISTENING_MODES)
            {
                if (visible && i.getCode().equals(sp.code))
                {
                    result.add(i);
                }
            }
        }
        return result;
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

    public boolean isVolumeKeys()
    {
        return preferences.getBoolean(Configuration.VOLUME_KEYS, false);
    }

    public boolean isKeepScreenOn()
    {
        return preferences.getBoolean(Configuration.KEEP_SCREEN_ON, false);
    }

    public boolean isBackAsReturn()
    {
        return preferences.getBoolean(Configuration.BACK_AS_RETURN, false);
    }

    public boolean isAdvancedQueue()
    {
        return preferences.getBoolean(Configuration.ADVANCED_QUEUE, false);
    }

    public boolean isExitConfirm()
    {
        return preferences.getBoolean(Configuration.EXIT_CONFIRM, false);
    }

    public boolean isDeveloperMode()
    {
        return preferences.getBoolean(DEVELOPER_MODE, false);
    }

}
