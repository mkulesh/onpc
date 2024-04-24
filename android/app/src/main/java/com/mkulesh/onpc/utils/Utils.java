/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2024 by Mikhail Kulesh
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
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.BlendMode;
import android.graphics.BlendModeColorFilter;
import android.graphics.Canvas;
import android.graphics.PorterDuff;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.util.Log;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.Map;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import androidx.annotation.ColorInt;
import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;

@SuppressWarnings({"RedundantSuppression"})
public class Utils
{
    public static final String SHARED_PREFERENCES_NAME = "FlutterSharedPreferences";

    public enum ProtoType
    {
        ISCP, // Integra Serial Communication Protocol (TCP:60128)
        DCP   // Denon Control Protocol (TCP:23)
    }

    public static ProtoType stringToProtoType(final String protoType)
    {
        if (protoType == null)
        {
            return ProtoType.ISCP;
        }
        for (ProtoType p : ProtoType.values())
        {
            if (p.name().equalsIgnoreCase(protoType))
            {
                return p;
            }
        }
        return ProtoType.ISCP;
    }

    /**
     * XML utils
     */
    public interface XmlProcessor
    {
        void onXmlOpened(final Element elem) throws Exception;
    }

    public static void openXml(final String data, XmlProcessor processor)
    {
        try
        {
            InputStream stream = new ByteArrayInputStream(data.getBytes(Charset.forName("UTF-8")));
            final DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            // https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Prevention_Cheat_Sheet
            factory.setExpandEntityReferences(false);
            final DocumentBuilder builder = factory.newDocumentBuilder();
            final Document doc = builder.parse(stream);
            final Node object = doc.getDocumentElement();
            //noinspection ConstantConditions
            if (object instanceof Element)
            {
                //noinspection CastCanBeRemovedNarrowingVariableType
                processor.onXmlOpened((Element) object);
            }
        }
        catch (Exception e)
        {
            Log.d("onpc", "Failed to parse XML: " + e.getLocalizedMessage());
        }
    }

    public static int parseIntAttribute(final Element e, final String name, int defValue)
    {
        final String val = e.getAttribute(name);
        if (val != null)
        {
            try
            {
                return Integer.parseInt(e.getAttribute(name));
            }
            catch (NumberFormatException ex)
            {
                return defValue;
            }
        }
        return defValue;
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

    public static Bitmap drawableToBitmap(Drawable drawable)
    {
        Bitmap bitmap;

        if (drawable instanceof BitmapDrawable)
        {
            BitmapDrawable bitmapDrawable = (BitmapDrawable) drawable;
            if (bitmapDrawable.getBitmap() != null)
            {
                return bitmapDrawable.getBitmap();
            }
        }

        if (drawable.getIntrinsicWidth() <= 0 || drawable.getIntrinsicHeight() <= 0)
        {
            bitmap = Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888); // Single color bitmap will be created of 1x1 pixel
        }
        else
        {
            bitmap = Bitmap.createBitmap(drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight(), Bitmap.Config.ARGB_8888);
        }

        Canvas canvas = new Canvas(bitmap);
        drawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
        drawable.draw(canvas);
        return bitmap;
    }

    public static boolean readBooleanPreference(final Map<String, ?> allPrefs, final String name, final boolean defValue)
    {
        Object val = allPrefs.get("flutter." + name);
        if (val instanceof Boolean)
        {
            return (Boolean)val;
        }
        return defValue;
    }

    public static long readIntPreference(final Map<String, ?> allPrefs, final String name, final long defValue)
    {
        Object val = allPrefs.get("flutter." + name);
        if (val instanceof Long)
        {
            return (long)val;
        }
        if (val instanceof Integer)
        {
            return (int)val;
        }
        return defValue;
    }

    public static String readStringPreference(final Map<String, ?> allPrefs, final String name, final String defValue)
    {
        Object val = allPrefs.get("flutter." + name);
        if (val instanceof String)
        {
            return (String)val;
        }
        return defValue;
    }

    public static int getColor(Context context, String par, int defValue)
    {
        final SharedPreferences preferences = context.getSharedPreferences(
                SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
        return (int) preferences.getLong("flutter." + par, ContextCompat.getColor(context, defValue));
    }

    @SuppressWarnings("deprecation")
    @SuppressLint("NewApi")
    public static void setColorFilter(@NonNull Drawable drawable, @ColorInt int color)
    {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q)
        {
            drawable.setColorFilter(new BlendModeColorFilter(color, BlendMode.SRC_ATOP));
        }
        else
        {
            drawable.setColorFilter(color, PorterDuff.Mode.SRC_ATOP);
        }
    }

    public static boolean getBooleanArgument(ArrayList<?> arguments, int i, boolean defValue, String logText)
    {
        boolean val = defValue;
        if (arguments.get(i) instanceof Boolean)
        {
            val = (boolean) arguments.get(i);
            Log.d("onpc", logText + "=" + val);
        }
        return val;
    }
}
