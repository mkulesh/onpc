/*
 * Copyright (C) 2018. Mikhail Kulesh
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
import android.content.Context;
import android.content.DialogInterface;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.support.annotation.DrawableRes;
import android.support.annotation.StringRes;
import android.support.v7.app.AlertDialog;
import android.text.Html;
import android.text.Spanned;
import android.text.method.LinkMovementMethod;
import android.view.LayoutInflater;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.mkulesh.onpc.R;

public class HtmlDialogBuilder
{
    private final static String VERSION_TAG = "<version/>";

    @SuppressWarnings("deprecation")
    @SuppressLint("NewApi")
    public static AlertDialog buildDialog(Context context, @DrawableRes int icon,
                                          @StringRes int title, @StringRes int text)
    {
        final FrameLayout frameView = new FrameLayout(context);
        final AlertDialog alertDialog = new AlertDialog.Builder(context)
                .setTitle(title)
                .setIcon(icon)
                .setCancelable(true)
                .setView(frameView)
                .setPositiveButton(context.getResources().getString(R.string.action_ok),
                        new DialogInterface.OnClickListener()
                        {
                            @Override
                            public void onClick(DialogInterface dialog, int which)
                            {
                                // empty
                            }
                        }).create();

        final LayoutInflater inflater = alertDialog.getLayoutInflater();
        final FrameLayout dialogFrame = (FrameLayout) inflater.inflate(R.layout.html_dialog_layout, frameView);

        String htmlSource = context.getResources().getString(text);
        if (htmlSource.isEmpty())
        {
            return alertDialog;
        }

        // Process app-specific tags like <version/>
        if (htmlSource.contains(VERSION_TAG))
        {
            try
            {
                final PackageInfo pi = context.getPackageManager().getPackageInfo(context.getPackageName(), 0);
                htmlSource = htmlSource.replace(VERSION_TAG, pi.versionName);
            }
            catch (PackageManager.NameNotFoundException e)
            {
                htmlSource = htmlSource.replace(VERSION_TAG, "unknown");
            }
        }

        Spanned result;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N)
        {
            result = Html.fromHtml(htmlSource, Html.FROM_HTML_MODE_LEGACY);
        }
        else
        {
            result = Html.fromHtml(htmlSource);
        }

        final TextView aboutMessage = dialogFrame.findViewById(R.id.text_message);
        aboutMessage.setText(result);
        aboutMessage.setMovementMethod(LinkMovementMethod.getInstance());

        return alertDialog;
    }
}
