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

package com.mkulesh.onpc.iscp.messages;

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

/*
 * NET Custom Popup Message (for Network Control Only)
 */
public class CustomPopupMsg extends ISCPMessage
{
    public final static String CODE = "NCP";

    /*
     * UI Type
     * 0 : List, 1 : Menu, 2 : Playback, 3 : Popup, 4 : Keyboard, 5 : Menu List
     */
    public enum UiType implements CharParameterIf
    {
        XML('X'), LIST('0'), MENU('1'), PLAYBACK('2'), POPUP('3'), KEYBOARD('4'), MENU_LIST('5');
        final Character code;

        UiType(Character code)
        {
            this.code = code;
        }

        public Character getCode()
        {
            return code;
        }
    }

    private final UiType uiType;
    private final String xml;


    CustomPopupMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        uiType = (UiType) searchParameter(data.charAt(0), UiType.values(), UiType.XML);
        xml = data.substring(1);
    }

    public CustomPopupMsg(final UiType uiType, final String xml)
    {
        super(0, null);
        this.uiType = uiType;
        this.xml = xml;
    }

    public String getXml()
    {
        return xml;
    }

    @Override
    public String toString()
    {
        return CODE + "[" + uiType.toString() + ": " + xml + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return new EISCPMessage('1', CODE, uiType.getCode() + "000" + xml);
    }
}
