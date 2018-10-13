package com.mkulesh.onpc.iscp.messages;

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

/*
 * System Power Command
 */
public class PowerStatusMsg extends ISCPMessage
{
    public final static String CODE = "PWR";

    /*
    * Play Status: "00": System Standby, "01":  System On, "ALL": All Zone(including Main Zone) Standby
    */
    public enum PowerStatus implements StringParameterIf
    {
        STB("00"), ON("01"), ALL_STB("ALL");
        final String code;

        PowerStatus(String code)
        {
            this.code = code;
        }

        public String getCode()
        {
            return code;
        }
    }

    private PowerStatus powerStatus = PowerStatus.STB;

    PowerStatusMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        powerStatus = (PowerStatus) searchParameter(data, PowerStatus.values(), powerStatus);
    }

    public PowerStatusMsg(PowerStatus powerStatus)
    {
        super(0, null);
        this.powerStatus = powerStatus;
    }

    public PowerStatus getPowerStatus()
    {
        return powerStatus;
    }

    @Override
    public String toString()
    {
        return CODE + "[" + data + "; PWR=" + powerStatus.toString() + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return new EISCPMessage('1', CODE, powerStatus.getCode());
    }
}
