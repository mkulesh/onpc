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

import android.content.res.Configuration;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.iscp.State;
import com.mkulesh.onpc.utils.Utils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;
import androidx.appcompat.view.ContextThemeWrapper;
import androidx.appcompat.widget.AppCompatButton;
import androidx.appcompat.widget.AppCompatImageButton;
import androidx.fragment.app.Fragment;

abstract public class BaseFragment extends Fragment
{
    /**
     * Constants used to save/restore the instance state.
     */
    static final String FRAGMENT_NUMBER = "fragment_number";

    private boolean visibleToUser = false;
    MainActivity activity = null;
    View rootView = null;

    private int buttonSize = 0;
    int buttonMarginHorizontal = 0;
    private int buttonMarginVertical = 0;
    final PopupManager popupManager = new PopupManager();

    interface ButtonListener
    {
        void onPostProcessing();
    }

    public BaseFragment()
    {
        // Empty constructor required for fragment subclasses
    }

    void initializeFragment(LayoutInflater inflater, ViewGroup container, int layoutId)
    {
        activity = (MainActivity) getActivity();
        rootView = inflater.inflate(layoutId, container, false);

        buttonSize = activity.getResources().getDimensionPixelSize(R.dimen.button_size);
        buttonMarginHorizontal = activity.getResources().getDimensionPixelSize(R.dimen.button_margin_horizontal);
        buttonMarginVertical = activity.getResources().getDimensionPixelSize(R.dimen.button_margin_vertical);
    }

    @SuppressWarnings("SameParameterValue")
    void initializeFragment(LayoutInflater inflater, ViewGroup container, int layoutPort, int layoutLand)
    {
        activity = (MainActivity) getActivity();
        initializeFragment(inflater, container,
                (activity != null && activity.orientation == Configuration.ORIENTATION_LANDSCAPE) ? layoutLand : layoutPort);
    }

    @Override
    public void onResume()
    {
        super.onResume();
        visibleToUser = true;
        if (activity != null)
        {
            updateContent();
        }
    }

    @Override
    public void onPause()
    {
        super.onPause();
        visibleToUser = false;
    }

    void updateContent()
    {
        update(visibleToUser && activity.isConnected() ? activity.getStateManager().getState() : null, null);
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
            updateStandbyView(state);
        }
        else
        {
            updateActiveView(state, eventChanges);
        }
        if (activity.isConnected() && state != null)
        {
            if (state.popup.get() != null)
            {
                popupManager.showPopupDialog(activity, state);
            }
            if (!state.isPopupMode())
            {
                popupManager.closePopupDialog();
            }
        }
    }

    protected abstract void updateStandbyView(@Nullable final State state);

    protected abstract void updateActiveView(@NonNull final State state, @NonNull final HashSet<State.ChangeType> eventChanges);

    AppCompatImageButton createButton(
            @DrawableRes int imageId, @StringRes int descriptionId,
            final ISCPMessage msg, Object tag)
    {
        return createButton(imageId, descriptionId, msg, tag,
                buttonMarginHorizontal, buttonMarginHorizontal, buttonMarginVertical);
    }

    AppCompatImageButton createButton(
            @DrawableRes int imageId, @StringRes int descriptionId,
            final ISCPMessage msg, Object tag,
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

    void prepareButton(@NonNull AppCompatImageButton b,
                       @DrawableRes final int imageId,
                       @StringRes final int descriptionId)
    {
        b.setImageResource(imageId);
        if (descriptionId != -1)
        {
            b.setContentDescription(activity.getResources().getString(descriptionId));
        }
    }

    void prepareButton(@NonNull AppCompatImageButton b,
                       final ISCPMessage msg,
                       @DrawableRes final int imageId,
                       @StringRes final int descriptionId)
    {
        prepareButton(b, imageId, descriptionId);
        b.setImageResource(imageId);
        prepareButtonListeners(b, msg);
        setButtonEnabled(b, false);
    }

    void prepareButtonListeners(@NonNull View b, final ISCPMessage msg)
    {
        prepareButtonListeners(b, msg, null);
    }

    void prepareButtonListeners(@NonNull View b, final ISCPMessage msg, final ButtonListener listener)
    {
        b.setClickable(true);
        b.setOnClickListener(v ->
        {
            if (activity.isConnected() && msg != null)
            {
                activity.getStateManager().sendMessage(msg);
            }
            if (listener != null)
            {
                listener.onPostProcessing();
            }
        });

        if (b.getContentDescription() != null && b.getContentDescription().length() > 0)
        {
            b.setLongClickable(true);
            b.setOnLongClickListener(v -> Utils.showButtonDescription(activity, v));
        }
    }

    void setButtonEnabled(View b, boolean isEnabled)
    {
        Utils.setButtonEnabled(activity, b, isEnabled);
    }

    void setButtonSelected(View b, boolean isSelected)
    {
        Utils.setButtonSelected(activity, b, isSelected);
    }

    AppCompatButton createButton(@StringRes int descriptionId,
                                 final ISCPMessage msg, Object tag, final ButtonListener listener)
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

    static void collectButtons(LinearLayout layout, ArrayList<View> out)
    {
        for (int k = 0; k < layout.getChildCount(); k++)
        {
            View v = layout.getChildAt(k);
            if (v instanceof AppCompatImageButton || v instanceof AppCompatButton)
            {
                out.add(v);
            }
            else if (v instanceof TextView && v.getTag() != null)
            {
                out.add(v);
            }
            if (v instanceof LinearLayout)
            {
                collectButtons((LinearLayout) v, out);
            }
        }
    }

    boolean onBackPressed()
    {
        // No default processing for Back button
        return false;
    }

    @SuppressWarnings("WeakerAccess")
    @NonNull
    protected String getStringValue(@StringRes int descriptionId)
    {
        String value = "";
        try
        {
            value = getString(descriptionId);
        }
        catch (Exception ex)
        {
            // nothing to do
        }
        return value;
    }
}
