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
// @dart=2.9
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import "../constants/Dimens.dart";
import "../constants/Strings.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/FriendlyNameMsg.dart";
import "../iscp/messages/MultiroomChannelSettingMsg.dart";
import "../iscp/messages/MultiroomDeviceInformationMsg.dart";
import "../iscp/messages/MultiroomGroupSettingMsg.dart";
import "../iscp/state/MultiroomState.dart";
import "../utils/Logging.dart";
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
        Logging.logRebuild(this);

        // Available devices and maximum groupId
        final List<DeviceInfo> devices = [];
        int maxGroupId = 0;
        state.multiroomState.deviceList.forEach((key, di)
        {
            if (stateManager.isMasterDevice(di))
            {
                devices.insert(0, di);
            }
            else
            {
                devices.add(di);
            }
            if (di.groupMsg != null)
            {
                di.groupMsg.zones.forEach((z)
                => maxGroupId = max(maxGroupId, z.groupid));
            }
        });

        // Define this group ID
        final int myZone = state.getActiveZone + 1;
        final int myGroupId = myDevice.groupMsg.getGroupId(myZone);
        final int targetGroupId = myGroupId == MultiroomZone.NO_GROUP ? maxGroupId + 1 : myGroupId;

        final List<Widget> controls = [];
        Logging.info(this, "Devices for group: " + myGroupId.toString() + ", maximum group ID=" + maxGroupId.toString());
        devices.forEach((di)
        {
            if (stateManager.isMasterDevice(di))
            {
                controls.add(_buildDeviceItem(di, true, myZone, myGroupId, targetGroupId, myZone));
            }
            else
            {
                controls.add(_buildDeviceItem(di, false, myZone, myGroupId, targetGroupId, MultiroomGroupSettingMsg.TARGET_ZONE_ID));
            }
        });

        return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ListBody(children: controls));
    }

    Widget _buildDeviceItem(DeviceInfo device, bool myDevice, int myZone, int myGroupId, int targetGroupId, int targetZoneId)
    {
        final MultiroomDeviceInformationMsg di = device.groupMsg;
        String description = Strings.multiroom_none;
        bool attached = false;
        if (di != null)
        {
            final int groupId = di.getGroupId(targetZoneId);
            if (groupId != MultiroomZone.NO_GROUP)
            {
                description = Strings.multiroom_group
                    + " " + groupId.toString()
                    + ": " + di.getRole(targetZoneId).description
                    + ", " + Strings.multiroom_channel
                    + " " + device.getChannelType(targetZoneId).toString();
                if (myGroupId == groupId)
                {
                    attached = device.getChannelType(targetZoneId).key != ChannelType.NONE;
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
            => _sendGroupCmd(device, attached, myZone, targetGroupId, targetZoneId));

        if (!myDevice)
        {
            result = Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    stateManager.waitingForData ? UpdatableView.createTimerSand() : checkBox,
                    Expanded(child: result)
                ]);

            if (!stateManager.waitingForData)
            {
                result = InkWell(
                    child: result,
                    onTap: ()
                    => _sendGroupCmd(device, attached, myZone, targetGroupId, targetZoneId)
                );
            }
        }

        Logging.info(this, "    " + (myDevice ? "MASTER" : "SLAVE") + ": " + device.getHostAndPort()
            + "; zone=" + targetZoneId.toString()
            + "; attached=" + attached.toString()
            + "; " + description);

        return Padding(padding: DialogDimens.rowPadding, child: result);
    }

    void _sendGroupCmd(DeviceInfo device, bool attached, int myZone, int targetGroupId, int targetZoneId)
    {
        if (attached)
        {
            Logging.info(this, "remove device " + device.getHostAndPort());
            final MultiroomGroupSettingMsg removeCmd = MultiroomGroupSettingMsg.output(
                MultiroomGroupCommand.REMOVE_SLAVE, myZone, 0, MAX_DELAY);
            removeCmd.addDevice(device.responseMsg.getIdentifier, targetZoneId);
            stateManager.sendMessage(removeCmd, waitingForData: true);
        }
        else
        {
            Logging.info(this, "add device " + device.getHostAndPort() + " to group " + targetGroupId.toString());
            final MultiroomGroupSettingMsg addCmd = MultiroomGroupSettingMsg.output(
                MultiroomGroupCommand.ADD_SLAVE, myZone, targetGroupId, MAX_DELAY);
            addCmd.addDevice(device.responseMsg.getIdentifier, targetZoneId);
            stateManager.sendMessage(addCmd, waitingForData: true);
        }
    }
}