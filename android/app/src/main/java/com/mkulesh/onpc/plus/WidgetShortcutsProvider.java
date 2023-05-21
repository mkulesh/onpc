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

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.ActivityNotFoundException;
import android.content.ComponentName;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.database.ContentObserver;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;
import android.widget.RemoteViews;

import com.mkulesh.onpc.utils.Utils;

/**
 * The shortcuts widget's AppWidgetProvider.
 */
public class WidgetShortcutsProvider extends AppWidgetProvider
{
    public static final String RUN_ACTION = "com.mkulesh.onpc.pro.RUN";
    public static final String CLICK_ACTION = "com.mkulesh.onpc.pro.CLICK";
    public static final String REFRESH_ACTION = "com.mkulesh.onpc.pro.REFRESH";
    public static final String WIDGET_SHORTCUT = "com.mkulesh.onpc.plus.WIDGET_SHORTCUT";

    private static HandlerThread sWorkerThread;
    private static Handler sWorkerQueue;
    private static WeatherDataProviderObserver sDataObserver;

    public WidgetShortcutsProvider()
    {
        // Start the worker thread
        sWorkerThread = new HandlerThread("WidgetShortcutsProvider-worker");
        sWorkerThread.start();
        sWorkerQueue = new Handler(sWorkerThread.getLooper());
    }

    @Override
    public void onEnabled(Context context)
    {
        // Register for external updates to the data to trigger an update of the widget.  When using
        // content providers, the data is often updated via a background service, or in response to
        // user interaction in the main app.  To ensure that the widget always reflects the current
        // state of the data, we must listen for changes and update ourselves accordingly.
        final ContentResolver r = context.getContentResolver();
        if (sDataObserver == null)
        {
            final AppWidgetManager mgr = AppWidgetManager.getInstance(context);
            final ComponentName cn = new ComponentName(context, WidgetShortcutsProvider.class);
            sDataObserver = new WeatherDataProviderObserver(mgr, cn, sWorkerQueue);
            r.registerContentObserver(WidgetShortcutsDataProvider.CONTENT_URI, true, sDataObserver);
        }
    }

    @Override
    public void onReceive(Context ctx, Intent intent)
    {
        final String action = intent.getAction();
        if (REFRESH_ACTION.equals(action))
        {
            // BroadcastReceivers have a limited amount of time to do work, so for this sample, we
            // are triggering an update of the data on another thread.  In practice, this update
            // can be triggered from a background service, or perhaps as a result of user actions
            // inside the main application.
            final Context context = ctx;
            sWorkerQueue.removeMessages(0);
            sWorkerQueue.post(() -> {
                final ContentResolver r = context.getContentResolver();

                // We disable the data changed observer temporarily since each of the updates
                // will trigger an onChange() in our data observer.
                try
                {
                    r.unregisterContentObserver(sDataObserver);
                }
                catch (Exception ex)
                {
                    // nothing to do
                }

                final Uri uri = ContentUris.withAppendedId(WidgetShortcutsDataProvider.CONTENT_URI, 0);
                final ContentValues values = new ContentValues();
                r.update(uri, values, null, null);
                try
                {
                    r.registerContentObserver(WidgetShortcutsDataProvider.CONTENT_URI, true, sDataObserver);
                }
                catch (Exception ex)
                {
                    // nothing to do
                }

                final AppWidgetManager mgr = AppWidgetManager.getInstance(context);
                final ComponentName cn = new ComponentName(context, WidgetShortcutsProvider.class);
                mgr.notifyAppWidgetViewDataChanged(mgr.getAppWidgetIds(cn), R.id.shortcuts_list);

                final AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context);
                final ComponentName thisWidget = new ComponentName(context, WidgetShortcutsProvider.class);
                onUpdate(context, appWidgetManager, appWidgetManager.getAppWidgetIds(thisWidget));
            });
        }
        else if (CLICK_ACTION.equals(action))
        {
            openApp(ctx, ctx.getPackageName(), intent.getStringExtra(WIDGET_SHORTCUT));
        }
        else if (RUN_ACTION.equals(action))
        {
            openApp(ctx, ctx.getPackageName(), null);
        }

        super.onReceive(ctx, intent);
    }

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds)
    {
        // Update each of the widgets with the remote adapter
        for (int appWidgetId : appWidgetIds)
        {
            RemoteViews layout = buildLayout(context, appWidgetId);
            appWidgetManager.updateAppWidget(appWidgetId, layout);
        }
        super.onUpdate(context, appWidgetManager, appWidgetIds);
    }

    @Override
    public void onAppWidgetOptionsChanged(Context context, AppWidgetManager appWidgetManager,
                                          int appWidgetId, Bundle newOptions)
    {
        appWidgetManager.updateAppWidget(appWidgetId, buildLayout(context, appWidgetId));
    }

    private void openApp(Context context, String packageName, String script)
    {
        final PackageManager manager = context.getPackageManager();
        try
        {
            Intent i = manager.getLaunchIntentForPackage(packageName);
            if (i != null)
            {
                i.addCategory(Intent.CATEGORY_LAUNCHER);
                if (script != null)
                {
                    i.setDataAndType(Uri.parse(script), "text/xml");
                }
                Log.d("onpc", "called with intent: " + i);
                context.startActivity(i);
            }
        }
        catch (ActivityNotFoundException e)
        {
            // empty
        }
    }

    private RemoteViews buildLayout(Context context, int appWidgetId)
    {
        RemoteViews rv;
        // Specify the service to provide data for the collection widget.  Note that we need to
        // embed the appWidgetId via the data otherwise it will be ignored.
        final Intent intent = new Intent(context, WidgetShortcutsService.class);
        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId);
        intent.setData(Uri.parse(intent.toUri(Intent.URI_INTENT_SCHEME)));
        rv = new RemoteViews(context.getPackageName(), R.layout.widget_shortcuts_layout);
        rv.setRemoteAdapter(R.id.shortcuts_list, intent);

        // Set the empty view to be displayed if the collection is empty.  It must be a sibling
        // view of the collection view.
        rv.setEmptyView(R.id.shortcuts_list, R.id.empty_view);

        // Prepare the title
        final int hColor = Utils.getColor(context, "widget_h_text", R.color.widget_h_text);
        rv.setInt(R.id.widget_title, "setBackgroundColor",
                Utils.getColor(context, "widget_h_background", R.color.widget_h_background));
        rv.setTextViewText(R.id.widget_name, context.getString(R.string.shortcut_widget_name));
        rv.setTextColor(R.id.widget_name, hColor);
        {
            final Intent refreshIntent = new Intent(context, WidgetShortcutsProvider.class);
            refreshIntent.setAction(WidgetShortcutsProvider.RUN_ACTION);
            // noinspection NewApi
            final PendingIntent refreshPendingIntent = PendingIntent.getBroadcast(context, 0,
                    refreshIntent, PendingIntent.FLAG_IMMUTABLE);
            rv.setOnClickPendingIntent(R.id.app_icon, refreshPendingIntent);
        }

        // Prepare refresh button
        final Drawable drawable = Utils.getDrawable(context, R.drawable.widget_refresh);
        if (drawable != null)
        {
            drawable.clearColorFilter();
            Utils.setColorFilter(drawable, hColor);
            rv.setImageViewBitmap(R.id.widget_refresh, Utils.drawableToBitmap(drawable));
        }
        {
            final Intent refreshIntent = new Intent(context, WidgetShortcutsProvider.class);
            refreshIntent.setAction(WidgetShortcutsProvider.REFRESH_ACTION);
            // noinspection NewApi
            final PendingIntent refreshPendingIntent = PendingIntent.getBroadcast(context, 0,
                    refreshIntent, PendingIntent.FLAG_IMMUTABLE);
            rv.setOnClickPendingIntent(R.id.widget_refresh, refreshPendingIntent);
        }

        // Prepare items
        rv.setInt(R.id.widget_content, "setBackgroundColor",
                Utils.getColor(context, "widget_b_background", R.color.widget_b_background));
        {
            final Intent onClickIntent = new Intent(context, WidgetShortcutsProvider.class);
            onClickIntent.setAction(WidgetShortcutsProvider.CLICK_ACTION);
            onClickIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId);
            onClickIntent.setData(Uri.parse(onClickIntent.toUri(Intent.URI_INTENT_SCHEME)));
            // noinspection NewApi
            final PendingIntent onClickPendingIntent = PendingIntent.getBroadcast(context, 0,
                    onClickIntent, PendingIntent.FLAG_MUTABLE);
            rv.setPendingIntentTemplate(R.id.shortcuts_list, onClickPendingIntent);
        }
        return rv;
    }
}

/**
 * Our data observer just notifies an update for all weather widgets when it detects a change.
 */
class WeatherDataProviderObserver extends ContentObserver
{
    private final AppWidgetManager mAppWidgetManager;
    private final ComponentName mComponentName;

    WeatherDataProviderObserver(AppWidgetManager mgr, ComponentName cn, Handler h)
    {
        super(h);
        mAppWidgetManager = mgr;
        mComponentName = cn;
    }

    @Override
    public void onChange(boolean selfChange)
    {
        // The data has changed, so notify the widget that the collection view needs to be updated.
        // In response, the factory's onDataSetChanged() will be called which will requery the
        // cursor for the new data.
        mAppWidgetManager.notifyAppWidgetViewDataChanged(
                mAppWidgetManager.getAppWidgetIds(mComponentName), R.id.shortcuts_list);
    }
}
