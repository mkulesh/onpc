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

import "package:flutter/material.dart";

import '../constants/Dimens.dart';
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../dialogs/GroupControlDialog.dart";
import "../iscp/messages/EnumParameterMsg.dart";
import "../iscp/messages/MultiroomChannelSettingMsg.dart";
import "../iscp/messages/MultiroomDeviceInformationMsg.dart";
import "../iscp/state/MultiroomState.dart";
import "../utils/Logging.dart";
import "../widgets/CustomImageButton.dart";
import "UpdatableView.dart";


class GroupButtonsView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        MultiroomDeviceInformationMsg.CODE,
        MultiroomChannelSettingMsg.CODE
    ];

    GroupButtonsView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        if (!stateManager.isMultiroomAvailable())
        {
            return SizedBox.shrink();
        }

        final DeviceInfo myDevice = stateManager.sourceDevice;
        Logging.logRebuild(this);

        final int zone = MultiroomDeviceInformationMsg.DEFAULT_ZONE;
        final EnumItem<ChannelType> channelType = myDevice.getChannelType(zone);
        final EnumItem<RoleType> roleType = myDevice.groupMsg.getRole(zone);
        return Padding(
            padding: ButtonDimens.smallButtonPadding,
            child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    CustomImageButton.small(
                        Drawables.cmd_multiroom_group,
                        Strings.cmd_multiroom_group,
                        onPressed: ()
                        => _showGroupControlDialog(context),
                        isEnabled: true,
                        isSelected: roleType.key == RoleType.SRC,
                    ),
                    CustomImageButton.small(
                        Drawables.cmd_multiroom_channel,
                        Strings.cmd_multiroom_channel,
                        text: channelType.key == ChannelType.NONE ? "" : channelType.toString(),
                        onPressed: ()
                        {
                            final int myZone = state.getActiveZone + 1;
                            final MultiroomChannelSettingMsg cmd = MultiroomChannelSettingMsg.output(
                                myZone, MultiroomChannelSettingMsg.getUpType(channelType.key));
                            stateManager.sendMessage(cmd);
                        },
                        isEnabled: true
                    ),
                ])
        );
    }

    void _showGroupControlDialog(final BuildContext context)
    {
        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext c)
            => GroupControlDialog(viewContext)
        );
    }
}