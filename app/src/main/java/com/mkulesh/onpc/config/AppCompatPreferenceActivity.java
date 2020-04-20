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
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.util.Locale;

import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.preference.Preference;
import androidx.preference.PreferenceGroup;
import androidx.preference.PreferenceManager;

public abstract class AppCompatPreferenceActivity extends AppCompatActivity
{
    SharedPreferences preferences;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        final com.mkulesh.onpc.config.Configuration configuration = new com.mkulesh.onpc.config.Configuration(this);
        setTheme(configuration.getTheme(com.mkulesh.onpc.config.Configuration.ThemeType.SETTINGS_THEME));
        getDelegate().installViewFactory();
        getDelegate().onCreate(savedInstanceState);
        super.onCreate(savedInstanceState);
        setupActionBar();
        preferences = PreferenceManager.getDefaultSharedPreferences(this);
    }

    @Override
    protected void attachBaseContext(Context newBase)
    {
        final Locale prefLocale = AppLocale.ContextWrapper.getPreferredLocale(newBase);
        Logging.info(this, "Settings locale: " + prefLocale.toString());
        super.attachBaseContext(AppLocale.ContextWrapper.wrap(newBase, prefLocale));
    }

    static void tintIcons(final Context c, Preference preference)
    {
        if (preference instanceof PreferenceGroup)
        {
            PreferenceGroup group = ((PreferenceGroup) preference);
            Utils.setDrawableColorAttr(c, group.getIcon(), android.R.attr.textColorSecondary);
            for (int i = 0; i < group.getPreferenceCount(); i++)
            {
                tintIcons(c, group.getPreference(i));
            }
        }
        else
        {
            Utils.setDrawableColorAttr(c, preference.getIcon(), android.R.attr.textColorSecondary);
        }
    }

    private void setupActionBar()
    {
        ViewGroup rootView = findViewById(R.id.action_bar_root); //id from appcompat
        if (rootView != null)
        {
            View view = getLayoutInflater().inflate(R.layout.settings_toolbar, rootView, false);
            rootView.addView(view, 0);

            Toolbar toolbar = findViewById(R.id.toolbar);
            setSupportActionBar(toolbar);
        }

        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null)
        {
            // Show the Up button in the action bar.
            actionBar.setDisplayHomeAsUpEnabled(true);
        }
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        //noinspection SwitchStatementWithTooFewBranches
        switch (item.getItemId())
        {
        case android.R.id.home:
            onBackPressed();
            return true;
        }
        return (super.onOptionsItemSelected(item));
    }
}
