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

package com.mkulesh.onpc.iscp;

import android.content.Context;
import android.widget.Toast;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.SocketChannel;
import java.util.Calendar;

import androidx.annotation.NonNull;

public class OnpcSocket implements ConnectionIf
{
    private final static long CONNECTION_TIMEOUT = 5000;
    private final static int SOCKET_BUFFER = 4 * 1024;

    // connected host (ConnectionIf)
    private String host = ConnectionIf.EMPTY_HOST;
    private int port = ConnectionIf.EMPTY_PORT;

    // Socket handling
    private SocketChannel socket = null;

    // data handling
    private byte[] packetJoinBuffer = null;
    private final ByteBuffer rawBuffer = ByteBuffer.allocate(SOCKET_BUFFER);

    public interface DataListener
    {
        void onData(ByteBuffer buffer);
    }

    @NonNull
    @Override
    public String getHost()
    {
        return host;
    }

    @Override
    public int getPort()
    {
        return port;
    }

    @NonNull
    @Override
    public String getHostAndPort()
    {
        return Utils.ipToString(host, port);
    }

    public SocketChannel getSocket()
    {
        return socket;
    }

    public boolean open(String host, int port, final Context context, boolean showInfo)
    {
        this.host = host;
        this.port = port;
        try
        {
            socket = SocketChannel.open();
            socket.configureBlocking(false);
            socket.connect(new InetSocketAddress(host, port));
            final long startTime = Calendar.getInstance().getTimeInMillis();
            while (!socket.finishConnect())
            {
                final long currTime = Calendar.getInstance().getTimeInMillis();
                if (currTime > startTime + CONNECTION_TIMEOUT)
                {
                    throw new Exception("connection timeout");
                }
            }
            if (socket.socket().getInetAddress() != null
                    && socket.socket().getInetAddress().getHostAddress() != null)
            {
                this.host = socket.socket().getInetAddress().getHostAddress();
            }
            Logging.info(this, "connected to " + getHostAndPort());
            return true;
        }
        catch (Exception e)
        {
            String message = String.format(context.getResources().getString(
                    R.string.error_connection_no_response), getHostAndPort());
            Logging.info(this, message + ": " + e.getLocalizedMessage());
            if (showInfo)
            {
                for (StackTraceElement t : e.getStackTrace())
                {
                    Logging.info(this, t.toString());
                }
            }

            try
            {
                // An exception is possible here:
                // Can't toast on a thread that has not called Looper.prepare()
                if (showInfo)
                {
                    Toast.makeText(context, message, Toast.LENGTH_LONG).show();
                }
            }
            catch (Exception e1)
            {
                // nothing to do
            }
        }
        socket = null;
        return false;
    }

    public void close() throws IOException
    {
        if (socket != null)
        {
            socket.close();
        }
    }

    public int readData(@NonNull DataListener dataListener) throws IOException
    {
        rawBuffer.clear();
        final int readSize = socket.read(rawBuffer);
        if (readSize < 0)
        {
            Logging.info(this, "host " + getHostAndPort() + " disconnected");
            return readSize;
        }
        else if (readSize > 0)
        {
            try
            {
                dataListener.onData(rawBuffer);
            }
            catch (Exception e)
            {
                Logging.info(this, "error: process input data: " + e.getLocalizedMessage());
                return -1;
            }
        }
        return readSize;
    }

    public byte[] joinBuffer(ByteBuffer buffer)
    {
        buffer.flip();
        final int incoming = buffer.remaining();
        byte[] bytes;

        if (packetJoinBuffer == null)
        {
            // A new buffer - just copy it
            bytes = new byte[incoming];
            buffer.get(bytes);
        }
        else
        {
            // Remaining part of existing buffer - join it
            final int s1 = packetJoinBuffer.length;
            bytes = new byte[s1 + incoming];
            System.arraycopy(packetJoinBuffer, 0, bytes, 0, s1);
            buffer.get(bytes, s1, incoming);
            packetJoinBuffer = null;
        }
        return bytes;
    }

    public void setBuffer(byte[] bytes)
    {
        packetJoinBuffer = bytes;
    }
}
