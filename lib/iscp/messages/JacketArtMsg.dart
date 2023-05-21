/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2023 by Mikhail Kulesh
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
// @dart=2.9
import "dart:math";
import "dart:typed_data";

import "package:collection/collection.dart";
import "package:flutter/widgets.dart";
import "package:http/http.dart" as http;

import "../../utils/Logging.dart";
import "../EISCPMessage.dart";
import "../ISCPMessage.dart";
import "EnumParameterMsg.dart";

enum ImageType
{
    BMP,
    JPEG,
    URL,
    NO_IMAGE
}

enum PacketFlag
{
    START,
    NEXT,
    END,
    NOT_USED
}

/*
 * NET/USB Jacket Art (When Jacket Art is available and Output for Network Control Only)
 */
class JacketArtMsg extends ISCPMessage
{
    static const String CODE = "NJA";
    static const String TYPE_LINK = "LINK";
    static const String TYPE_BMP = "BMP";
    static const String REQUEST = "REQ";

    /*
     * Image type 0:BMP, 1:JPEG, 2:URL, n:No Image
     */
    static const ExtEnum<ImageType> ImageTypeEnum = ExtEnum<ImageType>([
        EnumItem.char(ImageType.BMP, '0'),
        EnumItem.char(ImageType.JPEG, '1'),
        EnumItem.char(ImageType.URL, '2'),
        EnumItem.char(ImageType.NO_IMAGE, 'n', defValue: true)
    ]);

    ImageType imageType;

    /*
     * Packet flag 0:Start, 1:Next, 2:End, -:not used
     */
    static const ExtEnum<PacketFlag> PacketFlagEnum = ExtEnum<PacketFlag>([
        EnumItem.char(PacketFlag.START, '0'),
        EnumItem.char(PacketFlag.NEXT, '1'),
        EnumItem.char(PacketFlag.END, '2'),
        EnumItem.char(PacketFlag.NOT_USED, '-', defValue: true)
    ]);

    PacketFlag packetFlag;

    String url;
    List<int> rawData;

    JacketArtMsg(EISCPMessage raw) : super(CODE, raw)
    {
        if (getData.isNotEmpty)
        {
            imageType = ImageTypeEnum.valueByCode(getData.substring(0, 1)).key;
        }
        if (getData.length > 1)
        {
            packetFlag = PacketFlagEnum.valueByCode(getData.substring(1, 2)).key;
        }
        url = null;
        rawData = null;
        if (getData.length > 2)
        {
            switch (imageType)
            {
                case ImageType.URL:
                    url = getData.substring(2);
                    break;
                case ImageType.BMP:
                case ImageType.JPEG:
                    rawData = convertRaw(getData.substring(2));
                    break;
                case ImageType.NO_IMAGE:
                // nothing to do;
                    break;
            }
        }
    }

    ImageType get getImageType
    => imageType;

    PacketFlag get getPacketFlag
    => packetFlag;

    List<int> get getRawData
    => rawData;

    @override
    String toString()
    {
        return CODE + "/" + getMessageId.toString() + "[" + getData.substring(0, 2) + "..."
            + "; TYPE=" + imageType.toString()
            + "; PACKET=" + packetFlag.toString()
            + "; URL=" + (url == null ? "null" : url)
            + "; RAW(" + (rawData == null ? "null" : rawData.length.toString()) + ")"
            + "]";
    }

    List<int> convertRaw(String str)
    {
        final int size = (str.length / 2).floor();
        final List<int> bytes = List.generate(size, (i)
        {
            final int j1 = 2 * i;
            final int j2 = 2 * i + 1;
            return (j1 < str.length && j2 < str.length) ? ISCPMessage.nonNullInteger(str.substring(j1, j2 + 1), 16, 0) : 0;
        });
        return bytes;
    }

    Future<Image> loadFromUrl()
    {
        return http.get(Uri.parse(url)).then((response)
        {
            try
            {
                final Uint8List r = response.bodyBytes;
                final int offset = _getUrlHeaderLength(r);
                final int length = r.length - offset;
                if (length > 0)
                {
                    Logging.info(this, "image size: " + length.toString() + "B");
                    return Image.memory(Uint8List.view(r.buffer, offset));
                }
                else
                {
                    Logging.info(this, "empty image");
                    return null;
                }
            }
            on Exception catch (e)
            {
                Logging.info(this, "-> can not proccess image: " + e.toString());
                return null;
            }
        });
    }

    int _getUrlHeaderLength(Uint8List r)
    {
        final List<int> cnt = "Content-".codeUnits;
        int length = 0;
        while (true)
        {
            final int lf = r.indexOf(EISCPMessage.LF, length);
            final List<int> start = r.sublist(length, min(length + cnt.length, r.length));
            if (lf > 0 && IterableEquality().equals(start, cnt))
            {
                length = lf;
                while (length < r.length && (r[length] == EISCPMessage.LF || r[length] == EISCPMessage.CR))
                {
                    length++;
                }
                continue;
            }
            break;
        }
        return length;
    }

    Image loadFromBuffer(List<int> coverBuffer)
    => Image.memory(Uint8List.fromList(coverBuffer));
}
