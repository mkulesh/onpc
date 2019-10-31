/*
 * Copyright (C) 2019. Mikhail Kulesh
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
import "../constants/Strings.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/BroadcastResponseMsg.dart";
import "../iscp/messages/FriendlyNameMsg.dart";
import "../iscp/state/MultiroomState.dart";
import "../utils/Logging.dart";
import "../widgets/CustomTextLabel.dart";
import "UpdatableView.dart";

class DeviceSearchView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        StateManager.CONNECTION_EVENT,
        StateManager.BROADCAST_SEARCH_EVENT,
        BroadcastResponseMsg.CODE,
        FriendlyNameMsg.CODE
    ];

    OnDeviceFound onDeviceFound;

    DeviceSearchView(final ViewContext viewContext, this.onDeviceFound) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.info(this, "rebuild widget");

        final List<Widget> controls = List<Widget>();
        final List<DeviceInfo> devices = state.multiroomState.getSortedDevices();

        devices.forEach((d)
        {
            final Widget item = ListTile(
                contentPadding: ActivityDimens.noPadding,
                dense: true,
                title: CustomTextLabel.normal(d.getDeviceName(configuration.friendlyNames)),
                onTap: ()
                => onDeviceFound(d.responseMsg)
            );
            controls.add(item);
        });

        if (controls.isEmpty)
        {
            controls.add(CustomTextLabel.small(
                stateManager.isSearching ? Strings.drawer_device_searching : Strings.error_connection_no_wifi,
                padding: DialogDimens.rowPadding));
        }

        return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ListBody(children: controls));
    }
}