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

import com.mkulesh.onpc.R;
import com.mobeta.android.dslv.DragSortListView;

import java.util.List;

public abstract class DraggableListActivity extends AppCompatPreferenceActivity
{
    CheckableItemAdapter adapter;

    void prepareList(String parameter)
    {
        setContentView(R.layout.draggable_preference_activity);
        adapter = new CheckableItemAdapter(this, parameter);
    }

    String[] getTokens(String par)
    {
        final String cfg = preferences.getString(par, "");
        return cfg.isEmpty() ? null : cfg.split(",");
    }

    void setItems(List<CheckableItem> targetItems, List<String> checkedItems)
    {
        adapter.setItems(targetItems);
        final DragSortListView itemList = findViewById(R.id.list);
        itemList.setAdapter(adapter);
        for (int i = 0; i < adapter.getCount(); i++)
        {
            itemList.setItemChecked(i, checkedItems.contains(targetItems.get(i).code));
        }
        itemList.setOnItemClickListener((adapterView, view, pos, l) ->
                adapter.setChecked(pos, ((DragSortListView)adapterView).isItemChecked(pos)));
        itemList.setDropListener((int from, int to) ->
                adapter.drop(from, to));
    }
}
