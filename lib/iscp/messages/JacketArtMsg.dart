/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2025 by Mikhail Kulesh
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

import "dart:typed_data";

import "package:flutter/widgets.dart";

import "../../utils/Convert.dart";
import "../../utils/UrlLoader.dart";
import "../DcpHeosMessage.dart";
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

    late ImageType imageType;

    /*
     * Packet flag 0:Start, 1:Next, 2:End, -:not used
     */
    static const ExtEnum<PacketFlag> PacketFlagEnum = ExtEnum<PacketFlag>([
        EnumItem.char(PacketFlag.START, '0'),
        EnumItem.char(PacketFlag.NEXT, '1'),
        EnumItem.char(PacketFlag.END, '2'),
        EnumItem.char(PacketFlag.NOT_USED, '-', defValue: true)
    ]);

    PacketFlag? packetFlag;
    String? url;
    List<int>? rawData;

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
                    rawData = Convert.convertRaw(getData.substring(2));
                    break;
                case ImageType.NO_IMAGE:
                // nothing to do;
                    break;
            }
        }
    }

    JacketArtMsg._dcp(final String url) : super.output(CODE, url)
    {
        this.imageType = ImageType.URL;
        this.url = url;
    }

    ImageType get getImageType
    => imageType;

    PacketFlag? get getPacketFlag
    => packetFlag;

    List<int>? get getRawData
    => rawData;

    @override
    String toString()
    {
        return CODE + "/" + getMessageId.toString() + "[" + getData.substring(0, 2) + "..."
            + "; TYPE=" + imageType.toString()
            + "; PACKET=" + packetFlag.toString()
            + "; URL=" + (url == null ? "null" : url!)
            + "; RAW(" + (rawData == null ? "null" : rawData!.length.toString()) + ")"
            + "]";
    }

    Future<Image?> loadFromUrl()
    {
        if (url == null)
        {
            return Future<Image?>.value(null);
        }
        return UrlLoader().loadFromUrl(url!).then((Uint8List? data)
        {
            return data != null? Image.memory(data) : null;
        });
    }

    Image loadFromBuffer(List<int> coverBuffer)
    => Image.memory(Uint8List.fromList(coverBuffer));

    /*
     * Denon control protocol
     */
    static const String _HEOS_COMMAND = "player/get_now_playing_media";

    static JacketArtMsg? processHeosMessage(DcpHeosMessage jsonMsg)
    {
        final String? name = jsonMsg.getCmdProperty(_HEOS_COMMAND, "payload.image_url");
        return (name != null && name.isNotEmpty) ? JacketArtMsg._dcp(name) : null;
    }
}
