/*
 * Enhanced Controller for Onkyo and Pioneer
 * Copyright (C) 2018-2021 by Mikhail Kulesh
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

import androidx.annotation.NonNull;

/*
 * NET/USB List Info
 */
public class ListInfoMsg extends ISCPMessage
{
    public final static String CODE = "NLS";

    /*
     * Information Type (A : ASCII letter, C : Cursor Info, U : Unicode letter)
     */
    public enum InformationType implements CharParameterIf
    {
        ASCII('A'), CURSOR('C'), UNICODE('U');
        final Character code;

        InformationType(Character code)
        {
            this.code = code;
        }

        public Character getCode()
        {
            return code;
        }
    }

    private InformationType informationType = InformationType.CURSOR;

    /* Line Info (0-9 : 1st to 10th Line) */
    private int lineInfo;

    /*
     * Property
     * - : no
     * 0 : Playing, A : Artist, B : Album, F : Folder, M : Music, P : Playlist, S : Search
     * a : Account, b : Playlist-C, c : Starred, d : Unstarred, e : What's New
     */
    private enum Property implements CharParameterIf
    {
        NO('-'),
        PLAYING('0'),
        ARTIST('A'),
        ALBUM('B'),
        FOLDER('F'),
        MUSIC('M'),
        PLAYLIST('P'),
        SEARCH('S'),
        ACCOUNT('A'),
        PLAYLIST_C('B'),
        STARRED('C'),
        UNSTARRED('D'),
        WHATS_NEW('E');
        final Character code;

        Property(Character code)
        {
            this.code = code;
        }

        public Character getCode()
        {
            return code;
        }
    }

    private Property property = Property.NO;

    /*
     * Update Type (P : Page Information Update ( Page Clear or Disable List Info) , C : Cursor Position Update)
     */
    public enum UpdateType implements CharParameterIf
    {
        NO('-'), PAGE('P'), CURSOR('C');
        final Character code;

        UpdateType(Character code)
        {
            this.code = code;
        }

        public Character getCode()
        {
            return code;
        }
    }

    private UpdateType updateType = UpdateType.NO;

    private String listedData = null;

    ListInfoMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        informationType = (InformationType) searchParameter(data.charAt(0), InformationType.values(), informationType);
        final char lineInfoChar = data.charAt(1);
        lineInfo = Character.isDigit(lineInfoChar) ? Integer.parseInt(String.valueOf(lineInfoChar)) : -1;
        switch (informationType)
        {
        case ASCII:
        case UNICODE:
            property = (Property) searchParameter(data.charAt(2), Property.values(), property);
            listedData = data.substring(3);
            break;
        case CURSOR:
            updateType = (UpdateType) searchParameter(data.charAt(2), UpdateType.values(), updateType);
            break;
        }
    }

    public ListInfoMsg(final int lineInfo, final String listedData)
    {
        super(0, null);
        informationType = InformationType.UNICODE;
        this.lineInfo = lineInfo;
        //noinspection ConstantConditions
        property = Property.NO;
        //noinspection ConstantConditions
        updateType = UpdateType.NO;
        this.listedData = listedData;
    }

    public InformationType getInformationType()
    {
        return informationType;
    }

    public UpdateType getUpdateType()
    {
        return updateType;
    }

    public String getListedData()
    {
        return listedData;
    }

    public int getLineInfo()
    {
        return lineInfo;
    }

    @NonNull
    @Override
    public String toString()
    {
        return CODE + "[" + data
                + "; INF_TYPE=" + informationType.toString()
                + "; LINE_INFO=" + lineInfo
                + "; PROPERTY=" + property.toString()
                + "; UPD_TYPE=" + updateType.toString()
                + "; LIST_DATA=" + listedData
                + "]";
    }

    @Override
    public EISCPMessage getCmdMsg()
    {
        return new EISCPMessage(CODE, "L" + lineInfo);
    }
}
