/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2025 by Mikhail Kulesh
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

import com.jayway.jsonpath.JsonPath;
import com.mkulesh.onpc.iscp.messages.DCPMessageFactory;
import com.mkulesh.onpc.iscp.messages.DcpReceiverInformationMsg;
import com.mkulesh.onpc.iscp.messages.OperationCommandMsg;
import com.mkulesh.onpc.iscp.messages.TimeInfoMsg;
import com.mkulesh.onpc.utils.AppTask;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.io.IOException;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Map;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.atomic.AtomicBoolean;

import androidx.annotation.NonNull;

public class MessageChannelDcp extends AppTask implements Runnable, MessageChannel
{
    private final static String DCP_FORM_IPHONE_APP = "formiPhoneApp";
    private final static String DCP_APP_COMMAND1 = "<cmd id=\"1\">";
    private final static String DCP_APP_COMMAND3 = "<cmd id=\"3\">";

    private final static String DCP_HEOS_REQUEST = "heos://";
    public final static String DCP_HEOS_RESPONSE = "{\"heos\":";

    private final static int CR = 0x0D;
    private final static int LF = 0x0A;

    // thread implementation
    private final AtomicBoolean threadCancelled = new AtomicBoolean();

    // connection state
    private final ConnectionState connectionState;
    private final OnpcSocket dcpSocket = new OnpcSocket();
    private final OnpcSocket heosSocket = new OnpcSocket(); // HEOS connection is optional

    // input-output queues
    private final BlockingQueue<EISCPMessage> outputQueue = new ArrayBlockingQueue<>(QUEUE_SIZE, true);
    private final BlockingQueue<ISCPMessage> inputQueue;

    // message handling
    private final DCPMessageFactory dcpMessageFactory = new DCPMessageFactory();
    private Integer heosPid = null;

    MessageChannelDcp(final int zone, final ConnectionState connectionState, final BlockingQueue<ISCPMessage> inputQueue)
    {
        super(false);
        this.connectionState = connectionState;
        this.inputQueue = inputQueue;
        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);
        dcpMessageFactory.prepare(zone);
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
        return dcpSocket.getHost();
    }

    @Override
    public int getPort()
    {
        return dcpSocket.getPort();
    }

    @NonNull
    @Override
    public String getHostAndPort()
    {
        return dcpSocket.getHostAndPort();
    }

    @Override
    public void addAllowedMessage(final String code)
    {
        // nothing to do
    }

    @Override
    public ProtoType getProtoType()
    {
        return ConnectionIf.ProtoType.DCP;
    }

    @Override
    public void run()
    {
        Logging.info(this, "started " + getHostAndPort() + ":" + this);

        // Output data processing
        Long lastSendTime = null;
        final long DCP_SEND_DELAY = 75; // Send the COMMAND in 50ms or more intervals.
        final ArrayList<String> dcpOutputBuffer = new ArrayList<>();

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

                // process DCP input messages
                if (dcpSocket.readData((ByteBuffer b) -> processInputData(b, dcpSocket)) < 0)
                {
                    break;
                }

                // process HEOS input messages
                if (heosSocket.getSocket() != null)
                {
                    if (heosSocket.readData((ByteBuffer b) -> processInputData(b, heosSocket)) < 0)
                    {
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
                        final String rawCmd = dcpOutputBuffer.remove(0);
                        if (rawCmd.startsWith(DCP_FORM_IPHONE_APP))
                        {
                            sendDcpFormIphoneApp(rawCmd);
                        }
                        else if (rawCmd.startsWith(DCP_APP_COMMAND1))
                        {
                            sendDcpAppCommand(rawCmd, "AppCommand.xml");
                        }
                        else if (rawCmd.startsWith(DCP_APP_COMMAND3))
                        {
                            sendDcpAppCommand(rawCmd, "AppCommand0300.xml");
                        }
                        else if (rawCmd.startsWith(DCP_HEOS_REQUEST))
                        {
                            sendDcpHeosRequest(rawCmd);
                        }
                        else
                        {
                            sendDcpRawMsg(rawCmd);
                        }
                        lastSendTime = currTime;
                    }
                    else
                    {
                        final EISCPMessage m = outputQueue.poll();
                        dcpOutputBuffer.addAll(dcpMessageFactory.convertOutputMsg(m, getHost()));
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
            dcpSocket.close();
            heosSocket.close();
        }
        catch (IOException e)
        {
            // nothing to do
        }
        super.stop();
        Logging.info(this, "stopped " + getHostAndPort() + ":" + this);
        inputQueue.add(new OperationCommandMsg(OperationCommandMsg.Command.DOWN));
    }

    private void sendDcpFormIphoneApp(final String rawCmd)
    {
        final String shortCmd = rawCmd.replace(" ", "%20");
        try
        {
            final String fullCmd = ISCPMessage.getDcpGoformUrl(getHost(), DCP_HTTP_PORT, shortCmd);
            Logging.info(this, "DCP formiPhoneApp request: " + fullCmd);
            Utils.getUrlData(new URL(fullCmd), false);
        }
        catch (Exception ex)
        {
            Logging.info(this, "DCP formiPhoneApp error: " + ex.getLocalizedMessage());
        }
    }

    private void sendDcpAppCommand(final String rawCmd, final String endpoint)
    {
        try
        {
            final String json = "{\"body\": \"" + ISCPMessage.getDcpAppCommand(rawCmd) + "\"}";
            final byte[] out = json.getBytes(Utils.UTF_8);

            final URL url = new URL(ISCPMessage.getDcpGoformUrl(getHost(), DCP_HTTP_PORT, endpoint));
            final URLConnection con = url.openConnection();
            final HttpURLConnection http = (HttpURLConnection) con;
            http.setRequestMethod("POST");
            http.setDoOutput(true);
            http.setFixedLengthStreamingMode(out.length);
            http.setRequestProperty("Content-Type", "text/xml; charset=UTF-8");
            http.connect();
            OutputStream os = http.getOutputStream();
            os.write(out);
            os.flush();
            Logging.info(this, "DCP AppCommand POST request: " + url + json);
        }
        catch (Exception ex)
        {
            Logging.info(this, "DCP AppCommand error: " + ex.getLocalizedMessage());
        }
    }

    private void sendDcpHeosRequest(@NonNull String msg)
    {
        if (heosSocket.getSocket() == null)
        {
            return;
        }
        if (msg.contains(ISCPMessage.DCP_HEOS_PID))
        {
            if (heosPid == null)
            {
                return;
            }
            msg = msg.replace(ISCPMessage.DCP_HEOS_PID, Integer.toString(heosPid));
        }
        try
        {
            Logging.info(this, ">> DCP HEOS sending: " + msg + " to " + heosSocket.getHostAndPort());
            byte[] msgBin = msg.getBytes(Utils.UTF_8);
            final byte[] bytes = new byte[msgBin.length + 2];
            System.arraycopy(msgBin, 0, bytes, 0, msgBin.length);
            bytes[msgBin.length] = (byte) CR;
            bytes[msgBin.length + 1] = (byte) LF;
            heosSocket.getSocket().write(ByteBuffer.wrap(bytes));
        }
        catch (Exception ex)
        {
            Logging.info(this, "DCP HEOS error: " + ex.getLocalizedMessage());
        }
    }

    private void sendDcpRawMsg(String msg)
    {
        try
        {
            byte[] msgBin = msg.getBytes(Utils.UTF_8);
            final byte[] bytes = new byte[msgBin.length + 1];
            System.arraycopy(msgBin, 0, bytes, 0, msgBin.length);
            bytes[msgBin.length] = (byte) CR;
            dcpSocket.getSocket().write(ByteBuffer.wrap(bytes));
        }
        catch (Exception ex)
        {
            Logging.info(this, "DCP error: " + ex.getLocalizedMessage());
        }
    }

    @Override
    public boolean connectToServer(@NonNull String host, int port)
    {
        // Optional connection to HEOS port
        if (heosSocket.open(host, DCP_HEOS_PORT, connectionState.getContext(), false))
        {
            sendDcpHeosRequest("heos://player/get_players");
        }
        // Mandatory connection to AVR port
        return dcpSocket.open(host, port, connectionState.getContext(), true);
    }

    private void processInputData(ByteBuffer buffer, @NonNull final OnpcSocket socket)
    {
        byte[] bytes = socket.joinBuffer(buffer);
        int remaining = bytes.length;
        while (remaining > 0)
        {
            remaining = processDcpData(bytes, socket);
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

    private int processDcpData(byte[] bytes, @NonNull final OnpcSocket onpcSocket)
    {
        int expectedSize = -1;
        for (int i = 0; i < bytes.length; i++)
        {
            if (bytes[i] == CR)
            {
                expectedSize = i;
                break;
            }
        }
        if (expectedSize <= 0)
        {
            final String logMsg = new String(bytes, Utils.UTF_8);
            if (logMsg.startsWith(DcpReceiverInformationMsg.DCP_COMMAND_PRESET))
            {
                // A corner case: OPTPN has some time no end of message symbol
                Logging.info(this, "<< DCP warning: end of message not found: " + logMsg);
                expectedSize = logMsg.length();
            }
            else
            {
                onpcSocket.setBuffer(bytes);
                return -1;
            }
        }

        if (expectedSize + 1 < bytes.length &&
                bytes[expectedSize] == CR &&
                bytes[expectedSize + 1] == LF)
        {
            // Consider possible LF after CR
            expectedSize++;
        }

        final byte[] stringBytes = expectedSize + 1 == bytes.length ?
                bytes : Utils.catBuffer(bytes, 0, expectedSize);

        final String dcpMsg = new String(stringBytes, Utils.UTF_8).trim();
        final int remaining = Math.max(0, bytes.length - expectedSize - 1);

        boolean processed = false;
        if (dcpMsg.startsWith(DCP_HEOS_RESPONSE))
        {
            processed = processHeosMsg(dcpMsg);
        }

        final ArrayList<ISCPMessage> messages = dcpMessageFactory.convertInputMsg(dcpMsg, heosPid);
        final boolean logIgnored = messages.size() == 1 && messages.get(0) instanceof TimeInfoMsg;

        if (!logIgnored)
        {
            final String resStr = processed ? " -> Processed" :
                    (messages.isEmpty() ? " -> Ignored" :
                            (messages.size() == 1 ? " -> " + messages.get(0) :
                                    " -> " + messages.size() + "msg"));
            Logging.info(this, "<< new DCP message " + dcpMsg
                    + " from " + onpcSocket.getHostAndPort()
                    + ", size=" + dcpMsg.length()
                    + "B, remaining=" + remaining + "B"
                    + resStr);
        }

        for (ISCPMessage m : messages)
        {
            m.setHostAndPort(this);
            inputQueue.add(m);
        }
        return remaining;
    }

    private boolean processHeosMsg(String heosMsg)
    {
        try
        {
            final String cmd = JsonPath.read(heosMsg, "$.heos.command");
            // Device PID
            if (heosPid == null)
            {
                if ("player/get_players".equals(cmd))
                {
                    heosPid = JsonPath.read(heosMsg, "$.payload[0].pid");
                    Logging.info(this, "DCP HEOS PID received: " + heosPid);
                    return true;
                }
            }
            // Events
            if (heosPid != null && "event/player_now_playing_changed".equals(cmd))
            {
                final Map<String, String> tokens =
                        ISCPMessage.parseHeosMessage(JsonPath.read(heosMsg, "$.heos.message"));
                final String pidStr = tokens.get("pid");
                if (pidStr != null && heosPid.equals(Integer.valueOf(pidStr)))
                {
                    sendDcpHeosRequest("heos://player/get_now_playing_media?pid=" + heosPid);
                    return true;
                }
            }
        }
        catch (Exception ex)
        {
            Logging.info(this, "DCP HEOS error: " + ex.getLocalizedMessage());
        }
        return false;
    }

    @Override
    public void sendMessage(EISCPMessage eiscpMessage)
    {
        outputQueue.add(eiscpMessage);
    }
}
