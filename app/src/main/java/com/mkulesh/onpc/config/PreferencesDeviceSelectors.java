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
import android.os.Bundle;
import android.support.v7.preference.PreferenceFragmentCompat;
import android.support.v7.preference.PreferenceManager;
import android.support.v7.preference.PreferenceScreen;
import android.support.v7.preference.SwitchPreferenceCompat;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.messages.InputSelectorMsg;
import com.mkulesh.onpc.utils.Logging;

public class PreferencesDeviceSelectors extends AppCompatPreferenceActivity
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
            final String deviceSelectors = PreferenceManager
                    .getDefaultSharedPreferences(getPreferenceScreen().getContext())
                    .getString(Configuration.DEVICE_SELECTORS, "");
            prepareSelectors(deviceSelectors, getPreferenceScreen());
        }
    }

    private static void prepareSelectors(final String deviceSelectors,
                                         final PreferenceScreen preferenceScreen)
    {
        final Context context = preferenceScreen.getContext();

        final SwitchPreferenceCompat fName = createSwitchPreference(context,
                R.string.friendly_selector_name, Configuration.FRIENDLY_SELECTOR_NAME);
        fName.setSummaryOn(R.string.friendly_selector_summary_on);
        fName.setSummaryOff(R.string.friendly_selector_summary_off);
        preferenceScreen.addPreference(fName);

        if (deviceSelectors.isEmpty())
        {
            return;
        }
        String[] tokens = deviceSelectors.split(",");
        if (tokens.length == 0)
        {
            return;
        }

        for (String s : tokens)
        {
            final InputSelectorMsg.InputType inputType =
                    (InputSelectorMsg.InputType) InputSelectorMsg.searchParameter(
                            s, InputSelectorMsg.InputType.values(), InputSelectorMsg.InputType.NONE);
            if (inputType == InputSelectorMsg.InputType.NONE)
            {
                Logging.info(context, "Input selector not known: " + s);
                continue;
            }
            preferenceScreen.addPreference(createSwitchPreference(context,
                    inputType.getDescriptionId(),
                    Configuration.DEVICE_SELECTORS + "_" + inputType.getCode()));
        }
    }
}
