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
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;
import android.widget.RemoteViews;

import com.mkulesh.onpc.utils.Utils;

import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.loader.FlutterLoader;
import io.flutter.view.FlutterCallbackInformation;

public abstract class WidgetBase extends AppWidgetProvider
{
    protected static HandlerThread sWorkerThread;
    protected static Handler sWorkerQueue;
    protected static String dartBundlePath;
    protected String title;
    protected boolean darkTheme;
    protected boolean transparency;
    protected int textColor;
    protected int imageColor;
    protected int imageBgColor;
    protected int alpha;

    public WidgetBase(String name)
    {
        // Start the worker thread
        sWorkerThread = new HandlerThread(name);
        sWorkerThread.start();
        sWorkerQueue = new Handler(sWorkerThread.getLooper());
    }

    abstract protected RemoteViews buildLayout(Context context, int appWidgetId);

    protected void readParameters(Context context)
    {
        final SharedPreferences preferences = context.getSharedPreferences(Utils.SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
        Map<String, ?> allPrefs = preferences.getAll();
        final String model = Utils.readStringPreference(allPrefs, "model", "");
        final boolean friendlyNames = Utils.readBooleanPreference(allPrefs, "friendly_names", true);
        title = friendlyNames ? Utils.readStringPreference(allPrefs, "device_friendly_name", "") : model;
        final long activeZone = Utils.readIntPreference(allPrefs, "active_zone", 0);
        if (!title.isEmpty() && activeZone > 0)
        {
            final long zone = activeZone + 1;
            final String oldName = "Zone" + zone;
            final String newName = Utils.readStringPreference(allPrefs, ("zone_name_" + zone + "_" + model).toLowerCase(), oldName);
            title += ("/" + newName);
        }
        darkTheme = Utils.readBooleanPreference(allPrefs, "widget_dark_theme", false);
        transparency = Utils.readBooleanPreference(allPrefs, "widget_transparency", true);
        textColor = Utils.getColor(context, "widget_h_text", R.color.widget_h_text);
        imageColor = Utils.getColor(context, "widget_b_text", R.color.widget_b_text);
        imageBgColor = darkTheme ? R.drawable.widget_touch_background_dark : R.drawable.widget_touch_background_light;
        alpha = (50 * 255 / 100);
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

    protected void openApp(Context context, String packageName, String script)
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

    protected void prepareButton(Context context, RemoteViews rv, int widgetId, int imageId, int imageColor, int bgColor, PendingIntent action)
    {
        final Drawable drawable = Utils.getDrawable(context, imageId);
        if (drawable != null)
        {
            drawable.clearColorFilter();
            Utils.setColorFilter(drawable, imageColor);
            rv.setImageViewBitmap(widgetId, Utils.drawableToBitmap(drawable));
        }
        rv.setOnClickPendingIntent(widgetId, action);
        rv.setInt(widgetId, "setBackgroundResource", bgColor);
    }

    protected String initializeFlutterEngine(Context context)
    {
        Log.d("onpc", "Started Flutter engine initialization");
        FlutterLoader flutterLoader = new FlutterLoader();
        if (!flutterLoader.initialized())
        {
            flutterLoader.startInitialization(context);
            flutterLoader.ensureInitializationComplete(context, null);
            final String bundlePath = flutterLoader.findAppBundlePath();
            Log.d("onpc", "Finished Flutter engine initialization, bundlePath=" + bundlePath);
            return bundlePath;
        }
        return null;
    }

    protected void executeDartCallback(Context context, String bundlePath, String dispatcherHandlerName)
    {
        final FlutterEngine flutterEngine = new FlutterEngine(context);
        final SharedPreferences preferences = context.getSharedPreferences(Utils.SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
        final long dispatcherHandler = preferences.getLong("flutter." + dispatcherHandlerName, -1L);
        if (dispatcherHandler != -1L)
        {
            FlutterCallbackInformation callbackInfo = FlutterCallbackInformation.lookupCallbackInformation(dispatcherHandler);
            flutterEngine.getDartExecutor().executeDartCallback(
                    new DartExecutor.DartCallback(context.getAssets(), bundlePath, callbackInfo));
            Log.d("onpc", "Called widget callback " + dispatcherHandlerName);
        }
    }
}
