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

package com.mkulesh.onpc.fragments;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.config.CfgAppSettings;
import com.mkulesh.onpc.iscp.State;
import com.mkulesh.onpc.iscp.messages.ListeningModeMsg;
import com.mkulesh.onpc.iscp.messages.OperationCommandMsg;
import com.mkulesh.onpc.iscp.messages.ReceiverInformationMsg;
import com.mkulesh.onpc.iscp.messages.SetupOperationCommandMsg;

import java.util.ArrayList;
import java.util.HashSet;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatImageButton;

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
        initializeFragment(inflater, container, R.layout.remote_control_fragment, CfgAppSettings.Tabs.RC);
        final LinearLayout l = rootView.findViewById(R.id.remote_control_layout);
        collectButtons(l, buttons);
        for (View b : buttons)
        {
            prepareRCButton(b);
        }
        updateContent();
        return rootView;
    }

    private void prepareRCButton(View b)
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
        case ListeningModeMsg.CODE:
            final ListeningModeMsg cmd = new ListeningModeMsg(ListeningModeMsg.Mode.valueOf(tokens[1]));
            if (b instanceof AppCompatImageButton)
            {
                prepareButton((AppCompatImageButton) b, cmd, cmd.getMode().getImageId(), cmd.getMode().getDescriptionId());

            }
            else
            {
                prepareButtonListeners(b, cmd, null);
            }
            break;
        default:
            break;
        }
    }

    @Override
    protected void updateStandbyView(@Nullable final State state)
    {
        // Command buttons
        rootView.findViewById(R.id.cmd_buttons_layout).setVisibility(View.GONE);

        // All buttons
        for (View b : buttons)
        {
            setButtonEnabled(b, state != null && state.isOn());
        }

        // Listening modes
        rootView.findViewById(R.id.listening_mode_layout).setVisibility(
                state != null && state.isListeningModeControl() ? View.VISIBLE : View.GONE);
        rootView.findViewById(R.id.listening_mode).setVisibility(View.GONE);
    }

    @Override
    protected void updateActiveView(@NonNull final State state, @NonNull final HashSet<State.ChangeType> eventChanges)
    {
        // Command buttons
        rootView.findViewById(R.id.cmd_buttons_layout).setVisibility(View.VISIBLE);
        rootView.findViewById(R.id.cmd_setup_layout).setVisibility(
                state.isControlExists("Setup") ? View.VISIBLE : View.GONE);
        rootView.findViewById(R.id.cmd_home_layout).setVisibility(
                state.isControlExists("Home") ? View.VISIBLE : View.GONE);
        rootView.findViewById(R.id.cmd_quick_menu_layout).setVisibility(
                state.isControlExists("Quick") ? View.VISIBLE : View.GONE);

        // All buttons
        for (View b : buttons)
        {
            setButtonEnabled(b, true);
        }

        // Listening modes
        final LinearLayout listeningModeLayout = rootView.findViewById(R.id.listening_mode_layout);
        listeningModeLayout.setVisibility(state.isListeningModeControl() ? View.VISIBLE : View.GONE);
        final TextView listeningMode = rootView.findViewById(R.id.listening_mode);
        listeningMode.setVisibility(listeningModeLayout.getVisibility());
        if (eventChanges.contains(State.ChangeType.AUDIO_CONTROL))
        {
            listeningMode.setText(state.listeningMode.getDescriptionId());
        }
    }
}
