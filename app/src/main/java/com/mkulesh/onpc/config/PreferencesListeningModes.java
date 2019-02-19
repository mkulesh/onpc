/*
 * Copyright (C) 2018. Mikhail Kulesh
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
import com.mkulesh.onpc.iscp.messages.ListeningModeMsg;

import java.util.ArrayList;
import java.util.List;

public class PreferencesListeningModes extends DraggableListActivity
{
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        prepareList(R.layout.draggable_preference_activity, Configuration.SELECTED_LISTENING_MODES);
        prepareSelectors();
    }

    public void prepareSelectors()
    {
        final ListeningModeMsg.Mode[] allItems = Configuration.getListeningModes();

        final List<CheckableItemAdapter.Data> targetItems = new ArrayList<>();
        final List<String> checkedItems = new ArrayList<>();
        final String[] selectedItems = getTokens(adapter.getParameter());
        if (selectedItems != null)
        {
            for (String s : selectedItems)
            {
                final ListeningModeMsg.Mode item = (ListeningModeMsg.Mode) ISCPMessage.searchParameter(
                        s, ListeningModeMsg.Mode.values(), ListeningModeMsg.Mode.UP);
                if (item != ListeningModeMsg.Mode.UP)
                {
                    checkedItems.add(item.getCode());
                    targetItems.add(new CheckableItemAdapter.Data(
                            item.getDescriptionId(),
                            item.getCode(),
                            getText(item.getDescriptionId()),
                            -1, true));
                }
            }
        }

        for (ListeningModeMsg.Mode item : allItems)
        {
            if (!checkedItems.contains(item.getCode()))
            {
                targetItems.add(new CheckableItemAdapter.Data(
                        item.getDescriptionId(),
                        item.getCode(),
                        getText(item.getDescriptionId()),
                        -1, checkedItems.isEmpty()));
            }
        }

        setItems(targetItems, checkedItems);
    }
}
