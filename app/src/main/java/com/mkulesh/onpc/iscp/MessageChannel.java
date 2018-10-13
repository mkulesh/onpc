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
import android.support.v4.app.FragmentActivity;
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

public class MessageChannel extends AsyncTask<Void, Void, Void>
{
    private final static long CONNECTION_TIMEOUT = 5000;
    private final static int QUEUE_SIZE = 4 * 1024;
    private final static int SOCKET_BUFFER = 4 * 1024;

    private final FragmentActivity activity;
    private final AtomicBoolean active = new AtomicBoolean();
    private SocketChannel socket = null;

    private final BlockingQueue<EISCPMessage> outputQueue = new ArrayBlockingQueue<>(QUEUE_SIZE, true);
    private final BlockingQueue<ISCPMessage> inputQueue = new ArrayBlockingQueue<>(QUEUE_SIZE, true);

    private byte[] packetJoinBuffer = null;
    private int messageId = 0;

    public MessageChannel(FragmentActivity activity)
    {
        this.activity = activity;
        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);
    }

    public void stop()
    {
        synchronized (active)
        {
            active.set(false);
        }
        inputQueue.add(new OperationCommandMsg(OperationCommandMsg.Command.DOWN));
    }

    public BlockingQueue<ISCPMessage> getInputQueue()
    {
        return inputQueue;
    }

    @Override
    protected Void doInBackground(Void... params)
    {
        Logging.info(this, "started");

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
                        final ByteBuffer messageBuffer = ByteBuffer.wrap(m.getBytes());
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
        Logging.info(this, "stopped");
        return null;
    }

    public boolean connectToServer(String server, int port)
    {
        final String addr = server + ":" + Integer.toString(port);
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
                    throw new Exception(activity.getResources().getString(R.string.error_connection_timeout));
                }
            }
            Logging.info(this, "connected to " + addr);
            active.set(true);
        }
        catch (Exception e)
        {
            String message = String.format(activity.getResources().getString(R.string.error_connection_failed), addr);
            Logging.info(this, message + ": " + e.getLocalizedMessage());
            Toast.makeText(activity, message, Toast.LENGTH_LONG).show();
            for (StackTraceElement t : e.getStackTrace())
            {
                Logging.info(this, t.toString());
            }
            active.set(false);
        }
        return active.get();
    }

    private void processInputData(ByteBuffer buffer)
    {
        buffer.flip();
        byte[] bytes;

        if (packetJoinBuffer == null)
        {
            // A new buffer - just copy it
            bytes = new byte[buffer.remaining()];
            buffer.get(bytes);
        }
        else
        {
            // Remaining part of existing buffer - join it
            final int s1 = packetJoinBuffer.length;
            final int s2 = buffer.remaining();
            bytes = new byte[s1 + s2];
            System.arraycopy(packetJoinBuffer, 0, bytes, 0, s1);
            buffer.get(bytes, s1, s2);
            packetJoinBuffer = null;
        }

        int remaining = bytes.length;
        while (remaining > 0)
        {
            EISCPMessage raw = null;
            try
            {
                final int startIndex = EISCPMessage.getMsgStartIndex(bytes);
                if (startIndex != 0)
                {
                    Logging.info(this, "unexpected position of start index: " + startIndex);
                }

                final int hSize = EISCPMessage.getHeaderSize(bytes, startIndex);
                final int dSize = EISCPMessage.getDataSize(bytes, startIndex);
                final int expectedSize = hSize + dSize;
                if (expectedSize <= bytes.length)
                {
                    messageId++;
                    raw = new EISCPMessage(messageId, bytes, startIndex, hSize, dSize);
                    remaining = Math.max(0, bytes.length - raw.getMsgSize());
                    inputQueue.add(MessageFactory.create(raw));
                }
                else
                {
                    packetJoinBuffer = bytes;
                    return;
                }
            }
            catch (Exception e)
            {
                Logging.info(this, "Error: " + e.getLocalizedMessage() + ", message: "
                        + (raw != null ? raw.toString() : "null"));
                break;
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

    public void sendMessage(EISCPMessage eiscpMessage)
    {
        outputQueue.add(eiscpMessage);
    }
}
