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

import "package:collection/collection.dart";
import "package:flutter/material.dart";

import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../utils/Pair.dart";
import "../views/UpdatableView.dart";
import "../widgets/CustomCheckbox.dart";
import "../widgets/CustomDialogEditField.dart";
import "../widgets/CustomDialogTitle.dart";
import "../iscp/messages/DcpSearchMsg.dart";

class DcpSearchDialog extends StatefulWidget
{
    final ViewContext _viewContext;
    final List<Pair<String, int>> _searchCriteria;

    DcpSearchDialog(this._viewContext, this._searchCriteria);

    @override _DcpSearchDialogState createState()
    => _DcpSearchDialogState();
}

class _DcpSearchDialogState extends State<DcpSearchDialog>
{
    final List<Pair<String, String>> _translatedItems = [
        Pair("Artist", Strings.medialist_search_artist),
        Pair("Album", Strings.medialist_search_album),
        Pair("Track", Strings.medialist_search_track),
        Pair("Station", Strings.medialist_search_station),
        Pair("Playlist", Strings.medialist_search_playlist),
    ];

    final _searchStr = TextEditingController();
    int _scid = -1;

    ViewContext get viewContext
    => widget._viewContext;

    @override
    void initState()
    {
        super.initState();
        _searchStr.text = widget._viewContext.stateManager.state.trackState.artist;
        _scid = this.widget._searchCriteria.first.item2;
    }

    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = viewContext.getThemeData();

        final List<Widget> controls = [];

        this.widget._searchCriteria.forEach((Pair<String, int> element)
        {
            controls.add(CustomCheckbox(_getTranslatedName(element.item1),
                icon: Radio(
                    value: element.item2,
                    groupValue: _scid,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (int? v)
                    {
                        if (v != null)
                        {
                            setState(() {
                                _scid = v;
                            });
                        }
                    })
            ));
        });

        controls.add(CustomDialogEditField(_searchStr,
            textLabel: "",
            isFocused: true,
            onChanged: (val)
            {
                setState(()
                {
                    // empty, just to redraw OK button
                });
            })
        );

        final Widget dialog = AlertDialog(
            title: CustomDialogTitle(Strings.medialist_search, Drawables.cmd_search),
            contentPadding: DialogDimens.contentPadding,
            content: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: ListBody(children: controls)),
            actions: <Widget>[
                TextButton(
                    child: Text(Strings.action_cancel.toUpperCase(), style: td.textTheme.labelLarge),
                    onPressed: ()
                    {
                        Navigator.of(context).pop();
                    }),
                TextButton(
                    child: Text(Strings.action_ok.toUpperCase(),
                        style: _searchStr.text.isEmpty ? td.textTheme.labelLarge!.copyWith(color: td.disabledColor) : td.textTheme.labelLarge
                    ),
                    onPressed: _searchStr.text.isEmpty ? null : ()
                    {
                        Navigator.of(context).pop();
                        viewContext.stateManager.sendMessage(DcpSearchMsg.output(
                            viewContext.state.mediaListState.mediaListSid,
                            _scid.toString(),
                            _searchStr.text), waitingForData: true);
                    }),
            ]
        );

        return Theme(data: td, child: dialog);
    }

    String _getTranslatedName(String item)
    {
        final Pair<String, String>? tItem = _translatedItems.firstWhereOrNull((p) => p.item1.toLowerCase() == item.toLowerCase());
        return tItem == null? item : tItem.item2;
    }

    @override
    void dispose()
    {
        _searchStr.dispose();
        super.dispose();
    }
}