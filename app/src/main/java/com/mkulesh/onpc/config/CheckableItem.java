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

package com.mkulesh.onpc.config;

import android.support.annotation.DrawableRes;

class CheckableItem
{
    final int id;
    final String code;
    final CharSequence text;
    @DrawableRes
    final int imageId;
    boolean checked;

    CheckableItem(final int id, String code, CharSequence text, @DrawableRes int imageId, boolean checked)
    {
        this.id = id;
        this.code = code;
        this.text = text;
        this.imageId = imageId;
        this.checked = checked;
    }

    CheckableItem(CheckableItem d)
    {
        this.id = d.id;
        this.code = d.code;
        this.text = d.text;
        this.imageId = d.imageId;
        this.checked = d.checked;
    }

    public String getCode()
    {
        return code;
    }
}
