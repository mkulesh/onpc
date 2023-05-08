/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2023 by Mikhail Kulesh
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

import android.content.Context;
import android.content.SharedPreferences;
import android.content.res.TypedArray;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.util.ArrayList;
import java.util.Locale;

import androidx.annotation.NonNull;
import androidx.annotation.StyleRes;

import static com.mkulesh.onpc.utils.Utils.getStringPref;

public class CfgAppSettings
{
    // Themes
    public enum ThemeType
    {
        MAIN_THEME,
        SETTINGS_THEME
    }

    static final String APP_THEME = "app_theme";

    // Languages
    static final String APP_LANGUAGE = "app_language";

    // Tabs
    public enum Tabs
    {
        LISTEN(true, true),
        MEDIA(true, true),
        SHORTCUTS(true, false),
        DEVICE(true, true),
        RC(true, true),
        RI(true, false);

        final boolean isIscp, isDcp;

        Tabs(final boolean isIscp, final boolean isDcp)
        {
            this.isIscp = isIscp;
            this.isDcp = isDcp;
        }

        public boolean isVisible(Utils.ProtoType pt)
        {
            return (pt == Utils.ProtoType.ISCP && isIscp) || (pt == Utils.ProtoType.DCP && isDcp);
        }
    }

    static final String VISIBLE_TABS = "visible_tabs";
    private static final String OPENED_TAB_NAME = "opened_tab_name";

    // RI
    static final String REMOTE_INTERFACE_AMP = "remote_interface_amp";
    static final String REMOTE_INTERFACE_CD = "remote_interface_cd";

    private SharedPreferences preferences;

    void setPreferences(SharedPreferences preferences)
    {
        this.preferences = preferences;
    }

    @StyleRes
    public int getTheme(final Context context, ThemeType type)
    {
        final String themeCode = preferences.getString(APP_THEME,
                context.getResources().getString(R.string.pref_theme_default));

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

    public static String getTabName(final Context context, Tabs item)
    {
        Locale l = Locale.getDefault();
        try
        {
            final String[] tabNames = context.getResources().getStringArray(R.array.pref_visible_tabs_names);
            return item.ordinal() < tabNames.length ? tabNames[item.ordinal()].toUpperCase(l) : "";
        }
        catch (Exception ex)
        {
            return "";
        }
    }

    @NonNull
    public ArrayList<CfgAppSettings.Tabs> getVisibleTabs()
    {
        final ArrayList<CfgAppSettings.Tabs> result = new ArrayList<>();
        final ArrayList<String> defItems = new ArrayList<>();
        for (CfgAppSettings.Tabs i : CfgAppSettings.Tabs.values())
        {
            defItems.add(i.name());
        }

        final Utils.ProtoType protoType = Configuration.getProtoType(preferences);
        for (CheckableItem sp : CheckableItem.readFromPreference(preferences, VISIBLE_TABS, defItems))
        {
            for (CfgAppSettings.Tabs i : CfgAppSettings.Tabs.values())
            {
                if (!i.isVisible(protoType))
                {
                    continue;
                }
                if (sp.checked && i.name().equals(sp.code))
                {
                    result.add(i);
                }
            }
        }
        return result;
    }

    public CfgAppSettings.Tabs getOpenedTab()
    {
        CfgAppSettings.Tabs retValue = Tabs.LISTEN;
        try
        {
            final String tab = getStringPref(preferences, OPENED_TAB_NAME, Tabs.LISTEN.toString());
            retValue = CfgAppSettings.Tabs.valueOf(tab.toUpperCase());
        }
        catch (Exception ex)
        {
            // nothing to do
        }
        return retValue;
    }

    public void setOpenedTab(CfgAppSettings.Tabs tab)
    {
        Logging.info(this, "Save opened tab: " + tab.toString());
        SharedPreferences.Editor prefEditor = preferences.edit();
        prefEditor.putString(OPENED_TAB_NAME, tab.toString());
        prefEditor.apply();
    }

    public boolean isRemoteInterfaceAmp()
    {
        return preferences.getBoolean(REMOTE_INTERFACE_AMP, false);
    }

    public boolean isRemoteInterfaceCd()
    {
        return preferences.getBoolean(REMOTE_INTERFACE_CD, false);
    }
}
