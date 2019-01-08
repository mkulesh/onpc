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
import android.os.Bundle;
import android.support.v7.preference.PreferenceFragmentCompat;
import android.support.v7.preference.PreferenceManager;
import android.support.v7.preference.PreferenceScreen;
import android.support.v7.preference.SwitchPreferenceCompat;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.iscp.messages.ServiceType;
import com.mkulesh.onpc.utils.Logging;

public class PreferencesNetworkServices extends AppCompatPreferenceActivity
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
            final String networkServices = PreferenceManager.getDefaultSharedPreferences(getActivity())
                    .getString(Configuration.NETWORK_SERVICES, "");
            prepareSelectors(networkServices, getActivity(), getPreferenceScreen());
            tintIcons(getActivity(), getPreferenceScreen());
        }
    }

    private static void prepareSelectors(final String networkServices,
                                         final Activity activity, final PreferenceScreen preferenceScreen)
    {
        if (networkServices.isEmpty())
        {
            return;
        }
        String[] tokens = networkServices.split(",");
        if (tokens.length == 0)
        {
            return;
        }

        for (String s : tokens)
        {
            final ServiceType serviceType = (ServiceType) ISCPMessage.searchParameter(
                    s, ServiceType.values(), ServiceType.UNKNOWN);
            if (serviceType == ServiceType.UNKNOWN)
            {
                Logging.info(activity, "Service not known: " + s);
                continue;
            }

            final SwitchPreferenceCompat p =
                    new SwitchPreferenceCompat(preferenceScreen.getContext(), null);
            p.setDefaultValue(true);
            p.setIcon(serviceType.getImageId());
            p.setTitle(activity.getString(serviceType.getDescriptionId()));
            p.setKey(Configuration.NETWORK_SERVICES + "_" + serviceType.getCode());
            preferenceScreen.addPreference(p);
        }
    }
}
