/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2023 by Mikhail Kulesh
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
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RadioGroup;

import com.mkulesh.onpc.MainActivity;
import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.State;
import com.mkulesh.onpc.iscp.messages.DcpSearchMsg;
import com.mkulesh.onpc.utils.Utils;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.view.ContextThemeWrapper;
import androidx.appcompat.widget.AppCompatEditText;
import androidx.appcompat.widget.AppCompatRadioButton;

public class Dialogs
{
    private final MainActivity activity;

    interface ButtonListener
    {
        void onPositiveButton();
    }

    Dialogs(final MainActivity activity)
    {
        this.activity = activity;
    }

    public void showDcpSearchDialog(@NonNull final State state, final ButtonListener bl)
    {
        if (state.getDcpSearchCriteria() == null)
        {
            return;
        }

        final FrameLayout frameView = new FrameLayout(activity);
        activity.getLayoutInflater().inflate(R.layout.dialog_dcp_search_layout, frameView);

        final RadioGroup searchCriteria = frameView.findViewById(R.id.search_criteria_group);
        for (int i = 0; i < state.getDcpSearchCriteria().size(); i++)
        {
            final ContextThemeWrapper wrappedContext = new ContextThemeWrapper(activity, R.style.RadioButtonStyle);
            final AppCompatRadioButton b = new AppCompatRadioButton(wrappedContext, null, 0);
            final LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
            b.setLayoutParams(lp);
            b.setText(getTranslatedName(activity, state.getDcpSearchCriteria().get(i).first));
            b.setTag(state.getDcpSearchCriteria().get(i).second);
            b.setChecked(i == 0);
            b.setTextColor(Utils.getThemeColorAttr(activity, android.R.attr.textColor));
            b.setOnClickListener((v) -> {
                for (int k = 0; k < searchCriteria.getChildCount(); k++)
                {
                    final AppCompatRadioButton b1 = (AppCompatRadioButton) searchCriteria.getChildAt(k);
                    b1.setChecked(b1.getTag().equals(v.getTag()));
                }
            });
            searchCriteria.addView(b);
        }
        searchCriteria.invalidate();
        final AppCompatEditText searchText = frameView.findViewById(R.id.search_string);
        searchText.setText(activity.getStateManager().getState().artist);

        final Drawable icon = Utils.getDrawable(activity, R.drawable.cmd_search);
        Utils.setDrawableColorAttr(activity, icon, android.R.attr.textColorSecondary);
        final AlertDialog dialog = new AlertDialog.Builder(activity)
                .setTitle(R.string.medialist_search)
                .setIcon(icon)
                .setCancelable(true)
                .setView(frameView)
                .setNegativeButton(activity.getResources().getString(R.string.action_cancel), (dialog1, which) -> dialog1.dismiss())
                .setPositiveButton(activity.getResources().getString(R.string.action_ok), (dialog2, which) ->
                {
                    for (int i = 0; i < searchCriteria.getChildCount(); i++)
                    {
                        final AppCompatRadioButton b = (AppCompatRadioButton) searchCriteria.getChildAt(i);
                        if (b.isChecked() && searchText.getText() != null && searchText.getText().length() > 0)
                        {
                            activity.getStateManager().sendMessage(new DcpSearchMsg(
                                    activity.getStateManager().getState().mediaListSid,
                                    b.getTag().toString(),
                                    searchText.getText().toString()));
                            if (bl != null)
                            {
                                bl.onPositiveButton();
                            }
                        }
                    }
                    dialog2.dismiss();
                })
                .create();

        dialog.show();
        Utils.fixIconColor(dialog, android.R.attr.textColorSecondary);
    }

    @NonNull
    static String getTranslatedName(@NonNull MainActivity activity, String item)
    {
        final String[] sourceNames = new String[]{
                "Artist",
                "Album",
                "Track",
                "Station",
                "Playlist"
        };
        final int[] targetNames = new int[]{
                R.string.medialist_search_artist,
                R.string.medialist_search_album,
                R.string.medialist_search_track,
                R.string.medialist_search_station,
                R.string.medialist_search_playlist
        };
        for (int i = 0; i < sourceNames.length; i++)
        {
            if (sourceNames[i].equalsIgnoreCase(item))
            {
                return activity.getString(targetNames[i]);
            }
        }
        return item;
    }
}
