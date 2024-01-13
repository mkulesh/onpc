/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2023 by Mikhail Kulesh
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

import android.appwidget.AppWidgetManager;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.os.Bundle;
import android.widget.RemoteViews;
import android.widget.RemoteViewsService;

import com.mkulesh.onpc.utils.Utils;

/**
 * This is the service that provides the factory to be bound to the collection service.
 */
public class WidgetShortcutsService extends RemoteViewsService
{
    @Override
    public RemoteViewsFactory onGetViewFactory(Intent intent)
    {
        return new StackRemoteViewsFactory(this.getApplicationContext(), intent);
    }
}

/**
 * This is the factory that will provide data to the collection widget.
 */
class StackRemoteViewsFactory implements RemoteViewsService.RemoteViewsFactory
{
    private final Context mContext;
    private Cursor mCursor;
    private final int mAppWidgetId;

    StackRemoteViewsFactory(Context context, Intent intent)
    {
        mContext = context;
        mAppWidgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID,
                AppWidgetManager.INVALID_APPWIDGET_ID);
    }

    public void onCreate()
    {
        // empty
    }

    public void onDestroy()
    {
        if (mCursor != null)
        {
            mCursor.close();
        }
    }

    public int getCount()
    {
        return mCursor.getCount();
    }

    public RemoteViews getViewAt(int position)
    {
        // Get the data for this position from the content provider
        String alias = "";
        String script = "";
        if (mCursor.moveToPosition(position))
        {
            final int aliasIdx = mCursor.getColumnIndex(WidgetShortcutsDataProvider.Columns.ALIAS);
            if (aliasIdx >= 0)
            {
                alias = mCursor.getString(aliasIdx);
            }
            final int scriptIdx = mCursor.getColumnIndex(WidgetShortcutsDataProvider.Columns.SCRIPT);
            if (scriptIdx >= 0)
            {
                script = mCursor.getString(scriptIdx);
            }
        }

        // Return a proper item with filled data
        RemoteViews rv = new RemoteViews(mContext.getPackageName(), R.layout.widget_shortcuts_item);
        rv.setTextViewText(R.id.widget_item, alias);
        rv.setTextColor(R.id.widget_item, Utils.getColor(mContext, "widget_b_text", R.color.widget_b_text));

        // Set the click intent so that we can handle it and show a toast message
        final Intent fillInIntent = new Intent();
        final Bundle extras = new Bundle();
        extras.putString(WidgetShortcutsProvider.WIDGET_SHORTCUT, script);
        fillInIntent.putExtras(extras);
        rv.setOnClickFillInIntent(R.id.widget_item, fillInIntent);

        return rv;
    }

    public RemoteViews getLoadingView()
    {
        // We aren't going to return a default loading view in this sample
        return null;
    }

    public int getViewTypeCount()
    {
        return 1;
    }

    public long getItemId(int position)
    {
        return position;
    }

    public boolean hasStableIds()
    {
        return true;
    }

    public void onDataSetChanged()
    {
        if (mCursor != null)
        {
            mCursor.close();
        }
        mCursor = mContext.getContentResolver().query(WidgetShortcutsDataProvider.CONTENT_URI, null, null,
                null, null);
    }
}
