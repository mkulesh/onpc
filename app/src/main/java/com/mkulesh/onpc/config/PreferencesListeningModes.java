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
import android.app.Activity;
import android.os.Build;
import android.os.Bundle;
import android.preference.PreferenceFragment;
import android.preference.PreferenceScreen;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.messages.ListeningModeMsg;

public class PreferencesListeningModes extends AppCompatPreferenceActivity
{
    @SuppressWarnings("deprecation")
    @SuppressLint("NewApi")
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
        {
            getFragmentManager().beginTransaction().replace(
                    android.R.id.content, new MyPreferenceFragment()).commit();
        }
        else
        {
            addPreferencesFromResource(R.xml.preferences_empty);
            prepareSelectors(this, getPreferenceScreen());
        }
    }

    public static class MyPreferenceFragment extends PreferenceFragment
    {
        @Override
        public void onCreate(final Bundle savedInstanceState)
        {
            super.onCreate(savedInstanceState);
            addPreferencesFromResource(R.xml.preferences_empty);
            prepareSelectors(getActivity(), getPreferenceScreen());
        }
    }

    private static void prepareSelectors(final Activity activity, final PreferenceScreen preferenceScreen)
    {
        for (ListeningModeMsg.Mode m : Configuration.getListeningModes())
        {
            final MultilineCheckBoxPreference p =
                    new MultilineCheckBoxPreference(preferenceScreen.getContext(), null);
            p.setDefaultValue(true);
            p.setWidgetLayoutResource(R.layout.settings_check_box);
            p.setTitle(activity.getString(m.getDescriptionId()));
            p.setKey(Configuration.LISTENING_MODES + "_" + m.getCode());
            preferenceScreen.addPreference(p);
        }
    }
}
