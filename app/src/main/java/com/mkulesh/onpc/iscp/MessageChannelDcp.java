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

import android.os.StrictMode;
import android.widget.Toast;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.messages.DcpReceiverInformationMsg;
import com.mkulesh.onpc.iscp.messages.OperationCommandMsg;
import com.mkulesh.onpc.utils.AppTask;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.URL;
import java.nio.ByteBuffer;
import java.nio.channels.SocketChannel;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.atomic.AtomicBoolean;

import androidx.annotation.NonNull;

public class MessageChannelDcp extends AppTask implements Runnable, MessageChannel
{
    private final static long CONNECTION_TIMEOUT = 5000;
    private final static int SOCKET_BUFFER = 4 * 1024;
    private final static String DCP_GOFORM_PORT = "8080"; // goform protocol port

    // thread implementation
    private final AtomicBoolean threadCancelled = new AtomicBoolean();

    // connection state
    private final int zone;
    private final ConnectionState connectionState;
    private SocketChannel socket = null;

    // connected host (ConnectionIf)
    private String host = ConnectionIf.EMPTY_HOST;
    private int port = ConnectionIf.EMPTY_PORT;

    // input-output queues
    private final BlockingQueue<EISCPMessage> outputQueue = new ArrayBlockingQueue<>(QUEUE_SIZE, true);
    private final BlockingQueue<ISCPMessage> inputQueue;

    // message handling
    private byte[] packetJoinBuffer = null;
    private final DCPMessage dcpMessage = new DCPMessage();

    MessageChannelDcp(final int zone, final ConnectionState connectionState, final BlockingQueue<ISCPMessage> inputQueue)
    {
        super(false);
        this.zone = zone;
        this.connectionState = connectionState;
        this.inputQueue = inputQueue;
        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);
    }

    public void start()
    {
        if (isActive())
        {
            return;
        }
        super.start();
        final Thread thread = new Thread(this, this.getClass().getSimpleName());
        threadCancelled.set(false);
        thread.start();
    }

    public void stop()
    {
        synchronized (threadCancelled)
        {
            threadCancelled.set(true);
        }
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

    @Override
    public void addAllowedMessage(final String code)
    {
        // nothing to do
    }

    @Override
    public Utils.ProtoType getProtoType()
    {
        return Utils.ProtoType.DCP;
    }

    @Override
    public void run()
    {
        Logging.info(this, "started " + getHostAndPort() + ":" + this);

        ByteBuffer buffer = ByteBuffer.allocate(SOCKET_BUFFER);
        Long lastSendTime = null;
        final long DCP_SEND_DELAY = 75; // Send the COMMAND in 50ms or more intervals.
        final ArrayList<byte[]> dcpOutputBuffer = new ArrayList<>();
        if (getProtoType() == Utils.ProtoType.DCP)
        {
            dcpMessage.prepare(zone);
        }

        while (true)
        {
            try
            {
                synchronized (threadCancelled)
                {
                    if (threadCancelled.get())
                    {
                        Logging.info(this, "cancelled " + getHostAndPort());
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
                    Logging.info(this, "host " + getHostAndPort() + " disconnected");
                    break;
                }
                else if (readedSize > 0)
                {
                    try
                    {
                        processInputData(buffer);
                    }
                    catch (Exception e)
                    {
                        Logging.info(this, "error: process input data: " + e.getLocalizedMessage());
                        break;
                    }
                }

                // process output messages
                // DCP documentation: Send the COMMAND in 50ms or more intervals.
                long currTime = Calendar.getInstance().getTimeInMillis();
                if (lastSendTime == null || currTime - lastSendTime >= DCP_SEND_DELAY)
                {
                    if (!dcpOutputBuffer.isEmpty())
                    {
                        final byte[] bytes = dcpOutputBuffer.remove(0);
                        final String rawCmd = new String(bytes);
                        if (rawCmd.startsWith("formiPhoneApp"))
                        {
                            sendDcpGoformRequest(rawCmd);
                        }
                        else
                        {
                            final ByteBuffer messageBuffer = ByteBuffer.wrap(bytes);
                            socket.write(messageBuffer);
                        }
                        lastSendTime = currTime;
                    }
                    else
                    {
                        final EISCPMessage m = outputQueue.poll();
                        dcpOutputBuffer.addAll(dcpMessage.convertOutputMsg(m, getHostAndPort()));
                    }
                }
            }
            catch (Exception e)
            {
                Logging.info(this, "interrupted " + getHostAndPort() + ": " + e.getLocalizedMessage());
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
        super.stop();
        Logging.info(this, "stopped " + getHostAndPort() + ":" + this);
        inputQueue.add(new OperationCommandMsg(OperationCommandMsg.Command.DOWN));
    }

    private void sendDcpGoformRequest(final String rawCmd)
    {
        final String shortCmd = rawCmd.replace(" ", "%20");
        try
        {
            final String fullCmd = ISCPMessage.getDcpGoformUrl(host, DCP_GOFORM_PORT, shortCmd);
            Logging.info(this, "DCP GOFORM request: " + fullCmd);
            Utils.getUrlData(new URL(fullCmd), false);
        }
        catch (Exception ex)
        {
            Logging.info(this, "DCP GOFORM err: " + ex.getLocalizedMessage());
        }
    }

    @Override
    public boolean connectToServer(@NonNull String host, int port)
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
            String message = String.format(connectionState.getContext().getResources().getString(
                    R.string.error_connection_no_response), getHostAndPort());
            Logging.info(this, message + ": " + e.getLocalizedMessage());
            for (StackTraceElement t : e.getStackTrace())
            {
                Logging.info(this, t.toString());
            }

            try
            {
                // An exception is possible here:
                // Can't toast on a thread that has not called Looper.prepare()
                Toast.makeText(connectionState.getContext(), message, Toast.LENGTH_LONG).show();
            }
            catch (Exception e1)
            {
                // nothing to do
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
            remaining = processDcpData(bytes);
            if (remaining < 0)
            {
                // An error, nothing to process
                return;
            }

            if (remaining > 0)
            {
                bytes = Utils.catBuffer(bytes, bytes.length - remaining, remaining);
            }
        }
    }

    private int processDcpData(byte[] bytes)
    {
        int expectedSize = -1;
        for (int i = 0; i < bytes.length; i++)
        {
            if (bytes[i] == DCPMessage.CR)
            {
                expectedSize = i;
                break;
            }
        }
        if (expectedSize <= 0)
        {
            final String logMsg = new String(bytes, Utils.UTF_8);
            Logging.info(this, "<< DCP warning: end of message not found: " + logMsg);
            if (logMsg.startsWith(DcpReceiverInformationMsg.DCP_COMMAND_PRESET))
            {
                // A corner case: OPTPN has some time no end of message symbol
                expectedSize = logMsg.length();
            }
            else
            {
                packetJoinBuffer = bytes;
                return -1;
            }
        }

        final byte[] stringBytes = expectedSize + 1 == bytes.length ?
                bytes : Utils.catBuffer(bytes, 0, expectedSize);

        final String dcpMsg = new String(stringBytes, Utils.UTF_8).trim();
        final int remaining = Math.max(0, bytes.length - expectedSize - 1);

        final ArrayList<ISCPMessage> messages = dcpMessage.convertInputMsg(dcpMsg);

        Logging.info(this, "<< new DCP message " + dcpMsg
                + " from " + getHostAndPort()
                + ", size=" + dcpMsg.length()
                + "B, remaining=" + remaining + "B"
                + (messages.isEmpty() ? " -> Ignored" :
                    ( " -> " + (messages.size() == 1 ? messages.get(0) : messages.size() + "msg"))));

        for (ISCPMessage m : messages)
        {
            m.setHostAndPort(this);
            inputQueue.add(m);
        }
        return remaining;
    }

    @Override
    public void sendMessage(EISCPMessage eiscpMessage)
    {
        outputQueue.add(eiscpMessage);
    }
}
