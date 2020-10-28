/*
 * Enhanced Controller for Onkyo and Pioneer
 * Copyright (C) 2018-2020. Mikhail Kulesh
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

package com.mkulesh.onpc.widgets;


import android.content.Context;
import android.content.res.TypedArray;
import android.text.Editable;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.utils.Utils;

import androidx.appcompat.widget.AppCompatImageButton;


public class HorizontalNumberPicker extends LinearLayout implements OnClickListener
{
    private EditText editText = null;
    private ImageButton bDecrease = null, bIncrease = null;
    private TextView description = null;
    public int minValue = 1;
    public int maxValue = Integer.MAX_VALUE;

    public HorizontalNumberPicker(Context context, AttributeSet attrs)
    {
        super(context, attrs);
        prepare(attrs);
    }

    public HorizontalNumberPicker(Context context)
    {
        super(context);
        prepare(null);
    }

    private void prepare(AttributeSet attrs)
    {
        setBaselineAligned(false);
        setVerticalGravity(Gravity.CENTER_VERTICAL);
        setOrientation(HORIZONTAL);
        final LayoutInflater inflater = (LayoutInflater) getContext().getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        if (inflater != null)
        {
            inflater.inflate(R.layout.horizontal_number_picker, this);
            editText = findViewById(R.id.edit_text_value);
            if (attrs != null)
            {
                TypedArray a = getContext().obtainStyledAttributes(attrs, R.styleable.HorizontalNumberPicker, 0, 0);
                CharSequence label = a.getText(R.styleable.HorizontalNumberPicker_label);
                if (label != null)
                {
                    ((TextView) findViewById(R.id.label_text)).setText(label);
                }
                editText.setMinimumWidth(a.getDimensionPixelSize(R.styleable.HorizontalNumberPicker_minWidth, 0));
                a.recycle();
            }

            bDecrease = findViewById(R.id.button_decrease);
            bDecrease.setOnClickListener(this);
            bDecrease.setOnLongClickListener(v -> Utils.showButtonDescription(getContext(), v));
            updateViewColor(bDecrease);

            bIncrease = findViewById(R.id.button_increase);
            bIncrease.setOnClickListener(this);
            bIncrease.setOnLongClickListener(v -> Utils.showButtonDescription(getContext(), v));
            updateViewColor(bIncrease);

            description = findViewById(R.id.label_text);
        }
    }

    @Override
    public void onClick(View v)
    {
        if (v.getId() == R.id.button_decrease)
        {
            editText.setText(String.valueOf(convertToInt(editText.getText(), -1)));
        }
        else if (v.getId() == R.id.button_increase)
        {
            editText.setText(String.valueOf(convertToInt(editText.getText(), 1)));
        }
    }

    public void setValue(int value)
    {
        editText.setText(String.valueOf(value));
    }

    public int getValue()
    {
        return convertToInt(editText.getText(), 0);
    }

    private int convertToInt(Editable field, int inc)
    {
        try
        {
            final int r = Integer.valueOf(field.length() > 0 ? field.toString() : "") + inc;
            return ((r < minValue) ? minValue : ((r > maxValue) ? maxValue : r));
        }
        catch (Exception e)
        {
            return inc > 0 ? maxValue : minValue;
        }
    }

    @Override
    public void setEnabled(boolean enabled)
    {
        updateViewColor(editText);
        bDecrease.setEnabled(enabled);
        updateViewColor(bDecrease);
        bIncrease.setEnabled(enabled);
        updateViewColor(bIncrease);
        description.setEnabled(enabled);
        updateViewColor(description);
        super.setEnabled(enabled);
    }

    private void updateViewColor(View v)
    {
        if (v instanceof AppCompatImageButton)
        {
            final int attrId = v.isEnabled() ? R.attr.colorButtonEnabled : R.attr.colorButtonDisabled;
            Utils.setImageButtonColorAttr(getContext(), (AppCompatImageButton) v, attrId);
        }
        else if (v instanceof TextView)
        {
            final int attrId = v.isEnabled() ? R.attr.colorButtonEnabled : R.attr.colorButtonDisabled;
            final TextView b = (TextView) v;
            b.setTextColor(Utils.getThemeColorAttr(getContext(), attrId));
        }
    }
}
