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

import android.os.Bundle;
import android.support.v7.preference.PreferenceFragmentCompat;
import android.support.v7.preference.PreferenceScreen;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.messages.ListeningModeMsg;

public class PreferencesListeningModes extends AppCompatPreferenceActivity
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
            addPreferencesFromResource(R.xml.preferences_empty);
            prepareSelectors(getPreferenceScreen());
        }
    }

    private static void prepareSelectors(final PreferenceScreen preferenceScreen)
    {
        for (ListeningModeMsg.Mode m : Configuration.getListeningModes())
        {
            preferenceScreen.addPreference(createSwitchPreference(preferenceScreen.getContext(),
                    m.getDescriptionId(),
                    Configuration.LISTENING_MODES + "_" + m.getCode()));
        }
    }
}
