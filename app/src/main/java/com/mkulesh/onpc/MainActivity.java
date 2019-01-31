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
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.os.Bundle;
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
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.Toast;

import com.mkulesh.onpc.config.Configuration;
import com.mkulesh.onpc.config.PreferencesMain;
import com.mkulesh.onpc.iscp.BroadcastSearch;
import com.mkulesh.onpc.iscp.ConnectionState;
import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.State;
import com.mkulesh.onpc.iscp.StateHolder;
import com.mkulesh.onpc.iscp.StateManager;
import com.mkulesh.onpc.iscp.messages.PowerStatusMsg;
import com.mkulesh.onpc.iscp.messages.ReceiverInformationMsg;
import com.mkulesh.onpc.utils.HtmlDialogBuilder;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.util.HashSet;
import java.util.Locale;

public class MainActivity extends AppCompatActivity implements OnPageChangeListener, StateManager.StateListener
{
    private static final int SETTINGS_ACTIVITY_REQID = 256;

    private Configuration configuration;
    private Toolbar toolbar;
    private SectionsPagerAdapter pagerAdapter;
    private ViewPager viewPager;
    private Menu mainMenu;
    private ConnectionState connectionState;
    private final StateHolder stateHolder = new StateHolder();
    private Toast exitToast = null;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        try
        {
            final PackageInfo pi = getPackageManager().getPackageInfo(getPackageName(), 0);
            Logging.info(this, "Starting application: " + pi.versionName);
        }
        catch (PackageManager.NameNotFoundException e)
        {
            Logging.info(this, "Starting application");
        }

        configuration = new Configuration(this);
        setTheme(configuration.getTheme(Configuration.ThemeType.MAIN_THEME));
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        if (configuration.isKeepScreenOn())
        {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        }

        toolbar = findViewById(R.id.toolbar);
        toolbar.setTitle(R.string.app_short_name);
        setSupportActionBar(toolbar);
        if (getSupportActionBar() != null)
        {
            getSupportActionBar().setTitle(R.string.app_short_name);
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

        connectionState = new ConnectionState(this);

        // Initially reset zone state
        configuration.setZones(ReceiverInformationMsg.getDefaultZones());
        configuration.initActiveZone(ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE);

        updateToolbar(null);
    }

    public Configuration getConfiguration()
    {
        return configuration;
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
        Logging.info(this, "Selected main menu: " + menuItem.getTitle());
        switch (menuItem.getItemId())
        {
        case R.id.menu_power_standby:
            if (isConnected())
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
        case R.id.menu_app_settings:
        {
            Intent settings = new Intent(this, PreferencesMain.class);
            startActivityForResult(settings, SETTINGS_ACTIVITY_REQID);
            return true;
        }
        case R.id.menu_about:
        {
            HtmlDialogBuilder.buildDialog(this,
                    R.mipmap.ic_launcher, R.string.app_name, R.string.html_about).show();
            return true;
        }
        default:
            return super.onOptionsItemSelected(menuItem);
        }
    }

    @Override
    public void onBackPressed()
    {
        if (!configuration.isExitConfirm())
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
        private final int items;

        SectionsPagerAdapter(FragmentManager fm)
        {
            super(fm);
            items = configuration.isRemoteInterface() ? 4 : 3;
        }

        @Override
        public Fragment getItem(int position)
        {
            switch (position)
            {
            case 0:
                return prepareFragment(new MonitorFragment(), position);
            case 1:
                return prepareFragment(new MediaFragment(), position);
            case 2:
                return prepareFragment(new DeviceFragment(), position);
            case 3:
                return prepareFragment(new RemoteInterfaceFragment(), position);
            }
            return null;
        }

        private Fragment prepareFragment(Fragment fragment, int position)
        {
            Bundle args = new Bundle();
            args.putInt(BaseFragment.FRAGMENT_NUMBER, position);
            fragment.setArguments(args);
            return fragment;
        }

        @Override
        public int getCount()
        {
            return items;
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
            case 3:
                return getString(R.string.title_remote_interface).toUpperCase(l);
            }
            return null;
        }

        // Register the fragment when the item is instantiated
        @NonNull
        @Override
        public Object instantiateItem(@NonNull ViewGroup container, int position)
        {
            Fragment fragment = (Fragment) super.instantiateItem(container, position);
            registeredFragments.put(position, fragment);
            return fragment;
        }

        // Unregister when the item is inactive
        @Override
        public void destroyItem(@NonNull ViewGroup container, int position, @NonNull Object object)
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

    public boolean connectToDevice(final String device, final int port)
    {
        stateHolder.release(false);
        stateHolder.waitForRelease();
        onStateChanged(stateHolder.getState(), null);
        final int zone = configuration.getZone();
        try
        {
            stateHolder.setStateManager(new StateManager(connectionState, this, device, port, zone));
            return true;
        }
        catch (Exception ex)
        {
            if (Configuration.ENABLE_MOCKUP)
            {
                stateHolder.setStateManager(new StateManager(connectionState, this, zone));
                updateConfiguration(stateHolder.getState());
                return true;
            }
        }
        return false;
    }

    public boolean isConnected()
    {
        return stateHolder.getStateManager() != null;
    }

    public StateManager getStateManager()
    {
        return stateHolder.getStateManager();
    }

    public ConnectionState getConnectionState()
    {
        return connectionState;
    }

    @Override
    protected void onResume()
    {
        super.onResume();
        if (!configuration.getDeviceName().isEmpty() && configuration.getDevicePort() > 0)
        {
            Logging.info(this, "use stored connection data: "
                    + configuration.getDeviceName() + "/" + configuration.getDevicePort());
            connectToDevice(configuration.getDeviceName(), configuration.getDevicePort());
        }
        else
        {
            final BroadcastSearch bs = new BroadcastSearch(connectionState,
                    new ConnectionState.StateListener()
                    {
                        // These methods will be called from GUI thread
                        @Override
                        public void onDeviceFound(final String device, final int port, EISCPMessage response)
                        {
                            if (response != null && connectToDevice(device, port))
                            {
                                configuration.saveDevice(device, port);
                            }
                        }

                        @Override
                        public void noDevice(ConnectionState.FailureReason reason)
                        {
                            connectionState.showFailure(reason);
                        }
                    }, 5000, 2);
            bs.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, (Void[]) null);
        }
    }

    @Override
    protected void onPause()
    {
        super.onPause();
        stateHolder.release(true);
    }

    @Override
    public void onStateChanged(State state, @Nullable final HashSet<State.ChangeType> eventChanges)
    {
        if (state != null && eventChanges != null && eventChanges.contains(State.ChangeType.RECEIVER_INFO))
        {
            updateConfiguration(state);
        }
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

    private void updateConfiguration(@NonNull State state)
    {
        if (!state.zones.isEmpty())
        {
            configuration.setZones(state.zones);
        }
        if (!state.deviceSelectors.isEmpty())
        {
            configuration.setDeviceSelectors(state.deviceSelectors);
        }
        if (!state.networkServices.isEmpty())
        {
            configuration.setNetworkServices(state.networkServices);
        }
        updateToolbar(state);
    }

    @Override
    public void onManagerStopped()
    {
        stateHolder.setStateManager(null);
    }

    @Override
    public void onDeviceDisconnected()
    {
        Logging.info(this, "device disconnected");
        if (!stateHolder.isAppExit())
        {
            onStateChanged(stateHolder.getState(), null);
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
            final String name = state.deviceProperties.get("model");
            if (name != null)
            {
                final StringBuilder subTitle = new StringBuilder();
                subTitle.append(name);
                if (state.isExtendedZone())
                {
                    subTitle.append("/").append(state.zones.get(state.getActiveZone()).getName());
                }
                if (!state.isOn())
                {
                    subTitle.append(" (").append(getResources().getString(R.string.state_standby)).append(")");
                }
                toolbar.setSubtitle(subTitle.toString());
            }
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
        onStateChanged(stateHolder.getState(), null);
    }

    void selectRightTab()
    {
        viewPager.arrowScroll(View.FOCUS_RIGHT);
    }
}
