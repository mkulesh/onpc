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

import android.annotation.SuppressLint;
import android.util.Log;

import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.atomic.AtomicInteger;

@SuppressWarnings("SameReturnValue")
public final class Logging
{
    public static boolean saveLogging = false;
    private final static int LOG_SIZE = 5000;
    private final static BlockingQueue<String> latestLogging = new ArrayBlockingQueue<>(LOG_SIZE, true);
    private final static AtomicInteger logLineNumber = new AtomicInteger(0);

    public static boolean isEnabled()
    {
        // Should be false in release build
        return true;
    }

    public static boolean isTimeMsgEnabled()
    {
        // Should be false in release build
        return false;
    }

    @SuppressLint("DefaultLocale")
    public static void info(Object o, String text)
    {
        if (isEnabled())
        {
            final String out = o.getClass().getSimpleName() + ": " + text;
            if (saveLogging)
            {
                try
                {
                    if (latestLogging.size() >= LOG_SIZE - 1)
                    {
                        latestLogging.take();
                    }
                    final int l = logLineNumber.addAndGet(1);
                    latestLogging.offer(String.format("#%04d: ", l) + out);
                }
                catch (Exception e)
                {
                    // nothing to do
                }
            }

            Log.d("onpc", out);
        }
    }

    public static String getLatestLogging()
    {
        final StringBuilder str = new StringBuilder();
        try
        {
            while (!latestLogging.isEmpty())
            {
                str.append(latestLogging.take()).append("\n");
            }
        }
        catch (Exception e)
        {
            str.append("Can not collect logging: ").append(e.getLocalizedMessage());
        }
        return str.toString();
    }
}
