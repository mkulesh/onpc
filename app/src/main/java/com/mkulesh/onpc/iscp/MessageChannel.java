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
import android.widget.Toast;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.messages.MessageFactory;
import com.mkulesh.onpc.iscp.messages.OperationCommandMsg;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.SocketChannel;
import java.util.Calendar;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.atomic.AtomicBoolean;

class MessageChannel extends AsyncTask<Void, Void, Void>
{
    private final static long NETWORK_TIMEOUT = 1000;
    private final static long CONNECTION_TIMEOUT = 5000;
    private final static int QUEUE_SIZE = 4 * 1024;
    private final static int SOCKET_BUFFER = 4 * 1024;

    private final ConnectionState connectionState;
    private final AtomicBoolean active = new AtomicBoolean();
    private SocketChannel socket = null;

    private final BlockingQueue<EISCPMessage> outputQueue = new ArrayBlockingQueue<>(QUEUE_SIZE, true);
    private final BlockingQueue<ISCPMessage> inputQueue = new ArrayBlockingQueue<>(QUEUE_SIZE, true);

    private byte[] packetJoinBuffer = null;
    private int messageId = 0;

    MessageChannel(final ConnectionState connectionState)
    {
        this.connectionState = connectionState;
        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);
    }

    public void stop()
    {
        synchronized (active)
        {
            active.set(false);
        }
    }

    boolean isActive()
    {
        return active.get();
    }

    BlockingQueue<ISCPMessage> getInputQueue()
    {
        return inputQueue;
    }

    @Override
    protected Void doInBackground(Void... params)
    {
        Logging.info(this, "started: " + toString());

        ByteBuffer buffer = ByteBuffer.allocate(SOCKET_BUFFER);
        while (true)
        {
            try
            {
                synchronized (active)
                {
                    if (!active.get() || isCancelled())
                    {
                        Logging.info(this, "cancelled");
                        break;
                    }
                }

                if (!connectionState.isNetwork())
                {
                    Logging.info(this, "no network");
                    break;
                }

                // process input messages
                buffer.clear();
                int readedSize = socket.read(buffer);
                if (readedSize < 0)
                {
                    Logging.info(this, "server disconnected");
                    break;
                }
                else if (readedSize > 0)
                {
                    processInputData(buffer);
                }

                // process output messages
                EISCPMessage m = outputQueue.poll();
                if (m != null)
                {
                    final byte[] bytes = m.getBytes();
                    if (bytes != null)
                    {
                        final ByteBuffer messageBuffer = ByteBuffer.wrap(bytes);
                        Logging.info(this, ">> sending: " + m.toString());
                        socket.write(messageBuffer);
                    }
                }
            }
            catch (Exception e)
            {
                Logging.info(this, "interrupted: " + e.getLocalizedMessage());
                break;
            }
        }

        try
        {
            socket.close();
        }
        catch (IOException e)
        {
            // nothing to do
        }
        synchronized (active)
        {
            active.set(false);
        }
        Logging.info(this, "stopped: " + toString());
        inputQueue.add(new OperationCommandMsg(OperationCommandMsg.Command.DOWN));
        return null;
    }

    boolean connectToServer(String server, int port)
    {
        final String addr = server + ":" + Integer.toString(port);
        active.set(false);

        if (!waitForNetwork())
        {
            connectionState.showFailure(ConnectionState.FailureReason.NO_NETWORK);
            return active.get();
        }

        try
        {
            socket = SocketChannel.open();
            socket.configureBlocking(false);
            socket.connect(new InetSocketAddress(server, port));
            final long startTime = Calendar.getInstance().getTimeInMillis();
            while (!socket.finishConnect())
            {
                final long currTime = Calendar.getInstance().getTimeInMillis();
                if (currTime > startTime + CONNECTION_TIMEOUT)
                {
                    throw new Exception("connection timeout");
                }
            }
            Logging.info(this, "connected to " + addr);
            active.set(true);
        }
        catch (Exception e)
        {
            String message = String.format(connectionState.getContext().getResources().getString(
                    R.string.error_connection_no_response), addr);
            Logging.info(this, message + ": " + e.getLocalizedMessage());
            Toast.makeText(connectionState.getContext(), message, Toast.LENGTH_LONG).show();
            for (StackTraceElement t : e.getStackTrace())
            {
                Logging.info(this, t.toString());
            }
        }
        return active.get();
    }

    private boolean waitForNetwork()
    {
        long startTime = System.currentTimeMillis();
        while (true)
        {
            if (connectionState.isNetwork())
            {
                return true;
            }
            long currTime = System.currentTimeMillis();
            if (currTime - startTime > NETWORK_TIMEOUT)
            {
                Logging.info(this, "timeout for network connection: " + NETWORK_TIMEOUT + "ms");
                break;
            }
        }
        return false;
    }

    private void processInputData(ByteBuffer buffer)
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

        int remaining = bytes.length;
        while (remaining > 0)
        {
            final int startIndex = EISCPMessage.getMsgStartIndex(bytes);
            if (startIndex != 0)
            {
                Logging.info(this, "<< error: unexpected position of message start: " + startIndex + ", remaining=" + remaining + "B");
            }

            // convert header and data sizes
            int hSize, dSize;
            try
            {
                hSize = EISCPMessage.getHeaderSize(bytes, startIndex);
                dSize = EISCPMessage.getDataSize(bytes, startIndex);
            }
            catch (Exception e)
            {
                Logging.info(this, "<< error: invalid expected size: " + e.getLocalizedMessage());
                packetJoinBuffer = null;
                return;
            }

            // inspect expected size
            final int expectedSize = hSize + dSize;
            if (hSize < 0 || dSize < 0 || expectedSize > remaining)
            {
                packetJoinBuffer = bytes;
                return;
            }

            // try to convert raw message. In case of any errors, skip expectedSize
            EISCPMessage raw = null;
            try
            {
                messageId++;
                raw = new EISCPMessage(messageId, bytes, startIndex, hSize, dSize);
            }
            catch (Exception e)
            {
                remaining = Math.max(0, bytes.length - expectedSize);
                Logging.info(this, "<< error: invalid raw message: " + e.getLocalizedMessage() + ", remaining=" + remaining + "B");
            }

            if (raw != null)
            {
                remaining = Math.max(0, bytes.length - raw.getMsgSize());
                try
                {
                    if (!"NTM".equals(raw.getCode()))
                    {
                        Logging.info(this, "<< new message " + raw.getCode() + ", size=" + raw.getMsgSize() + "B, remaining=" + remaining + "B");
                    }
                    inputQueue.add(MessageFactory.create(raw));
                }
                catch (Exception e)
                {
                    Logging.info(this, "<< error: ignored: " + e.getLocalizedMessage() + ": " + raw.toString());
                }
            }

            if (remaining > 0)
            {
                bytes = Utils.catBuffer(bytes, bytes.length - remaining, remaining);
            }
        }
    }

    @Override
    protected void onProgressUpdate(Void... result)
    {
        // empty
    }

    void sendMessage(EISCPMessage eiscpMessage)
    {
        outputQueue.add(eiscpMessage);
    }
}
