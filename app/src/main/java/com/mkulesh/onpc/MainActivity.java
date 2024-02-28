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

package com.mkulesh.onpc;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.WindowManager;
import android.widget.Toast;

import com.google.android.material.tabs.TabLayout;
import com.mkulesh.onpc.config.AppLocale;
import com.mkulesh.onpc.config.CfgAppSettings;
import com.mkulesh.onpc.config.CfgFavoriteShortcuts;
import com.mkulesh.onpc.config.Configuration;
import com.mkulesh.onpc.fragments.BaseFragment;
import com.mkulesh.onpc.fragments.Dialogs;
import com.mkulesh.onpc.iscp.ConnectionIf;
import com.mkulesh.onpc.iscp.ConnectionState;
import com.mkulesh.onpc.iscp.DeviceList;
import com.mkulesh.onpc.iscp.State;
import com.mkulesh.onpc.iscp.StateHolder;
import com.mkulesh.onpc.iscp.StateManager;
import com.mkulesh.onpc.iscp.messages.*;
import com.mkulesh.onpc.iscp.scripts.AutoPower;
import com.mkulesh.onpc.iscp.scripts.MessageScript;
import com.mkulesh.onpc.iscp.scripts.MessageScriptIf;
import com.mkulesh.onpc.iscp.scripts.RequestListeningMode;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.logging.Logger;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.viewpager.widget.ViewPager;

public class MainActivity extends AppCompatActivity implements StateManager.StateListener, DeviceList.BackgroundEventListener
{
    public static final int SETTINGS_ACTIVITY_REQID = 256;
    private static final String SHORTCUT_AUTO_POWER = "com.mkulesh.onpc.AUTO_POWER";
    private static final String SHORTCUT_ALL_STANDBY = "com.mkulesh.onpc.ALL_STANDBY";

    private Configuration configuration;
    private Toolbar toolbar;
    private MainPagerAdapter pagerAdapter;
    private ViewPager viewPager;
    private Menu mainMenu;
    private ConnectionState connectionState;
    private final StateHolder stateHolder = new StateHolder();
    private DeviceList deviceList;
    private Toast exitToast = null;
    private MainNavigationDrawer navigationDrawer;
    private ActionBarDrawerToggle mDrawerToggle;
    private String versionName = null;
    private int startRequestCode;
    private final AtomicBoolean connectToAnyDevice = new AtomicBoolean(false);
    public int orientation;
    private String intentData = null;
    private MessageScript messageScript = null;

    // #58: observed missed receiver information message on device rotation.
    // Solution: save and restore the receiver information in
    // onSaveInstanceState/onRestoreInstanceState
    private String savedReceiverInformation = null;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        configuration = new Configuration(this);
        setTheme(configuration.appSettings.getTheme(this, CfgAppSettings.ThemeType.MAIN_THEME));
        Logging.saveLogging = Logging.isEnabled() && configuration.isDeveloperMode();

        // Note that due to onActivityResult, the activity will be started twice
        // after the Preference activity is closed
        // We store activity result code in startRequestCode and use it to prevent
        // network communication after Preference activity is just closed
        startRequestCode = 0;

        super.onCreate(savedInstanceState);

        orientation = getResources().getConfiguration().orientation;
        try
        {
            final PackageInfo pi = getPackageManager().getPackageInfo(getPackageName(), 0);
            versionName = "v. " + pi.versionName;
            Logging.info(this, "Starting application: version " + versionName + ", orientation " + orientation);
        }
        catch (PackageManager.NameNotFoundException e)
        {
            Logging.info(this, "Starting application");
            versionName = null;
        }

        connectionState = new ConnectionState(this);
        deviceList = new DeviceList(this, connectionState, this,
                configuration.favoriteConnections.getDevices());

        // Initially reset zone state
        configuration.initActiveZone(ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE);

        initGUI();
        setOpenedTab(configuration.appSettings.getOpenedTab());
        updateToolbar(null);
    }

    @Override
    public void onConfigurationChanged(android.content.res.Configuration newConfig)
    {
        orientation = newConfig.orientation;
        Logging.info(this, "device orientation change: " + orientation);
        super.onConfigurationChanged(newConfig);

        // restore active page
        int page = viewPager.getCurrentItem();
        initGUI();
        viewPager.setCurrentItem(page);
        if (stateHolder.getState() != null)
        {
            updateConfiguration(stateHolder.getState());
        }

        // Pass any configuration change to the drawer toggles
        mDrawerToggle.onConfigurationChanged(newConfig);
        mDrawerToggle.syncState();
    }

    private void initGUI()
    {
        setContentView(orientation == android.content.res.Configuration.ORIENTATION_PORTRAIT ?
                R.layout.activity_main_port : R.layout.activity_main_land);

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

        final TabLayout tabLayout = findViewById(R.id.tab_layout);
        tabLayout.setupWithViewPager(viewPager);

        // Navigation drawer
        navigationDrawer = new MainNavigationDrawer(this, versionName);
        // ActionBarDrawerToggle ties together the the proper interactions
        // between the sliding drawer and the action bar app icon
        mDrawerToggle = new ActionBarDrawerToggle(this, navigationDrawer.getDrawerLayout(), toolbar,
                R.string.drawer_open, R.string.drawer_open)
        {
            public void onDrawerOpened(View drawerView)
            {
                super.onDrawerOpened(drawerView);
                navigationDrawer.updateNavigationContent(stateHolder.getState());
            }
        };
        Utils.setDrawerListener(navigationDrawer.getDrawerLayout(), mDrawerToggle);
    }

    @Override
    protected void attachBaseContext(Context newBase)
    {
        final Locale prefLocale = AppLocale.ContextWrapper.getPreferredLocale(newBase);
        Logging.info(this, "Application locale: " + prefLocale);
        super.attachBaseContext(AppLocale.ContextWrapper.wrap(newBase, prefLocale));
    }

    @Override
    public void applyOverrideConfiguration(android.content.res.Configuration overrideConfiguration)
    {
        // See https://stackoverflow.com/questions/55265834/change-locale-not-work-after-migrate-to-androidx:
        // There is an issue in new app compat libraries related to night mode that is causing to
        // override the configuration on android 21 to 25. This can be fixed as follows
        if (overrideConfiguration != null)
        {
            int uiMode = overrideConfiguration.uiMode;
            overrideConfiguration.setTo(getBaseContext().getResources().getConfiguration());
            overrideConfiguration.uiMode = uiMode;
        }
        super.applyOverrideConfiguration(overrideConfiguration);
    }

    @Override
    public void onSaveInstanceState(@NonNull Bundle outState)
    {
        super.onSaveInstanceState(outState);
        try
        {
            if (savedReceiverInformation != null)
            {
                Logging.info(this, "save receiver information");
                outState.putString("savedReceiverInformation", savedReceiverInformation);
            }
        }
        catch (Exception e)
        {
            Logging.info(this, "cannot save state: " + e.getLocalizedMessage());
        }
    }

    public void onRestoreInstanceState(@NonNull Bundle inState)
    {
        super.onRestoreInstanceState(inState);
        try
        {
            savedReceiverInformation = inState.getString("savedReceiverInformation", "");
            if (!savedReceiverInformation.isEmpty())
            {
                Logging.info(this, "restore receiver information");
            }
        }
        catch (Exception e)
        {
            Logging.info(this, "cannot restore state: " + e.getLocalizedMessage());
        }
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
            if (m.getItemId() == R.id.menu_latest_logging)
            {
                m.setVisible(Logging.saveLogging);
            }
            if (m.getItemId() == R.id.menu_continue)
            {
                m.setVisible(configuration.isContinueEnabled());
            }
        }
        updateToolbar(stateHolder.getState());
        return true;
    }

    private boolean isResumeStateAvailable() {
        return (configuration.getContinuePath() != null);
    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem menuItem)
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
                powerOnOff();
            }
            return true;
            case R.id.menu_continue:
            if (isConnected())
            {
                continuePlayback();
            }
            return true;
        case R.id.menu_receiver_information:
        {
            final String text = isConnected() ? getStateManager().getState().receiverInformation :
                    getResources().getString(R.string.state_not_connected);
            final Dialogs dl = new Dialogs(this);
            dl.showXmlDialog(R.mipmap.ic_launcher, R.string.menu_receiver_information, text);
            return true;
        }
        case R.id.menu_latest_logging:
        {
            final Dialogs dl = new Dialogs(this);
            dl.showXmlDialog(R.mipmap.ic_launcher, R.string.menu_latest_logging, Logging.getLatestLogging());
            return true;
        }
        default:
            return super.onOptionsItemSelected(menuItem);
        }
    }

    private void powerOnOff()
    {
        final State state = getStateManager().getState();
        final PowerStatusMsg.PowerStatus p = state.isOn() ?
                PowerStatusMsg.PowerStatus.STB : PowerStatusMsg.PowerStatus.ON;
        final PowerStatusMsg cmdMsg = new PowerStatusMsg(getStateManager().getState().getActiveZone(), p);

        // if usb is used, save the current playback path
        if (state.isUsb() && configuration.isContinueEnabled()) {
            List<String> path = state.pathItems;
            path.add(state.title);
            configuration.setContinuePath(path);
        }

        if (state.isOn() && isMultiroomAvailable() && state.isMasterDevice())
        {
            final Dialogs dl = new Dialogs(this);
            dl.showOnStandByDialog(cmdMsg);
        }
        else
        {
            getStateManager().sendMessage(cmdMsg);
        }
    }

    private void continuePlayback() {
        List<String> path = configuration.getContinuePath();
        if (path != null) {
            String lastitem = path.remove(path.size()-1);
            CfgFavoriteShortcuts.Shortcut sc = new CfgFavoriteShortcuts.Shortcut(
                    42,
                    InputSelectorMsg.InputType.USB_FRONT,
                    ServiceType.USB_FRONT,
                    lastitem,""
            );
            sc.setPathItems(path,this,ServiceType.USB_FRONT);
            getStateManager().applyShortcut(this,sc);
            configuration.clearContinuePath();
        }
    }

    @Override
    public void onBackPressed()
    {
        if (configuration.isBackAsReturn())
        {
            final BaseFragment f = (BaseFragment) (pagerAdapter.getRegisteredFragment(viewPager.getCurrentItem()));
            if (f != null && f.onBackPressed())
            {
                return;
            }
        }
        if (!configuration.isExitConfirm())
        {
            finish();
        }
        else if (Utils.isToastVisible(exitToast))
        {
            exitToast.cancel();
            exitToast = null;
            finish();
        }
        else
        {
            exitToast = Toast.makeText(this, R.string.action_exit_confirm, Toast.LENGTH_LONG);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R)
            {
                exitToast.addCallback(new Toast.Callback()
                {
                    @Override
                    public void onToastHidden()
                    {
                        exitToast = null;
                    }
                });
            }
            if (exitToast != null)
            {
                exitToast.show();
            }
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data)
    {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == SETTINGS_ACTIVITY_REQID)
        {
            startRequestCode = requestCode;
            restartActivity();
        }
    }

    public void restartActivity()
    {
        PackageManager pm = getPackageManager();
        Intent intent = pm.getLaunchIntentForPackage(getPackageName());
        if (intent == null)
        {
            intent = getIntent();
        }
        finish();
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        startActivity(intent);
    }

    public void connectToDevice(BroadcastResponseMsg response)
    {
        if (connectToDevice(response.getHost(), response.getPort(), false))
        {
            configuration.saveDevice(response.getHost(), response.getPort());
            updateTabs();
        }
    }

    private void updateTabs()
    {
        // Update tabs since tabs depend on the protocol
        final BaseFragment f = (BaseFragment) (pagerAdapter.getRegisteredFragment(viewPager.getCurrentItem()));
        pagerAdapter = new MainPagerAdapter(this, getSupportFragmentManager(), configuration);
        viewPager.setAdapter(pagerAdapter);
        try
        {
            setOpenedTab(f.getTabName());
        }
        catch (Exception ex)
        {
            // nothing to do
        }
    }

    public boolean connectToDevice(final String device, final int port, final boolean connectToAnyInErrorCase)
    {
        // Parse and use input intent
        AutoPower.AutoPowerMode powerMode = null;
        if (configuration.isAutoPower())
        {
            powerMode = AutoPower.AutoPowerMode.POWER_ON;
        }
        if (SHORTCUT_AUTO_POWER.equals(intentData))
        {
            powerMode = AutoPower.AutoPowerMode.POWER_ON;
        }
        else if (SHORTCUT_ALL_STANDBY.equals(intentData))
        {
            powerMode = AutoPower.AutoPowerMode.ALL_STANDBY;
        }

        intentData = null;

        stateHolder.release(false, "reconnect");
        stateHolder.waitForRelease();
        onStateChanged(stateHolder.getState(), null);
        int zone = configuration.getZone();
        try
        {
            final ArrayList<MessageScriptIf> messageScripts = new ArrayList<>();
            if (powerMode != null)
            {
                messageScripts.add(new AutoPower(powerMode));
            }
            messageScripts.add(new RequestListeningMode());
            if (messageScript != null)
            {
                messageScripts.add(messageScript);
                zone = messageScript.getZone();
                // Be sure that messageScript.tab contains a value from CfgAppSettings.Tabs enum.
                // If not, the app will crash here
                if (messageScript.tab != null)
                {
                    try
                    {
                        setOpenedTab(CfgAppSettings.Tabs.valueOf(messageScript.tab.toUpperCase()));
                    }
                    catch (Exception ex)
                    {
                        // nothing to do
                    }
                }
            }

            stateHolder.setStateManager(new StateManager(
                    deviceList, connectionState, this,
                    device, port, zone,
                    true,
                    savedReceiverInformation,
                    messageScripts));
            savedReceiverInformation = null;
            // Default receiver information used if ReceiverInformationMsg is missing
            {
                final State s = stateHolder.getState();
                s.createDefaultReceiverInfo(this, configuration.audioControl.isForceAudioControl());
                configuration.setReceiverInformation(s);
            }
            if (!deviceList.isActive())
            {
                deviceList.start();
            }
            return true;
        }
        catch (Exception ex)
        {
            if (Configuration.ENABLE_MOCKUP)
            {
                stateHolder.setStateManager(new StateManager(connectionState, this, zone));
                final State s = stateHolder.getState();
                s.createDefaultReceiverInfo(this, configuration.audioControl.isForceAudioControl());
                updateConfiguration(s);
                return true;
            }
            else if (deviceList.isActive() && connectToAnyInErrorCase)
            {
                Logging.info(this, "searching for any device to connect");
                connectToAnyDevice.set(true);
            }
        }
        return false;
    }

    @Override
    public void onDeviceFound(DeviceList.DeviceInfo di)
    {
        if (isConnected())
        {
            getStateManager().inform(di.message);
        }
        else if (connectToAnyDevice.get())
        {
            connectToAnyDevice.set(false);
            connectToDevice(di.message);
        }
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
        if (startRequestCode == SETTINGS_ACTIVITY_REQID)
        {
            return;
        }

        // Analyse input intent
        handleIntent(getIntent());

        connectionState.start();
        if (connectionState.isActive())
        {
            deviceList.start();
        }
        if (!configuration.getDeviceName().isEmpty() && configuration.getDevicePort() > 0)
        {
            Logging.info(this, "use stored connection data: "
                    + Utils.ipToString(configuration.getDeviceName(), configuration.getDevicePort()));
            connectToDevice(configuration.getDeviceName(), configuration.getDevicePort(), true);
        }
        else if (messageScript != null &&
                !messageScript.getHost().equals(ConnectionIf.EMPTY_HOST) &&
                messageScript.getPort() != ConnectionIf.EMPTY_PORT)
        {
            Logging.info(this, "use intent connection data: " + messageScript.getHostAndPort());
            connectToDevice(messageScript.getHost(), messageScript.getPort(), true);
        }
        else
        {
            navigationDrawer.navigationSearchDevice();
        }
    }

    @Override
    protected void onNewIntent(Intent intent)
    {
        super.onNewIntent(intent);
        handleIntent(intent);
    }

    private void handleIntent(Intent intent)
    {
        if (intent != null)
        {
            Logging.info(this, "Received intent: " + intent);
            if (intent.getDataString() != null)
            {
                intentData = intent.getDataString();
                final MessageScript ms = (intentData != null && !intentData.isEmpty()) ? new MessageScript(this, intentData) : null;
                messageScript = ms != null && ms.isValid() ? ms : null;
            }
            else
            {
                intentData = intent.getAction();
            }
            setIntent(null);
        }
    }

    @Override
    protected void onPause()
    {
        super.onPause();
        final BaseFragment f = (BaseFragment) (pagerAdapter.getRegisteredFragment(viewPager.getCurrentItem()));
        if (f != null && f.getTabName() != null)
        {
            configuration.appSettings.setOpenedTab(f.getTabName());
        }
        if (getStateManager() != null)
        {
            savedReceiverInformation = getStateManager().getState().receiverInformation;
        }
        deviceList.stop();
        connectionState.stop();
        stateHolder.release(true, "pause");
    }

    @Override
    public void onStateChanged(State state, @Nullable final HashSet<State.ChangeType> eventChanges)
    {
        if (state != null && eventChanges != null)
        {
            if (eventChanges.contains(State.ChangeType.RECEIVER_INFO) ||
                    eventChanges.contains(State.ChangeType.MULTIROOM_INFO))
            {
                updateConfiguration(state);
            }
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
        configuration.setReceiverInformation(state);
        deviceList.updateFavorites(true);
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
                subTitle.append(state.getActiveZoneInfo().getName());
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
                    if (m.isEnabled() && state != null)
                    {
                        Utils.setDrawableColorAttr(this, m.getIcon(),
                                state.isOn() ? android.R.attr.textColorTertiary : R.attr.colorAccent);
                    }
                }
                if (m.getItemId() == R.id.menu_continue) {
                    if (state != null && isResumeStateAvailable()) {
                        m.setEnabled(true);
                        Utils.setDrawableColorAttr(this, m.getIcon(), android.R.attr.textColorTertiary);
                    }
                    else {
                        m.setEnabled(false);
                        Utils.setDrawableColorAttr(this, m.getIcon(), R.attr.colorButtonDisabled);
                    }
                }
            }
        }
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
    public boolean dispatchKeyEvent(KeyEvent event)
    {
        if (isConnected() && configuration.audioControl.isVolumeKeys())
        {
            if (event.getKeyCode() == KeyEvent.KEYCODE_VOLUME_UP || event.getKeyCode() == KeyEvent.KEYCODE_VOLUME_DOWN)
            {
                if (event.getAction() == KeyEvent.ACTION_DOWN)
                {
                    Logging.info(this, "Key event: " + event);
                    getStateManager().changeMasterVolume(configuration.audioControl.getSoundControl(),
                            event.getKeyCode() == KeyEvent.KEYCODE_VOLUME_UP);
                    return true;
                }
                else if (event.getAction() == KeyEvent.ACTION_UP)
                {
                    // Report to the OS that event is fully processed
                    return true;
                }
            }
        }
        return super.dispatchKeyEvent(event);
    }

    @NonNull
    public DeviceList getDeviceList()
    {
        return deviceList;
    }

    public boolean isMultiroomAvailable()
    {
        return deviceList.getDevicesNumber() > 1;
    }

    @NonNull
    public String myDeviceId()
    {
        return stateHolder.getState() != null ? stateHolder.getState().multiroomDeviceId : "";
    }

    @NonNull
    public String getMultiroomDeviceName(final @NonNull BroadcastResponseMsg msg)
    {
        if (msg.getAlias() != null)
        {
            return msg.getAlias();
        }
        final State state = stateHolder.getState();
        final String name = (configuration.isFriendlyNames() && state != null) ?
                state.multiroomNames.get(msg.getHostAndPort()) : null;
        return (name != null) ? name : msg.getDescription();
    }

    public void setOpenedTab(CfgAppSettings.Tabs tab)
    {
        final ArrayList<CfgAppSettings.Tabs> tabs = configuration.appSettings.getVisibleTabs();
        for (int i = 0; i < tabs.size(); i++)
        {
            if (tabs.get(i) == tab)
            {
                try
                {
                    viewPager.setCurrentItem(i);
                }
                catch (Exception ex)
                {
                    Logging.info(this, "can not change opened tab: " + ex.getLocalizedMessage());
                }
                break;
            }
        }
    }
}
