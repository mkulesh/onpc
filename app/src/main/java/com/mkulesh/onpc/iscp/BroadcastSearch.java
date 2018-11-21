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
import android.os.StrictMode;

import com.mkulesh.onpc.utils.Logging;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.SocketException;
import java.util.Arrays;

public class BroadcastSearch
{
    private final static int ISCP_PORT = 60128;

    private final Context context;
    private final InetAddress local;
    private final InetAddress target;
    private EISCPMessage responseMsg = null;
    private InetAddress responseAddr = null;

    public BroadcastSearch(Context context) throws Exception
    {
        this.context = context;

        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);

        local = InetAddress.getByName("0.0.0.0");
        target = getBroadcastAddress();
    }

    public void searchDevice() throws SocketException
    {
        final DatagramSocket socket = new DatagramSocket(ISCP_PORT, local);

        try
        {
            socket.setBroadcast(true);
            socket.setSoTimeout(5000);

            new Thread(new Runnable()
            {
                public void run()
                {
                    while (true)
                    {
                        try
                        {
                            responseMsg = null;
                            responseAddr = null;
                            sendMessage(socket);
                            waitForResponse(socket);
                            if (responseMsg != null && responseAddr != null)
                            {
                                Logging.info(this, "received response from: " + responseAddr.getHostAddress() + ":" + responseMsg.toString());
                                socket.close();
                                break;
                            }
                        }
                        catch (Exception e)
                        {
                            Logging.info(this, "Can not receive response: " + e.toString());
                        }
                    }
                }
            }).start();
        }
        catch (Exception e)
        {
            Logging.info(this, "Can not send broadcast: " + e.toString());
        }
    }

    private void waitForResponse(DatagramSocket socket) throws IOException
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

            if (msg.getModelCategoryId() != 'x')
            {
                responseMsg = msg;
                responseAddr = p2.getAddress();
                break;
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

    private void sendMessage(DatagramSocket socket) throws IOException
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
