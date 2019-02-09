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
    public static AlertDialog buildHtmlDialog(Context context, @DrawableRes int icon,
                                              @StringRes int title, @StringRes int textId)
    {
        return buildHtmlDialog(context, icon, title, context.getResources().getString(textId), true);
    }

    public static AlertDialog buildXmlDialog(Context context, @DrawableRes int icon,
                                             @StringRes int title, final String text)
    {
        return buildHtmlDialog(context, icon, title, text, false);
    }

    @SuppressWarnings("deprecation")
    @SuppressLint("NewApi")
    private static AlertDialog buildHtmlDialog(Context context, @DrawableRes int icon,
                                               @StringRes int title, final String text, final boolean isHtml)
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

        if (text.isEmpty())
        {
            return alertDialog;
        }

        final TextView aboutMessage = dialogFrame.findViewById(R.id.text_message);
        if (isHtml)
        {
            Spanned result;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N)
            {
                result = Html.fromHtml(text, Html.FROM_HTML_MODE_LEGACY);
            }
            else
            {
                result = Html.fromHtml(text);
            }
            aboutMessage.setText(result);
            aboutMessage.setMovementMethod(LinkMovementMethod.getInstance());
        }
        else
        {
            aboutMessage.setText(text);
        }

        return alertDialog;
    }
}
