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

package com.mkulesh.onpc.fragments;

import android.content.Context;
import android.util.AttributeSet;
import android.view.ViewGroup;
import android.widget.Checkable;
import android.widget.CheckedTextView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.mkulesh.onpc.R;

public class MultiroomDeviceItem extends LinearLayout implements Checkable
{
    private TextView textView, description;
    private CheckedTextView checkBox;
    private boolean checked;

    public MultiroomDeviceItem(Context context, AttributeSet attrs)
    {
        super(context, attrs);
    }

    @Override
    public void onFinishInflate()
    {
        textView = this.findViewById(R.id.checkable_text);
        description = this.findViewById(R.id.checkable_description);
        checkBox = this.findViewById(R.id.checkable_checkbox);
        super.onFinishInflate();
    }

    @Override
    public void setTag(Object tag)
    {
        textView.setTag(tag);
    }

    @Override
    public Object getTag()
    {
        return textView.getTag();
    }

    public void setText(String line)
    {
        textView.setText(line);
    }

    public void setDescription(String line)
    {
        textView.getLayoutParams().height = ViewGroup.LayoutParams.WRAP_CONTENT;
        description.setVisibility(VISIBLE);
        description.setText(line);
    }

    public void setCheckBoxVisibility(int v)
    {
        checkBox.setVisibility(v);
    }

    @Override
    public boolean isChecked()
    {
        return checked;
    }

    @Override
    public void setChecked(boolean checked)
    {
        this.checked = checked;
        checkBox.setChecked(this.checked);
    }

    @Override
    public void toggle()
    {
        if (checkBox.getVisibility() == VISIBLE)
        {
            setChecked(!checked);
        }
    }
}
