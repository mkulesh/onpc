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

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v7.widget.AppCompatButton;
import android.support.v7.widget.AppCompatImageButton;
import android.support.v7.widget.AppCompatImageView;
import android.view.ContextMenu;
import android.view.LayoutInflater;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;

import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.iscp.State;
import com.mkulesh.onpc.iscp.StateManager;
import com.mkulesh.onpc.iscp.messages.InputSelectorMsg;
import com.mkulesh.onpc.iscp.messages.MenuStatusMsg;
import com.mkulesh.onpc.iscp.messages.NetworkServiceMsg;
import com.mkulesh.onpc.iscp.messages.OperationCommandMsg;
import com.mkulesh.onpc.iscp.messages.PlayQueueAddMsg;
import com.mkulesh.onpc.iscp.messages.PlayQueueRemoveMsg;
import com.mkulesh.onpc.iscp.messages.PlayQueueReorderMsg;
import com.mkulesh.onpc.iscp.messages.PresetCommandMsg;
import com.mkulesh.onpc.iscp.messages.ReceiverInformationMsg;
import com.mkulesh.onpc.iscp.messages.ServiceType;
import com.mkulesh.onpc.iscp.messages.XmlListItemMsg;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

public class MediaFragment extends BaseFragment implements AdapterView.OnItemClickListener
{
    private TextView titleBar;
    private ListView listView;
    private MediaListAdapter listViewAdapter;
    private LinearLayout selectorPaletteLayout;
    private XmlListItemMsg selectedItem = null;
    int moveFrom = -1;
    private int filteredItems = 0;
    private final OperationCommandMsg returnMsg = new OperationCommandMsg(OperationCommandMsg.Command.RETURN);
    private AppCompatImageView progressIndicator;

    public MediaFragment()
    {
        // Empty constructor required for fragment subclasses
    }

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
    {
        initializeFragment(inflater, container, R.layout.media_fragment);
        rootView.setLayerType(View.LAYER_TYPE_HARDWARE, null);

        selectorPaletteLayout = rootView.findViewById(R.id.selector_palette);
        titleBar = rootView.findViewById(R.id.items_list_title_bar);
        listView = rootView.findViewById(R.id.items_list_view);
        listView.setItemsCanFocus(false);
        listView.setFocusableInTouchMode(true);
        listView.setChoiceMode(ListView.CHOICE_MODE_MULTIPLE);
        listView.setOnItemClickListener(this);

        registerForContextMenu(listView);

        progressIndicator = rootView.findViewById(R.id.progress_indicator);
        Utils.setImageViewColorAttr(activity, progressIndicator, R.attr.colorButtonDisabled);

        update(null, null);
        return rootView;
    }

    @Override
    public void onCreateContextMenu(ContextMenu menu, View v, ContextMenu.ContextMenuInfo menuInfo)
    {
        selectedItem = null;
        if (v.getId() == listView.getId() && activity.isConnected())
        {
            final State state = activity.getStateManager().getState();
            final ReceiverInformationMsg.Selector selector = state.getActualSelector();
            final ReceiverInformationMsg.NetworkService networkService = state.getNetworkService();
            if (selector != null)
            {
                Logging.info(this, "Context menu for selector " + selector.toString() +
                        (networkService != null? " and service " + networkService.toString() : ""));
                ListView lv = (ListView) v;
                AdapterView.AdapterContextMenuInfo acmi = (AdapterView.AdapterContextMenuInfo) menuInfo;
                final Object item = lv.getItemAtPosition(acmi.position);
                if (item instanceof XmlListItemMsg)
                {
                    selectedItem = (XmlListItemMsg) item;
                    MenuInflater inflater = activity.getMenuInflater();
                    inflater.inflate(R.menu.playlist_context_menu, menu);

                    final boolean isQueue = state.serviceType == ServiceType.PLAYQUEUE;
                    final boolean addToQueue = selector.isAddToQueue() ||
                            (networkService != null && networkService.isAddToQueue());
                    final boolean isAdvQueue = activity.getConfiguration().isAdvancedQueue();

                    if (isQueue || addToQueue)
                    {
                        menu.setHeaderTitle(R.string.playlist_options);
                    }
                    menu.findItem(R.id.playlist_menu_add).setVisible(!isQueue && addToQueue);
                    menu.findItem(R.id.playlist_menu_add_and_play).setVisible(!isQueue && addToQueue);
                    menu.findItem(R.id.playlist_menu_replace).setVisible(!isQueue && addToQueue && isAdvQueue);
                    menu.findItem(R.id.playlist_menu_replace_and_play).setVisible(!isQueue && addToQueue && isAdvQueue);
                    menu.findItem(R.id.playlist_menu_remove).setVisible(isQueue);
                    menu.findItem(R.id.playlist_menu_remove_all).setVisible(isQueue);
                    menu.findItem(R.id.playlist_menu_move_from).setVisible(isQueue);
                    menu.findItem(R.id.playlist_menu_move_to).setVisible(
                            isQueue && isMoveToValid(selectedItem.getMessageId()));

                    final boolean isTrackMenu = state.trackMenu == MenuStatusMsg.TrackMenu.ENABLE;
                    menu.findItem(R.id.playlist_track_menu).setVisible(isTrackMenu &&
                            selectedItem.getIcon() == XmlListItemMsg.Icon.PLAY && !isQueue);
                }
            }
        }
    }

    @Override
    public boolean onContextItemSelected(MenuItem item)
    {
        if (selectedItem != null && activity.isConnected())
        {
            final State state = activity.getStateManager().getState();
            final int idx = selectedItem.getMessageId();
            Logging.info(this, "Context menu: " + item.toString() + "; " + selectedItem.toString());
            selectedItem = null;
            switch (item.getItemId())
            {
            case R.id.playlist_menu_add:
                activity.getStateManager().sendPlayQueueMsg(new PlayQueueAddMsg(idx, 2), false);
                return true;
            case R.id.playlist_menu_add_and_play:
                activity.getStateManager().sendPlayQueueMsg(new PlayQueueAddMsg(idx, 0), false);
                return true;
            case R.id.playlist_menu_replace:
                activity.getStateManager().sendPlayQueueMsg(new PlayQueueRemoveMsg(1, 0), false);
                activity.getStateManager().sendPlayQueueMsg(new PlayQueueAddMsg(idx, 2), false);
                return true;
            case R.id.playlist_menu_replace_and_play:
                activity.getStateManager().sendPlayQueueMsg(new PlayQueueRemoveMsg(1, 0), false);
                activity.getStateManager().sendPlayQueueMsg(new PlayQueueAddMsg(idx, 0), false);
                return true;
            case R.id.playlist_menu_remove:
                activity.getStateManager().sendPlayQueueMsg(new PlayQueueRemoveMsg(0, idx), false);
                return true;
            case R.id.playlist_menu_remove_all:
                if (activity.getConfiguration().isAdvancedQueue())
                {
                    activity.getStateManager().sendPlayQueueMsg(new PlayQueueRemoveMsg(1, 0), false);
                }
                else
                {
                    activity.getStateManager().sendPlayQueueMsg(new PlayQueueRemoveMsg(0, 0), true);
                }
                return true;
            case R.id.playlist_menu_move_from:
                moveFrom = idx;
                updateListView(state);
                return true;
            case R.id.playlist_menu_move_to:
                if (isMoveToValid(idx))
                {
                    activity.getStateManager().sendPlayQueueMsg(new PlayQueueReorderMsg(moveFrom, idx), false);
                    moveFrom = -1;
                }
                return true;
            case R.id.playlist_track_menu:
                activity.getStateManager().sendMessage(new OperationCommandMsg(OperationCommandMsg.Command.MENU));
                return true;
            }
        }
        return super.onContextItemSelected(item);
    }

    @Override
    protected void updateStandbyView(@Nullable final State state, @NonNull final HashSet<State.ChangeType> eventChanges)
    {
        moveFrom = -1;
        if (state != null)
        {
            updateSelectorButtons(state);
        }
        else
        {
            selectorPaletteLayout.removeAllViews();
        }
        titleBar.setVisibility(View.GONE);
        titleBar.setText(R.string.dashed_string);
        listView.clearChoices();
        listView.invalidate();
        listView.setAdapter(new MediaListAdapter(this, activity, new ArrayList<>()));
    }

    @Override
    protected void updateActiveView(@NonNull final State state, @NonNull final HashSet<State.ChangeType> eventChanges)
    {
        if (eventChanges.contains(State.ChangeType.MEDIA_ITEMS) || eventChanges.contains(State.ChangeType.RECEIVER_INFO))
        {
            Logging.info(this, "Updating media fragment");
            moveFrom = -1;
            filteredItems = state.numberOfItems;
            updateSelectorButtons(state);
            updateListView(state);
            updateTitle(state, state.numberOfItems > 0 && state.isMediaEmpty());
        }
        else if (eventChanges.contains(State.ChangeType.COMMON))
        {
            updateSelectorButtonsState(state);
        }
    }

    private void updateSelectorButtons(@NonNull final State state)
    {
        selectorPaletteLayout.removeAllViews();
        if (state.deviceSelectors.isEmpty())
        {
            return;
        }

        // Top menu button
        {
            final OperationCommandMsg msg = new OperationCommandMsg(OperationCommandMsg.Command.TOP);
            final AppCompatImageButton b = createButton(
                    msg.getCommand().getImageId(), msg.getCommand().getDescriptionId(),
                    msg, msg.getCommand(), 0, buttonMarginHorizontal, 0);
            prepareButtonListeners(b, msg, () -> progressIndicator.setVisibility(View.VISIBLE));
            selectorPaletteLayout.addView(b);
        }

        // Selectors
        AppCompatButton selectedButton = null;
        for (ReceiverInformationMsg.Selector s : activity.getConfiguration().getSortedDeviceSelectors(
                false, state.inputType, state.deviceSelectors))
        {
            final InputSelectorMsg msg = new InputSelectorMsg(state.getActiveZone(), s.getId());
            if (msg.getInputType() == InputSelectorMsg.InputType.NONE)
            {
                continue;
            }
            final AppCompatButton b = createButton(msg.getInputType().getDescriptionId(),
                    msg, msg.getInputType(), () -> progressIndicator.setVisibility(View.VISIBLE));
            if (activity.getConfiguration().isFriendlyNames())
            {
                b.setText(s.getName());
            }
            if (state.inputType.getCode().equals(s.getId()))
            {
                selectedButton = b;
            }
            selectorPaletteLayout.addView(b);
        }
        updateSelectorButtonsState(state);
        if (selectedButton != null)
        {
            selectorPaletteLayout.requestChildFocus(selectedButton, selectedButton);
        }
    }

    private void updateSelectorButtonsState(@NonNull final State state)
    {
        for (int i = 0; i < selectorPaletteLayout.getChildCount(); i++)
        {
            final View v = selectorPaletteLayout.getChildAt(i);
            setButtonEnabled(v, state.isOn());
            if (!state.isOn())
            {
                continue;
            }
            if (v.getTag() instanceof OperationCommandMsg.Command)
            {
                setButtonEnabled(v, v.getTag() == OperationCommandMsg.Command.TOP && !state.isTopLayer());

            }
            else if (v.getTag() instanceof InputSelectorMsg.InputType)
            {
                setButtonSelected(v, state.inputType == v.getTag());
            }
        }
    }

    private void updateListView(@NonNull final State state)
    {
        listView.clearChoices();
        listView.invalidate();
        final List<XmlListItemMsg> mediaItems = state.cloneMediaItems();
        final List<NetworkServiceMsg> serviceItems = state.cloneServiceItems();

        ArrayList<ISCPMessage> newItems = new ArrayList<>();
        if (!state.isTopLayer() && !activity.getConfiguration().isBackAsReturn())
        {
            newItems.add(returnMsg);
        }
        int playing = -1;
        if (!mediaItems.isEmpty())
        {
            for (XmlListItemMsg i : mediaItems)
            {
                newItems.add(i);
                if (i.getIcon() == XmlListItemMsg.Icon.PLAY)
                {
                    playing = newItems.size() - 1;
                }
            }
        }
        else if (!serviceItems.isEmpty())
        {
            final ArrayList<NetworkServiceMsg> items =
                    activity.getConfiguration().getSortedNetworkServices(state.serviceIcon, serviceItems);
            filteredItems = items.size();
            newItems.addAll(items);
        }
        else if (state.isPlaybackMode())
        {
            final XmlListItemMsg nsMsg = new XmlListItemMsg(-1, 0,
                    activity.getResources().getString(R.string.medialist_playback_mode),
                    XmlListItemMsg.Icon.PLAY, false);
            newItems.add(nsMsg);
        }
        else if (state.isRadioInput())
        {
            for (ReceiverInformationMsg.Preset p : state.presetList)
            {
                if ((state.inputType == InputSelectorMsg.InputType.FM && p.getBand() == 1)
                        || (state.inputType == InputSelectorMsg.InputType.DAB && p.getBand() == 2))
                {
                    final boolean isPlaying = (p.getId() == state.preset);
                    newItems.add(new PresetCommandMsg(
                            state.getActiveZone(), p, isPlaying ? state.preset : PresetCommandMsg.NO_PRESET));
                }
            }
        }
        listViewAdapter = new MediaListAdapter(this, activity, newItems);
        listView.setAdapter(listViewAdapter);
        if (playing >= 0)
        {
            setSelection(playing, listView.getHeight() / 2);
        }
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id)
    {
        if (activity.isConnected() && listViewAdapter != null && position < listViewAdapter.getCount())
        {
            final ISCPMessage selectedItem = listViewAdapter.getItem(position);
            if (selectedItem != null)
            {
                moveFrom = -1;
                // #6: Unable to play music from NAS: allow to select not selectable items as well
                updateTitle(activity.getStateManager().getState(), true);
                activity.getStateManager().sendMessage(selectedItem);
            }
        }
    }

    private boolean isMoveToValid(int messageId)
    {
        return moveFrom >= 0 && moveFrom != messageId;
    }

    private void setSelection(int i, int y_)
    {
        final ListView flv$ = listView;
        final int position$ = i, y$ = y_;
        flv$.post(() -> flv$.setSelectionFromTop(position$, y$ > 0 ? y$ : flv$.getHeight() / 2));
    }

    private void updateTitle(@NonNull final State state, boolean processing)
    {
        final StringBuilder title = new StringBuilder();
        if (state.isPlaybackMode() || state.isMenuMode())
        {
            title.append(state.title);
        }
        else if (state.isRadioInput())
        {
            title.append(activity.getResources().getString(state.inputType.getDescriptionId()));
        }
        else if (state.inputType.isMediaList())
        {
            title.append(state.titleBar);
            if (state.numberOfItems > 0)
            {
                title.append(" | ").append(activity.getResources().getString(R.string.medialist_items)).append(": ");
                if (filteredItems != state.numberOfItems)
                {
                    title.append(filteredItems).append("/");
                }
                title.append(state.numberOfItems);
            }
        }
        else
        {
            title.append(state.titleBar).append("/").append(
                    activity.getResources().getString(R.string.medialist_no_items));
        }
        titleBar.setVisibility(View.VISIBLE);
        titleBar.setText(title.toString());
        progressIndicator.setVisibility(state.inputType.isMediaList() && processing ? View.VISIBLE : View.INVISIBLE);
    }

    protected boolean onBackPressed()
    {
        final StateManager stateManager = activity.getStateManager();
        if (!activity.isConnected() || stateManager == null)
        {
            return false;
        }
        if (stateManager.getState().isTopLayer())
        {
            return false;
        }
        moveFrom = -1;
        updateTitle(stateManager.getState(), true);
        stateManager.sendMessage(returnMsg);
        return true;
    }
}
