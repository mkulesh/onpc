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

package com.mkulesh.onpc;

import android.graphics.drawable.Drawable;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.LinearLayout;

import com.mkulesh.onpc.iscp.State;
import com.mkulesh.onpc.iscp.messages.BroadcastResponseMsg;
import com.mkulesh.onpc.iscp.messages.MultiroomDeviceInformationMsg;
import com.mkulesh.onpc.iscp.messages.MultiroomGroupSettingMsg;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;

class MultiroomManager
{
    static AlertDialog createDeviceSelectionDialog(
            @NonNull final MainActivity activity,
            @NonNull CharSequence title,
            @NonNull final List<BroadcastResponseMsg> devices)
    {
        final State state = activity.getStateManager().getState();
        final FrameLayout frameView = new FrameLayout(activity);
        activity.getLayoutInflater().inflate(R.layout.dialog_multiroom_layout, frameView);

        // Define this group ID
        final int myZone = state.getActiveZone() + 1;
        final int myGroupId = state.getMultiroomGroupId();
        final Map<String, Boolean> attachedDevices = new HashMap<>();

        // Create device list
        final LinearLayout deviceGroup = frameView.findViewById(R.id.device_group);
        Logging.info(activity, "Devices for group: " + myGroupId);
        for (BroadcastResponseMsg msg : devices)
        {
            final MultiroomDeviceItem view = createDeviceItem(activity, msg,
                    state.multiroomLayout.get(msg.getIdentifier()),
                    myZone, myGroupId);
            attachedDevices.put(msg.getIdentifier(), view.isChecked());
            deviceGroup.addView(view);
        }
        // Define maximum group ID
        int _maxGroupId = 0;
        for (MultiroomDeviceInformationMsg di : state.multiroomLayout.values())
        {
            for (MultiroomDeviceInformationMsg.Zone z : di.getZones())
            {
                _maxGroupId = Math.max(_maxGroupId, z.getGroupid());
            }
        }
        final int maxGroupId = _maxGroupId;
        Logging.info(activity, "    Maximum group ID=" + maxGroupId);

        // Create dialog
        final Drawable icon = Utils.getDrawable(activity, R.drawable.cmd_multiroom_group);
        Utils.setDrawableColorAttr(activity, icon, android.R.attr.textColorSecondary);

        return new AlertDialog.Builder(activity)
                .setTitle(title)
                .setIcon(icon)
                .setCancelable(true)
                .setView(frameView)
                .setNegativeButton(R.string.action_cancel, (dialog1, which) -> dialog1.dismiss())
                .setPositiveButton(R.string.action_ok, (dialog2, which) ->
                {
                    int groupId = myGroupId;
                    if (myGroupId == MultiroomDeviceInformationMsg.NO_GROUP)
                    {
                        groupId = maxGroupId + 1;
                    }
                    sendGroupUpdates(activity, deviceGroup, attachedDevices, myZone, groupId);
                    dialog2.dismiss();
                }).create();
    }

    private static MultiroomDeviceItem createDeviceItem(
            @NonNull final MainActivity activity,
            @NonNull final BroadcastResponseMsg msg,
            @Nullable final MultiroomDeviceInformationMsg di,
            final int zone,
            final int myGroupId)
    {
        final ViewGroup dummyView = null;
        final MultiroomDeviceItem view = (MultiroomDeviceItem) activity.getLayoutInflater().inflate(
                R.layout.multiroom_device_item, dummyView, false);

        final boolean myDevice = msg.getIdentifier().equals(activity.myDeviceId());
        int tz = MultiroomGroupSettingMsg.TARGET_ZONE_ID;
        if (myDevice)
        {
            view.setChecked(false);
            view.setCheckBoxVisibility(View.GONE);
            tz = zone;
        }
        view.setText(activity.getMultiroomDeviceName(msg));
        String description = activity.getString(R.string.multiroom_none);
        boolean attached = false;
        if (di != null)
        {
            final int groupId = di.getGroupId(tz);
            if (groupId != MultiroomDeviceInformationMsg.NO_GROUP)
            {
                description = activity.getString(R.string.multiroom_group)
                        + " " + groupId
                        + ": " + activity.getString(di.getRole(tz).getDescriptionId())
                        + ", " + activity.getString(R.string.multiroom_channel)
                        + " " + di.getChannelType(tz).toString();
                if (!myDevice && myGroupId == groupId)
                {
                    attached = di.getChannelType(tz) != MultiroomDeviceInformationMsg.ChannelType.NONE;
                }
            }
        }
        view.setDescription(description);
        view.setChecked(attached);
        view.setTag(msg.getIdentifier());
        view.setOnClickListener(v -> {
            MultiroomDeviceItem cv = (MultiroomDeviceItem) v;
            cv.toggle();
        });

        Logging.info(activity, "    ID: " + msg.getIdentifier() + "; " + description + "; attached=" + attached);
        return view;
    }

    private static void sendGroupUpdates(
            @NonNull final MainActivity activity,
            @NonNull final LinearLayout deviceGroup,
            @NonNull final Map<String, Boolean> attachedDevices,
            int myZone,
            int myGroupId)
    {
        final int maxDelay = 3000;

        final MultiroomGroupSettingMsg removeCmd = new MultiroomGroupSettingMsg(
                MultiroomGroupSettingMsg.Command.REMOVE_SLAVE, myZone, 0, maxDelay);

        final MultiroomGroupSettingMsg addCmd = new MultiroomGroupSettingMsg(
                MultiroomGroupSettingMsg.Command.ADD_SLAVE, myZone, myGroupId, maxDelay);

        for (int i = 0; i < deviceGroup.getChildCount(); i++)
        {
            MultiroomDeviceItem cv = (MultiroomDeviceItem) deviceGroup.getChildAt(i);
            final String id = (String) cv.getTag();
            boolean attached = false;
            {
                Boolean _attached = attachedDevices.get(id);
                if (_attached != null)
                {
                    attached = _attached;
                }
            }
            if (!attached && cv.isChecked())
            {
                addCmd.getDevice().add(id);
            }
            else if (attached && !cv.isChecked())
            {
                removeCmd.getDevice().add(id);
            }
        }
        if (removeCmd.getDevice().size() > 0)
        {
            activity.getStateManager().sendMessage(removeCmd);
        }
        if (addCmd.getDevice().size() > 0)
        {
            activity.getStateManager().sendMessage(addCmd);
        }
    }

}
