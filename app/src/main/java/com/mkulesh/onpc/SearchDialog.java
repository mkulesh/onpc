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
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.util.Pair;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RadioGroup;

import com.mkulesh.onpc.iscp.BroadcastSearch;
import com.mkulesh.onpc.iscp.ConnectionState;
import com.mkulesh.onpc.iscp.messages.BroadcastResponseMsg;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.util.ArrayList;
import java.util.List;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.view.ContextThemeWrapper;
import androidx.appcompat.widget.AppCompatRadioButton;

@SuppressLint("StaticFieldLeak")
public class SearchDialog extends BroadcastSearch
{
    public interface StateListener
    {
        void onDeviceFound(BroadcastResponseMsg response);

        void noDevice(ConnectionState.FailureReason reason);
    }

    private final Context context;
    private final StateListener stateListener;

    private AlertDialog dialog = null;
    private RadioGroup radioGroup = null;
    private final List<Pair<BroadcastResponseMsg, AppCompatRadioButton>> devices = new ArrayList<>();

    SearchDialog(Context context, ConnectionState connectionState, StateListener stateListener)
    {
        super(connectionState);
        this.context = context;
        this.stateListener = stateListener;
    }

    @Override
    protected void onPreExecute()
    {
        super.onPreExecute();

        final FrameLayout frameView = new FrameLayout(context);

        final Drawable icon = Utils.getDrawable(context, R.drawable.media_item_search);
        Utils.setDrawableColorAttr(context, icon, android.R.attr.textColorSecondary);
        dialog = new AlertDialog.Builder(context)
                .setTitle(R.string.drawer_device_search)
                .setIcon(icon)
                .setCancelable(false)
                .setView(frameView)
                .setNegativeButton(context.getResources().getString(R.string.action_cancel), (dialog, which) -> setActive(false))
                .create();

        dialog.getLayoutInflater().inflate(R.layout.dialog_broadcast_layout, frameView);
        radioGroup = frameView.findViewById(R.id.broadcast_radio_group);

        dialog.show();
        Utils.fixIconColor(dialog, android.R.attr.textColorSecondary);
    }

    @Override
    protected void onPostExecute(Void aVoid)
    {
        super.onPostExecute(aVoid);
        try
        {
            if (dialog != null)
            {
                dialog.dismiss();
            }
            if (stateListener != null)
            {
                BroadcastResponseMsg device = null;
                if (devices.size() > 0)
                {
                    for (Pair<BroadcastResponseMsg, AppCompatRadioButton> d : devices)
                    {
                        if (d.second.isChecked())
                        {
                            device = d.first;
                            break;
                        }
                    }
                }

                if (device != null)
                {
                    Logging.info(SearchDialog.this, "Found device: " + device.toString());
                    stateListener.onDeviceFound(device);
                }
                else if (failureReason != null)
                {
                    Logging.info(SearchDialog.this, "Device not found: " + failureReason.toString());
                    stateListener.noDevice(failureReason);
                }
            }
        }
        catch (Exception ex)
        {
            // nothing to do
        }
    }

    @Override
    protected void onProgressUpdate(BroadcastResponseMsg... result)
    {
        super.onProgressUpdate(result);

        if (result == null || result.length == 0 || radioGroup == null || dialog == null)
        {
            return;
        }
        final BroadcastResponseMsg msg = result[0];
        Logging.info(this, "  new response " + msg);
        for (Pair<BroadcastResponseMsg, AppCompatRadioButton> d : devices)
        {
            if (d.first.getDevice().equals(msg.getDevice()))
            {
                Logging.info(this, "  -> device already registered");
                return;
            }
        }

        final ContextThemeWrapper wrappedContext = new ContextThemeWrapper(context, R.style.RadioButtonStyle);
        final AppCompatRadioButton b = new AppCompatRadioButton(wrappedContext, null, 0);
        final LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        b.setLayoutParams(lp);
        b.setText(msg.getDevice());
        b.setTextColor(Utils.getThemeColorAttr(context, android.R.attr.textColor));
        b.setOnClickListener(v -> setActive(false));

        radioGroup.addView(b);
        devices.add(new Pair<>(msg, b));
    }
}
