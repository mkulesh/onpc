/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2022 by Mikhail Kulesh
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

package com.mkulesh.onpc.fragments;

import android.graphics.drawable.Drawable;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.mkulesh.onpc.MainActivity;
import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.PopupBuilder;
import com.mkulesh.onpc.iscp.State;
import com.mkulesh.onpc.iscp.StateManager;
import com.mkulesh.onpc.iscp.messages.CustomPopupMsg;
import com.mkulesh.onpc.iscp.messages.XmlListItemMsg;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.util.List;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;

class PopupManager
{
    private AlertDialog trackMenuDialog = null;
    private LinearLayout trackMenuGroup = null;
    private AlertDialog popupDialog = null;

    void showTrackMenuDialog(@NonNull final MainActivity activity, @NonNull final State state)
    {
        if (trackMenuDialog == null)
        {
            Logging.info(this, "create track menu dialog");
            final FrameLayout frameView = new FrameLayout(activity);

            final Drawable icon = Utils.getDrawable(activity, R.drawable.cmd_track_menu);
            Utils.setDrawableColorAttr(activity, icon, android.R.attr.textColorSecondary);

            trackMenuDialog = new AlertDialog.Builder(activity)
                    .setTitle(R.string.cmd_track_menu)
                    .setIcon(icon)
                    .setCancelable(false)
                    .setView(frameView)
                    .setNegativeButton(activity.getResources().getString(R.string.action_cancel), (d, which) ->
                    {
                        if (activity.isConnected())
                        {
                            activity.getStateManager().sendMessage(StateManager.RETURN_MSG);
                        }
                        d.dismiss();
                    })
                    .create();

            trackMenuDialog.getLayoutInflater().inflate(R.layout.dialog_track_menu, frameView);
            trackMenuDialog.setOnDismissListener((d) ->
            {
                Logging.info(this, "close track menu dialog");
                trackMenuDialog = null;
                trackMenuGroup = null;
            });

            trackMenuGroup = frameView.findViewById(R.id.track_menu_layout);
            updateTrackMenuGroup(activity, state, trackMenuGroup);

            trackMenuDialog.show();
            Utils.fixIconColor(trackMenuDialog, android.R.attr.textColorSecondary);
        }
        else if (trackMenuGroup != null)
        {
            Logging.info(this, "update track menu dialog");
            updateTrackMenuGroup(activity, state, trackMenuGroup);
        }
    }

    private void updateTrackMenuGroup(@NonNull final MainActivity activity,
                                      @NonNull final State state,
                                      @NonNull LinearLayout trackMenuGroup)
    {
        trackMenuGroup.removeAllViews();
        final List<XmlListItemMsg> menuItems = state.cloneMediaItems();
        for (final XmlListItemMsg msg : menuItems)
        {
            if (msg.getTitle() == null || msg.getTitle().isEmpty())
            {
                continue;
            }
            Logging.info(this, "    menu item: " + msg.toString());
            final LinearLayout itemView = (LinearLayout) LayoutInflater.from(activity).
                    inflate(R.layout.media_item, trackMenuGroup, false);
            final View textView = itemView.findViewById(R.id.media_item_title);
            if (textView != null)
            {
                ((TextView) textView).setText(msg.getTitle());
                if (!msg.isSelectable())
                {
                    ((TextView) textView).setTextColor(Utils.getThemeColorAttr(activity,
                            android.R.attr.textColorSecondary));
                    ((TextView) textView).setTextSize(TypedValue.COMPLEX_UNIT_PX,
                            activity.getResources().getDimensionPixelSize(R.dimen.secondary_text_size));
                }
            }
            itemView.setOnClickListener((View v) ->
            {
                if (activity.isConnected())
                {
                    activity.getStateManager().sendMessage(msg);
                }
                if (trackMenuDialog != null)
                {
                    trackMenuDialog.dismiss();
                }
            });
            trackMenuGroup.addView(itemView);
        }
    }

    void closeTrackMenuDialog()
    {
        if (trackMenuDialog != null)
        {
            Logging.info(this, "close track menu dialog");
            trackMenuDialog.setOnDismissListener(null);
            trackMenuDialog.dismiss();
            trackMenuDialog = null;
            trackMenuGroup = null;
        }
    }

    void showPopupDialog(@NonNull final MainActivity activity, @NonNull final State state)
    {
        closePopupDialog();

        final CustomPopupMsg inMsg = state.popup.getAndSet(null);
        if (inMsg == null)
        {
            return;
        }

        try
        {
            PopupBuilder builder = new PopupBuilder(activity, state, (outMsg) ->
            {
                if (activity.isConnected())
                {
                    activity.getStateManager().sendMessage(outMsg);
                }
            });
            popupDialog = builder.build(inMsg);
            if (popupDialog == null)
            {
                return;
            }

            popupDialog.setOnDismissListener((d) ->
            {
                Logging.info(this, "closing popup dialog");
                popupDialog = null;
            });

            popupDialog.show();
            Utils.fixIconColor(popupDialog, android.R.attr.textColorSecondary);
        }
        catch (Exception e)
        {
            Logging.info(this, "can not create popup dialog: " + e.getLocalizedMessage());
        }
    }

    void closePopupDialog()
    {
        if (popupDialog != null)
        {
            Logging.info(this, "closing popup dialog");
            popupDialog.setOnDismissListener(null);
            popupDialog.dismiss();
            popupDialog = null;
        }
    }
}
