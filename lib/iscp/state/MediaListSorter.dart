/*
 * Enhanced Controller for Onkyo and Pioneer Pro
 * Copyright (C) 2019-2021 by Mikhail Kulesh
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

import "../../config/CfgAppSettings.dart";
import "../ISCPMessage.dart";
import "../messages/PresetCommandMsg.dart";
import "../messages/XmlListItemMsg.dart";

class MediaListSorter
{
    static final String _ALBUMS_SEPARATOR = " / ";

    bool isSortableItem(final List<ISCPMessage> items)
    => items.every((rowMsg) => rowMsg is XmlListItemMsg && !([ListItemIcon.MUSIC, ListItemIcon.PLAY].contains(rowMsg.getIcon.key)));

    List<ISCPMessage> sortDeezerItems(final List<ISCPMessage> items, final MediaSortMode _sortMode)
    {
        final List<ISCPMessage> sortedItems = List.from(items);
        switch (_sortMode)
        {
            case MediaSortMode.ITEM_NAME:
                sortedItems.sort((a, b)
                => _sortByItemName(a, b));
                break;
            case MediaSortMode.ARTIST_ALBUM:
                sortedItems.sort((a, b)
                => _sortByArtistAlbum(a, b));
                break;
        }
        return sortedItems;
    }

    String _getItemName(final ISCPMessage cmd)
    => cmd is XmlListItemMsg ? cmd.getTitle : cmd is PresetCommandMsg ? cmd.getPresetConfig.displayedString : null;

    int _sortByItemName(final ISCPMessage a, final ISCPMessage b)
    {
        final String aName = _getItemName(a);
        final String bName = _getItemName(b);
        return aName != null && bName != null ? aName.compareTo(bName) : 0;
    }

    int _sortByArtistAlbum(final ISCPMessage a, final ISCPMessage b)
    {
        final String aName = _getItemName(a);
        if (aName == null)
        {
            return 0;
        }
        final List<String> aTerms = aName.split(_ALBUMS_SEPARATOR);

        final String bName = _getItemName(b);
        if (bName == null)
        {
            return 0;
        }
        final List<String> bTerms = bName.split(_ALBUMS_SEPARATOR);

        if (aTerms.isEmpty || bTerms.isEmpty)
        {
            return 0;
        }

        final int artist = aTerms.last.compareTo(bTerms.last);
        if (aTerms.length < 2 || bTerms.length < 2 || artist != 0)
        {
            return artist;
        }
        return aTerms.first.compareTo(bTerms.first);
    }
}