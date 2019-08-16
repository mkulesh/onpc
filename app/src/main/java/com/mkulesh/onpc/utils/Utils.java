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
import android.content.res.Configuration;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.MenuItem;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.ImageView;
import android.widget.Toast;

import com.mkulesh.onpc.R;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.ArrayList;
import java.util.List;

import androidx.annotation.AttrRes;
import androidx.annotation.ColorInt;
import androidx.annotation.NonNull;
import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.widget.AppCompatImageButton;
import androidx.drawerlayout.widget.DrawerLayout;

public class Utils
{
    public static byte[] catBuffer(byte[] bytes, int offset, int length)
    {
        final byte[] newBytes = new byte[length];
        System.arraycopy(bytes, offset, newBytes, 0, length);
        return newBytes;
    }

    @SuppressWarnings("deprecation")
    @SuppressLint("NewApi")
    public static Drawable getDrawable(Context context, int icon)
    {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
        {
            return context.getResources().getDrawable(icon, context.getTheme());
        }
        else
        {
            return context.getResources().getDrawable(icon);
        }
    }

    public static byte[] streamToByteArray(InputStream stream) throws IOException
    {
        byte[] buffer = new byte[1024];
        ByteArrayOutputStream os = new ByteArrayOutputStream();

        int line;
        // read bytes from stream, and store them in buffer
        while ((line = stream.read(buffer)) != -1)
        {
            // Writes bytes from byte array (buffer) into output stream.
            os.write(buffer, 0, line);
        }
        os.flush();
        os.close();
        stream.close();
        return os.toByteArray();
    }

    public static boolean ensureAttribute(Element e, String type, String s)
    {
        return e.getAttribute(type) != null && e.getAttribute(type).equals(s);
    }

    public static Element getElement(final Document doc, final String name)
    {
        for (Node object = doc.getDocumentElement(); object != null; object = object.getNextSibling())
        {
            if (object instanceof Element)
            {
                final Element popup = (Element) object;
                if (popup.getTagName().equals(name))
                {
                    return popup;
                }
            }
        }
        return null;
    }

    public static List<Element> getElements(final Element e, final String name)
    {
        List<Element> retValue = new ArrayList<>();
        for (Node object = e.getFirstChild(); object != null; object = object.getNextSibling())
        {
            if (object instanceof Element)
            {
                final Element en = (Element) object;
                if (name == null || name.equals(en.getTagName()))
                {
                    retValue.add(en);
                }
            }
        }
        return retValue;
    }

    /**
     * Procedure returns theme color
     */
    @ColorInt
    public static int getThemeColorAttr(final Context context, @AttrRes int resId)
    {
        final TypedValue value = new TypedValue();
        context.getTheme().resolveAttribute(resId, value, true);
        return value.data;
    }

    /**
     * Procedure updates menu item color depends its enabled state
     */
    public static void updateMenuIconColor(Context context, MenuItem m)
    {
        setDrawableColorAttr(context, m.getIcon(),
                m.isEnabled() ? android.R.attr.textColorTertiary : R.attr.colorPrimaryDark);
    }

    /**
     * Procedure sets AppCompatImageButton color given by attribute ID
     */
    public static void setImageButtonColorAttr(Context context, AppCompatImageButton b, @AttrRes int resId)
    {
        final int c = getThemeColorAttr(context, resId);
        b.clearColorFilter();
        b.setColorFilter(c, PorterDuff.Mode.SRC_ATOP);
    }

    /**
     * Procedure sets ImageView background color given by attribute ID
     */
    public static void setImageViewColorAttr(Context context, ImageView b, @AttrRes int resId)
    {
        final int c = getThemeColorAttr(context, resId);
        b.clearColorFilter();
        b.setColorFilter(c, PorterDuff.Mode.SRC_ATOP);
    }

    public static void setDrawableColorAttr(Context c, Drawable drawable, @AttrRes int resId)
    {
        if (drawable != null)
        {
            drawable.clearColorFilter();
            drawable.setColorFilter(getThemeColorAttr(c, resId), PorterDuff.Mode.SRC_ATOP);
        }
    }

    /**
     * Fix dialog icon color after dialog creation. Necessary for older Android Versions
     */
    public static void fixIconColor(@NonNull AlertDialog dialog, @AttrRes int resId)
    {
        final ImageView imageView = dialog.findViewById(android.R.id.icon);
        if (imageView != null)
        {
            Utils.setImageViewColorAttr(dialog.getContext(), imageView, resId);
        }
    }

    /**
     * Procedure hows toast that contains description of the given button
     */
    @SuppressLint("RtlHardcoded")
    public static boolean showButtonDescription(Context context, View button)
    {
        CharSequence contentDesc = button.getContentDescription();
        if (contentDesc != null && contentDesc.length() > 0)
        {
            int[] pos = new int[2];
            button.getLocationOnScreen(pos);

            Toast t = Toast.makeText(context, contentDesc, Toast.LENGTH_SHORT);
            t.setGravity(Gravity.TOP | Gravity.LEFT, 0, 0);
            t.getView().measure(View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED),
                    View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED));
            final int x = pos[0] + button.getMeasuredWidth() / 2 - (t.getView().getMeasuredWidth() / 2);
            final int y = pos[1] - button.getMeasuredHeight() / 2 - t.getView().getMeasuredHeight()
                    - context.getResources().getDimensionPixelSize(R.dimen.activity_vertical_margin_port);
            t.setGravity(Gravity.TOP | Gravity.LEFT, x, y);
            t.show();
            return true;
        }
        return false;
    }

    public static int timeToSeconds(final String timestampStr)
    {
        try
        {
            String[] tokens = timestampStr.split(":");
            int hours = Integer.parseInt(tokens[0]);
            int minutes = Integer.parseInt(tokens[1]);
            int seconds = Integer.parseInt(tokens[2]);
            return 3600 * hours + 60 * minutes + seconds;
        }
        catch (Exception ex)
        {
            return -1;
        }
    }

    /**
     * Procedure checks whether the hard keyboard is available
     */
    private static boolean isHardwareKeyboardAvailable(Context context)
    {
        return context.getResources().getConfiguration().keyboard != Configuration.KEYBOARD_NOKEYS;
    }

    public static void showSoftKeyboard(Context context, View v, boolean flag)
    {
        if (Utils.isHardwareKeyboardAvailable(context))
        {
            return;
        }
        final InputMethodManager imm = (InputMethodManager) context.getSystemService(Context.INPUT_METHOD_SERVICE);
        if (imm == null)
        {
            return;
        }
        if (flag)
        {
            imm.toggleSoftInput(InputMethodManager.SHOW_FORCED, InputMethodManager.HIDE_IMPLICIT_ONLY);
        }
        else
        {
            imm.hideSoftInputFromWindow(v.getWindowToken(), 0);
        }
    }

    /**
     * Procedure creates new dot-separated DecimalFormat
     */
    public static DecimalFormat getDecimalFormat(String format)
    {
        DecimalFormat df = new DecimalFormat(format);
        DecimalFormatSymbols dfs = new DecimalFormatSymbols();
        dfs.setDecimalSeparator('.');
        dfs.setExponentSeparator("e");
        df.setDecimalFormatSymbols(dfs);
        return df;
    }

    @SuppressWarnings("deprecation")
    public static void setDrawerListener(DrawerLayout mDrawerLayout, ActionBarDrawerToggle mDrawerToggle)
    {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
        {
            mDrawerLayout.removeDrawerListener(mDrawerToggle);
            mDrawerLayout.addDrawerListener(mDrawerToggle);
        }
        else
        {
            mDrawerLayout.setDrawerListener(mDrawerToggle);
        }
    }

    public static String intToneToString(Character m, int tone)
    {
        if (tone == 0)
        {
            return String.format("%c%02x", m, tone);
        }
        final Character s = tone < 0 ? '-' : '+';
        return String.format("%c%c%1x", m, s, Math.abs(tone)).toUpperCase();
    }

    public static String intToneToString(int tone, int length)
    {
        if (tone == 0)
        {
            return length == 1 ? "00" : "000";
        }
        else
        {
            final Character s = tone < 0 ? '-' : '+';
            final String format = length == 1 ? "%c%1x" : "%c%02x";
            return String.format(format, s, Math.abs(tone)).toUpperCase();
        }
    }
}
