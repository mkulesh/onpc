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

package com.mkulesh.onpc;

import android.graphics.drawable.Drawable;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;

import com.mkulesh.onpc.iscp.PopupBuilder;
import com.mkulesh.onpc.iscp.State;
import com.mkulesh.onpc.iscp.StateManager;
import com.mkulesh.onpc.iscp.messages.CustomPopupMsg;
import com.mkulesh.onpc.iscp.messages.XmlListItemMsg;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.util.List;

class PopupManager
{
    private AlertDialog trackMenuDialog = null;
    private AlertDialog popupDialog = null;

    void showTrackMenuDialog(@NonNull final MainActivity activity, @NonNull final State state)
    {
        closeTrackMenuDialog();

        if (!state.isTrackMenuReceived())
        {
            return;
        }

        Logging.info(this, "open track menu dialog");
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

        final LinearLayout menuGroup = frameView.findViewById(R.id.track_menu_layout);
        final List<XmlListItemMsg> menuItems = state.cloneMediaItems();
        for (final XmlListItemMsg msg : menuItems)
        {
            final LinearLayout itemView = (LinearLayout) LayoutInflater.from(activity).
                    inflate(R.layout.media_item, frameView, false);
            final View textView = itemView.findViewById(R.id.media_item_title);
            if (textView != null)
            {
                ((TextView) textView).setText(msg.getTitle());
            }
            itemView.setOnClickListener((View v) ->
            {
                if (activity.isConnected())
                {
                    activity.getStateManager().sendMessage(msg);
                }
                trackMenuDialog.dismiss();
            });
            menuGroup.addView(itemView);
        }

        trackMenuDialog.setOnDismissListener((d) ->
        {
            Logging.info(this, "closing track menu dialog");
            trackMenuDialog = null;
        });

        trackMenuDialog.show();
        Utils.fixIconColor(trackMenuDialog, android.R.attr.textColorSecondary);
    }

    void closeTrackMenuDialog()
    {
        if (trackMenuDialog != null)
        {
            Logging.info(this, "closing track menu dialog");
            trackMenuDialog.setOnDismissListener(null);
            trackMenuDialog.dismiss();
            trackMenuDialog = null;
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
