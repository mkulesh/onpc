/*
 * Enhanced Controller for Onkyo and Pioneer
 * Copyright (C) 2018-2021 by Mikhail Kulesh
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

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.iscp.messages.NetworkServiceMsg;
import com.mkulesh.onpc.iscp.messages.OperationCommandMsg;
import com.mkulesh.onpc.iscp.messages.PresetCommandMsg;
import com.mkulesh.onpc.iscp.messages.XmlListItemMsg;
import com.mkulesh.onpc.utils.Utils;

import java.util.ArrayList;

import androidx.annotation.NonNull;

final class MediaListAdapter extends ArrayAdapter<ISCPMessage>
{
    private final MediaFragment mediaFragment;

    MediaListAdapter(final MediaFragment mediaFragment, Context context, ArrayList<ISCPMessage> list)
    {
        super(context, 0, list);
        this.mediaFragment = mediaFragment;
    }

    @NonNull
    @Override
    public View getView(int position, View convertView, @NonNull ViewGroup parent)
    {
        // Get the data item for this position
        ISCPMessage item = getItem(position);

        // Check if an existing view is being reused, otherwise inflate the view
        if (convertView == null)
        {
            convertView = LayoutInflater.from(getContext()).inflate(R.layout.media_item, parent, false);
        }

        final ImageView icon = convertView.findViewById(R.id.media_item_icon);
        final TextView tvTitle = convertView.findViewById(R.id.media_item_title);

        if (item instanceof XmlListItemMsg)
        {
            final XmlListItemMsg msg = (XmlListItemMsg) item;
            if (msg.getIcon() != XmlListItemMsg.Icon.UNKNOWN)
            {
                icon.setImageResource(msg.getIcon().getImageId());
                icon.setVisibility(View.VISIBLE);
                boolean isPlaying = msg.getIcon() == XmlListItemMsg.Icon.PLAY;
                Utils.setImageViewColorAttr(mediaFragment.activity, icon,
                        isPlaying ? R.attr.colorAccent : R.attr.colorButtonDisabled);
            }
            else if (!msg.isSelectable())
            {
                icon.setImageDrawable(null);
                icon.setVisibility(View.GONE);
            }
            tvTitle.setText(msg.getTitle());
            tvTitle.setTextColor(Utils.getThemeColorAttr(mediaFragment.activity,
                    (mediaFragment.moveFrom == msg.getMessageId() || !msg.isSelectable()) ?
                            android.R.attr.textColorSecondary : android.R.attr.textColor));
        }
        else if (item instanceof NetworkServiceMsg)
        {
            final NetworkServiceMsg msg = (NetworkServiceMsg) item;
            icon.setImageResource(msg.getService().getImageId());
            final boolean isPlaying = mediaFragment.activity.getStateManager() != null &&
                    mediaFragment.activity.getStateManager().getState().serviceIcon == msg.getService();
            Utils.setImageViewColorAttr(mediaFragment.activity, icon,
                    isPlaying ? R.attr.colorAccent : R.attr.colorButtonDisabled);
            tvTitle.setText(msg.getService().getDescriptionId());
        }
        else if (item instanceof OperationCommandMsg)
        {
            final OperationCommandMsg msg = (OperationCommandMsg) item;
            if (msg.getCommand().isImageValid())
            {
                icon.setImageResource(msg.getCommand().getImageId());
                Utils.setImageViewColorAttr(mediaFragment.activity, icon, android.R.attr.textColor);
            }
            tvTitle.setText(msg.getCommand().getDescriptionId());
        }
        else if (item instanceof PresetCommandMsg)
        {
            final PresetCommandMsg msg = (PresetCommandMsg) item;
            if (msg.getPreset() != PresetCommandMsg.NO_PRESET)
            {
                icon.setImageResource(R.drawable.media_item_play);
                Utils.setImageViewColorAttr(mediaFragment.activity, icon, R.attr.colorAccent);
            }
            else
            {
                icon.setImageResource(msg.getPresetConfig().getImageId());
                Utils.setImageViewColorAttr(mediaFragment.activity, icon, android.R.attr.textColor);
            }
            tvTitle.setText(msg.getPresetConfig().displayedString());
        }

        return convertView;
    }
}
