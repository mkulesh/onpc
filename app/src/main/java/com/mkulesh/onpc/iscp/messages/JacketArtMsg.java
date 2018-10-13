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

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import com.mkulesh.onpc.iscp.EISCPMessage;
import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.io.ByteArrayOutputStream;
import java.net.URL;

/*
 * NET/USB Jacket Art (When Jacket Art is available and Output for Network Control Only)
 */
public class JacketArtMsg extends ISCPMessage
{
    public final static String CODE = "NJA";

    /*
     * Image type 0:BMP, 1:JPEG, 2:URL, n:No Image
     */
    public enum ImageType implements CharParameterIf
    {
        BMP('0'), JPEG('1'), URL('2'), NO_IMAGE('n');
        final Character code;

        ImageType(Character code)
        {
            this.code = code;
        }

        public Character getCode()
        {
            return code;
        }
    }

    private ImageType imageType = ImageType.NO_IMAGE;

    /*
     * Packet flag 0:Start, 1:Next, 2:End, -:not used
     */
    public enum PacketFlag implements CharParameterIf
    {
        START('0'), NEXT('1'), END('2'), NOT_USED('-');
        final Character code;

        PacketFlag(Character code)
        {
            this.code = code;
        }

        public Character getCode()
        {
            return code;
        }
    }

    private PacketFlag packetFlag = PacketFlag.NOT_USED;

    private URL url = null;
    private byte[] rawData = null;

    JacketArtMsg(EISCPMessage raw) throws Exception
    {
        super(raw);
        if (data.length() > 0)
        {
            imageType = (ImageType) searchParameter(data.charAt(0), ImageType.values(), imageType);
        }
        if (data.length() > 1)
        {
            packetFlag = (PacketFlag) searchParameter(data.charAt(1), PacketFlag.values(), packetFlag);
        }
        if (data.length() > 2)
        {
            switch (imageType)
            {
            case URL:
                url = new URL(data.substring(2));
                break;
            case BMP:
            case JPEG:
                rawData = convertRaw(data.substring(2));
                break;
            case NO_IMAGE:
                // nothing to do;
                break;
            }

        }
    }

    public ImageType getImageType()
    {
        return imageType;
    }

    public PacketFlag getPacketFlag()
    {
        return packetFlag;
    }

    public byte[] getRawData()
    {
        return rawData;
    }

    @Override
    public String toString()
    {
        return CODE + "/" + Integer.toString(messageId) + "[" + data.substring(0, 2) + "..."
                + "; TYPE=" + imageType.toString()
                + "; PACKET=" + packetFlag.toString()
                + "; URL=" + url
                + "; RAW(" + (rawData == null ? "null" : rawData.length) + ")"
                + "]";
    }

    private byte[] convertRaw(String str)
    {
        byte[] bytes = new byte[str.length() / 2];
        for (int i = 0; i < bytes.length; i++)
        {
            final int j1 = 2 * i;
            final int j2 = 2 * i + 1;
            if (j1 < str.length() && j2 < str.length())
            {
                bytes[i] = (byte) Integer.parseInt(str.substring(j1, j2 + 1), 16);
            }
        }
        return bytes;
    }

    public Bitmap loadFromUrl()
    {
        Bitmap cover = null;
        try
        {
            Logging.info(this, "loading image from URL: " + url.toString());

            byte[] bytes = Utils.streamToByteArray(url.openConnection().getInputStream());
            int offset = 1;
            for (; offset < bytes.length; offset++)
            {
                if (bytes[offset] == 0x0A && bytes[offset - 1] == 0x0A)
                {
                    break;
                }
            }
            offset++;
            final int length = bytes.length - offset;
            if (length > 0)
            {
                Logging.info(this, "Cover image size length=" + length);
                cover = BitmapFactory.decodeByteArray(bytes, offset, length);
            }
        }
        catch (Exception e)
        {
            Logging.info(this, "can not open image: " + e.getLocalizedMessage());
        }
        if (cover == null)
        {
            Logging.info(this, "can not open image");
        }
        return cover;
    }

    public Bitmap loadFromBuffer(ByteArrayOutputStream coverBuffer)
    {
        if (coverBuffer == null)
        {
            Logging.info(this, "can not open image: empty stream");
            return null;
        }
        Bitmap cover = null;
        try
        {
            Logging.info(this, "loading image from stream");
            coverBuffer.flush();
            coverBuffer.close();
            final byte out[] = coverBuffer.toByteArray();
            cover = BitmapFactory.decodeByteArray(out, 0, out.length);
        }
        catch (Exception e)
        {
            Logging.info(this, "can not open image: " + e.getLocalizedMessage());
        }
        if (cover == null)
        {
            Logging.info(this, "can not open image");
        }
        return cover;
    }
}
