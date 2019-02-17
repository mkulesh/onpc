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
import com.mkulesh.onpc.iscp.messages.InputSelectorMsg;
import com.mkulesh.onpc.iscp.messages.MenuStatusMsg;
import com.mkulesh.onpc.iscp.messages.NetworkServiceMsg;
import com.mkulesh.onpc.iscp.messages.OperationCommandMsg;
import com.mkulesh.onpc.iscp.messages.PlayQueueAddMsg;
import com.mkulesh.onpc.iscp.messages.PlayQueueRemoveMsg;
import com.mkulesh.onpc.iscp.messages.PlayQueueReorderMsg;
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
            if (selector != null)
            {
                Logging.info(this, "Context menu for selector " + selector.toString());
                ListView lv = (ListView) v;
                AdapterView.AdapterContextMenuInfo acmi = (AdapterView.AdapterContextMenuInfo) menuInfo;
                final Object item = lv.getItemAtPosition(acmi.position);
                if (item instanceof XmlListItemMsg)
                {
                    selectedItem = (XmlListItemMsg) item;
                    MenuInflater inflater = activity.getMenuInflater();
                    inflater.inflate(R.menu.playlist_context_menu, menu);
                    menu.findItem(R.id.playlist_menu_add).setVisible(selector.isAddToQueue());
                    menu.findItem(R.id.playlist_menu_add_and_play).setVisible(selector.isAddToQueue());

                    final boolean isQueue = state.serviceType == ServiceType.PLAYQUEUE;
                    menu.findItem(R.id.playlist_menu_remove).setVisible(isQueue);
                    menu.findItem(R.id.playlist_menu_remove_all).setVisible(isQueue);
                    menu.findItem(R.id.playlist_menu_move_from).setVisible(isQueue);
                    menu.findItem(R.id.playlist_menu_move_to).setVisible(
                            isQueue && isMoveToValid(selectedItem.getMessageId()));

                    final boolean isTrackMenu = state.trackMenu == MenuStatusMsg.TrackMenu.ENABLE;
                    menu.findItem(R.id.playlist_track_menu).setVisible(isTrackMenu &&
                            selectedItem.getIcon() == XmlListItemMsg.Icon.PLAY);
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
            case R.id.playlist_menu_remove:
                activity.getStateManager().sendPlayQueueMsg(new PlayQueueRemoveMsg(0, idx), false);
                return true;
            case R.id.playlist_menu_remove_all:
                activity.getStateManager().sendPlayQueueMsg(new PlayQueueRemoveMsg(0, 0), true);
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
        selectorPaletteLayout.removeAllViews();
        titleBar.setText("");
        listView.clearChoices();
        listView.invalidate();
        listView.setAdapter(new MediaListAdapter(this, activity, new ArrayList<>()));
    }

    @Override
    protected void updateActiveView(@NonNull final State state, @NonNull final HashSet<State.ChangeType> eventChanges)
    {
        if (eventChanges.contains(State.ChangeType.MEDIA_ITEMS) || eventChanges.contains(State.ChangeType.RECEIVER_INFO))
        {
            Logging.info(this, "Updating media fragment: " + state.mediaItems.size() + "/" + state.serviceItems.size());
            moveFrom = -1;
            updateSelectorButtons(state);
            updateTitle(state, state.numberOfItems > 0 && state.isMediaEmpty());
            updateListView(state);
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
        final int selNumber = state.deviceSelectors.size();
        for (int i = 0; i < selNumber; i++)
        {
            final ReceiverInformationMsg.Selector s = state.deviceSelectors.get(i);
            final InputSelectorMsg msg = new InputSelectorMsg(state.getActiveZone(), s.getId());
            if (msg.getInputType() != InputSelectorMsg.InputType.NONE)
            {
                final AppCompatButton b = createButton(msg.getInputType().getDescriptionId(),
                        msg, msg.getInputType(), () -> progressIndicator.setVisibility(View.VISIBLE));
                if (activity.getConfiguration().isFriendlySelectorName())
                {
                    b.setText(s.getName());
                }
                selectorPaletteLayout.addView(b);
            }
        }

        for (int i = 0; i < selectorPaletteLayout.getChildCount(); i++)
        {
            final View v = selectorPaletteLayout.getChildAt(i);
            if (v instanceof AppCompatImageButton && v.getTag() instanceof OperationCommandMsg.Command)
            {
                final AppCompatImageButton b = (AppCompatImageButton) v;
                setButtonEnabled(b, b.getTag() == OperationCommandMsg.Command.TOP && !state.isTopLayer());
            }
            if (v instanceof AppCompatButton && v.getTag() instanceof InputSelectorMsg.InputType)
            {
                final AppCompatButton b = (AppCompatButton) v;
                final InputSelectorMsg.InputType s = (InputSelectorMsg.InputType) (b.getTag());
                if (s == state.inputType || activity.getConfiguration().isSelectorVisible(s.getCode()))
                {
                    b.setVisibility(View.VISIBLE);
                    setButtonSelected(b, s == state.inputType);
                    if (b.isSelected())
                    {
                        b.getParent().requestChildFocus(b, b);
                    }
                }
                else
                {
                    b.setVisibility(View.GONE);
                }
            }
        }
    }

    private void updateListView(@NonNull final State state)
    {
        listView.clearChoices();
        listView.invalidate();
        final List<XmlListItemMsg> mediaItems = state.mediaItems;
        final List<NetworkServiceMsg> serviceItems = state.serviceItems;

        ArrayList<ISCPMessage> newItems = new ArrayList<>();
        if (!state.isTopLayer())
        {
            newItems.add(new OperationCommandMsg(OperationCommandMsg.Command.RETURN));
        }
        int playing = -1;
        if (!mediaItems.isEmpty())
        {
            for (XmlListItemMsg i : mediaItems)
            {
                if (i == null)
                {
                    // i != null: a paranoia check: mediaItems can not actually contain null elements,
                    // but we observed a NullPointerException for i in GooglePlay console.
                    continue;
                }
                newItems.add(new XmlListItemMsg(i));
                if (i.getIcon() == XmlListItemMsg.Icon.PLAY)
                {
                    playing = newItems.size() - 1;
                }
            }
        }
        else if (!serviceItems.isEmpty())
        {
            final ArrayList<String> selectedItems = activity.getConfiguration().getSelectedNetworkServices();
            if (selectedItems == null)
            {
                // Default configuration if filter is not active
                for (NetworkServiceMsg i : serviceItems)
                {
                    newItems.add(new NetworkServiceMsg(i));
                }
            }
            else
            {
                // Add item that is currently playing
                if (state.serviceIcon != ServiceType.UNKNOWN
                        && !selectedItems.contains(state.serviceIcon.getCode()))
                {
                    for (NetworkServiceMsg i : serviceItems)
                    {
                        if (i.getService().getCode().equals(state.serviceIcon.getCode()))
                        {
                            newItems.add(new NetworkServiceMsg(i));
                        }
                    }
                }
                // Add all selected items
                for (String s : selectedItems)
                {
                    for (NetworkServiceMsg i : serviceItems)
                    {
                        if (i.getService().getCode().equals(s))
                        {
                            newItems.add(new NetworkServiceMsg(i));
                        }
                    }
                }
            }
        }
        else if (state.isPlaybackMode())
        {
            final XmlListItemMsg nsMsg = new XmlListItemMsg(-1, 0,
                    activity.getResources().getString(R.string.medialist_playback_mode),
                    XmlListItemMsg.Icon.PLAY, false);
            newItems.add(nsMsg);
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

    public final void setSelection(int i, int y_)
    {
        final ListView flv$ = listView;
        final int position$ = i, y$ = y_;
        flv$.post(new Runnable()
        {
            public void run()
            {
                flv$.setSelectionFromTop(position$, y$ > 0 ? y$ : flv$.getHeight() / 2);
            }
        });
    }

    private void updateTitle(@NonNull final State state, boolean processing)
    {
        final StringBuilder title = new StringBuilder();
        if (state.isPlaybackMode() || state.isMenuMode())
        {
            title.append(state.title);
        }
        else if (state.inputType.isMediaList())
        {
            title.append(state.titleBar);
            if (state.numberOfItems > 0)
            {
                title.append("/").append(state.numberOfItems).append(" ").append(
                        activity.getResources().getString(R.string.medialist_items));
            }
        }
        else
        {
            title.append(state.titleBar).append("/").append(
                    activity.getResources().getString(R.string.medialist_no_items));
        }
        titleBar.setText(title.toString());
        progressIndicator.setVisibility(state.inputType.isMediaList() && processing ? View.VISIBLE : View.INVISIBLE);
    }
}
