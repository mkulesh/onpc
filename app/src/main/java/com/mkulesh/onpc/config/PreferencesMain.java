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

import android.content.Intent;
import android.os.Bundle;
import android.preference.ListPreference;
import android.preference.Preference;
import android.preference.PreferenceFragment;

import com.mkulesh.onpc.R;

public class PreferencesMain extends AppCompatPreferenceActivity
{
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        final Configuration configuration = new Configuration(this);
        setTheme(configuration.getTheme(Configuration.ThemeType.SETTINGS_THEME));
        super.onCreate(savedInstanceState);

        final MyPreferenceFragment pf = new MyPreferenceFragment();
        getFragmentManager().beginTransaction().replace(android.R.id.content, pf).commit();
    }

    public static class MyPreferenceFragment extends PreferenceFragment
    {
        @Override
        public void onCreate(final Bundle savedInstanceState)
        {
            super.onCreate(savedInstanceState);
            addPreferencesFromResource(R.xml.preferences_main);
            prepareListPreference((ListPreference) findPreference(Configuration.APP_THEME), getActivity().getIntent());
            prepareListPreference((ListPreference) findPreference(Configuration.SOUND_CONTROL), null);
        }

        private void prepareListPreference(final ListPreference listPreference, final Intent intent)
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
                    if (intent != null)
                    {
                        getActivity().finish();
                        getActivity().startActivity(intent);
                    }
                    return true;
                }
            });
        }
    }
}
