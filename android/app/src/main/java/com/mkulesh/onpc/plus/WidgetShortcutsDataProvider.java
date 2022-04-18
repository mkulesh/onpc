/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2022 by Mikhail Kulesh
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

package com.mkulesh.onpc.plus;

import android.content.ContentProvider;
import android.content.ContentValues;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.database.MatrixCursor;
import android.net.Uri;
import android.util.Log;

import com.mkulesh.onpc.config.CfgFavoriteShortcuts;
import com.mkulesh.onpc.utils.Utils;

import java.util.ArrayList;

/**
 * The AppWidgetProvider that provides the configuration of shortcuts.
 */
public class WidgetShortcutsDataProvider extends ContentProvider
{
    public static final Uri CONTENT_URI = Uri.parse("content://com.mkulesh.onpc.pro.shortcuts");

    static class Columns
    {
        static final String ID = "_id";
        static final String ALIAS = "_alias";
        static final String SCRIPT = "_script";
    }

    private final ArrayList<CfgFavoriteShortcuts.Shortcut> shortcuts = new ArrayList<>();

    private void readData()
    {
        shortcuts.clear();
        if (getContext() != null)
        {
            final SharedPreferences preferences = getContext().getSharedPreferences(
                    Utils.SHARED_PREFERENCES_NAME, getContext().MODE_PRIVATE);
            final CfgFavoriteShortcuts cfg = new CfgFavoriteShortcuts();
            cfg.read(preferences);
            shortcuts.addAll(cfg.getShortcuts());
            Log.d("onpc", "read shortcuts: " + shortcuts.size());
        }
    }

    @Override
    public boolean onCreate()
    {
        readData();
        return true;
    }

    @Override
    public synchronized Cursor query(Uri uri, String[] projection, String selection,
                                     String[] selectionArgs, String sortOrder)
    {
        final MatrixCursor c = new MatrixCursor(new String[]{ Columns.ID, Columns.ALIAS, Columns.SCRIPT });
        for (CfgFavoriteShortcuts.Shortcut data : shortcuts)
        {
            c.addRow(new Object[]{ data.id, data.alias, WidgetShortcutsProvider.WIDGET_SHORTCUT + ":" + data.id });
        }
        return c;
    }

    @Override
    public String getType(Uri uri)
    {
        return "vnd.android.cursor.dir/com.mkulesh.onpc.pro.alias";
    }

    @Override
    public Uri insert(Uri uri, ContentValues values)
    {
        // This example code does not support inserting
        return null;
    }

    @Override
    public int delete(Uri uri, String selection, String[] selectionArgs)
    {
        // This example code does not support deleting
        return 0;
    }

    @Override
    public synchronized int update(Uri uri, ContentValues values, String selection,
                                   String[] selectionArgs)
    {
        readData();

        // Notify any listeners that the data backing the content provider has changed, and return
        // the number of rows affected.
        if (getContext() != null)
        {
            getContext().getContentResolver().notifyChange(uri, null);
        }
        return shortcuts.size();
    }
}
