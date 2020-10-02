/*
 * Copyright (C) 2020. Mikhail Kulesh
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

import "package:flutter/material.dart";

import "../constants/Dimens.dart";
import "../iscp/messages/XmlListItemMsg.dart";
import "../iscp/messages/ListInfoMsg.dart";
import "../iscp/messages/XmlListInfoMsg.dart";
import "../utils/Logging.dart";
import "../widgets/CustomTextLabel.dart";
import "UpdatableView.dart";

class TrackMenuView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        ListInfoMsg.CODE,
        XmlListInfoMsg.CODE
    ];

    final void Function(XmlListItemMsg msg) _onMenuSelected;

    TrackMenuView(final ViewContext viewContext, this._onMenuSelected) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.logRebuild(this);

        final List<Widget> controls = List<Widget>();
        state.mediaListState.retrieveMenu().forEach((msg)
        {
            if (msg is XmlListItemMsg)
            {
                final Widget item = ListTile(
                    contentPadding: ActivityDimens.noPadding,
                    dense: true,
                    title: msg.isSelectable ? CustomTextLabel.normal(msg.getTitle) : CustomTextLabel.small(msg.getTitle),
                    onTap: ()
                    => _onMenuSelected(msg)
                );
                controls.add(item);
            }
        });

        return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ListBody(children: controls));
    }
}