package com.mkulesh.onpc.iscp.messages;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

/*
 * Amplifier Operation Command
 */
public class AmpOperationCommandMsg extends ISCPMessage
{
    public final static String CODE = "CAP";

    public enum Command implements StringParameterIf
    {
        MVLUP(R.string.amp_cmd_volume_up, R.drawable.volume_up),
        MVLDOWN(R.string.amp_cmd_volume_down, R.drawable.volume_down),
        SLIUP(R.string.amp_cmd_selector_up),
        SLIDOWN(R.string.amp_cmd_selector_down),
        AMTON(R.string.amp_cmd_audio_mut_off),
        AMTOFF(R.string.amp_cmd_audio_mut_on),
        AMTTG(R.string.amp_cmd_audio_mut_toggle, R.drawable.volume_mute),
        PWRON(R.string.amp_cmd_system_on),
        PWROFF(R.string.amp_cmd_system_standby),
        PWRTG(R.string.amp_cmd_system_on_toggle);

        final int descriptionId;
        final int imageId;

        Command(final int descriptionId)
        {
            this.descriptionId = descriptionId;
            this.imageId = -1;
        }

        Command(final int descriptionId, final int imageId)
        {
            this.descriptionId = descriptionId;
            this.imageId = imageId;
        }

        public String getCode()
        {
            return toString();
        }

        public int getDescriptionId()
        {
            return descriptionId;
        }

        public int getImageId()
        {
            return imageId;
        }
    }

    private final Command command;

    public AmpOperationCommandMsg(final String command)
    {
        super(0, null);
        this.command = (Command) OperationCommandMsg.searchParameter(command, Command.values(), null);
    }

    public Command getCommand()
    {
        return command;
    }

    @Override
    public String toString()
    {
        return CODE + "[" + (command == null ? "null" : command.toString()) + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return command == null ? null : new EISCPMessage('1', CODE, command.getCode());
    }
}
