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

package com.mkulesh.onpc.iscp;

import com.mkulesh.onpc.utils.Logging;

import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;

public class StateHolder
{
    private StateManager stateManager = null;
    private final AtomicBoolean released = new AtomicBoolean();
    private boolean appExit = false;

    public StateHolder()
    {
        released.set(true);
    }

    public void setStateManager(StateManager stateManager)
    {
        this.stateManager = stateManager;
        synchronized (released)
        {
            released.set(stateManager == null);
        }
    }

    public StateManager getStateManager()
    {
        return stateManager;
    }

    public State getState()
    {
        return stateManager == null ? null : stateManager.getState();
    }

    public void release(boolean appExit, String reason)
    {
        this.appExit = appExit;
        synchronized (released)
        {
            if (stateManager != null)
            {
                Logging.info(this, "request to release state holder (" + reason + ")");
                released.set(false);
                // state manager may be set to null in setStateManager during the setting
                // "released" to false
                if (stateManager != null)
                {
                    stateManager.stop();
                }
            }
            else
            {
                released.set(true);
            }
        }
    }

    public void waitForRelease()
    {
        while (true)
        {
            synchronized (released)
            {
                if (released.get())
                {
                    Logging.info(this, "state holder released");
                    return;
                }
            }
            try
            {
                TimeUnit.MILLISECONDS.sleep(50);
            }
            catch (InterruptedException e)
            {
                // nothing to do
            }
        }
    }

    public boolean isAppExit()
    {
        return appExit;
    }
}
