package com.mkulesh.onpc;

import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v7.widget.AppCompatImageButton;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.mkulesh.onpc.utils.Utils;

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
    protected int fragmentNumber = -1;

    public BaseFragment()
    {
        // Empty constructor required for fragment subclasses
    }

    public void initializeFragment(LayoutInflater inflater, ViewGroup container, int layoutId)
    {
        activity = (MainActivity) getActivity();
        preferences = PreferenceManager.getDefaultSharedPreferences(activity);
        rootView = inflater.inflate(layoutId, container, false);
        Bundle args = getArguments();
        fragmentNumber = args != null ? args.getInt(FRAGMENT_NUMBER) : 0;
    }

    public void update(final State state)
    {
        if (state == null || !state.isOn())
        {
            updateStandbyView(state);
        }
        else
        {
            updateActiveView(state);
        }
    }

    protected abstract void updateStandbyView(@Nullable final State state);

    protected abstract void updateActiveView(@NonNull final State state);

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
