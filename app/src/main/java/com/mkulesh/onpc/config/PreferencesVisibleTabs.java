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
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.util.ArrayList;
import java.util.List;

public class PreferencesVisibleTabs extends DraggableListActivity
{
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        prepareList(CfgAppSettings.VISIBLE_TABS);
        prepareSelectors();
        setTitle(R.string.pref_visible_tabs);
    }

    private void prepareSelectors()
    {
        final ArrayList<String> defItems = new ArrayList<>();
        for (CfgAppSettings.Tabs i : CfgAppSettings.Tabs.values())
        {
            defItems.add(i.name());
        }

        final Utils.ProtoType protoType = Configuration.getProtoType(preferences);
        final List<CheckableItem> targetItems = new ArrayList<>();
        final List<String> checkedItems = new ArrayList<>();
        for (CheckableItem sp : CheckableItem.readFromPreference(preferences, adapter.getParameter(), defItems))
        {
            try
            {
                final CfgAppSettings.Tabs item = CfgAppSettings.Tabs.valueOf(sp.code);
                if (!item.isVisible(protoType))
                {
                    continue;
                }
                if (sp.checked)
                {
                    checkedItems.add(item.name());
                }
                targetItems.add(new CheckableItem(
                        item.ordinal(),
                        item.name(),
                        CfgAppSettings.getTabName(this, item),
                        -1, sp.checked));
            }
            catch (Exception ex)
            {
                Logging.info(this, "A tab with code not known: " + sp.code);
            }
        }

        setItems(targetItems, checkedItems);
    }
}
