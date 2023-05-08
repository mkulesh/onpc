/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2023 by Mikhail Kulesh
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
import com.mkulesh.onpc.iscp.messages.InputSelectorMsg;
import com.mkulesh.onpc.utils.Logging;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static com.mkulesh.onpc.utils.Utils.getStringPref;

public class PreferencesDeviceSelectors extends DraggableListActivity
{
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        prepareList(Configuration.getSelectedDeviceSelectorsParameter(preferences));
        prepareSelectors();
        setTitle(R.string.pref_device_selectors);
    }

    private void prepareSelectors()
    {
        final String[] allItems = getTokens(Configuration.DEVICE_SELECTORS);
        if (allItems == null || allItems.length == 0)
        {
            return;
        }

        final boolean fName = preferences.getBoolean(Configuration.FRIENDLY_NAMES, true);
        final ArrayList<String> defItems = new ArrayList<>(Arrays.asList(allItems));
        final List<CheckableItem> targetItems = new ArrayList<>();
        final List<String> checkedItems = new ArrayList<>();
        for (CheckableItem sp : CheckableItem.readFromPreference(preferences, adapter.getParameter(), defItems))
        {
            final InputSelectorMsg.InputType item =
                    (InputSelectorMsg.InputType) InputSelectorMsg.searchParameter(
                            sp.code, InputSelectorMsg.InputType.values(), InputSelectorMsg.InputType.NONE);
            if (item == InputSelectorMsg.InputType.NONE)
            {
                Logging.info(this, "Input selector not known: " + sp.code);
                continue;
            }
            if (sp.checked)
            {
                checkedItems.add(item.getCode());
            }

            final String defName = getString(item.getDescriptionId());
            final String name = fName ? getStringPref(preferences,
                    Configuration.DEVICE_SELECTORS + "_" + item.getCode(), defName) : defName;
            targetItems.add(new CheckableItem(
                    item.getDescriptionId(),
                    item.getCode(),
                    name,
                    -1, sp.checked));
        }

        setItems(targetItems, checkedItems);
    }
}
