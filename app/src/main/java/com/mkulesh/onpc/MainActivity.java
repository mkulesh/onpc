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

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.design.widget.TabLayout;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.WindowManager;
import android.widget.Toast;

import com.mkulesh.onpc.config.AppLocale;
import com.mkulesh.onpc.config.Configuration;
import com.mkulesh.onpc.config.PreferencesMain;
import com.mkulesh.onpc.iscp.ConnectionState;
import com.mkulesh.onpc.iscp.State;
import com.mkulesh.onpc.iscp.StateHolder;
import com.mkulesh.onpc.iscp.StateManager;
import com.mkulesh.onpc.iscp.messages.AmpOperationCommandMsg;
import com.mkulesh.onpc.iscp.messages.MasterVolumeMsg;
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
    private MainPagerAdapter pagerAdapter;
    private ViewPager viewPager;
    private Menu mainMenu;
    private ConnectionState connectionState;
    private final StateHolder stateHolder = new StateHolder();
    private Toast exitToast = null;
    private MainNavigationDrawer navigationDrawer;
    private ActionBarDrawerToggle mDrawerToggle;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        String versionName = null;
        try
        {
            final PackageInfo pi = getPackageManager().getPackageInfo(getPackageName(), 0);
            versionName = "v. " + pi.versionName;
            Logging.info(this, "Starting application: " + versionName);
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
        final ActionBar actionBar = getSupportActionBar();
        if (actionBar != null)
        {
            actionBar.setDisplayHomeAsUpEnabled(true);
            actionBar.setTitle(R.string.app_short_name);
            actionBar.setElevation(5.0f);
        }

        // Create the adapter that will return a fragment for each of the three
        // primary sections of the activity.
        pagerAdapter = new MainPagerAdapter(this, getSupportFragmentManager(), configuration);

        // Set up the ViewPager with the sections adapter.
        viewPager = findViewById(R.id.view_pager);
        viewPager.setAdapter(pagerAdapter);
        viewPager.addOnPageChangeListener(this);

        final TabLayout tabLayout = findViewById(R.id.tab_layout);
        tabLayout.setupWithViewPager(viewPager);

        connectionState = new ConnectionState(this);

        // Initially reset zone state
        configuration.initActiveZone(ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE);

        // Navigation drawer
        navigationDrawer = new MainNavigationDrawer(this, versionName);
        // ActionBarDrawerToggle ties together the the proper interactions
        // between the sliding drawer and the action bar app icon
        mDrawerToggle = new ActionBarDrawerToggle(this, navigationDrawer.getDrawerLayout(), toolbar,
                R.string.drawer_open, R.string.drawer_open);
        Utils.setDrawerListener(navigationDrawer.getDrawerLayout(), mDrawerToggle);

        updateToolbar(null);
    }

    @Override
    protected void attachBaseContext(Context newBase)
    {
        final Locale prefLocale = AppLocale.ContextWrapper.getPreferredLocale(newBase);
        Logging.info(this, "Application locale: " + prefLocale.toString());
        super.attachBaseContext(AppLocale.ContextWrapper.wrap(newBase, prefLocale));
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
            final MenuItem m = mainMenu.getItem(i);
            Utils.updateMenuIconColor(this, m);
            if (m.getItemId() == R.id.menu_receiver_information)
            {
                m.setVisible(configuration.isDeveloperMode());
            }
        }
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem menuItem)
    {
        // The action bar home/up action should open or close the drawer.
        // ActionBarDrawerToggle will take care of this.
        if (mDrawerToggle.onOptionsItemSelected(menuItem))
        {
            return true;
        }

        Logging.info(this, "Selected main menu: " + menuItem.getTitle());
        switch (menuItem.getItemId())
        {
        case R.id.menu_power_standby:
            if (isConnected())
            {
                final PowerStatusMsg.PowerStatus p = getStateManager().getState().isOn() ?
                        PowerStatusMsg.PowerStatus.STB : PowerStatusMsg.PowerStatus.ON;
                getStateManager().sendMessage(
                        new PowerStatusMsg(getStateManager().getState().getActiveZone(), p));
            }
            return true;
        case R.id.menu_app_settings:
        {
            Intent settings = new Intent(this, PreferencesMain.class);
            startActivityForResult(settings, SETTINGS_ACTIVITY_REQID);
            return true;
        }
        case R.id.menu_receiver_information:
        {
            final String text = isConnected() ? getStateManager().getState().receiverInformation :
                    getResources().getString(R.string.state_not_connected);
            HtmlDialogBuilder.buildXmlDialog(this,
                    R.mipmap.ic_launcher, R.string.app_name, text).show();
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
            navigationDrawer.navigationSearchDevice();
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
        if (!state.deviceSelectors.isEmpty())
        {
            configuration.setDeviceSelectors(state.deviceSelectors);
        }
        if (!state.networkServices.isEmpty())
        {
            configuration.setNetworkServices(state.networkServices);
        }
        navigationDrawer.updateNavigationContent(state);
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

    private void updateToolbar(State state)
    {
        // Logo
        if (state == null)
        {
            toolbar.setSubtitle(R.string.state_not_connected);
        }
        else
        {
            final StringBuilder subTitle = new StringBuilder();
            subTitle.append(state.getDeviceName(configuration.isFriendlyNames()));
            if (state.isExtendedZone())
            {
                if (!subTitle.toString().isEmpty())
                {
                    subTitle.append("/");
                }
                subTitle.append(state.zones.get(state.getActiveZone()).getName());
            }
            if (!state.isOn())
            {
                subTitle.append(" (").append(getResources().getString(R.string.state_standby)).append(")");
            }
            toolbar.setSubtitle(subTitle.toString());
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

    /**
     * Navigation drawer: When using the ActionBarDrawerToggle,
     * you must call it during onPostCreate() and onConfigurationChanged()...
     */
    @Override
    protected void onPostCreate(Bundle savedInstanceState)
    {
        super.onPostCreate(savedInstanceState);
        // Sync the toggle state after onRestoreInstanceState has occurred.
        mDrawerToggle.syncState();
    }

    @Override
    public void onConfigurationChanged(android.content.res.Configuration newConfig)
    {
        super.onConfigurationChanged(newConfig);
        // Pass any configuration change to the drawer toggls
        mDrawerToggle.onConfigurationChanged(newConfig);
    }

    @Override
    public boolean dispatchKeyEvent(KeyEvent event)
    {
        if (isConnected() && configuration.isVolumeKeys())
        {
            if (event.getKeyCode() == KeyEvent.KEYCODE_VOLUME_UP || event.getKeyCode() == KeyEvent.KEYCODE_VOLUME_DOWN)
            {
                if (event.getAction() == KeyEvent.ACTION_DOWN)
                {
                    Logging.info(this, "Key event: " + event);
                    changeMasterVolume(event.getKeyCode() == KeyEvent.KEYCODE_VOLUME_UP);
                    return true;
                }
            }
        }
        return super.dispatchKeyEvent(event);
    }

    private void changeMasterVolume(boolean isUp)
    {
        switch (configuration.getSoundControl())
        {
        case "none":
            // nothing to do
            break;
        case "external-amplifier":
            getStateManager().sendMessage(new AmpOperationCommandMsg(isUp ?
                    AmpOperationCommandMsg.Command.MVLUP.getCode() :
                    AmpOperationCommandMsg.Command.MVLDOWN.getCode()));
            break;
        case "device":
            final int zone = getStateManager().getState().getActiveZone();
            getStateManager().sendMessage(new MasterVolumeMsg(zone, isUp ?
                    MasterVolumeMsg.Command.UP : MasterVolumeMsg.Command.DOWN));
            break;
        }
    }
}
