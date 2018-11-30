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

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceFragment;
import android.preference.PreferenceManager;
import android.preference.PreferenceScreen;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.messages.InputSelectorMsg;
import com.mkulesh.onpc.utils.Logging;

public class PreferencesDeviceSelectors extends AppCompatPreferenceActivity
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
            addPreferencesFromResource(R.xml.preferences_empty);

            Context context = getActivity();
            final SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(context);
            prepareSelectors(preferences.getString(Configuration.DEVICE_SELECTORS, ""));
        }

        private void prepareSelectors(final String deviceSelectors)
        {
            if (deviceSelectors.isEmpty())
            {
                return;
            }
            String[] tokens = deviceSelectors.split(",");
            if (tokens.length == 0)
            {
                return;
            }

            Logging.info(this, "Device selectors: " + deviceSelectors);
            PreferenceScreen preferenceScreen = this.getPreferenceScreen();
            for (String s : tokens)
            {
                final InputSelectorMsg.InputType inputType =
                        (InputSelectorMsg.InputType) InputSelectorMsg.searchParameter(
                                s, InputSelectorMsg.InputType.values(), InputSelectorMsg.InputType.NONE);
                if (inputType == InputSelectorMsg.InputType.NONE)
                {
                    Logging.info(this, "Input selector not known: " + s);
                    continue;
                }

                final MultilineCheckBoxPreference p =
                        new MultilineCheckBoxPreference(preferenceScreen.getContext(), null);
                p.setDefaultValue(true);
                p.setWidgetLayoutResource(R.layout.settings_check_box);
                p.setTitle(getString(inputType.getDescriptionId()));
                p.setKey(Configuration.DEVICE_SELECTORS + "_" + s);
                preferenceScreen.addPreference(p);
            }
        }
    }
}
