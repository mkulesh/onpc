package com.mkulesh.onpc.utils;

import android.util.Log;

public final class Logging
{
    public static void info(Object o, String text)
    {
        Log.d("onpc", o.getClass().getSimpleName() + ": " + text);
    }
}
