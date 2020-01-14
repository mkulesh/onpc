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

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/FriendlyNameMsg.dart";
import "../iscp/messages/MultiroomChannelSettingMsg.dart";
import "../iscp/messages/MultiroomDeviceInformationMsg.dart";
import "../iscp/messages/MultiroomGroupSettingMsg.dart";
import "../iscp/state/MultiroomState.dart";
import "../utils/Logging.dart";
import "../widgets/CustomImageButton.dart";
import "../widgets/CustomTextLabel.dart";
import "UpdatableView.dart";

class GroupControlView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        StateManager.WAITING_FOR_DATA_EVENT,
        MultiroomDeviceInformationMsg.CODE,
        MultiroomChannelSettingMsg.CODE,
        FriendlyNameMsg.CODE
    ];

    static const int MAX_DELAY = 3000;

    GroupControlView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        if (!stateManager.isMultiroomAvailable())
        {
            return SizedBox.shrink();
        }

        final DeviceInfo myDevice = stateManager.sourceDevice;
        Logging.info(this, "rebuild widget for " + myDevice.getDeviceName(false));

        // Available devices and maximum groupId
        final List<DeviceInfo> devices = List();
        int maxGroupId = 0;
        state.multiroomState.deviceList.values.forEach((di)
        {
            if (di.getId() == myDevice.getId())
            {
                devices.insert(0, di);
            }
            else
            {
                devices.add(di);
            }
            di.groupMsg.zones.forEach((z) => maxGroupId = max(maxGroupId, z.groupid));
        });

        // Define this group ID
        final int myZone = state.getActiveZone + 1;
        final int myGroupId = myDevice.groupMsg.getGroupId(myZone);
        final int targetGroupId = myGroupId == MultiroomZone.NO_GROUP ? maxGroupId + 1 : myGroupId;

        final List<Widget> controls = List<Widget>();
        Logging.info(this, "Devices for group: " + myGroupId.toString() + ",  maximum group ID=" + maxGroupId.toString());
        devices.forEach((di)
        {
            controls.add(_buildDeviceItem(di, di.getId() == myDevice.getId(), myZone, myGroupId, targetGroupId));
        });

        return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ListBody(children: controls));
    }

    Widget _buildDeviceItem(DeviceInfo device, bool myDevice, int myZone, int myGroupId, int targetGroupId)
    {
        final MultiroomDeviceInformationMsg di = device.groupMsg;
        final int tz = myDevice ? myZone : MultiroomGroupSettingMsg.TARGET_ZONE_ID;
        String description = Strings.multiroom_none;
        bool attached = false;
        if (di != null)
        {
            final int groupId = di.getGroupId(tz);
            if (groupId != MultiroomZone.NO_GROUP)
            {
                description = Strings.multiroom_group
                    + " " + groupId.toString()
                    + ": " + di.getRole(tz).description
                    + ", " + Strings.multiroom_channel
                    + " " + device.getChannelType(tz).toString();
                if (myGroupId == groupId)
                {
                    attached = device.getChannelType(tz).key != ChannelType.NONE;
                }
            }
        }

        Widget result = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                CustomTextLabel.normal(device.getDeviceName(configuration.friendlyNames)),
                CustomTextLabel.small(description)
            ]);

        final Widget checkBox = Checkbox(
            value: attached,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: (bool newValue)
            => _sendGroupCmd(device, attached, myZone, myGroupId, targetGroupId));

        if (!myDevice)
        {
            result = Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    stateManager.waitingForData ? createTimerSand() : checkBox,
                    result
                ]);

            if (!stateManager.waitingForData)
            {
                result = InkWell(
                    child: result,
                    onTap: ()
                    => _sendGroupCmd(device, attached, myZone, myGroupId, targetGroupId)
                );
            }
        }

        Logging.info(this, "    ID: " + device.getId() + "; " + description + "; attached=" + attached.toString());

        return Padding(padding: DialogDimens.rowPadding, child: result);
    }

    _sendGroupCmd(DeviceInfo device, bool attached, int myZone, int myGroupId, int targetGroupId)
    {
        if (attached)
        {
            Logging.info(this, "remove device " + device.getId());
            final MultiroomGroupSettingMsg removeCmd = MultiroomGroupSettingMsg.output(
                MultiroomGroupCommand.REMOVE_SLAVE, myZone, 0, MAX_DELAY);
            stateManager.sendMessage(removeCmd, waitingForData: true);
        }
        else
        {
            Logging.info(this, "add device " + device.getId() + " to group " + targetGroupId.toString());
            final MultiroomGroupSettingMsg addCmd = MultiroomGroupSettingMsg.output(
                MultiroomGroupCommand.ADD_SLAVE, myZone, targetGroupId, MAX_DELAY);
            addCmd.devices.add(device.responseMsg.getIdentifier);
            stateManager.sendMessage(addCmd, waitingForData: true);
        }
    }
}