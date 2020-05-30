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

package com.mkulesh.onpc.iscp;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RadioGroup;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.messages.BroadcastResponseMsg;
import com.mkulesh.onpc.utils.AppTask;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.view.ContextThemeWrapper;
import androidx.appcompat.widget.AppCompatRadioButton;

public class DeviceList extends AppTask implements BroadcastSearch.EventListener
{
    private final static int RESPONSE_NUMBER = 5;

    // Common properties
    private final Context context;
    private final ConnectionState connectionState;
    private BroadcastSearch searchEngine = null;

    // Devices properties
    public class DeviceInfo
    {
        public final BroadcastResponseMsg message;
        private final boolean isFavorite;
        int responses;
        boolean selected;

        DeviceInfo(@NonNull final BroadcastResponseMsg msg, final boolean isFavorite, int responses)
        {
            this.message = msg;
            this.isFavorite = isFavorite;
            this.responses = responses;
            this.selected = false;
        }
    }

    private final Map<String, DeviceInfo> devices = new TreeMap<>();

    // Dialog properties
    private boolean dialogMode = false;
    private AlertDialog dialog = null;
    private RadioGroup dialogList = null;

    // Callbacks for dialogs
    public interface DialogEventListener
    {
        void onDeviceFound(BroadcastResponseMsg response);

        void noDevice(ConnectionState.FailureReason reason);
    }

    private DialogEventListener dialogEventListener = null;

    // Callback for background search
    public interface BackgroundEventListener
    {
        void onDeviceFound(DeviceInfo device);
    }

    private final BackgroundEventListener backgroundEventListener;
    private final List<BroadcastResponseMsg> favorites;

    public DeviceList(final Context context,
                      final ConnectionState connectionState,
                      final BackgroundEventListener backgroundEventListener,
                      final List<BroadcastResponseMsg> favorites)
    {
        super(false);
        this.context = context;
        this.connectionState = connectionState;
        this.backgroundEventListener = backgroundEventListener;
        this.favorites = favorites;
    }

    public int getDevicesNumber()
    {
        synchronized (devices)
        {
            return devices.size();
        }
    }

    public List<BroadcastResponseMsg> getDevices()
    {
        List<BroadcastResponseMsg> retValue = new ArrayList<>();
        synchronized (devices)
        {
            for (DeviceInfo di : devices.values())
            {
                retValue.add(new BroadcastResponseMsg(di.message));
            }
        }
        return retValue;
    }

    public void start()
    {
        synchronized (devices)
        {
            devices.clear();
        }
        updateFavorites(false);
        if (connectionState.isWifi())
        {
            super.start();
            Logging.info(this, "started");
            searchEngine = new BroadcastSearch(connectionState, this);
            searchEngine.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, (Void[]) null);
        }
        else
        {
            Logging.info(this, "device search skipped: no WiFi");
        }
    }

    public void stop()
    {
        super.stop();
        Logging.info(this, "stopped");
        if (searchEngine != null)
        {
            searchEngine.stop();
        }
        searchEngine = null;
        if (dialogMode)
        {
            dialogMode = false;
            if (dialog != null)
            {
                dialog.dismiss();
            }
            dialog = null;
            dialogList = null;
            if (dialogEventListener != null)
            {
                BroadcastResponseMsg found = null;
                synchronized (devices)
                {
                    for (DeviceInfo deviceInfo : devices.values())
                    {
                        if (deviceInfo.selected)
                        {
                            found = new BroadcastResponseMsg(deviceInfo.message);
                            break;
                        }
                    }
                }
                if (found != null)
                {
                    dialogEventListener.onDeviceFound(found);
                }
            }
            dialogEventListener = null;
        }
    }

    public void updateFavorites(boolean callHandler)
    {
        synchronized (devices)
        {
            final List<String> toBeDeleted = new ArrayList<>();
            for (Map.Entry<String, DeviceInfo> d : devices.entrySet())
            {
                if (d.getValue().isFavorite)
                {
                    toBeDeleted.add(d.getKey());
                }
            }
            for (String key :  toBeDeleted)
            {
                devices.remove(key);
            }
            for (BroadcastResponseMsg msg : favorites)
            {
                Logging.info(this, "Added favorite connection " + msg);
                final DeviceInfo newInfo = new DeviceInfo(msg, true,0);
                devices.put(msg.getHostAndPort(), newInfo);
                if (callHandler && backgroundEventListener != null)
                {
                    backgroundEventListener.onDeviceFound(newInfo);
                }
            }
        }
    }

    @Override
    public void onDeviceFound(BroadcastResponseMsg msg)
    {
        if (!msg.isValid())
        {
            Logging.info(this, "  invalid response " + msg + ", ignored");
            return;
        }
        Logging.info(this, "  new response " + msg);

        synchronized (devices)
        {
            final String d = msg.getHostAndPort();
            final DeviceInfo oldInfo = devices.get(d);
            DeviceInfo newInfo;
            if (oldInfo == null)
            {
                newInfo = new DeviceInfo(msg, false, 1);
                devices.put(d, newInfo);
                if (dialogMode)
                {
                    addToRadioGroup(newInfo);
                }
            }
            else
            {
                final BroadcastResponseMsg newMsg = oldInfo.isFavorite ? oldInfo.message : msg;
                newInfo = new DeviceInfo(newMsg, oldInfo.isFavorite,oldInfo.responses + 1);
                devices.put(d, newInfo);
            }

            if (backgroundEventListener != null)
            {
                backgroundEventListener.onDeviceFound(newInfo);
            }

            if (!dialogMode)
            {
                for (DeviceInfo di : devices.values())
                {
                    if (!di.isFavorite && di.responses < RESPONSE_NUMBER)
                    {
                        return;
                    }
                }
                Logging.info(this, "  -> no more devices");
                stop();
            }
        }
    }

    @Override
    public void noDevice(ConnectionState.FailureReason reason)
    {
        if (dialogEventListener != null)
        {
            dialogEventListener.noDevice(reason);
        }
        stop();
    }

    public void startSearchDialog(DialogEventListener listener)
    {
        if (!connectionState.isWifi())
        {
            if (listener != null)
            {
                listener.noDevice(ConnectionState.FailureReason.NO_WIFI);
            }
            return;
        }

        dialogMode = true;
        dialogEventListener = listener;
        final FrameLayout frameView = new FrameLayout(context);

        final Drawable icon = Utils.getDrawable(context, R.drawable.media_item_search);
        Utils.setDrawableColorAttr(context, icon, android.R.attr.textColorSecondary);
        dialog = new AlertDialog.Builder(context)
                .setTitle(R.string.drawer_device_search)
                .setIcon(icon)
                .setCancelable(false)
                .setView(frameView)
                .setNegativeButton(context.getResources().getString(R.string.action_cancel), (d, which) -> stop())
                .create();

        dialog.getLayoutInflater().inflate(R.layout.dialog_broadcast_layout, frameView);
        dialogList = frameView.findViewById(R.id.broadcast_radio_group);

        if (!isActive())
        {
            start();
        }
        else for (DeviceInfo deviceInfo : devices.values())
        {
            addToRadioGroup(deviceInfo);
        }

        dialog.show();
        Utils.fixIconColor(dialog, android.R.attr.textColorSecondary);
    }

    private void addToRadioGroup(final DeviceInfo deviceInfo)
    {
        if (deviceInfo.responses == 0)
        {
            return;
        }
        deviceInfo.selected = false;
        if (dialogList != null)
        {
            final ContextThemeWrapper wrappedContext = new ContextThemeWrapper(context, R.style.RadioButtonStyle);
            final AppCompatRadioButton b = new AppCompatRadioButton(wrappedContext, null, 0);
            final LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
            b.setLayoutParams(lp);
            b.setText(deviceInfo.message.getDescription());
            b.setTextColor(Utils.getThemeColorAttr(context, android.R.attr.textColor));
            b.setOnClickListener(v ->
            {
                deviceInfo.selected = true;
                stop();
            });
            dialogList.addView(b);
        }
    }
}
