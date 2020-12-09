/*
 * Enhanced Controller for Onkyo and Pioneer
 * Copyright (C) 2018-2020. Mikhail Kulesh
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
import com.mkulesh.onpc.utils.Logging;

import java.util.ArrayList;
import java.util.List;

public class PreferencesListeningModes extends DraggableListActivity
{
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        prepareList(CfgAudioControl.SELECTED_LISTENING_MODES);
        prepareSelectors();
        setTitle(R.string.pref_listening_modes);
    }

    private void prepareSelectors()
    {
        final ArrayList<String> defItems = new ArrayList<>();
        for (ListeningModeMsg.Mode i : CfgAudioControl.DEFAULT_LISTENING_MODES)
        {
            defItems.add(i.getCode());
        }

        final List<CheckableItem> targetItems = new ArrayList<>();
        final List<String> checkedItems = new ArrayList<>();
        for (CheckableItem sp : CheckableItem.readFromPreference(preferences, adapter.getParameter(), defItems))
        {
            final ListeningModeMsg.Mode item = (ListeningModeMsg.Mode) ISCPMessage.searchParameter(
                    sp.code, ListeningModeMsg.Mode.values(), ListeningModeMsg.Mode.UP);
            if (item == ListeningModeMsg.Mode.UP)
            {
                Logging.info(this, "Listening mode not known: " + sp.code);
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
                    -1, sp.checked));
        }

        setItems(targetItems, checkedItems);
    }
}
