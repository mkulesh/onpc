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

import android.os.Bundle;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.iscp.messages.ServiceType;
import com.mkulesh.onpc.utils.Logging;

import java.util.ArrayList;
import java.util.List;

public class PreferencesNetworkServices extends DraggableListActivity
{
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        prepareList(R.layout.draggable_preference_activity, Configuration.SELECTED_NETWORK_SERVICES);
        prepareSelectors();
    }

    public void prepareSelectors()
    {
        final String[] allItems = getTokens(Configuration.NETWORK_SERVICES);
        if (allItems == null || allItems.length == 0)
        {
            return;
        }

        final List<CheckableItemAdapter.Data> targetItems = new ArrayList<>();
        final List<String> checkedItems = new ArrayList<>();
        final String[] selectedItems = getTokens(adapter.getParameter());
        if (selectedItems != null)
        {
            for (String s : selectedItems)
            {
                final ServiceType item = (ServiceType) ISCPMessage.searchParameter(
                        s, ServiceType.values(), ServiceType.UNKNOWN);
                if (item != ServiceType.UNKNOWN)
                {
                    checkedItems.add(item.getCode());
                    targetItems.add(new CheckableItemAdapter.Data(
                            item.getDescriptionId(),
                            item.getCode(),
                            getText(item.getDescriptionId()),
                            item.getImageId(), true));
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
                targetItems.add(new CheckableItemAdapter.Data(
                        item.getDescriptionId(),
                        item.getCode(),
                        getText(item.getDescriptionId()),
                        item.getImageId(), checkedItems.isEmpty()));
            }
        }

        setItems(targetItems, checkedItems);
    }
}
