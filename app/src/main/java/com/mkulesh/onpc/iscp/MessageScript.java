package com.mkulesh.onpc.iscp;

import android.content.Intent;

import com.mkulesh.onpc.iscp.messages.ReceiverInformationMsg;
import com.mkulesh.onpc.utils.Utils;

import java.util.ArrayList;
import java.util.List;

import androidx.annotation.NonNull;

public class MessageScript implements ConnectionIf
{
    enum ActionType
    {
        CMD,
        WAIT
    }

    class Action
    {
        // action type
        final ActionType actionType;

        // command used for actions CMD and WAIT
        final String cmd;

        // parameter used for actions CMD and WAIT. Empty string means no parameter is used.
        final String par;

        // Delay in milliseconds used for action WAIT. Zero means no delay.
        final int milliseconds;

        Action (ActionType actionType, String cmd, String par, final int milliseconds)
        {
            this.actionType = actionType;
            this.cmd = cmd;
            this.par = par;
            this.milliseconds = milliseconds;
        }
    }

    // optional connected host (ConnectionIf)
    private String host = ConnectionIf.EMPTY_HOST;
    private int port = ConnectionIf.EMPTY_PORT;

    // optional target zone
    private int zone = ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE;

    // Actions to be performed
    private final List<Action> actions = new ArrayList<>();

    public void initialize(@NonNull final Intent intent)
    {
        // This method shall parse the data field in the input intent
        // How to parse XML, see method ReceiverInformationMsg.parseXml
        // After XML is parsed, the method fills attributes host, port, and zone, if the
        // input XML contains this information.
        // After it, the method fills a list of available action. This list contains
        // elements of type "Action" that is defined within this class.
        // Example also see in the method ReceiverInformationMsg.parseXml
        // If the list of actions is not empty, the MessageScript is valid and these
        // actions will be performed after the connection is established.
        // The way how the script is performed (asynchronously in a separate thread or
        // synchronously) shall be defined later.
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
}
