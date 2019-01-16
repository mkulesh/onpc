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

import android.os.AsyncTask;
import android.os.StrictMode;

import com.mkulesh.onpc.utils.Logging;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.util.Arrays;

public class BroadcastSearch extends AsyncTask<Void, Void, Void>
{
    public final static int ISCP_PORT = 60128;

    private final ConnectionState connectionState;
    private final ConnectionState.StateListener stateListener;
    private final int timeout;
    private final int numberQueries;

    private class Response
    {
        InetAddress deviceAddress;
        EISCPMessage responseMessage;

        Response()
        {
            deviceAddress = null;
            responseMessage = null;
        }
    }

    private final Response retValue = new Response();

    public BroadcastSearch(final ConnectionState connectionState, final ConnectionState.StateListener stateListener,
                           final int timeout, final int numberQueries)
    {
        this.connectionState = connectionState;
        this.stateListener = stateListener;
        this.timeout = timeout;
        this.numberQueries = numberQueries;

        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);
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
            socket.setSoTimeout(timeout);

            for (int i = 0; i < numberQueries; i++)
            {
                if (!connectionState.isNetwork() || !connectionState.isWifi())
                {
                    break;
                }

                try
                {
                    sendMessage(socket, target);
                    if (waitForResponse(socket, retValue))
                    {
                        break;
                    }
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
    protected void onProgressUpdate(Void... result)
    {
        // empty
    }

    @Override
    protected void onPostExecute(Void aVoid)
    {
        super.onPostExecute(aVoid);
        if (stateListener != null)
        {
            if (retValue.deviceAddress != null && retValue.responseMessage != null)
            {
                final String device = retValue.deviceAddress.getHostName() != null ?
                        retValue.deviceAddress.getHostName() : retValue.deviceAddress.getHostAddress();
                Logging.info(BroadcastSearch.this, "Found device: " + device
                        + ":" + retValue.responseMessage.toString());
                stateListener.onDeviceFound(device, ISCP_PORT, retValue.responseMessage);
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

    private boolean waitForResponse(DatagramSocket socket, final Response retValue) throws IOException
    {
        while (true)
        {
            final byte[] response = new byte[512];
            Arrays.fill(response, (byte) 0);
            DatagramPacket p2 = new DatagramPacket(response, response.length);
            socket.receive(p2);

            final EISCPMessage msg = convertResponse(response);
            if (msg == null)
            {
                break;
            }

            if (p2.getAddress() != null && msg.getModelCategoryId() != 'x')
            {
                retValue.deviceAddress = p2.getAddress();
                retValue.responseMessage = msg;
                return true;
            }
        }
        return false;
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

    private void sendMessage(DatagramSocket socket, final InetAddress target) throws IOException
    {
        final EISCPMessage m = new EISCPMessage('x', "ECN", "QSTN");
        final byte[] bytes = m.getBytes();

        DatagramPacket p = new DatagramPacket(bytes, bytes.length, target, ISCP_PORT);
        socket.send(p);
        Logging.info(this, "message send to " + target);
    }
}
