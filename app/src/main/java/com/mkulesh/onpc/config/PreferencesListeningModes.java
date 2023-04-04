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
import com.mkulesh.onpc.iscp.messages.ListeningModeMsg;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.util.ArrayList;
import java.util.List;

import androidx.annotation.NonNull;

public class PreferencesListeningModes extends DraggableListActivity
{
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        Utils.ProtoType protoType = getProtoType();
        Logging.info(this, "Listening mode for: " + protoType);
        prepareList(CfgAudioControl.getSelectedListeningModePar(protoType));
        prepareSelectors(protoType);
        setTitle(R.string.pref_listening_modes);
    }

    private void prepareSelectors(final Utils.ProtoType protoType)
    {
        final ArrayList<String> defItems = new ArrayList<>();
        for (ListeningModeMsg.Mode i : CfgAudioControl.getListeningModes(protoType))
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

    @NonNull
    private Utils.ProtoType getProtoType()
    {
        final String protoType = preferences.getString(Configuration.PROTO_TYPE, "NONE");
        for (Utils.ProtoType p : Utils.ProtoType.values())
        {
            if (p.name().equalsIgnoreCase(protoType))
            {
                return p;
            }
        }
        return Utils.ProtoType.ISCP;
    }
}
