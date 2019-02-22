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

package com.mkulesh.onpc;

import android.content.Context;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;
import android.util.SparseArray;
import android.view.ViewGroup;

import com.mkulesh.onpc.config.Configuration;

import java.util.Locale;

class MainPagerAdapter extends FragmentStatePagerAdapter
{
    private final Context context;
    private final SparseArray<Fragment> registeredFragments = new SparseArray<>();
    private final int items;

    MainPagerAdapter(final Context context, final FragmentManager fm, final Configuration configuration)
    {
        super(fm);
        this.context = context;
        this.items = configuration.isRemoteInterface() ? 5 : 4;
    }

    @Override
    public Fragment getItem(int position)
    {
        switch (position)
        {
        case 0:
            return prepareFragment(new MonitorFragment(), position);
        case 1:
            return prepareFragment(new MediaFragment(), position);
        case 2:
            return prepareFragment(new DeviceFragment(), position);
        case 3:
            return prepareFragment(new RemoteControlFragment(), position);
        case 4:
            return prepareFragment(new RemoteInterfaceFragment(), position);
        }
        return null;
    }

    private Fragment prepareFragment(Fragment fragment, int position)
    {
        Bundle args = new Bundle();
        args.putInt(BaseFragment.FRAGMENT_NUMBER, position);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public int getCount()
    {
        return items;
    }

    @Override
    public CharSequence getPageTitle(int position)
    {
        Locale l = Locale.getDefault();
        switch (position)
        {
        case 0:
            return context.getString(R.string.title_monitor).toUpperCase(l);
        case 1:
            return context.getString(R.string.title_media).toUpperCase(l);
        case 2:
            return context.getString(R.string.title_device).toUpperCase(l);
        case 3:
            return context.getString(R.string.title_remote_control).toUpperCase(l);
        case 4:
            return context.getString(R.string.title_remote_interface).toUpperCase(l);
        }
        return null;
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
