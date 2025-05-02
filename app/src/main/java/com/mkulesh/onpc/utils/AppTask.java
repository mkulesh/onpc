/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2023 by Mikhail Kulesh
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

package com.mkulesh.onpc.utils;

import java.util.concurrent.atomic.AtomicBoolean;

import androidx.annotation.NonNull;

public class AppTask
{
    private final AtomicBoolean active = new AtomicBoolean();
    private final AtomicBoolean cancelled = new AtomicBoolean();
    private Runnable backgroundTask;
    private String backgroundTaskName;

    protected AppTask(boolean a)
    {
        active.set(a);
        cancelled.set(false);
    }

    protected void setBackgroundTask(@NonNull Runnable backgroundTask, @NonNull String backgroundTaskName)
    {
        this.backgroundTask = backgroundTask;
        this.backgroundTaskName = backgroundTaskName;
    }

    public void start()
    {
        final boolean alreadyActive = isActive();
        synchronized (active)
        {
            active.set(true);
        }
        synchronized (cancelled)
        {
            cancelled.set(false);
        }
        if (!alreadyActive && backgroundTask != null && backgroundTaskName != null)
        {
            final Thread thread = new Thread(backgroundTask, backgroundTaskName);
            thread.start();
        }
    }

    public void stop()
    {
        synchronized (active)
        {
            active.set(false);
        }
        synchronized (cancelled)
        {
            cancelled.set(true);
        }
    }

    public boolean isActive()
    {
        synchronized (active)
        {
            return active.get();
        }
    }

    public boolean isCancelled()
    {
        synchronized (cancelled)
        {
            return cancelled.get();
        }
    }
}
