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

package com.mkulesh.onpc.utils;

import java.util.concurrent.atomic.AtomicBoolean;

public class AppTask
{
    private final AtomicBoolean active = new AtomicBoolean();

    protected AppTask(boolean a)
    {
        active.set(a);
    }

    public void start()
    {
        synchronized (active)
        {
            active.set(true);
        }
    }

    public void stop()
    {
        synchronized (active)
        {
            active.set(false);
        }
    }

    public boolean isActive()
    {
        synchronized (active)
        {
            return active.get();
        }
    }
}
