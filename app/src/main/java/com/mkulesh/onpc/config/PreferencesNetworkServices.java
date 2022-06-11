/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2022 by Mikhail Kulesh
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
import java.util.Arrays;
import java.util.List;

public class PreferencesNetworkServices extends DraggableListActivity
{
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        prepareList(Configuration.getSelectedNetworkServicesParameter(preferences));
        prepareSelectors();
        setTitle(R.string.pref_network_services);
    }

    private void prepareSelectors()
    {
        final String[] allItems = getTokens(Configuration.NETWORK_SERVICES);
        if (allItems == null || allItems.length == 0)
        {
            return;
        }

        final ArrayList<String> defItems = new ArrayList<>(Arrays.asList(allItems));
        final List<CheckableItem> targetItems = new ArrayList<>();
        final List<String> checkedItems = new ArrayList<>();
        for (CheckableItem sp : CheckableItem.readFromPreference(preferences, adapter.getParameter(), defItems))
        {
            final ServiceType item = (ServiceType) ISCPMessage.searchParameter(
                    sp.code, ServiceType.values(), ServiceType.UNKNOWN);
            if (item == ServiceType.UNKNOWN)
            {
                Logging.info(this, "Service not known: " + sp.code);
                continue;
            }
            if (sp.checked)
            {
                checkedItems.add(item.getCode());
            }
            targetItems.add(new CheckableItem(
                    item.getDescriptionId(),
                    item.getCode(),
                    getString(item.getDescriptionId()),
                    item.getImageId(), sp.checked));
        }

        setItems(targetItems, checkedItems);
    }
}
