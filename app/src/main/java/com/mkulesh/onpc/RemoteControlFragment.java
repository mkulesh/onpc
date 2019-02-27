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

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v7.widget.AppCompatImageButton;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.mkulesh.onpc.iscp.State;
import com.mkulesh.onpc.iscp.messages.OperationCommandMsg;
import com.mkulesh.onpc.iscp.messages.ReceiverInformationMsg;
import com.mkulesh.onpc.iscp.messages.SetupOperationCommandMsg;

import java.util.ArrayList;
import java.util.HashSet;

public class RemoteControlFragment extends BaseFragment
{
    private final ArrayList<View> buttons = new ArrayList<>();

    public RemoteControlFragment()
    {
        // Empty constructor required for fragment subclasses
    }

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
    {
        initializeFragment(inflater, container, R.layout.remote_control_fragment);
        final LinearLayout l = rootView.findViewById(R.id.remote_control_layout);
        collectButtons(l, buttons);
        for (View b : buttons)
        {
            prepareRiButton(b);
        }
        update(null, null);
        return rootView;
    }

    private void prepareRiButton(View b)
    {
        if (b.getTag() == null)
        {
            return;
        }
        String[] tokens = b.getTag().toString().split(":");
        if (tokens.length != 2)
        {
            return;
        }
        final String msgName = tokens[0];

        switch (msgName)
        {
        case SetupOperationCommandMsg.CODE:
        {
            final SetupOperationCommandMsg cmd = new SetupOperationCommandMsg(tokens[1]);
            if (b instanceof AppCompatImageButton)
            {
                prepareButton((AppCompatImageButton) b, cmd, cmd.getCommand().getImageId(), cmd.getCommand().getDescriptionId());

            }
            else
            {
                prepareButtonListeners(b, cmd, null);
            }
            break;
        }
        case OperationCommandMsg.CODE:
        {
            final OperationCommandMsg cmd = new OperationCommandMsg(ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE, tokens[1]);
            if (b instanceof AppCompatImageButton)
            {
                prepareButton((AppCompatImageButton) b, cmd, cmd.getCommand().getImageId(), cmd.getCommand().getDescriptionId());

            }
            else
            {
                prepareButtonListeners(b, cmd, null);
            }
            break;
        }
        default:
            break;
        }
    }

    @Override
    protected void updateStandbyView(@Nullable final State state, @NonNull final HashSet<State.ChangeType> eventChanges)
    {
        for (View b : buttons)
        {
            setButtonEnabled(b, state != null && state.isOn());
        }
    }

    @Override
    protected void updateActiveView(@NonNull final State state, @NonNull final HashSet<State.ChangeType> eventChanges)
    {
        for (View b : buttons)
        {
            setButtonEnabled(b, true);
        }
    }
}
