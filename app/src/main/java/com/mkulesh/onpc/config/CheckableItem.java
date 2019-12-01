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

import android.annotation.SuppressLint;
import android.content.SharedPreferences;

import com.mkulesh.onpc.utils.Logging;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;

class CheckableItem
{
    final int id;
    final String code;
    final String text;
    @DrawableRes
    final int imageId;
    boolean checked;

    CheckableItem(final int id,
                  @NonNull final String code,
                  @NonNull final String text,
                  @DrawableRes final int imageId,
                  final boolean checked)
    {
        this.id = id;
        this.code = code;
        this.text = text;
        this.imageId = imageId;
        this.checked = checked;
    }

    private CheckableItem(@NonNull final String code, final boolean checked)
    {
        this.id = -1;
        this.code = code;
        this.text = "";
        this.imageId = -1;
        this.checked = checked;
    }

    CheckableItem(@NonNull CheckableItem d)
    {
        this.id = d.id;
        this.code = d.code;
        this.text = d.text;
        this.imageId = d.imageId;
        this.checked = d.checked;
    }

    @NonNull
    @Override
    public String toString()
    {
        return code + "/" + checked;
    }

    @SuppressLint("ApplySharedPref")
    static void writeToPreference(
            @NonNull final SharedPreferences preferences,
            @NonNull final String parameter,
            @NonNull final List<CheckableItem> items)
    {
        final StringBuilder selectedItems = new StringBuilder();
        for (CheckableItem d : items)
        {
            if (d != null)
            {
                if (!selectedItems.toString().isEmpty())
                {
                    selectedItems.append(";");
                }
                selectedItems.append(d.code).append(",").append(d.checked);
            }
        }
        Logging.info(preferences, parameter + ": " + selectedItems.toString());
        SharedPreferences.Editor prefEditor = preferences.edit();
        prefEditor.putString(parameter, selectedItems.toString());
        prefEditor.commit();
    }

    @NonNull
    static ArrayList<CheckableItem> readFromPreference(
            @NonNull final SharedPreferences preference,
            @NonNull final String parameter,
            @NonNull final ArrayList<String> defItems)
    {
        ArrayList<CheckableItem> retValue = new ArrayList<>();
        final String cfg = preference.getString(parameter, "");

        // Add items stored in the configuration
        if (!cfg.isEmpty())
        {
            final ArrayList<String> items = new ArrayList<>(Arrays.asList(cfg.split(";")));
            if (items.isEmpty())
            {
                for (String d : defItems)
                {
                    retValue.add(new CheckableItem(d, true));
                }
            }
            else
            {
                for (String d : items)
                {
                    String[] item = d.split(",");
                    if (item.length == 1)
                    {
                        retValue.add(new CheckableItem(item[0], true));
                    }
                    else if (item.length == 2)
                    {
                        retValue.add(new CheckableItem(item[0], Boolean.parseBoolean(item[1])));
                    }
                }
            }
        }

        // Add missed default items
        for (String d : defItems)
        {
            boolean found = false;
            for (CheckableItem p : retValue)
            {
                if (d.equals(p.code))
                {
                    found = true;
                    break;
                }
            }
            if (!found)
            {
                retValue.add(new CheckableItem(d, true));
            }
        }

        return retValue;
    }
}
