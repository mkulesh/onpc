package com.mkulesh.onpc.iscp.messages;

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;

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
     * Update Type (P : Page Infomation Update ( Page Clear or Disable List Info) , C : Cursor Position Update)
     */
    private enum UpdateType implements CharParameterIf
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

    public InformationType getInformationType()
    {
        return informationType;
    }

    public String getListedData()
    {
        return listedData;
    }

    @Override
    public String toString()
    {
        return CODE + "[" + data
                + "; INF_TYPE=" + informationType.toString()
                + "; LINE_INFO=" + Integer.toString(lineInfo)
                + "; PROPERTY=" + property.toString()
                + "; UPD_TYPE=" + updateType.toString()
                + "; LIST_DATA=" + listedData
                + "]";
    }
}
