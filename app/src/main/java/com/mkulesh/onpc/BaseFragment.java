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

import android.support.annotation.AttrRes;
import android.support.annotation.DrawableRes;
import android.support.annotation.IdRes;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.annotation.StringRes;
import android.support.v4.app.Fragment;
import android.support.v7.app.AlertDialog;
import android.support.v7.view.ContextThemeWrapper;
import android.support.v7.widget.AppCompatButton;
import android.support.v7.widget.AppCompatImageButton;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
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

    protected MainActivity activity;
    protected View rootView = null;

    int buttonSize = 0, buttonMarginHorizontal = 0, buttonMarginVertical = 0;

    interface ButtonListener
    {
        void onPostProcessing();
    }


    public BaseFragment()
    {
        // Empty constructor required for fragment subclasses
    }

    public void initializeFragment(LayoutInflater inflater, ViewGroup container, int layoutId)
    {
        activity = (MainActivity) getActivity();
        rootView = inflater.inflate(layoutId, container, false);

        buttonSize = activity.getResources().getDimensionPixelSize(R.dimen.button_size);
        buttonMarginHorizontal = activity.getResources().getDimensionPixelSize(R.dimen.button_margin_horizontal);
        buttonMarginVertical = activity.getResources().getDimensionPixelSize(R.dimen.button_margin_vertical);
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
            @NonNull final ISCPMessage msg, Object tag)
    {
        return createButton(imageId, descriptionId, msg, tag,
                buttonMarginHorizontal, buttonMarginHorizontal, buttonMarginVertical);
    }

    protected AppCompatImageButton createButton(
            @DrawableRes int imageId, @StringRes int descriptionId,
            @NonNull final ISCPMessage msg, Object tag,
            int leftMargin, int rightMargin, int verticalMargin)
    {
        ContextThemeWrapper wrappedContext = new ContextThemeWrapper(activity, R.style.ImageButtonPrimaryStyle);
        final AppCompatImageButton b = new AppCompatImageButton(wrappedContext, null, 0);

        final LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(buttonSize, buttonSize);
        lp.setMargins(leftMargin, verticalMargin, rightMargin, verticalMargin);
        b.setLayoutParams(lp);

        b.setTag(tag);
        prepareButton(b, msg, imageId, descriptionId);
        return b;
    }

    protected void prepareButton(
            @NonNull AppCompatImageButton b, final ISCPMessage msg, @DrawableRes final int imageId, @StringRes final int descriptionId)
    {
        b.setImageResource(imageId);
        if (descriptionId != -1)
        {
            b.setContentDescription(activity.getResources().getString(descriptionId));
        }
        prepareButtonListeners(b, msg);
        setButtonEnabled(b, false);
    }

    protected void prepareButtonListeners(@NonNull View b, final ISCPMessage msg)
    {
        prepareButtonListeners(b, msg, null);
    }

    protected void prepareButtonListeners(@NonNull View b, final ISCPMessage msg, final ButtonListener listener)
    {
        if (msg != null)
        {
            b.setOnClickListener(new View.OnClickListener()
            {
                @Override
                public void onClick(View v)
                {
                    if (activity.getStateManager() != null)
                    {
                        activity.getStateManager().sendMessage(msg);
                        if (listener != null)
                        {
                            listener.onPostProcessing();
                        }
                    }
                }
            });
        }

        if (b instanceof AppCompatImageButton)
        {
            AppCompatImageButton bb = (AppCompatImageButton) b;
            bb.setLongClickable(true);
            bb.setOnLongClickListener(new View.OnLongClickListener()
            {
                @Override
                public boolean onLongClick(View v)
                {
                    return Utils.showButtonDescription(activity, v);
                }
            });
        }
    }

    protected void setButtonEnabled(@IdRes int buttonId, boolean isEnabled)
    {
        final AppCompatImageButton b = rootView.findViewById(buttonId);
        setButtonEnabled(b, isEnabled);
    }

    protected void setButtonEnabled(View b, boolean isEnabled)
    {
        @AttrRes int resId = isEnabled ? R.attr.colorButtonEnabled : R.attr.colorButtonDisabled;
        b.setEnabled(isEnabled);
        if (b instanceof AppCompatImageButton)
        {
            Utils.setImageButtonColorAttr(activity, (AppCompatImageButton) b, resId);
        }
        if (b instanceof AppCompatButton)
        {
            ((AppCompatButton) b).setTextColor(Utils.getThemeColorAttr(activity, resId));
        }
    }

    protected void setButtonSelected(View b, boolean isSelected)
    {
        @AttrRes int resId = isSelected ? R.attr.colorAccent : R.attr.colorButtonEnabled;
        b.setSelected(isSelected);
        if (b instanceof AppCompatImageButton)
        {
            Utils.setImageButtonColorAttr(activity, (AppCompatImageButton) b, resId);
        }
        if (b instanceof AppCompatButton)
        {
            ((AppCompatButton) b).setTextColor(Utils.getThemeColorAttr(activity, resId));
        }
    }

    protected AppCompatButton createButton(@StringRes int descriptionId,
                                           @NonNull final ISCPMessage msg, Object tag, final ButtonListener listener)
    {
        ContextThemeWrapper wrappedContext = new ContextThemeWrapper(activity, R.style.TextButtonStyle);
        final AppCompatButton b = new AppCompatButton(wrappedContext, null, 0);

        final LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, buttonSize);
        lp.setMargins(buttonMarginHorizontal, 0, buttonMarginHorizontal, 0);
        b.setLayoutParams(lp);

        b.setText(descriptionId);
        b.setTag(tag);
        prepareButtonListeners(b, msg, listener);
        return b;
    }
}
