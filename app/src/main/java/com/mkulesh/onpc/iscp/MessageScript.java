package com.mkulesh.onpc.iscp;

import android.content.Intent;

import com.mkulesh.onpc.iscp.messages.ReceiverInformationMsg;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.List;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import androidx.annotation.NonNull;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

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

        public String toString() {
            String s = "Action:";
            if (actionType == ActionType.CMD)
            {
                s += "CMD";
            }
            else if(actionType == ActionType.WAIT)
            {
                s += "WAIT";
            }
            s += ","+cmd+","+par+","+milliseconds;
            return s;
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
        Logging.info( this, intent.getDataString());
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

        final String data = intent.getDataString();
        if (data == null || data.isEmpty())
        {
            Logging.info(this, "intent data parameter empty: no script to parse");
            return;
        }

        try
        {
            InputStream stream = new ByteArrayInputStream(data.getBytes(Charset.forName("UTF-8")));
            final DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            final DocumentBuilder builder = factory.newDocumentBuilder();
            final Document doc = builder.parse(stream);
            Node object = doc.getDocumentElement();
            if (object instanceof Element)
            {
                final Element elem = (Element) object;
                if (elem.getTagName().equals("onpcScript"))
                {
                    Logging.info(this, "found onpcScript element");
                    if (elem.getAttribute("host") != null)
                    {
                        host = elem.getAttribute(("host"));
                    }
                    if (elem.getAttribute("port") != null)
                    {
                        host = elem.getAttribute(("port"));
                    }
                    if (elem.getAttribute("zone") != null)
                    {
                        host = elem.getAttribute(("zone"));
                    }
                }
                for (Node prop = elem.getFirstChild(); prop != null; prop = prop.getNextSibling())
                {
                    if (prop instanceof Element)
                    {
                        final Element action = (Element) prop;
                        if (action.getTagName().equals("send")) {
                            final String cmd = action.getAttribute("cmd");
                            if (cmd == null) {
                                // TODO - raise to user
                                Logging.info(this, "send command missing 'cmd' element");
                                return;
                            }
                            actions.add(new Action(ActionType.CMD, cmd,
                                    action.getAttribute("par"), 0));
                        } else if (action.getTagName().equals("wait")) {
                            final String response = action.getAttribute("response");
                            if (response == null) {
                                // TODO raise to user
                                Logging.info(this, "wait command missing 'response' element");
                                return;
                            }
                            int milliseconds = 0;
                            String cmd = "";
                            try {
                                milliseconds = Integer.parseInt(response);
                            } catch (NumberFormatException e) {
                                cmd = response;
                            }
                            actions.add(new Action(ActionType.WAIT, cmd,
                                    action.getAttribute("par"), milliseconds));
                        }
                    }
                }
            }
        }
        catch (Exception e)
        {
            // TODO - raise this to the user's attention - they stuffed up and they'd probably like to know
            Logging.info(this, "Failed to parse onpcScript pass in intent: " + e.getLocalizedMessage());
        }
        for (Action a : actions)
        {
            Logging.info(this, a.toString());
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
}
