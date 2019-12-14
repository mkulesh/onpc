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

package com.mkulesh.onpc.iscp;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.iscp.messages.CustomPopupMsg;
import com.mkulesh.onpc.iscp.messages.ServiceType;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.io.StringWriter;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.widget.AppCompatButton;
import androidx.appcompat.widget.AppCompatEditText;

public class PopupBuilder
{
    public interface ButtonListener
    {
        void onButtonSelected(final CustomPopupMsg outMsg);
    }

    private final Context context;
    private final ServiceType serviceType;
    private final String artist;
    private final ButtonListener buttonListener;

    @DrawableRes
    private final int serviceIcon;

    public PopupBuilder(final @NonNull Context context,
                        final @NonNull State state,
                        final @NonNull ButtonListener buttonListener)
    {
        this.context = context;
        this.serviceType = state.serviceType;
        this.artist = state.artist;
        this.buttonListener = buttonListener;
        this.serviceIcon = state.getServiceIcon();
    }

    public AlertDialog build(final CustomPopupMsg pMsg) throws Exception
    {
        CustomPopupMsg.UiType uiType = null;
        final Document document = xmlToDocument(pMsg.getXml().getBytes(ISCPMessage.UTF_8));

        final Element popup = Utils.getElement(document, "popup");
        if (popup == null)
        {
            throw new Exception("popup element not found");
        }

        final String title = popup.getAttribute("title");
        Logging.info(this, "received popup: " + title);

        final FrameLayout frameView = new FrameLayout(context);
        AlertDialog.Builder builder = new AlertDialog.Builder(context)
                .setTitle(title)
                .setView(frameView);

        // icon
        if (serviceIcon != R.drawable.media_item_unknown)
        {
            final Drawable bg = Utils.getDrawable(context, serviceIcon);
            Utils.setDrawableColorAttr(context, bg, android.R.attr.textColorSecondary);
            builder.setIcon(bg);
        }

        // dialog layout
        final AlertDialog alertDialog = builder.create();
        LayoutInflater inflater = alertDialog.getLayoutInflater();
        FrameLayout dialogFrame = (FrameLayout) inflater.inflate(R.layout.dialog_popup_layout, frameView);
        if (dialogFrame.getChildCount() != 1)
        {
            throw new Exception("cannot inflate dialog layout");
        }
        LinearLayout dialogLayout = (LinearLayout) dialogFrame.getChildAt(0);

        // labels
        final StringBuilder message = new StringBuilder();
        message.append(title).append(": ");
        for (final Element label : Utils.getElements(popup, "label"))
        {
            for (final Element line : Utils.getElements(label, "line"))
            {
                message.append(line.getAttribute("text"));
                dialogLayout.addView(createTextView(line, R.style.PrimaryTextViewStyle));
            }
        }

        // text boxes
        for (final Element group : Utils.getElements(popup, "textboxgroup"))
        {
            for (final Element textBox : Utils.getElements(group, "textbox"))
            {
                dialogLayout.addView(createTextView(textBox, R.style.SecondaryTextViewStyle));
                dialogLayout.addView(createEditText(textBox));
                uiType = CustomPopupMsg.UiType.KEYBOARD;
            }
        }

        // buttons
        for (final Element group : Utils.getElements(popup, "buttongroup"))
        {
            for (final Element button : Utils.getElements(group, "button"))
            {
                if (uiType == null)
                {
                    uiType = CustomPopupMsg.UiType.POPUP;
                }
                dialogLayout.addView(createButton(alertDialog, document, button, uiType));
            }
        }

        // Show toast instead dialog, if there are no buttons and fields
        if (uiType == null)
        {
            Toast.makeText(context, message.toString(), Toast.LENGTH_LONG).show();
            return null;
        }

        return alertDialog;
    }

    @SuppressLint("NewApi")
    private TextView createTextView(final Element textBox, final int style)
    {
        final TextView tv = new TextView(context);
        tv.setLayoutParams(new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
        {
            tv.setTextAppearance(style);
        }
        else
        {
            tv.setTextAppearance(context, style);
        }
        tv.setText(textBox.getAttribute("text"));
        return tv;
    }

    private AppCompatEditText createEditText(final Element box)
    {
        final AppCompatEditText tv = new AppCompatEditText(context);
        tv.setLayoutParams(new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        final String defValue = getDefaultValue(box);
        if (defValue != null)
        {
            tv.setText(defValue);
            box.setAttribute("value", defValue);
        }
        else
        {
            tv.setText(box.getAttribute("value"));
        }
        tv.addTextChangedListener(new TextWatcher()
        {

            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after)
            {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count)
            {
                box.setAttribute("value", s.toString());
            }

            @Override
            public void afterTextChanged(Editable s)
            {

            }
        });

        return tv;
    }

    private String getDefaultValue(Element box)
    {
        final String text = box.getAttribute("text");
        if (serviceType == ServiceType.DEEZER && text != null && "Search".equals(text)
                && artist != null && !artist.isEmpty())
        {
            return artist.contains("(") ? artist.substring(0, artist.indexOf("(")) : artist;
        }
        return null;
    }

    private AppCompatButton createButton(final AlertDialog alertDialog,
                                         final Document document, final Element button,
                                         final CustomPopupMsg.UiType uiType)
    {
        final AppCompatButton b = new AppCompatButton(context);
        b.setLayoutParams(new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        b.setGravity(Gravity.CENTER);
        b.setText(button.getAttribute("text"));
        b.setOnClickListener(v ->
        {
            Utils.showSoftKeyboard(context, v, false);
            button.setAttribute("selected", "true");
            alertDialog.dismiss();
            final CustomPopupMsg outMsg = new CustomPopupMsg(uiType, documentToXml(document));
            buttonListener.onButtonSelected(outMsg);
        });
        return b;
    }

    private Document xmlToDocument(byte[] bytes) throws Exception
    {
        InputStream stream = new ByteArrayInputStream(bytes);
        final DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        final DocumentBuilder builder = factory.newDocumentBuilder();
        final Document document = builder.parse(stream);
        stream.close();
        return document;
    }

    private static String documentToXml(final Document document)
    {
        try
        {
            DOMSource domSource = new DOMSource(document);
            StringWriter writer = new StringWriter();
            StreamResult result = new StreamResult(writer);
            TransformerFactory tf = TransformerFactory.newInstance();
            Transformer transformer = tf.newTransformer();
            transformer.transform(domSource, result);
            return writer.toString();
        }
        catch (Exception e)
        {
            Logging.info(document, "Can not generate popup response: " + e.getLocalizedMessage());
            return null;
        }
    }

}
