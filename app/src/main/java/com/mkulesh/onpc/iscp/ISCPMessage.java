package com.mkulesh.onpc.iscp;

public class ISCPMessage
{
    protected final static String PAR_SEP = "/";

    protected final int messageId;
    protected final String data;
    private final Character modelCategoryId;

    protected ISCPMessage(final int messageId, final String data)
    {
        this.messageId = messageId;
        this.data = data;
        modelCategoryId = 'X';
    }

    protected ISCPMessage(EISCPMessage raw) throws Exception
    {
        messageId = raw.getMessageId();
        data = raw.getParameters().trim();
        modelCategoryId = raw.getModelCategoryId();
    }

    public ISCPMessage(ISCPMessage other)
    {
        messageId = other.messageId;
        data = other.data;
        modelCategoryId = other.modelCategoryId;
    }

    public int getMessageId()
    {
        return messageId;
    }

    public final String getData()
    {
        return data;
    }

    @Override
    public String toString()
    {
        return "ISCPMessage/" + modelCategoryId;
    }

    /**
     * Helper methods for enumerations based on char parameter
     */
    protected interface CharParameterIf
    {
        Character getCode();
    }

    protected static CharParameterIf searchParameter(Character code, CharParameterIf[] values, CharParameterIf defValue)
    {
        for (CharParameterIf t : values)
        {
            if (t.getCode() == code)
            {
                return t;
            }
        }
        return defValue;
    }

    /**
     * Helper methods for enumerations based on char parameter
     */
    public interface StringParameterIf
    {
        String getCode();
    }

    public static StringParameterIf searchParameter(String code, StringParameterIf[] values, StringParameterIf defValue)
    {
        if (code == null)
        {
            return defValue;
        }
        for (StringParameterIf t : values)
        {
            if (t.getCode().toUpperCase().equals(code.toUpperCase()))
            {
                return t;
            }
        }
        return defValue;
    }

    public EISCPMessage getCmdMsg()
    {
        return null;
    }
}
