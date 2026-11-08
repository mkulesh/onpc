/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2026 by Mikhail Kulesh
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

import android.content.SharedPreferences;
import android.os.Build;
import android.widget.Toast;

import com.mkulesh.onpc.MainActivity;
import com.mkulesh.onpc.R;

import androidx.activity.OnBackPressedCallback;
import androidx.preference.PreferenceManager;

public class ExitConfirm extends OnBackPressedCallback
{
    private static final String EXIT_CONFIRM = "exit_confirm";
    private Toast exitToast = null;
    final MainActivity activity;

    public ExitConfirm(boolean enabled, final MainActivity activity)
    {
        super(enabled);
        this.activity = activity;
    }

    @Override
    public void handleOnBackPressed()
    {
        Logging.info(this, "handleOnBackPressed called");
        final SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(activity);
        if (activity.isBackAsReturn())
        {
            return;
        }
        if (!preferences.getBoolean(EXIT_CONFIRM, false))
        {
            activity.finish();
        }
        else if (Utils.isToastVisible(exitToast))
        {
            exitToast.cancel();
            exitToast = null;
            activity.finish();
        }
        else
        {
            exitToast = Toast.makeText(activity, R.string.action_exit_confirm, Toast.LENGTH_LONG);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R)
            {
                exitToast.addCallback(new Toast.Callback()
                {
                    @Override
                    public void onToastHidden()
                    {
                        exitToast = null;
                    }
                });
            }
            if (exitToast != null)
            {
                exitToast.show();
            }
        }
    }
}