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

import android.widget.Checkable;

import com.mkulesh.onpc.R;
import com.mobeta.android.dslv.DragSortListView;

import java.util.List;

public class DraggableListActivity extends AppCompatPreferenceActivity
{
    protected PreferenceItemAdapter adapter;

    protected void prepareList(int layoutId, String parameter)
    {
        setContentView(layoutId);
        adapter = new PreferenceItemAdapter(this, parameter);
    }

    protected String[] getTokens(String par)
    {
        final String cfg = preferences.getString(par, "");
        return cfg.isEmpty() ? null : cfg.split(",");
    }

    protected void setItems(List<PreferenceItemAdapter.Data> targetItems, List<String> checkedItems)
    {
        adapter.setItems(targetItems);
        final DragSortListView itemList = findViewById(R.id.list);
        itemList.setAdapter(adapter);
        for (int i = 0; i < adapter.getCount(); i++)
        {
            itemList.setItemChecked(i,
                    checkedItems.isEmpty() || checkedItems.contains(targetItems.get(i).getCode()));
        }
        itemList.setOnItemClickListener((adapterView, view, pos, l) ->
        {
            if (view instanceof Checkable)
            {
                adapter.setChecked(pos, ((Checkable) view).isChecked());
            }
        });
        itemList.setDropListener((int from, int to) -> adapter.drop(from, to));
    }
}
