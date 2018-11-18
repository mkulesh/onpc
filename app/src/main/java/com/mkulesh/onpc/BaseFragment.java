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

package com.mkulesh.onpc;

import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.support.annotation.DrawableRes;
import android.support.annotation.IdRes;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.annotation.StringRes;
import android.support.v4.app.Fragment;
import android.support.v7.app.AlertDialog;
import android.support.v7.widget.AppCompatImageButton;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.iscp.PopupBuilder;
import com.mkulesh.onpc.iscp.messages.CustomPopupMsg;
import com.mkulesh.onpc.iscp.messages.ServiceType;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.util.Collections;
import java.util.HashSet;

abstract public class BaseFragment extends Fragment
{
    /**
     * Constants used to save/restore the instance state.
     */
    public static final String FRAGMENT_NUMBER = "fragment_number";
    public static final String SERVER_NAME = "server_name";
    public static final String SERVER_PORT = "server_port";

    protected MainActivity activity;
    protected SharedPreferences preferences;
    protected View rootView = null;

    int buttonSize = 0, buttonMargin = 0, buttonPadding = 0;

    public BaseFragment()
    {
        // Empty constructor required for fragment subclasses
    }

    public void initializeFragment(LayoutInflater inflater, ViewGroup container, int layoutId)
    {
        activity = (MainActivity) getActivity();
        preferences = PreferenceManager.getDefaultSharedPreferences(activity);
        rootView = inflater.inflate(layoutId, container, false);

        buttonSize = activity.getResources().getDimensionPixelSize(R.dimen.button_size);
        buttonMargin = activity.getResources().getDimensionPixelSize(R.dimen.button_margin);
        buttonPadding = activity.getResources().getDimensionPixelSize(R.dimen.button_padding);
    }

    public void update(final State state, @Nullable HashSet<State.ChangeType> eventChanges)
    {
        if (eventChanges == null)
        {
            eventChanges = new HashSet<>();
            Collections.addAll(eventChanges, State.ChangeType.values());
        }
        if (state == null || !state.isOn())
        {
            updateStandbyView(state, eventChanges);
        }
        else
        {
            updateActiveView(state, eventChanges);
        }
        if (activity.getStateManager() != null && state != null && state.popup != null)
        {
            final CustomPopupMsg inMsg = state.popup;
            state.popup = null;
            processPopup(inMsg, state.serviceType);
        }
    }

    private void processPopup(CustomPopupMsg inMsg, final ServiceType serviceType)
    {
        try
        {
            PopupBuilder builder = new PopupBuilder(activity, serviceType, new PopupBuilder.ButtonListener()
            {
                @Override
                public void onButtonSelected(final CustomPopupMsg outMsg)
                {
                    activity.getStateManager().sendPopupMsg(outMsg);
                }
            });
            final AlertDialog alertDialog = builder.build(inMsg);
            if (alertDialog != null)
            {
                alertDialog.show();
            }
        }
        catch (Exception e)
        {
            Logging.info(this, "Can not create popup dialog: " + e.getLocalizedMessage());
        }
    }

    protected abstract void updateStandbyView(@Nullable final State state, @NonNull final HashSet<State.ChangeType> eventChanges);

    protected abstract void updateActiveView(@NonNull final State state, @NonNull final HashSet<State.ChangeType> eventChanges);

    protected AppCompatImageButton createButton(
            @DrawableRes int imageId, @StringRes int descriptionId,
            @NonNull final ISCPMessage msg, Object tag,
            int leftMargin, int rightMargin)
    {
        final AppCompatImageButton b = new AppCompatImageButton(activity, null, R.style.ImageButtonStyle);
        final LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(buttonSize, buttonSize);
        lp.setMargins(leftMargin, buttonMargin, rightMargin, buttonMargin);
        b.setLayoutParams(lp);
        b.setPadding(buttonPadding, buttonPadding, buttonPadding, buttonPadding);
        b.setTag(tag);
        b.setScaleType(ImageView.ScaleType.FIT_CENTER);
        b.setAdjustViewBounds(true);
        prepareButton(b, msg, imageId, descriptionId);
        setButtonEnabled(b, true);
        return b;
    }

    protected void prepareImageButton(@IdRes int buttonId, final ISCPMessage msg)
    {
        final AppCompatImageButton b = rootView.findViewById(buttonId);
        prepareImageButton(b, msg);
    }

    protected void prepareButton(
            @NonNull AppCompatImageButton b, final ISCPMessage msg, @DrawableRes final int imageId, @StringRes final int descriptionId)
    {
        b.setImageResource(imageId);
        if (descriptionId != -1)
        {
            b.setContentDescription(activity.getResources().getString(descriptionId));
        }
        prepareImageButton(b, msg);
    }

    private void prepareImageButton(
            @NonNull AppCompatImageButton b, final ISCPMessage msg)
    {
        TypedValue outValue = new TypedValue();
        activity.getTheme().resolveAttribute(R.attr.selectableItemBackground, outValue, true);
        b.setBackgroundResource(outValue.resourceId);

        b.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
                if (activity.getStateManager() != null)
                {
                    activity.getStateManager().sendMessage(msg);
                }
            }
        });

        b.setLongClickable(true);
        b.setOnLongClickListener(new View.OnLongClickListener()
        {
            @Override
            public boolean onLongClick(View v)
            {
                return Utils.showButtonDescription(activity, v);
            }
        });
    }

    protected void setButtonEnabled(@IdRes int buttonId, boolean isEnabled)
    {
        final AppCompatImageButton b = rootView.findViewById(buttonId);
        setButtonEnabled(b, isEnabled);
    }

    protected void setButtonEnabled(AppCompatImageButton b, boolean isEnabled)
    {
        b.setEnabled(isEnabled);
        Utils.setImageButtonColorAttr(activity, b,
                b.isEnabled() ? R.attr.colorButtonEnabled : R.attr.colorButtonDisabled);
    }

    protected void setButtonSelected(AppCompatImageButton b, boolean isSelected)
    {
        b.setSelected(isSelected);
        Utils.setImageButtonColorAttr(activity, b,
                b.isSelected() ? R.attr.colorAccent : R.attr.colorButtonEnabled);
    }
}
