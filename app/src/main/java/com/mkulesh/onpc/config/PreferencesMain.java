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

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.v7.preference.ListPreference;
import android.support.v7.preference.Preference;
import android.support.v7.preference.PreferenceFragmentCompat;
import android.support.v7.preference.PreferenceManager;

import com.mkulesh.onpc.R;

public class PreferencesMain extends AppCompatPreferenceActivity
{
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        getSupportFragmentManager().beginTransaction().replace(
                android.R.id.content, new MyPreferenceFragment()).commit();
    }

    public static class MyPreferenceFragment extends PreferenceFragmentCompat
    {
        @Override
        public void onCreatePreferences(Bundle bundle, String s)
        {
            addPreferencesFromResource(R.xml.preferences_main);
            final Activity activity = getActivity();
            if (activity != null)
            {
                prepareListPreference((ListPreference) findPreference(Configuration.APP_THEME), activity);
                prepareListPreference((ListPreference) findPreference(Configuration.SOUND_CONTROL), null);

                final ListPreference activeZone = (ListPreference) findPreference(Configuration.ACTIVE_ZONE);
                final String zones = PreferenceManager.getDefaultSharedPreferences(activity)
                        .getString(Configuration.ZONES, "");
                fillZones(activeZone, zones);

                tintIcons(activity, getPreferenceScreen());
            }
        }
    }

    private static void fillZones(ListPreference listPreference, String zones)
    {
        if (listPreference == null)
        {
            return;
        }

        if (zones.isEmpty())
        {
            return;
        }
        String[] tokens = zones.split(",");
        if (tokens.length == 0)
        {
            return;
        }

        final CharSequence[] entryValues = new CharSequence[tokens.length];
        final CharSequence[] entries = new CharSequence[tokens.length];
        for (int i = 0; i < tokens.length; i++)
        {
            entryValues[i] = Integer.toString(i);
            entries[i] = tokens[i];
        }
        listPreference.setEntryValues(entryValues);
        listPreference.setEntries(entries);
        listPreference.setDefaultValue(entryValues[0]);
        listPreference.setVisible(tokens.length > 1);
        if (listPreference.isVisible())
        {
            prepareListPreference(listPreference, null);
        }
    }

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
        listPreference.setOnPreferenceChangeListener(new Preference.OnPreferenceChangeListener()
        {
            @Override
            public boolean onPreferenceChange(Preference preference, Object newValue)
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
            }
        });
    }
}
