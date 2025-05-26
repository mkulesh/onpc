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

import '../../utils/Logging.dart';
import '../messages/DcpMediaContainerMsg.dart';

class MediaDownloadCtrl
{
    // Total target number of media items, when media list is
    // downloaded in several blocks like for huge Denon media lists
    int _total = -1;

    int get total
    => _total;

    // Number of already downloaded items
    int _downloaded = -1;

    void clear()
    {
        _total = -1;
        _downloaded = -1;
    }

    void start(DcpMediaContainerMsg msg)
    {
        _total = msg.getCount();
        _downloaded = 0;
    }

    void checkTotal(DcpMediaContainerMsg msg)
    {
        if (_total != msg.getCount())
        {
            _total = msg.getCount();
            Logging.info(this, "Changed total number of items: " + _total.toString());
        }
    }

    void addBlock(DcpMediaContainerMsg msg)
    {
        _downloaded += msg.getItems().length;
        Logging.info(this, "Downloaded " + _downloaded.toString() + " from " + _total.toString() + " items");
    }

    bool get downloadFinished
    => _total == _downloaded;
}
