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
import org.w3c.dom.Node;

import java.util.ArrayList;
import java.util.List;

public class CfgFavoriteShortcuts
{
    private static final String FAVORITE_SHORTCUT_TAG = "favoriteShortcut";
    private static final String FAVORITE_SHORTCUT_NUMBER = "favorite_shortcut_number";
    private static final String FAVORITE_SHORTCUT_ITEM = "favorite_shortcut_item";

    public static class Shortcut
    {
        public final int id;
        public final InputSelectorMsg.InputType input;
        public final ServiceType service;
        public final String item;
        public final String alias;
        public int order;
        final List<String> pathItems = new ArrayList<>();

        Shortcut(final Element e)
        {
            this.id = Utils.parseIntAttribute(e, "id", 0);
            this.input = (InputSelectorMsg.InputType) InputSelectorMsg.searchParameter(
                    e.getAttribute("input"), InputSelectorMsg.InputType.values(), InputSelectorMsg.InputType.NONE);
            this.service = (ServiceType) ISCPMessage.searchParameter(
                    e.getAttribute("service"), ServiceType.values(), ServiceType.UNKNOWN);
            this.item = e.getAttribute("item");
            this.alias = e.getAttribute("alias");
            this.order = Utils.parseIntAttribute(e, "order", id);
            for (Node dir = e.getFirstChild(); dir != null; dir = dir.getNextSibling())
            {
                if (dir instanceof Element)
                {
                    if (((Element) dir).getTagName().equals("dir"))
                    {
                        this.pathItems.add(((Element) dir).getAttribute("name"));
                    }
                }
            }
        }

        public Shortcut(final Shortcut old, final String alias)
        {
            this.id = old.id;
            this.input = old.input;
            this.service = old.service;
            this.item = old.item;
            this.alias = alias;
            this.order = old.order;
            this.pathItems.addAll(old.pathItems);
        }

        public Shortcut(final int id, final InputSelectorMsg.InputType input, final ServiceType service, final String item, final String alias)
        {
            this.id = id;
            this.input = input;
            this.service = service;
            this.item = item;
            this.alias = alias;
            this.order = id;
        }

        public void setPathItems(final List<String> path)
        {
            pathItems.clear();
            for (int i = 1; i < path.size(); i++)
            {
                pathItems.add(path.get(i));
            }
        }

        @Override
        @NonNull
        public String toString()
        {
            StringBuilder label = new StringBuilder();
            label.append("<").append(FAVORITE_SHORTCUT_TAG);
            label.append(" id=\"").append(id).append("\"");
            label.append(" input=\"").append(input.getCode()).append("\"");
            label.append(" service=\"").append(service.getCode()).append("\"");
            label.append(" item=\"").append(item).append("\"");
            label.append(" alias=\"").append(alias).append("\"");
            label.append(" order=\"").append(order).append("\">");
            for (String dir : pathItems)
            {
                label.append("<dir name=\"").append(dir).append("\"/>");
            }
            label.append("</" + FAVORITE_SHORTCUT_TAG + ">");
            return label.toString();
        }

        public String getLabel(Context context)
        {
            StringBuilder label = new StringBuilder();

            if (input != InputSelectorMsg.InputType.NONE)
            {
                label.append(context.getString(input.getDescriptionId())).append("/");
            }

            if (input == InputSelectorMsg.InputType.NET && service != ServiceType.UNKNOWN)
            {
                label.append(context.getString(service.getDescriptionId())).append("/");
            }

            for (String dir : pathItems)
            {
                label.append(dir).append("/");
            }
            label.append(item);
            return label.toString();
        }

        @NonNull
        public String toScript(final Context context)
        {
            final StringBuilder data = new StringBuilder();
            data.append("<onpcScript host=\"\" port=\"\" zone=\"0\">");
            data.append("<send cmd=\"PWR\" par=\"QSTN\" wait=\"PWR\"/>");
            data.append("<send cmd=\"PWR\" par=\"01\" wait=\"PWR\" resp=\"01\"/>");
            data.append("<send cmd=\"SLI\" par=\"QSTN\" wait=\"SLI\"/>");
            data.append("<send cmd=\"SLI\" par=\"").append(input.getCode())
                    .append("\" wait=\"SLI\" resp=\"").append(input.getCode()).append("\"/>");
            data.append("<send cmd=\"NLT\" par=\"QSTN\" wait=\"NLT\"/>");

            // Go to the top level. Response depends on the input type
            String firstPath = pathItems.isEmpty() ? item : pathItems.get(0);
            if (input == InputSelectorMsg.InputType.NET && service != ServiceType.UNKNOWN)
            {
                data.append("<send cmd=\"NTC\" par=\"TOP\" wait=\"NLS\" listitem=\"")
                        .append(context.getString(service.getDescriptionId())).append("\"/>");
            }
            else
            {
                data.append("<send cmd=\"NTC\" par=\"TOP\" wait=\"NLA\" listitem=\"")
                        .append(firstPath).append("\"/>");
            }

            // Select target service
            data.append("<send cmd=\"NSV\" par=\"").append(service.getCode())
                    .append("0\" wait=\"NLA\" listitem=\"").append(firstPath).append("\"/>");

            // Apply target path, if necessary
            if (!pathItems.isEmpty())
            {
                for (int i = 0; i < pathItems.size() - 1; i++)
                {
                    firstPath = pathItems.get(i);
                    String nextPath = pathItems.get(i + 1);
                    data.append("<send cmd=\"NLA\" par=\"").append(firstPath)
                            .append("\" wait=\"NLA\" listitem=\"").append(nextPath).append("\"/>");
                }
                String lastPath = pathItems.get(pathItems.size() - 1);
                data.append("<send cmd=\"NLA\" par=\"").append(lastPath)
                        .append("\" wait=\"NLA\" listitem=\"").append(item).append("\"/>");
            }

            // Select target item
            data.append("<send cmd=\"NLA\" par=\"").append(item).append("\" wait=\"1000\"/>");
            data.append("</onpcScript>");
            return data.toString();            
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

    public void updateShortcut(@NonNull final Shortcut shortcut, final String alias)
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

    public int getNextId()
    {
        int id = 0;
        for (Shortcut s : shortcuts)
        {
            id = Math.max(id, s.id);
        }
        return id + 1;
    }

    public void reorder(List<Shortcut> items)
    {
        for (int i = 0; i < items.size(); i++)
        {
            int idx = find(items.get(i).id);
            if (idx >= 0)
            {
                shortcuts.get(idx).order = i;
            }
        }
        write();
    }
}
