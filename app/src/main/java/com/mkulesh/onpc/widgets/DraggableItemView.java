/*
 * Enhanced Controller for Onkyo and Pioneer
 * Copyright (C) 2018-2021 by Mikhail Kulesh
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
import android.util.AttributeSet;
import android.widget.Checkable;
import android.widget.CheckedTextView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.utils.Utils;

import androidx.annotation.DrawableRes;

public class DraggableItemView extends LinearLayout implements Checkable
{
    private ImageView icon;
    private TextView textView;
    private CheckedTextView checkBox;
    private boolean checked;

    public DraggableItemView(Context context, AttributeSet attrs)
    {
        super(context, attrs);
    }

    @Override
    public void onFinishInflate()
    {
        icon = this.findViewById(R.id.draggable_icon);
        textView = this.findViewById(R.id.draggable_text);
        checkBox = this.findViewById(R.id.draggable_checkbox);
        ImageView checkableDragger = this.findViewById(R.id.draggable_dragger);
        Utils.setImageViewColorAttr(getContext(), checkableDragger, android.R.attr.textColor);
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

    public void setImage(@DrawableRes int imageId)
    {
        icon.setImageResource(imageId);
        icon.setVisibility(VISIBLE);
        Utils.setImageViewColorAttr(getContext(), icon, android.R.attr.textColorSecondary);
    }

    public void setText(String line)
    {
        textView.setText(line);
    }

    public void setCheckBoxVisibility(int visibility)
    {
        checkBox.setVisibility(visibility);
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
        setChecked(!checked);
    }
}
