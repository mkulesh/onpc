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
import android.content.SharedPreferences;
import android.support.annotation.DrawableRes;
import android.support.v7.preference.PreferenceManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.utils.Logging;

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
        boolean checked;

        Data(final int id, String code, CharSequence text, @DrawableRes int imageId, boolean checked)
        {
            this.id = id;
            this.code = code;
            this.text = text;
            this.imageId = imageId;
            this.checked = checked;
        }

        Data(Data d)
        {
            this.id = d.id;
            this.code = d.code;
            this.text = d.text;
            this.imageId = d.imageId;
            this.checked = d.checked;
        }

        public String getCode()
        {
            return code;
        }
    }

    private final LayoutInflater inflater;
    private final List<Data> items = new ArrayList<>();
    private final SharedPreferences preferences;
    private String parameter;

    PreferenceItemAdapter(Context context, String parameter)
    {
        inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        preferences = PreferenceManager.getDefaultSharedPreferences(context);
        this.parameter = parameter;
    }

    String getParameter()
    {
        return parameter;
    }

    void setItems(final List<Data> newItems)
    {
        for (Data d : newItems)
        {
            items.add(new Data(d));
        }
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
            if (p.checked)
            {
                save();
            }
        }
        notifyDataSetChanged();
    }

    void setChecked(int pos, boolean checked)
    {
        if (pos < items.size())
        {
            Data p = items.get(pos);
            p.checked = checked;
            save();
        }
        notifyDataSetChanged();
    }

    private void save()
    {
        final StringBuilder selectedItems = new StringBuilder();
        for (Data d : items)
        {
            if (d != null && d.checked)
            {
                if (!selectedItems.toString().isEmpty())
                {
                    selectedItems.append(",");
                }
                selectedItems.append(d.getCode());
            }
        }
        Logging.info(this, parameter + ": " + selectedItems.toString());
        SharedPreferences.Editor prefEditor = preferences.edit();
        prefEditor.putString(parameter, selectedItems.toString());
        prefEditor.apply();
    }
}
