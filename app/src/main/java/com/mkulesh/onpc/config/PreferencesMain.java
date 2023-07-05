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

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.ConnectionIf;

import androidx.preference.ListPreference;
import androidx.preference.PreferenceCategory;
import androidx.preference.PreferenceFragmentCompat;
import androidx.preference.PreferenceManager;
import androidx.preference.PreferenceScreen;

public class PreferencesMain extends AppCompatPreferenceActivity
{
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        getSupportFragmentManager().beginTransaction().replace(
                android.R.id.content, new MyPreferenceFragment()).commit();
        setTitle(R.string.drawer_app_settings);
    }

    @SuppressWarnings("WeakerAccess")
    public static class MyPreferenceFragment extends PreferenceFragmentCompat
    {
        @Override
        public void onCreatePreferences(Bundle bundle, String s)
        {
            addPreferencesFromResource(R.xml.preferences_main);
            prepareListPreference(findPreference(CfgAppSettings.APP_THEME), getActivity());
            prepareListPreference(findPreference(CfgAppSettings.APP_LANGUAGE), getActivity());
            prepareListPreference(findPreference(CfgAudioControl.SOUND_CONTROL), null);
            tintIcons(getPreferenceScreen().getContext(), getPreferenceScreen());
            hidePreferences();
        }

        private void hidePreferences()
        {
            final PreferenceScreen screen = getPreferenceScreen();
            final SharedPreferences preferences =
                    PreferenceManager.getDefaultSharedPreferences(screen.getContext());
            final ConnectionIf.ProtoType protoType = Configuration.getProtoType(preferences);
            if (protoType == ConnectionIf.ProtoType.DCP)
            {
                screen.removePreference(findPreference(CfgAppSettings.REMOTE_INTERFACE_AMP));
                screen.removePreference(findPreference(CfgAppSettings.REMOTE_INTERFACE_CD));
                final PreferenceCategory adv = (PreferenceCategory) findPreference("category_advanced");
                if (adv != null)
                {
                    adv.removePreference(findPreference(Configuration.ADVANCED_QUEUE));
                    adv.removePreference(findPreference(Configuration.KEEP_PLAYBACK_MODE));
                }
            }
        }
    }

    @SuppressWarnings("SameReturnValue")
    private static void prepareListPreference(final ListPreference listPreference, final Activity activity)
    {
        if (listPreference == null)
        {
            return;
        }

        if (listPreference.getValue() == null)
        {
            // to ensure we don't get a null value
            // set first value by default
            listPreference.setValueIndex(0);
        }

        if (listPreference.getEntry() != null)
        {
            listPreference.setSummary(listPreference.getEntry().toString());
        }
        listPreference.setOnPreferenceChangeListener((preference, newValue) ->
        {
            listPreference.setValue(newValue.toString());
            preference.setSummary(listPreference.getEntry().toString());
            if (activity != null)
            {
                final Intent intent = activity.getIntent();
                activity.finish();
                activity.startActivity(intent);
            }
            return true;
        });
    }
}
