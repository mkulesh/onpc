/*
 * Copyright (C) 2019. Mikhail Kulesh
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

import android.annotation.SuppressLint;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.material.navigation.NavigationView;
import com.mkulesh.onpc.config.Configuration;
import com.mkulesh.onpc.config.PreferencesMain;
import com.mkulesh.onpc.iscp.BroadcastSearch;
import com.mkulesh.onpc.iscp.ConnectionState;
import com.mkulesh.onpc.iscp.DeviceList;
import com.mkulesh.onpc.iscp.State;
import com.mkulesh.onpc.iscp.messages.BroadcastResponseMsg;
import com.mkulesh.onpc.iscp.messages.ReceiverInformationMsg;
import com.mkulesh.onpc.utils.HtmlDialogBuilder;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.util.ArrayList;
import java.util.List;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.widget.AppCompatImageButton;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatRadioButton;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.drawerlayout.widget.DrawerLayout;

class MainNavigationDrawer
{
    private final MainActivity activity;
    private final DrawerLayout drawerLayout;
    private final NavigationView navigationView;
    private final Configuration configuration;
    private final List<BroadcastResponseMsg> devices = new ArrayList<>();

    MainNavigationDrawer(MainActivity activity, String versionName)
    {
        this.activity = activity;
        drawerLayout = activity.findViewById(R.id.main_drawer_layout);
        navigationView = activity.findViewById(R.id.navigation_view);
        configuration = activity.getConfiguration();
        if (navigationView != null)
        {
            updateNavigationContent(null);
            updateNavigationHeader(versionName);
        }
    }

    DrawerLayout getDrawerLayout()
    {
        return drawerLayout;
    }

    private void selectNavigationItem(MenuItem menuItem)
    {
        drawerLayout.closeDrawers();
        switch (menuItem.getItemId())
        {
        case R.id.drawer_device_search:
            navigationSearchDevice();
            break;
        case R.id.drawer_device_connect:
            navigationConnectDevice();
            break;
        case R.id.drawer_zone_1:
        case R.id.drawer_zone_2:
        case R.id.drawer_zone_3:
        case R.id.drawer_zone_4:
            navigationChangeZone(menuItem.getOrder());
            break;
        case R.id.drawer_multiroom_1:
        case R.id.drawer_multiroom_2:
        case R.id.drawer_multiroom_3:
        case R.id.drawer_multiroom_4:
        case R.id.drawer_multiroom_5:
        case R.id.drawer_multiroom_6:
            navigationMultiroom(menuItem.getOrder());
            break;
        case R.id.drawer_app_settings:
            activity.startActivityForResult(new Intent(activity, PreferencesMain.class), MainActivity.SETTINGS_ACTIVITY_REQID);
            break;
        case R.id.drawer_about:
            HtmlDialogBuilder.buildHtmlDialog(activity,
                    R.mipmap.ic_launcher, R.string.app_name, R.string.about_text).show();
        }
    }

    void navigationSearchDevice()
    {
        activity.getDeviceList().startSearchDialog(new DeviceList.DialogEventListener()
        {
            // These methods will be called from GUI thread
            @Override
            public void onDeviceFound(BroadcastResponseMsg response)
            {
                if (response == null || !response.isValid())
                {
                    return;
                }
                activity.connectToDevice(response);
            }

            @Override
            public void noDevice(ConnectionState.FailureReason reason)
            {
                activity.getConnectionState().showFailure(reason);
            }
        });
    }

    @SuppressLint("SetTextI18n")
    private void navigationConnectDevice()
    {
        final FrameLayout frameView = new FrameLayout(activity);
        activity.getLayoutInflater().inflate(R.layout.dialog_connect_layout, frameView);
        final EditText deviceName = frameView.findViewById(R.id.device_name);
        deviceName.setText(configuration.getDeviceName());
        final EditText devicePort = frameView.findViewById(R.id.device_port);
        devicePort.setText(configuration.getDevicePortAsString());

        final EditText deviceFriendlyName = frameView.findViewById(R.id.device_friendly_name);
        final CheckBox checkBox = frameView.findViewById(R.id.checkbox_device_save);
        checkBox.setOnCheckedChangeListener((buttonView, isChecked) ->
                deviceFriendlyName.setVisibility(isChecked ? View.VISIBLE : View.GONE));

        final Drawable icon = Utils.getDrawable(activity, R.drawable.drawer_connect);
        Utils.setDrawableColorAttr(activity, icon, android.R.attr.textColorSecondary);
        final AlertDialog dialog = new AlertDialog.Builder(activity)
                .setTitle(R.string.drawer_device_connect)
                .setIcon(icon)
                .setCancelable(false)
                .setView(frameView)
                .setNegativeButton(activity.getResources().getString(R.string.action_cancel), (dialog1, which) ->
                {
                    Utils.showSoftKeyboard(activity, deviceName, false);
                    dialog1.dismiss();
                })
                .setPositiveButton(activity.getResources().getString(R.string.action_ok), (dialog12, which) ->
                {
                    Utils.showSoftKeyboard(activity, deviceName, false);
                    // First, use port from configuration
                    if (devicePort.getText().length() == 0)
                    {
                        devicePort.setText(configuration.getDevicePortAsString());
                    }
                    // Second, fallback to standard port
                    if (devicePort.getText().length() == 0)
                    {
                        devicePort.setText(Integer.toString(BroadcastSearch.ISCP_PORT));
                    }
                    try
                    {
                        final String device = deviceName.getText().toString();
                        final int port = Integer.parseInt(devicePort.getText().toString());
                        if (activity.connectToDevice(device, port, false))
                        {
                            configuration.saveDevice(device, port);
                            if (checkBox.isChecked())
                            {
                                final String friendlyName = deviceFriendlyName.getText().length() > 0 ?
                                        deviceFriendlyName.getText().toString() :
                                        Utils.ipToString(device, devicePort.getText().toString());
                                configuration.updateFavoriteConnection(
                                        device, port, friendlyName);
                            }
                        }
                    }
                    catch (Exception e)
                    {
                        String message = activity.getString(R.string.error_invalid_device_address);
                        Logging.info(activity, message + ": " + e.getLocalizedMessage());
                        Toast.makeText(activity, message, Toast.LENGTH_LONG).show();
                    }
                    dialog12.dismiss();
                }).create();

        dialog.show();
        Utils.fixIconColor(dialog, android.R.attr.textColorSecondary);
    }

    private void navigationChangeZone(final int idx)
    {
        Logging.info(this, "changed zone: " + idx);
        configuration.setActiveZone(idx);
        activity.restartActivity();
    }

    private void navigationMultiroom(int idx)
    {
        Logging.info(this, "changed multiroom device: " + idx);
        if (idx < devices.size())
        {
            activity.connectToDevice(devices.get(idx));
        }
    }

    private void updateNavigationHeader(final String versionName)
    {
        for (int i = 0; i < navigationView.getHeaderCount(); i++)
        {
            final TextView versionInfo = navigationView.getHeaderView(i).findViewById(R.id.navigation_view_header_version);
            if (versionInfo != null)
            {
                versionInfo.setText(versionName);
            }

            final AppCompatImageView logo = navigationView.getHeaderView(i).findViewById(R.id.drawer_header);
            if (logo != null)
            {
                Utils.setImageViewColorAttr(activity, logo, R.attr.colorAccent);
            }
        }
    }

    void updateNavigationContent(@Nullable final State state)
    {
        final int activeZone = state == null ?
                ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE : state.getActiveZone();
        final List<ReceiverInformationMsg.Zone> zones = state == null ?
                ReceiverInformationMsg.getDefaultZones() : state.getZones();

        final int[] zoneImages = {
                R.drawable.drawer_zone_1,
                R.drawable.drawer_zone_2,
                R.drawable.drawer_zone_3,
                R.drawable.drawer_zone_4,
        };

        final List<BroadcastResponseMsg> favoriteConnections = configuration.getFavoriteConnections();

        // store devices
        devices.clear();
        devices.addAll(favoriteConnections);
        devices.addAll(activity.getDeviceList().getDevices());

        final Menu menu = navigationView.getMenu();
        for (int k = 0; k < menu.size(); k++)
        {
            final MenuItem g = menu.getItem(k);
            switch (g.getItemId())
            {
            case R.id.drawer_group_zone_id:
                for (int i = 0; i < g.getSubMenu().size(); i++)
                {
                    final MenuItem m = g.getSubMenu().getItem(i);
                    if (zones == null || i >= zones.size())
                    {
                        m.setVisible(false);
                        continue;
                    }
                    updateItem(m, zoneImages[i], zones.get(i).getName(), null);
                    m.setChecked(i == activeZone);
                }
                break;
            case R.id.drawer_multiroom:
                g.setVisible(devices.size() > 1 || !favoriteConnections.isEmpty());
                for (int i = 0; i < g.getSubMenu().size(); i++)
                {
                    final MenuItem m = g.getSubMenu().getItem(i);
                    if (g.isVisible() && i < devices.size())
                    {
                        setDeviceVisible(m, devices.get(i), state);
                    }
                    else
                    {
                        m.setVisible(false);
                        m.setChecked(false);
                    }
                }
                break;
            default:
                for (int i = 0; i < g.getSubMenu().size(); i++)
                {
                    final MenuItem m = g.getSubMenu().getItem(i);
                    switch (m.getItemId())
                    {
                    case R.id.drawer_device_search:
                        updateItem(m, R.drawable.drawer_search, R.string.drawer_device_search);
                        break;
                    case R.id.drawer_device_connect:
                        updateItem(m, R.drawable.drawer_connect, R.string.drawer_device_connect);
                        break;
                    case R.id.drawer_app_settings:
                        updateItem(m, R.drawable.drawer_app_settings, R.string.drawer_app_settings);
                        break;
                    case R.id.drawer_about:
                        updateItem(m, R.drawable.drawer_about, R.string.drawer_about);
                        break;
                    }
                }
            }
        }
        navigationView.setNavigationItemSelectedListener(menuItem ->
        {
            selectNavigationItem(menuItem);
            return true;
        });
    }

    interface ButtonListener
    {
        void onEditItem();
    }

    private void updateItem(@NonNull final MenuItem m, final @DrawableRes int iconId, @StringRes final int titleId)
    {
        updateItem(m, iconId, activity.getString(titleId), null);
    }

    private void updateItem(@NonNull final MenuItem m, final @DrawableRes int iconId, final String title, final ButtonListener editListener)
    {
        if (m.getActionView() != null && m.getActionView() instanceof LinearLayout)
        {
            final LinearLayout l = (LinearLayout)m.getActionView();
            ((AppCompatImageView) l.findViewWithTag("ICON")).setImageResource(iconId);
            ((AppCompatTextView)l.findViewWithTag("TEXT")).setText(title);
            final AppCompatImageButton editBtn = l.findViewWithTag("EDIT");
            if (editListener != null)
            {
                editBtn.setVisibility(View.VISIBLE);
                editBtn.setOnClickListener(v -> editListener.onEditItem());
                Utils.setButtonEnabled(activity, editBtn, true);
            }
            else
            {
                editBtn.setVisibility(View.GONE);
            }
        }
        m.setVisible(true);
    }

    private void setDeviceVisible(@NonNull final MenuItem m, final BroadcastResponseMsg msg, @Nullable final State state)
    {
        if (msg.getAlias() != null)
        {
            updateItem(m, R.drawable.drawer_favorite_device, msg.getAlias(), () -> editFavoriteConnection(m, msg));
        }
        else
        {
            updateItem(m, R.drawable.drawer_found_device, activity.getMultiroomDeviceName(msg), null);
        }
        m.setChecked(state != null && !state.isAnotherHost(msg));
    }

    @SuppressLint("DefaultLocale")
    private void editFavoriteConnection(@NonNull final MenuItem m, final BroadcastResponseMsg msg)
    {
        final FrameLayout frameView = new FrameLayout(activity);
        activity.getLayoutInflater().inflate(R.layout.dialog_favorite_connect_layout, frameView);

        final TextView deviceAddress = frameView.findViewById(R.id.device_address);
        deviceAddress.setText(String.format("%s %s",
                activity.getString(R.string.connect_dialog_address),
                Utils.ipToString(msg.getHost(), msg.getPort())));

        final EditText deviceName = frameView.findViewById(R.id.device_name);
        deviceName.setText(msg.getAlias());

        final AppCompatRadioButton renameBtn = frameView.findViewById(R.id.device_rename_connection);
        final AppCompatRadioButton deleteBtn = frameView.findViewById(R.id.device_delete_connection);
        final AppCompatRadioButton[] radioGroup = {renameBtn, deleteBtn};
        for (AppCompatRadioButton r : radioGroup)
        {
            r.setOnClickListener((View v) ->
            {
                onRadioBtnChange(radioGroup, (AppCompatRadioButton)v);
                if (v != renameBtn)
                {
                    deviceName.clearFocus();
                }
            });
        }
        deviceName.setOnFocusChangeListener((v, hasFocus) -> {
            if (hasFocus)
            {
                onRadioBtnChange(radioGroup, renameBtn);
            }
        });

        final Drawable icon = Utils.getDrawable(activity, R.drawable.drawer_edit_item);
        Utils.setDrawableColorAttr(activity, icon, android.R.attr.textColorSecondary);
        final AlertDialog dialog = new AlertDialog.Builder(activity)
                .setTitle(R.string.favorite_connection_edit)
                .setIcon(icon)
                .setCancelable(false)
                .setView(frameView)
                .setNegativeButton(activity.getResources().getString(R.string.action_cancel), (dialog1, which) ->
                {
                    Utils.showSoftKeyboard(activity, deviceName, false);
                    dialog1.dismiss();
                })
                .setPositiveButton(activity.getResources().getString(R.string.action_ok), (dialog12, which) ->
                {
                    Utils.showSoftKeyboard(activity, deviceName, false);
                    // rename or delete favorite connection
                    if (renameBtn.isChecked() && deviceName.getText().length() > 0)
                    {
                        final String newName = deviceName.getText().toString();
                        final BroadcastResponseMsg newMsg = configuration.updateFavoriteConnection(
                                msg.getHost(), msg.getPort(), newName);
                        updateItem(m, R.drawable.drawer_favorite_device, newMsg.getAlias(), () -> editFavoriteConnection(m, newMsg));
                    }
                    if (deleteBtn.isChecked())
                    {
                        configuration.deleteFavoriteConnection(msg.getHost(), msg.getPort());
                        m.setVisible(false);
                        m.setChecked(false);
                    }
                    dialog12.dismiss();
                }).create();

        dialog.show();
        Utils.fixIconColor(dialog, android.R.attr.textColorSecondary);
    }

    private void onRadioBtnChange(final AppCompatRadioButton[] radioGroup, AppCompatRadioButton v)
    {
        for (AppCompatRadioButton r : radioGroup)
        {
            r.setChecked(false);
        }
        v.setChecked(true);
    }
}
