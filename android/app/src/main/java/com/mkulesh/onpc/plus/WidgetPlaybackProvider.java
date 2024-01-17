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
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.widget.RemoteViews;

/**
 * The playback widget's AppWidgetProvider.
 */
public class WidgetPlaybackProvider extends WidgetBase
{
    // Actions
    private static final String RUN_ACTION = "com.mkulesh.onpc.plus.playback.RUN";
    public static final String REFRESH_ACTION = "com.mkulesh.onpc.plus.playback.REFRESH";
    private static final String PLAYBACK_ACTION = "com.mkulesh.onpc.plus.playback.PLAYBACK_ACTION:";
    // Intents send to Flutter
    public static final String TARGET_CONTROL = "com.mkulesh.onpc.plus.CONTROL:PLC";

    public WidgetPlaybackProvider()
    {
        super("WidgetPlaybackProvider-worker");
    }

    public static PendingIntent buildIntent(Context context, String action)
    {
        final Intent intent = new Intent(context, WidgetPlaybackProvider.class);
        intent.setAction(action);
        // noinspection NewApi
        return PendingIntent.getBroadcast(context, 1, intent, PendingIntent.FLAG_IMMUTABLE);
    }

    @Override
    public void onEnabled(Context context)
    {
        if (dartBundlePath == null)
        {
            dartBundlePath = initializeFlutterEngine(context);
        }
    }

    @Override
    public void onReceive(Context ctx, Intent intent)
    {
        Log.d("onpc", "WidgetPlayback action: " + intent);
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
                final AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context);
                final ComponentName thisWidget = new ComponentName(context, WidgetPlaybackProvider.class);
                onUpdate(context, appWidgetManager, appWidgetManager.getAppWidgetIds(thisWidget));
            });
        }
        else if (RUN_ACTION.equals(action))
        {
            openApp(ctx, ctx.getPackageName(), TARGET_CONTROL);
        }
        else if (action != null && action.startsWith(PLAYBACK_ACTION))
        {
            final String cmd = action.replaceFirst(PLAYBACK_ACTION, "");
            executeDartCallback(ctx, dartBundlePath, cmd);
        }

        super.onReceive(ctx, intent);
    }

    @Override
    protected RemoteViews buildLayout(Context context, int appWidgetId)
    {
        readParameters(context);
        RemoteViews rv = new RemoteViews(context.getPackageName(), R.layout.widget_playback_layout);

        // Background
        rv.setInt(R.id.widget_background, "setImageResource",
                darkTheme ? R.drawable.widget_background_dark : R.drawable.widget_background_light);
        rv.setInt(R.id.widget_background, "setImageAlpha",
                transparency ? alpha : 255);

        // Prepare the title
        rv.setTextViewText(R.id.widget_name, title);
        rv.setTextColor(R.id.widget_name, textColor);
        rv.setOnClickPendingIntent(R.id.app_icon, buildIntent(context, WidgetPlaybackProvider.RUN_ACTION));
        rv.setInt(R.id.widget_divider, "setColorFilter", imageColor);
        rv.setInt(R.id.widget_divider, "setImageAlpha", alpha);

        // Prepare items
        prepareButton(context, rv, R.id.btn_power, R.drawable.cmd_power, imageColor, imageBgColor,
                buildIntent(context, PLAYBACK_ACTION + "widget_playback_power"));
        prepareButton(context, rv, R.id.btn_previous, R.drawable.cmd_previous, imageColor, imageBgColor,
                buildIntent(context, PLAYBACK_ACTION + "widget_playback_previous"));
        prepareButton(context, rv, R.id.btn_next, R.drawable.cmd_next, imageColor, imageBgColor,
                buildIntent(context, PLAYBACK_ACTION + "widget_playback_next"));
        prepareButton(context, rv, R.id.btn_stop, R.drawable.cmd_stop, imageColor, imageBgColor,
                buildIntent(context, PLAYBACK_ACTION + "widget_playback_stop"));
        prepareButton(context, rv, R.id.btn_play, R.drawable.cmd_play, imageColor, imageBgColor,
                buildIntent(context, PLAYBACK_ACTION + "widget_playback_play"));
        prepareButton(context, rv, R.id.btn_volume_up, R.drawable.cmd_volume_up, imageColor, imageBgColor,
                buildIntent(context, PLAYBACK_ACTION + "widget_playback_volume_up"));
        prepareButton(context, rv, R.id.btn_volume_down, R.drawable.cmd_volume_down, imageColor, imageBgColor,
                buildIntent(context, PLAYBACK_ACTION + "widget_playback_volume_down"));
        prepareButton(context, rv, R.id.btn_volume_off, R.drawable.cmd_volume_off, imageColor, imageBgColor,
                buildIntent(context, PLAYBACK_ACTION + "widget_playback_volume_off"));

        return rv;
    }
}
