/*
 * Copyright (C) 2020. Mikhail Kulesh
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

import android.content.Context;
import android.content.SharedPreferences;

import androidx.annotation.NonNull;

import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.iscp.messages.InputSelectorMsg;
import com.mkulesh.onpc.iscp.messages.ServiceType;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import org.w3c.dom.Element;

import java.util.ArrayList;
import java.util.List;

public class CfgFavoriteShortcuts
{
    public static final int FAVORITE_SHORTCUT_MAX = 6;
    private static final String FAVORITE_SHORTCUT_TAG = "favoriteShortcut";
    private static final String FAVORITE_SHORTCUT_NUMBER = "favorite_shortcut_number";
    private static final String FAVORITE_SHORTCUT_ITEM = "favorite_shortcut_item";

    public static class Shortcut
    {
        public final int id;
        public final String input;
        public final String service;
        public final String path;
        public final String item;
        public final String alias;

        Shortcut(final Element e)
        {
            this.id = Utils.parseIntAttribute(e, "id", 0);
            this.input = e.getAttribute("input");
            this.service = e.getAttribute("service");
            this.path = e.getAttribute("path");
            this.item = e.getAttribute("item");
            this.alias = e.getAttribute("alias");
        }

        Shortcut(final Shortcut old, final String alias)
        {
            this.id = old.id;
            this.input = old.input;
            this.service = old.service;
            this.path = old.path;
            this.item = old.item;
            this.alias = alias;
        }

        public Shortcut(final int id, final String input, final String service, final String path, final String item, final String alias)
        {
            this.id = id;
            this.input = input;
            this.service = service;
            this.path = path;
            this.item = item;
            this.alias = alias;
        }

        @Override
        @NonNull
        public String toString()
        {
            return "<" + FAVORITE_SHORTCUT_TAG
                    + " id=\"" + id + "\""
                    + " input=\"" + input + "\""
                    + " service=\"" + service + "\""
                    + " path=\"" + path + "\""
                    + " item=\"" + item + "\""
                    + " alias=\"" + alias + "\" />";
        }

        public String getLabel(Context context)
        {
            StringBuilder label = new StringBuilder();

            final InputSelectorMsg.InputType inputType =
                    (InputSelectorMsg.InputType) InputSelectorMsg.searchParameter(
                            input, InputSelectorMsg.InputType.values(), InputSelectorMsg.InputType.NONE);
            if (inputType != InputSelectorMsg.InputType.NONE)
            {
                label.append(context.getString(inputType.getDescriptionId())).append("/");
            }

            if (inputType == InputSelectorMsg.InputType.NET)
            {
                final ServiceType serviceType = (ServiceType) ISCPMessage.searchParameter(
                        service, ServiceType.values(), ServiceType.UNKNOWN);
                if (serviceType != ServiceType.UNKNOWN)
                {
                    label.append(context.getString(serviceType.getDescriptionId())).append("/");
                }
            }

            if (!path.isEmpty())
            {
                label.append(path).append("/");
            }
            label.append(item);
            return label.toString();
        }
    }

    private final ArrayList<Shortcut> shortcuts = new ArrayList<>();

    private SharedPreferences preferences;

    void setPreferences(SharedPreferences preferences)
    {
        this.preferences = preferences;
    }

    void read()
    {
        shortcuts.clear();
        final int fcNumber = preferences.getInt(FAVORITE_SHORTCUT_NUMBER, 0);
        for (int i = 0; i < fcNumber; i++)
        {
            final String key = FAVORITE_SHORTCUT_ITEM + "_" + i;
            Utils.openXml(this, preferences.getString(key, ""), (final Element elem) ->
            {
                if (elem.getTagName().equals(FAVORITE_SHORTCUT_TAG))
                {
                    shortcuts.add(new Shortcut(elem));
                }
            });
        }
    }

    private void write()
    {
        final int fcNumber = shortcuts.size();
        SharedPreferences.Editor prefEditor = preferences.edit();
        prefEditor.putInt(FAVORITE_SHORTCUT_NUMBER, fcNumber);
        for (int i = 0; i < fcNumber; i++)
        {
            final String key = FAVORITE_SHORTCUT_ITEM + "_" + i;
            prefEditor.putString(key, shortcuts.get(i).toString());
        }
        prefEditor.apply();
    }

    @NonNull
    public final List<Shortcut> getShortcuts()
    {
        return shortcuts;
    }

    private int find(final int id)
    {
        for (int i = 0; i < shortcuts.size(); i++)
        {
            final Shortcut item = shortcuts.get(i);
            if (item.id == id)
            {
                return i;
            }
        }
        return -1;
    }

    public Shortcut updateShortcut(@NonNull final Shortcut shortcut, final String alias)
    {
        Shortcut newMsg;
        int idx = find(shortcut.id);
        if (idx >= 0)
        {
            final Shortcut oldMsg = shortcuts.get(idx);
            newMsg = new Shortcut(oldMsg, alias);
            Logging.info(this, "Update favorite shortcut: " + oldMsg.toString() + " -> " + newMsg.toString());
            shortcuts.set(idx, newMsg);
        }
        else
        {
            newMsg = new Shortcut(shortcut, alias);
            Logging.info(this, "Add favorite shortcut: " + newMsg.toString());
            shortcuts.add(newMsg);
        }
        write();
        return newMsg;
    }

    public void deleteShortcut(@NonNull final Shortcut shortcut)
    {
        int idx = find(shortcut.id);
        if (idx >= 0)
        {
            final Shortcut oldMsg = shortcuts.get(idx);
            Logging.info(this, "Delete favorite shortcut: " + oldMsg.toString());
            shortcuts.remove(oldMsg);
            write();
        }
    }
}
