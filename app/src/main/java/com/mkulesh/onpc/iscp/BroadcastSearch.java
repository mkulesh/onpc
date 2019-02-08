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

package com.mkulesh.onpc.iscp;

import android.content.Context;
import android.content.DialogInterface;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.os.StrictMode;
import android.support.v7.app.AlertDialog;
import android.support.v7.view.ContextThemeWrapper;
import android.support.v7.widget.AppCompatRadioButton;
import android.util.Pair;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RadioGroup;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.messages.BroadcastResponseMsg;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;

public class BroadcastSearch extends AsyncTask<Void, BroadcastResponseMsg, Void>
{
    public final static int ISCP_PORT = 60128;

    private final ConnectionState connectionState;
    private final ConnectionState.StateListener stateListener;

    private final static int TIMEOUT = 3000;
    private final Context context;
    private final List<Pair<BroadcastResponseMsg, AppCompatRadioButton>> devices = new ArrayList<>();
    private final AtomicBoolean active = new AtomicBoolean();
    private final ContextThemeWrapper wrappedContext;
    private AlertDialog dialog = null;
    private RadioGroup radioGroup = null;

    public BroadcastSearch(final Context context, final ConnectionState connectionState,
                           final ConnectionState.StateListener stateListener)
    {
        this.connectionState = connectionState;
        this.stateListener = stateListener;
        this.context = context;
        active.set(false);
        wrappedContext = new ContextThemeWrapper(context, R.style.RadioButtonStyle);

        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);
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
                .setNegativeButton(context.getResources().getString(R.string.action_cancel),
                        new DialogInterface.OnClickListener()
                        {
                            @Override
                            public void onClick(DialogInterface dialog, int which)
                            {
                                active.set(false);
                            }
                        }).create();

        dialog.getLayoutInflater().inflate(R.layout.broadcast_dialog_layout, frameView);
        radioGroup = frameView.findViewById(R.id.broadcast_radio_group);
        active.set(true);
        dialog.show();
    }

    @Override
    protected Void doInBackground(Void... params)
    {
        Logging.info(this, "started, network=" + connectionState.isNetwork()
                + ", wifi=" + connectionState.isWifi());

        try
        {
            final InetAddress local = InetAddress.getByName("0.0.0.0");
            final InetAddress target = connectionState.getBroadcastAddress();

            final DatagramSocket socket = new DatagramSocket(ISCP_PORT, local);
            socket.setBroadcast(true);
            socket.setSoTimeout(TIMEOUT);

            while (true)
            {
                synchronized (active)
                {
                    if (!active.get() || isCancelled())
                    {
                        break;
                    }
                }

                if (!connectionState.isNetwork() || !connectionState.isWifi())
                {
                    break;
                }

                try
                {
                    request(socket, target);
                }
                catch (Exception e)
                {
                    Logging.info(BroadcastSearch.this, "Can not receive response: " + e.toString());
                }
            }
            socket.close();
        }
        catch (Exception e)
        {
            Logging.info(this, "Can not open socket: " + e.toString());
        }

        Logging.info(this, "stopped");
        return null;
    }

    @Override
    protected void onPostExecute(Void aVoid)
    {
        super.onPostExecute(aVoid);
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
                Logging.info(BroadcastSearch.this, "Found device: " + device.toString());
                stateListener.onDeviceFound(device);
            }
            else
            {
                final ConnectionState.FailureReason reason =
                        !connectionState.isNetwork() ? ConnectionState.FailureReason.NO_NETWORK : (
                                !connectionState.isWifi() ? ConnectionState.FailureReason.NO_WIFI :
                                        ConnectionState.FailureReason.NO_DEVICE
                        );
                Logging.info(BroadcastSearch.this, "search skipped: " + reason.toString());
                stateListener.noDevice(reason);
            }
        }
    }

    private EISCPMessage convertResponse(byte[] response)
    {
        try
        {
            final int startIndex = EISCPMessage.getMsgStartIndex(response);
            if (startIndex != 0)
            {
                Logging.info(this, "unexpected position of start index: " + startIndex);
                return null;
            }
            final int hSize = EISCPMessage.getHeaderSize(response, startIndex);
            final int dSize = EISCPMessage.getDataSize(response, startIndex);
            return new EISCPMessage(0, response, startIndex, hSize, dSize);
        }
        catch (Exception e)
        {
            return null;
        }
    }

    private void request(DatagramSocket socket, final InetAddress target) throws Exception
    {
        final EISCPMessage m = new EISCPMessage('x', "ECN", "QSTN");
        final byte[] bytes = m.getBytes();

        DatagramPacket p = new DatagramPacket(bytes, bytes.length, target, ISCP_PORT);
        socket.send(p);
        Logging.info(this, "message send to " + target);

        while (true)
        {
            final byte[] response = new byte[512];
            Arrays.fill(response, (byte) 0);
            DatagramPacket p2 = new DatagramPacket(response, response.length);
            socket.receive(p2);

            final EISCPMessage msg = convertResponse(response);
            if (msg == null || p2.getAddress() == null || msg.getModelCategoryId() == 'x')
            {
                continue;
            }

            final BroadcastResponseMsg responseMessage = new BroadcastResponseMsg(p2.getAddress(), msg);
            if (responseMessage.isValid())
            {
                publishProgress(responseMessage);
            }
        }
    }

    @Override
    protected void onProgressUpdate(BroadcastResponseMsg... result)
    {
        if (result == null || result.length == 0 || radioGroup == null || dialog == null)
        {
            return;
        }
        final BroadcastResponseMsg msg = result[0];
        Logging.info(this, "new response " + msg);
        for (Pair<BroadcastResponseMsg, AppCompatRadioButton> d : devices)
        {
            if (d.first.getDevice().equals(msg.getDevice()))
            {
                Logging.info(this, "device already registered");
                return;
            }
        }

        final AppCompatRadioButton b = new AppCompatRadioButton(wrappedContext, null, 0);
        final LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        b.setLayoutParams(lp);
        b.setText(msg.getDevice());
        b.setTextColor(Utils.getThemeColorAttr(context, android.R.attr.textColor));
        b.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v)
            {
                synchronized (active)
                {
                    active.set(false);
                }
            }
        });

        radioGroup.addView(b);
        devices.add(new Pair<>(msg, b));
    }
}
