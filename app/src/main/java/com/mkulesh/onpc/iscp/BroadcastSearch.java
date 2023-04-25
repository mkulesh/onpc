/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2022 by Mikhail Kulesh
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

import android.os.AsyncTask;
import android.os.StrictMode;

import com.mkulesh.onpc.iscp.messages.BroadcastResponseMsg;
import com.mkulesh.onpc.utils.Logging;

import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.util.Arrays;
import java.util.Calendar;
import java.util.concurrent.atomic.AtomicBoolean;

public class BroadcastSearch extends AsyncTask<Void, BroadcastResponseMsg, Void>
{
    public final static int ISCP_PORT = 60128;
    private final static int DCP_PORT = 1900; // UDP port of HEOS protocol
    private final static int TIMEOUT = 3000;

    // Connection state
    private final ConnectionState connectionState;

    // Callbacks
    public interface EventListener
    {
        void onDeviceFound(BroadcastResponseMsg response);

        void noDevice(ConnectionState.FailureReason reason);
    }

    private EventListener eventListener;

    // Common properties
    private final AtomicBoolean active = new AtomicBoolean();
    private ConnectionState.FailureReason failureReason = null;

    BroadcastSearch(final ConnectionState connectionState, final EventListener eventListener)
    {
        this.connectionState = connectionState;
        this.eventListener = eventListener;
        active.set(false);

        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);
    }

    @Override
    protected void onPreExecute()
    {
        super.onPreExecute();
        active.set(true);
    }

    public void stop()
    {
        synchronized (active)
        {
            active.set(false);
            eventListener = null;
        }
    }

    private boolean isStopped()
    {
        if (!connectionState.isNetwork())
        {
            failureReason = ConnectionState.FailureReason.NO_NETWORK;
            return true;
        }
        if (!connectionState.isWifi())
        {
            failureReason = ConnectionState.FailureReason.NO_WIFI;
            return true;
        }
        // no reason for events below
        if (isCancelled() || !connectionState.isActive())
        {
            return true;
        }
        synchronized (active)
        {
            return !active.get();
        }
    }

    @Override
    protected Void doInBackground(Void... params)
    {
        Logging.info(this, "started, network=" + connectionState.isNetwork()
                + ", wifi=" + connectionState.isWifi());

        final Character[] models = new Character[]{ 'x', 'p' };
        int modelId = 0;

        try
        {
            final DatagramSocket iscpSocket = prepareSocket(ISCP_PORT);
            final DatagramSocket dcpSocket = prepareSocket(DCP_PORT);

            while (!isStopped())
            {
                requestIscp(iscpSocket, models[modelId]);
                modelId++;
                if (modelId > 1)
                {
                    modelId = 0;
                }
                if (modelId == 0)
                {
                    requestDcp(dcpSocket);
                }
            }
            iscpSocket.close();
            dcpSocket.close();
        }
        catch (Exception e)
        {
            Logging.info(this, "Can not open socket: " + e);
        }

        Logging.info(this, "stopped");
        return null;
    }

    private DatagramSocket prepareSocket(int port) throws Exception
    {
        final DatagramSocket s = new DatagramSocket(null);
        s.setReuseAddress(true);
        s.setBroadcast(true);
        s.setSoTimeout(500);
        s.bind(new InetSocketAddress(port));
        return s;
    }

    private EISCPMessage convertResponse(byte[] response)
    {
        try
        {
            final int startIndex = EISCPMessage.getMsgStartIndex(response);
            if (startIndex != 0)
            {
                Logging.info(this, "  -> unexpected position of start index: " + startIndex);
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

    private void requestIscp(DatagramSocket socket, final Character modelCategoryId)
    {
        final EISCPMessage m = new EISCPMessage(modelCategoryId, "ECN", "QSTN");
        final byte[] bytes = m.getBytes();

        try
        {
            final InetAddress target = InetAddress.getByName("255.255.255.255");
            final DatagramPacket p = new DatagramPacket(bytes, bytes.length, target, ISCP_PORT);
            socket.send(p);
            Logging.info(this, "message " + m + " for category '"
                    + modelCategoryId + "' send to " + target + ", wait response for " + TIMEOUT + "ms");
        }
        catch (Exception e)
        {
            Logging.info(BroadcastSearch.this, "  -> can not send request: " + e);
        }

        final long startTime = Calendar.getInstance().getTimeInMillis();
        final byte[] response = new byte[512];
        while (Calendar.getInstance().getTimeInMillis() < startTime + TIMEOUT)
        {
            if (isStopped())
            {
                break;
            }

            try
            {
                Arrays.fill(response, (byte) 0);
                final DatagramPacket p2 = new DatagramPacket(response, response.length);
                socket.receive(p2);
                if (p2.getAddress() == null)
                {
                    continue;
                }

                final EISCPMessage msg = convertResponse(response);
                if (msg == null || msg.getParameters() == null)
                {
                    continue;
                }

                if (msg.getParameters().equals("QSTN"))
                {
                    continue;
                }

                final BroadcastResponseMsg responseMessage = new BroadcastResponseMsg(p2.getAddress(), msg);
                if (responseMessage.isValidConnection())
                {
                    publishProgress(responseMessage);
                }
            }
            catch (Exception e)
            {
                // nothing to do
            }
        }
    }

    private void requestDcp(DatagramSocket socket)
    {
        final String host = "239.255.255.250";
        final String schema = "schemas-denon-com:device";
        final String request =
            "M-SEARCH * HTTP/1.1\r\n" +
            "HOST: " + host + ":" + DCP_PORT + "\r\n" +
            "MAN: \"ssdp:discover\"\r\n" +
            "MX: 10\r\n" +
            "ST: urn:" + schema + ":ACT-Denon:1\r\n\r\n";
        final byte[] bytes = request.getBytes();

        try
        {
            final InetAddress target = InetAddress.getByName(host);
            final DatagramPacket p = new DatagramPacket(bytes, bytes.length, target, DCP_PORT);
            socket.send(p);
            Logging.info(this, "message M-SEARCH for category send to " + target + ", wait response for " + TIMEOUT + "ms");
        }
        catch (Exception e)
        {
            Logging.info(BroadcastSearch.this, "  -> can not send request: " + e);
        }

        final long startTime = Calendar.getInstance().getTimeInMillis();
        final byte[] response = new byte[1024];
        while (Calendar.getInstance().getTimeInMillis() < startTime + TIMEOUT)
        {
            if (isStopped())
            {
                break;
            }

            try
            {
                Arrays.fill(response, (byte) 0);
                final DatagramPacket p2 = new DatagramPacket(response, response.length);
                socket.receive(p2);
                if (p2.getAddress() == null || p2.getAddress().getHostAddress() == null)
                {
                    continue;
                }

                final String responseStr = new String(response);
                if (responseStr.contains(schema))
                {
                    Logging.info(this, "M-SEARCH response from " + p2.getAddress() + ": " + schema);
                    final BroadcastResponseMsg responseMessage =
                            new BroadcastResponseMsg(p2.getAddress().getHostAddress(), 23, "Denon-Heos AVR");
                    if (responseMessage.isValidConnection())
                    {
                        publishProgress(responseMessage);
                    }
                }
            }
            catch (Exception e)
            {
                // nothing to do
            }
        }
    }

    @Override
    protected void onProgressUpdate(BroadcastResponseMsg... result)
    {
        if (result == null || result.length == 0)
        {
            return;
        }
        final BroadcastResponseMsg msg = result[0];
        if (eventListener != null)
        {
            eventListener.onDeviceFound(msg);
        }
    }

    @Override
    protected void onPostExecute(Void aVoid)
    {
        super.onPostExecute(aVoid);
        if (failureReason != null)
        {
            Logging.info(this, "Device not found: " + failureReason);
            if (eventListener != null)
            {
                eventListener.noDevice(failureReason);
            }
        }
    }
}
