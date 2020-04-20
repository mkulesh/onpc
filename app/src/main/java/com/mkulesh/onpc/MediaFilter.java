/*
 * Copyright (C) 2020. Mikhail Kulesh
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

package com.mkulesh.onpc;

import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;

import com.mkulesh.onpc.utils.Utils;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.AppCompatEditText;

class MediaFilter
{
    public interface MediaFilterInterface
    {
        void onMediaFilterChanged();
    }

    private MainActivity activity = null;
    private AppCompatEditText filterRegex = null;
    private boolean enabled;
    private boolean visible;

    void init(@NonNull final MainActivity activity,
              @NonNull final View rootView,
              @NonNull final MediaFilterInterface mediaFilterInterface)
    {
        this.activity = activity;
        filterRegex = rootView.findViewById(R.id.filter_regex);
        filterRegex.addTextChangedListener(new TextWatcher()
        {
            @Override
            public void afterTextChanged(Editable s)
            {
                // empty
            }

            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after)
            {
                // empty
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count)
            {
                if (visible)
                {
                    mediaFilterInterface.onMediaFilterChanged();
                }
            }
        });
        disable();
        visible = false;
    }

    void enable()
    {
        enabled = true;
    }

    void disable()
    {
        enabled = false;
    }

    boolean isEnabled()
    {
        return enabled;
    }

    @SuppressWarnings("BooleanMethodIsAlwaysInverted")
    boolean isVisible()
    {
        return visible;
    }

    void setVisibility(boolean visible, boolean clear)
    {
        this.visible = visible;
        filterRegex.setVisibility(this.visible ? View.VISIBLE : View.GONE);
        if (activity == null && filterRegex == null)
        {
            return;
        }
        if (this.visible)
        {
            filterRegex.requestFocus();
            Utils.showSoftKeyboard(activity, filterRegex, true);
        }
        else
        {
            Utils.showSoftKeyboard(activity, filterRegex, false);
            filterRegex.clearFocus();
            if (clear && filterRegex.getText() != null)
            {
                filterRegex.getText().clear();
            }
        }
    }

    boolean ignore(@NonNull String title)
    {
        final String filter = (visible && filterRegex != null &&
                filterRegex.getText() != null && filterRegex.getText().length() > 0) ?
                filterRegex.getText().toString() : null;
        if (filter == null)
        {
            return false;
        }
        if (filter.isEmpty() || filter.equals("*"))
        {
            return false;
        }
        if (title.toUpperCase().startsWith(filter.toUpperCase()))
        {
            return false;
        }
        if (filter.startsWith("*"))
        {
            final String f = filter.substring(filter.lastIndexOf('*') + 1);
            return !title.toUpperCase().contains(f.toUpperCase());
        }
        return true;
    }
}
