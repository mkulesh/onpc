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

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.os.Build;
import android.os.LocaleList;

import java.util.Locale;

import static com.mkulesh.onpc.utils.Utils.getStringPref;

/*********************************************************
 * Handling of locale (language etc)
 *********************************************************/
public final class AppLocale
{
    public static class ContextWrapper extends android.content.ContextWrapper
    {
        ContextWrapper(Context base)
        {
            super(base);
        }

        public static Locale getPreferredLocale(Context context)
        {
            final String prefFile = context.getPackageName() + "_preferences";
            final SharedPreferences pref = context.getSharedPreferences(prefFile, Context.MODE_PRIVATE);
            final String languageCode = getStringPref(pref,
                    com.mkulesh.onpc.config.CfgAppSettings.APP_LANGUAGE,
                    "system");

            if (languageCode.equals("system"))
            {
                return new Locale(Locale.getDefault().getLanguage());
            }

            String[] array = languageCode.split("-r", -1);
            if (array.length == 1)
            {
                return new Locale(array[0]);
            }
            else
            {
                return new Locale(array[0], array[1]);
            }
        }

        /** @noinspection RedundantSuppression*/
        @SuppressWarnings("deprecation")
        @SuppressLint({ "NewApi", "AppBundleLocaleChanges" })
        public static ContextWrapper wrap(Context context, Locale newLocale)
        {
            final Resources res = context.getResources();
            final Configuration configuration = res.getConfiguration();

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N)
            {
                configuration.setLocale(newLocale);
                LocaleList localeList = new LocaleList(newLocale);
                LocaleList.setDefault(localeList);
                configuration.setLocales(localeList);
                context = context.createConfigurationContext(configuration);
            }
            else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1)
            {
                configuration.setLocale(newLocale);
                context = context.createConfigurationContext(configuration);
            }
            else
            {
                configuration.locale = newLocale;
            }
            res.updateConfiguration(configuration, res.getDisplayMetrics());
            return new ContextWrapper(context);
        }
    }
}
