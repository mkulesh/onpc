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

package com.mkulesh.onpc.config;

import android.content.Context;
import android.support.annotation.DrawableRes;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;

import com.mkulesh.onpc.R;

import java.util.ArrayList;
import java.util.List;

public class PreferenceItemAdapter extends BaseAdapter
{
    static class Data
    {
        final int id;
        final String code;
        final CharSequence text;
        @DrawableRes
        final int imageId;

        Data(final int id, String code, CharSequence text, @DrawableRes int imageId)
        {
            this.id = id;
            this.code = code;
            this.text = text;
            this.imageId = imageId;
        }

        Data(Data d)
        {
            this.id = d.id;
            this.code = d.code;
            this.text = d.text;
            this.imageId = d.imageId;
        }

        public String getCode()
        {
            return code;
        }
    }

    private final LayoutInflater inflater;
    private final List<Data> items = new ArrayList<>();

    PreferenceItemAdapter(Context context)
    {
        inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
    }

    void setItems(final List<Data> newItems)
    {
        for (Data d : newItems)
        {
            items.add(new Data(d));
        }
        notifyDataSetChanged();
    }

    public Data getDataItem(int i)
    {
        return (i < items.size()) ? items.get(i) : null;
    }

    @Override
    public int getCount()
    {
        return items.size();
    }

    @Override
    public Object getItem(int position)
    {
        return null;
    }

    @Override
    public long getItemId(int position)
    {
        return items.get(position).id;
    }

    @Override
    public boolean hasStableIds()
    {
        return true;
    }

    @Override
    public View getView(int position, View convert, ViewGroup parent)
    {
        DraggableItem view;
        if (convert == null)
        {
            view = (DraggableItem) inflater.inflate(R.layout.draggable_item, parent, false);
        }
        else
        {
            view = (DraggableItem) convert;
        }
        final Data d = items.get(position);
        view.setTag(d.code);
        view.setText(d.text);
        if (d.imageId > 0)
        {
            view.setImage(d.imageId);
        }
        return view;
    }

    void drop(int from, int to)
    {
        if (from != to && from < items.size() && to < items.size())
        {
            Data p = items.remove(from);
            items.add(to, p);
        }
        notifyDataSetChanged();
    }
}
