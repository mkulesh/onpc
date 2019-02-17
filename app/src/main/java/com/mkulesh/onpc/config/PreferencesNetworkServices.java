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

import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.iscp.messages.ServiceType;
import com.mkulesh.onpc.utils.Logging;
import com.mobeta.android.dslv.DragSortListView;

import java.util.ArrayList;
import java.util.List;

public class PreferencesNetworkServices extends AppCompatPreferenceActivity
        implements OnItemClickListener, DragSortListView.DropListener
{
    private PreferenceItemAdapter adapter;
    private DragSortListView itemList;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.draggable_preference_activity);
        adapter = new PreferenceItemAdapter(this);
        itemList = findViewById(R.id.list);
        itemList.setAdapter(adapter);
        itemList.setOnItemClickListener(this);
        itemList.setDropListener(this);
        prepareSelectors();
    }

    public void prepareSelectors()
    {
        final String[] allItems = getTokens(Configuration.NETWORK_SERVICES);
        if (allItems.length == 0)
        {
            return;
        }

        final List<PreferenceItemAdapter.Data> targetItems = new ArrayList<>();
        final List<String> checkedItems = new ArrayList<>();
        final String[] selectedItems = getTokens(Configuration.SELECTED_NETWORK_SERVICES);
        if (selectedItems != null)
        {
            for (String s : selectedItems)
            {
                final ServiceType item = (ServiceType) ISCPMessage.searchParameter(
                        s, ServiceType.values(), ServiceType.UNKNOWN);
                if (item != ServiceType.UNKNOWN)
                {
                    checkedItems.add(item.getCode());
                    targetItems.add(new PreferenceItemAdapter.Data(
                            item.getDescriptionId(),
                            item.getCode(),
                            getText(item.getDescriptionId()),
                            item.getImageId()));
                }
            }
        }

        for (String s : allItems)
        {
            final ServiceType item = (ServiceType) ISCPMessage.searchParameter(
                    s, ServiceType.values(), ServiceType.UNKNOWN);
            if (item == ServiceType.UNKNOWN)
            {
                Logging.info(this, "Service not known: " + s);
                continue;
            }
            if (!checkedItems.contains(item.getCode()))
            {
                targetItems.add(new PreferenceItemAdapter.Data(
                        item.getDescriptionId(),
                        item.getCode(),
                        getText(item.getDescriptionId()),
                        item.getImageId()));
            }
        }

        adapter.setItems(targetItems);
        for (int i = 0; i < adapter.getCount(); i++)
        {
            itemList.setItemChecked(i,
                    checkedItems.isEmpty() || checkedItems.contains(targetItems.get(i).getCode()));
        }
    }

    public void save()
    {
        final StringBuilder selectedItems = new StringBuilder();
        for (int i = 0; i < adapter.getCount(); i++)
        {
            final PreferenceItemAdapter.Data d = adapter.getDataItem(i);
            if (d != null && itemList.isItemChecked(i))
            {
                if (!selectedItems.toString().isEmpty())
                {
                    selectedItems.append(",");
                }
                selectedItems.append(d.getCode());
            }
        }
        Logging.info(this, "Selected items: " + selectedItems.toString());
        SharedPreferences.Editor prefEditor = preferences.edit();
        prefEditor.putString(Configuration.SELECTED_NETWORK_SERVICES, selectedItems.toString());
        prefEditor.apply();
    }

    @Override
    public void onItemClick(AdapterView<?> arg0, View arg1, int arg2, long arg3)
    {
        save();
    }

    @Override
    public void drop(int from, int to)
    {
        adapter.drop(from, to);
        save();
    }
}
