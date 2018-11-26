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
import android.net.DhcpInfo;
import android.net.wifi.WifiManager;
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
    public interface SearchListener
    {
        void onDeviceFound(final String device, final int port, EISCPMessage response);

        void noDevice();
    }

    public final static int ISCP_PORT = 60128;

    private final Context context;
    private final SearchListener searchListener;
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

    public BroadcastSearch(Context context, final SearchListener searchListener,
                           final int timeout, final int numberQueries)
    {
        this.context = context;
        this.searchListener = searchListener;
        this.timeout = timeout;
        this.numberQueries = numberQueries;

        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);
    }

    @Override
    protected Void doInBackground(Void... params)
    {
        Logging.info(this, "started");

        try
        {
            final InetAddress local = InetAddress.getByName("0.0.0.0");
            final InetAddress target = getBroadcastAddress();

            final DatagramSocket socket = new DatagramSocket(ISCP_PORT, local);
            socket.setBroadcast(true);
            socket.setSoTimeout(timeout);

            for (int i = 0; i < numberQueries; i++)
            {
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
        if (searchListener != null)
        {
            if (retValue.deviceAddress != null && retValue.responseMessage != null)
            {
                final String device = retValue.deviceAddress.getHostName() != null ?
                        retValue.deviceAddress.getHostName() : retValue.deviceAddress.getHostAddress();
                Logging.info(BroadcastSearch.this, "Found device: " + device
                        + ":" + retValue.responseMessage.toString());
                searchListener.onDeviceFound(device, ISCP_PORT, retValue.responseMessage);
            }
            else
            {
                Logging.info(BroadcastSearch.this, "search skipped, device not found");
                searchListener.noDevice();
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

    private InetAddress getBroadcastAddress() throws Exception
    {
        final WifiManager wifi = (WifiManager) context.getApplicationContext().getSystemService(Context.WIFI_SERVICE);
        final DhcpInfo dhcp = wifi.getDhcpInfo();
        if (dhcp == null)
        {
            throw new Exception("can not access DHCP");
        }
        int broadcast = (dhcp.ipAddress & dhcp.netmask) | ~dhcp.netmask;
        byte[] quads = new byte[4];
        for (int k = 0; k < 4; k++)
        {
            quads[k] = (byte) ((broadcast >> k * 8) & 0xFF);
        }
        return InetAddress.getByAddress(quads);
    }
}
