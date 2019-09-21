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
        int responses;
        boolean selected;

        DeviceInfo(BroadcastResponseMsg msg)
        {
            message = msg;
            responses = 1;
            selected = false;
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

    public DeviceList(final Context context,
                      final ConnectionState connectionState,
                      final BackgroundEventListener backgroundEventListener)
    {
        super(false);
        this.context = context;
        this.connectionState = connectionState;
        this.backgroundEventListener = backgroundEventListener;
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
        super.start();
        Logging.info(this, "started");
        synchronized (devices)
        {
            devices.clear();
        }
        searchEngine = new BroadcastSearch(connectionState, this);
        searchEngine.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, (Void[]) null);
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
            final String d = msg.getDevice();
            DeviceInfo deviceInfo = devices.get(d);
            if (deviceInfo == null)
            {
                deviceInfo = new DeviceInfo(msg);
                devices.put(d, deviceInfo);
                if (backgroundEventListener != null)
                {
                    backgroundEventListener.onDeviceFound(deviceInfo);
                }
                if (dialogMode)
                {
                    addToRadioGroup(deviceInfo);
                }
            }
            else
            {
                deviceInfo.responses++;
            }

            if (!dialogMode)
            {
                for (DeviceInfo di : devices.values())
                {
                    if (di.responses < RESPONSE_NUMBER)
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
        deviceInfo.selected = false;
        if (dialogList != null)
        {
            final ContextThemeWrapper wrappedContext = new ContextThemeWrapper(context, R.style.RadioButtonStyle);
            final AppCompatRadioButton b = new AppCompatRadioButton(wrappedContext, null, 0);
            final LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
            b.setLayoutParams(lp);
            b.setText(deviceInfo.message.getDevice());
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
