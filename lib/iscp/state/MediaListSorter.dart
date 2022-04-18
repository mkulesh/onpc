/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2022 by Mikhail Kulesh
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
        final List<ISCPMessage> sortedItems = _sortMode == MediaSortMode.ITEM_NAME ? List.from(items) : _swapArtistAndAlbum(items);
        sortedItems.sort((a, b) => _sortByItemName(a, b));
        return sortedItems;
    }

    String _getItemName(final ISCPMessage cmd)
    => cmd is XmlListItemMsg ? cmd.getTitle : cmd is PresetCommandMsg ? cmd.getPresetConfig.displayedString : null;

    List<ISCPMessage> _swapArtistAndAlbum(final List<ISCPMessage> items)
    {
        final List<ISCPMessage> newItems = [];
        items.forEach((a)
        {
            final String aName = _getItemName(a);
            if (a is XmlListItemMsg && aName != null)
            {
                String newTitle = a.getTitle;
                final List<String> aTerms = aName.split(_ALBUMS_SEPARATOR);
                if (aTerms.isNotEmpty)
                {
                    final String album = aTerms.first;
                    final String artist = aTerms.last;
                    if (artist != album)
                    {
                        newTitle = artist + _ALBUMS_SEPARATOR + album;
                    }
                }
                newItems.add(XmlListItemMsg.rename(a, newTitle));
            }
            else
            {
                newItems.add(a);
            }
        });
        return newItems;
    }

    int _sortByItemName(final ISCPMessage a, final ISCPMessage b)
    {
        final String aName = _getItemName(a);
        final String bName = _getItemName(b);
        return aName != null && bName != null ? aName.compareTo(bName) : 0;
    }
}