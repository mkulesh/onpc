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

package com.mkulesh.onpc;

import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.design.widget.TabLayout;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.SparseArray;
import android.view.Menu;
import android.view.MenuItem;
import android.view.ViewGroup;
import android.widget.Toast;

import com.mkulesh.onpc.iscp.MessageChannel;
import com.mkulesh.onpc.iscp.messages.DisplayModeMsg;
import com.mkulesh.onpc.iscp.messages.PowerStatusMsg;
import com.mkulesh.onpc.utils.AppTheme;
import com.mkulesh.onpc.utils.Utils;

import java.util.HashSet;
import java.util.Locale;

public class MainActivity extends AppCompatActivity implements OnPageChangeListener
{
    private final static boolean ENABLE_MOCKUP = false;
    private static final int SETTINGS_ACTIVITY_REQID = 256;
    public static final String EXIT_CONFIRM = "exit_confirm";

    private Toolbar toolbar;
    private SectionsPagerAdapter pagerAdapter;
    private ViewPager viewPager;
    private MessageChannel messageChannel = null;
    private Menu mainMenu;
    private StateManager stateManager = null;
    private Toast exitToast = null;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        setTheme(AppTheme.getTheme(this, AppTheme.ThemeType.MAIN_THEME));
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        toolbar = findViewById(R.id.toolbar);
        toolbar.setTitle(R.string.app_toolbar_title);
        setSupportActionBar(toolbar);
        if (getSupportActionBar() != null)
        {
            getSupportActionBar().setTitle(R.string.app_toolbar_title);
            getSupportActionBar().setElevation(5.0f);
        }

        // Create the adapter that will return a fragment for each of the three
        // primary sections of the activity.
        pagerAdapter = new SectionsPagerAdapter(getSupportFragmentManager());

        // Set up the ViewPager with the sections adapter.
        viewPager = findViewById(R.id.view_pager);
        viewPager.setAdapter(pagerAdapter);
        viewPager.addOnPageChangeListener(this);

        final TabLayout tabLayout = findViewById(R.id.tab_layout);
        tabLayout.setupWithViewPager(viewPager);
        updateToolbar(null);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu)
    {
        mainMenu = menu;
        getMenuInflater().inflate(R.menu.activity_main_actions, menu);
        for (int i = 0; i < mainMenu.size(); i++)
        {
            Utils.updateMenuIconColor(this, mainMenu.getItem(i));
        }
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem menuItem)
    {
        switch (menuItem.getItemId())
        {
        case R.id.menu_power_standby:
            if (getStateManager() != null)
            {
                if (getStateManager().getState().isOn())
                {
                    getStateManager().sendMessage(new PowerStatusMsg(PowerStatusMsg.PowerStatus.STB));
                }
                else
                {
                    getStateManager().sendMessage(new PowerStatusMsg(PowerStatusMsg.PowerStatus.ON));
                }
            }
            return true;
        case R.id.menu_display_mode:
            if (getStateManager() != null && getStateManager().getState().isOn())
            {
                getStateManager().sendMessage(new DisplayModeMsg(DisplayModeMsg.TOGGLE));
            }
            return true;
        case R.id.menu_app_settings:
        {
            Intent settings = new Intent(this, SettingsActivity.class);
            startActivityForResult(settings, SETTINGS_ACTIVITY_REQID);
            return true;
        }
        default:
            return super.onOptionsItemSelected(menuItem);
        }
    }

    @Override
    public void onBackPressed()
    {
        final SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(this);
        if (!preferences.getBoolean(EXIT_CONFIRM, false))
        {
            finish();
        }
        else if (exitToast != null && exitToast.getView().isShown())
        {
            exitToast.cancel();
            finish();
        }
        else
        {
            exitToast = Toast.makeText(this, R.string.action_exit_confirm, Toast.LENGTH_LONG);
            exitToast.show();
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data)
    {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == SETTINGS_ACTIVITY_REQID)
        {
            restartActivity();
        }
    }

    public void restartActivity()
    {
        Intent intent = getIntent();
        finish();
        startActivity(intent);
    }

    private class SectionsPagerAdapter extends FragmentStatePagerAdapter
    {
        private final SparseArray<Fragment> registeredFragments = new SparseArray<>();

        SectionsPagerAdapter(FragmentManager fm)
        {
            super(fm);
        }

        @Override
        public Fragment getItem(int position)
        {
            Fragment fragment;
            switch (position)
            {
            case 0:
                fragment = new MonitorFragment();
                break;
            case 1:
                fragment = new MediaFragment();
                break;
            default:
                fragment = new DeviceFragment();
                break;
            }
            Bundle args = new Bundle();
            args.putInt(BaseFragment.FRAGMENT_NUMBER, position);
            fragment.setArguments(args);
            return fragment;
        }

        @Override
        public int getCount()
        {
            // Show 3 total pages.
            return 3;
        }

        @Override
        public CharSequence getPageTitle(int position)
        {
            Locale l = Locale.getDefault();
            switch (position)
            {
            case 0:
                return getString(R.string.title_monitor).toUpperCase(l);
            case 1:
                return getString(R.string.title_media).toUpperCase(l);
            case 2:
                return getString(R.string.title_device).toUpperCase(l);
            }
            return null;
        }

        // Register the fragment when the item is instantiated
        @NonNull
        @Override
        public Object instantiateItem(ViewGroup container, int position)
        {
            Fragment fragment = (Fragment) super.instantiateItem(container, position);
            registeredFragments.put(position, fragment);
            return fragment;
        }

        // Unregister when the item is inactive
        @Override
        public void destroyItem(ViewGroup container, int position, Object object)
        {
            registeredFragments.remove(position);
            super.destroyItem(container, position, object);
        }

        // Returns the fragment for the position (if instantiated)
        Fragment getRegisteredFragment(int position)
        {
            return registeredFragments.get(position);
        }
    }

    public boolean connectToServer(String server, int port)
    {
        stopThreads();
        messageChannel = new MessageChannel(this);
        if (messageChannel.connectToServer(server, port))
        {
            messageChannel.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, (Void[]) null);
            stateManager = new StateManager(this, messageChannel, false);
            stateManager.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, (Void[]) null);
            return true;
        }
        else if (ENABLE_MOCKUP)
        {
            stateManager = new StateManager(this, messageChannel, true);
            return true;
        }
        else
        {
            return false;
        }
    }

    private void stopThreads()
    {
        if (stateManager != null)
        {
            stateManager.stop();
        }
        if (messageChannel != null)
        {
            messageChannel.stop();
        }
        messageChannel = null;
        stateManager = null;
    }

    public StateManager getStateManager()
    {
        return stateManager;
    }

    @Override
    protected void onResume()
    {
        super.onResume();
        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(this);
        final String serverName = preferences.getString(DeviceFragment.SERVER_NAME, "");
        final int serverPort = preferences.getInt(DeviceFragment.SERVER_PORT, 0);
        if (!serverName.isEmpty() && serverPort > 0)
        {
            connectToServer(serverName, serverPort);
        }
    }

    @Override
    protected void onPause()
    {
        super.onPause();
        stopThreads();
    }

    public void updateCurrentFragment(State state, @Nullable final HashSet<State.ChangeType> eventChanges)
    {
        final BaseFragment f = (BaseFragment) (pagerAdapter.getRegisteredFragment(viewPager.getCurrentItem()));
        if (f != null)
        {
            f.update(state, eventChanges);
        }
        if (eventChanges == null || eventChanges.contains(State.ChangeType.COMMON))
        {
            updateToolbar(state);
        }
    }

    public void updateToolbar(State state)
    {
        // Logo
        Drawable icon;
        if (state == null)
        {
            icon = Utils.getDrawable(this, R.drawable.device_disconnect);
            toolbar.setSubtitle(R.string.state_not_connected);
        }
        else
        {
            icon = Utils.getDrawable(this, R.drawable.device_connect);
            final StringBuilder subTitle = new StringBuilder();
            subTitle.append(state.deviceProperties.get("model"));
            if (!state.isOn())
            {
                subTitle.append(" (").append(getResources().getString(R.string.state_standby)).append(")");
            }
            toolbar.setSubtitle(subTitle.toString());
        }
        Utils.setDrawableColorAttr(this, icon, android.R.attr.textColorTertiary);
        if (getSupportActionBar() != null)
        {
            getSupportActionBar().setLogo(icon);
        }
        // Main menu
        if (mainMenu != null)
        {
            for (int i = 0; i < mainMenu.size(); i++)
            {
                final MenuItem m = mainMenu.getItem(i);
                if (m.getItemId() == R.id.menu_power_standby)
                {
                    m.setEnabled(state != null);
                    Utils.updateMenuIconColor(this, m);
                }
                if (m.getItemId() == R.id.menu_display_mode)
                {
                    m.setEnabled(state != null && state.isOn());
                    Utils.updateMenuIconColor(this, m);
                }
            }

        }
    }

    @Override
    public void onPageScrollStateChanged(int arg0)
    {
        // empty

    }

    @Override
    public void onPageScrolled(int arg0, float arg1, int arg2)
    {
        // empty
    }

    @Override
    public void onPageSelected(int p)
    {
        updateCurrentFragment(stateManager == null ? null : stateManager.getState(), null);
    }
}
