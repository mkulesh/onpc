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
import android.widget.BaseAdapter;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.config.CfgFavoriteShortcuts;
import com.mkulesh.onpc.iscp.messages.ServiceType;
import com.mkulesh.onpc.widgets.DraggableItemView;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

class ShortcutsListAdapter extends BaseAdapter
{
    private final LayoutInflater inflater;
    private final List<CfgFavoriteShortcuts.Shortcut> items = new ArrayList<>();
    private final CfgFavoriteShortcuts favoriteShortcuts;

    ShortcutsListAdapter(Context context, final CfgFavoriteShortcuts favoriteShortcuts)
    {
        this.inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        this.favoriteShortcuts = favoriteShortcuts;
    }

    void setItems(final List<CfgFavoriteShortcuts.Shortcut> newItems)
    {
        items.clear();
        for (CfgFavoriteShortcuts.Shortcut d : newItems)
        {
            items.add(new CfgFavoriteShortcuts.Shortcut(d, d.alias));
        }
        Collections.sort(items, (o1, o2) -> Integer.compare(o1.order, o2.order));
        notifyDataSetChanged();
    }

    @Override
    public int getCount()
    {
        return items.size();
    }

    @Override
    public Object getItem(int position)
    {
        return position < items.size() ? items.get(position) : null;
    }

    @Override
    public long getItemId(int position)
    {
        return position < items.size() ? items.get(position).id : 0;
    }

    @Override
    public boolean hasStableIds()
    {
        return true;
    }

    @Override
    public View getView(int position, View convert, ViewGroup parent)
    {
        DraggableItemView view;
        if (convert == null)
        {
            view = (DraggableItemView) inflater.inflate(R.layout.draggable_item_view, parent, false);
        }
        else
        {
            view = (DraggableItemView) convert;
        }
        final CfgFavoriteShortcuts.Shortcut d = items.get(position);
        view.setTag(d.id);
        view.setText(d.alias);
        view.setCheckBoxVisibility(View.GONE);
        if (d.service != ServiceType.UNKNOWN)
        {
            view.setImage(d.service.getImageId());
        }
        return view;
    }

    void drop(int from, int to)
    {
        if (from != to && from < items.size() && to < items.size())
        {
            CfgFavoriteShortcuts.Shortcut p = items.remove(from);
            items.add(to, p);
            favoriteShortcuts.reorder(items);
        }
        notifyDataSetChanged();
    }
}
