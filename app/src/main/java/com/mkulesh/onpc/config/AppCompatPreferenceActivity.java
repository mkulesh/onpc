/*
 * Copyright (C) 2014 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.mkulesh.onpc.config;

import android.content.Context;
import android.os.Bundle;

import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.preference.Preference;
import android.support.v7.preference.PreferenceGroup;
import android.support.v7.widget.Toolbar;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

public abstract class AppCompatPreferenceActivity extends AppCompatActivity
{

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        final com.mkulesh.onpc.config.Configuration configuration = new com.mkulesh.onpc.config.Configuration(this);
        setTheme(configuration.getTheme(com.mkulesh.onpc.config.Configuration.ThemeType.SETTINGS_THEME));
        getDelegate().installViewFactory();
        getDelegate().onCreate(savedInstanceState);
        super.onCreate(savedInstanceState);
        setupActionBar();
    }

    protected static void tintIcons(final Context c, Preference preference)
    {
        Logging.info(c, preference.toString());
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

    protected void setupActionBar()
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
        switch (item.getItemId())
        {
        case android.R.id.home:
            onBackPressed();
            return true;
        }
        return (super.onOptionsItemSelected(item));
    }
}
