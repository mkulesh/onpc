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

package com.mkulesh.onpc;

import android.content.Context;
import android.util.SparseArray;
import android.view.ViewGroup;

import com.mkulesh.onpc.config.CfgAppSettings;
import com.mkulesh.onpc.config.Configuration;
import com.mkulesh.onpc.fragments.DeviceFragment;
import com.mkulesh.onpc.fragments.ListenFragment;
import com.mkulesh.onpc.fragments.MediaFragment;
import com.mkulesh.onpc.fragments.RemoteControlFragment;
import com.mkulesh.onpc.fragments.RemoteInterfaceFragment;
import com.mkulesh.onpc.fragments.ShortcutsFragment;

import java.util.ArrayList;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentStatePagerAdapter;

import static com.mkulesh.onpc.config.CfgAppSettings.Tabs;

class MainPagerAdapter extends FragmentStatePagerAdapter
{
    private final Context context;
    private final ArrayList<Tabs> tabs;
    private final SparseArray<Fragment> registeredFragments = new SparseArray<>();

    MainPagerAdapter(final Context context, final FragmentManager fm, final Configuration configuration)
    {
        super(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT);
        this.context = context;
        this.tabs = configuration.appSettings.getVisibleTabs();
    }

    @Override
    @NonNull
    public Fragment getItem(int position)
    {
        if (position >= getCount())
        {
            return new ListenFragment();
        }
        final Tabs item = tabs.get(position);
        switch (item)
        {
        case LISTEN:
            return new ListenFragment();
        case MEDIA:
            return new MediaFragment();
        case SHORTCUTS:
            return new ShortcutsFragment();
        case DEVICE:
            return new DeviceFragment();
        case RC:
            return new RemoteControlFragment();
        default:
            return new RemoteInterfaceFragment();
        }
    }

    @Override
    public int getCount()
    {
        return tabs.size();
    }

    @Override
    public CharSequence getPageTitle(int position)
    {
        return (position < getCount()) ? CfgAppSettings.getTabName(context, tabs.get(position)) : "";
    }

    // Register the fragment when the item is instantiated
    @NonNull
    @Override
    public Object instantiateItem(@NonNull ViewGroup container, int position)
    {
        Fragment fragment = (Fragment) super.instantiateItem(container, position);
        registeredFragments.put(position, fragment);
        return fragment;
    }

    // Unregister when the item is inactive
    @Override
    public void destroyItem(@NonNull ViewGroup container, int position, @NonNull Object object)
    {
        registeredFragments.remove(position);
        super.destroyItem(container, position, object);
    }

    // Returns the fragment for the position (if instantiated)
    Fragment getRegisteredFragment(int position)
    {
        return registeredFragments.get(position);
    }
}
