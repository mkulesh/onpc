/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2022 by Mikhail Kulesh
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
import android.widget.Toast;

import com.mkulesh.onpc.R;
import com.mkulesh.onpc.config.CfgAppSettings;
import com.mkulesh.onpc.config.CfgFavoriteShortcuts;
import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.iscp.State;
import com.mkulesh.onpc.iscp.StateManager;
import com.mkulesh.onpc.iscp.messages.DcpMediaContainerMsg;
import com.mkulesh.onpc.iscp.messages.DcpTunerModeMsg;
import com.mkulesh.onpc.iscp.messages.InputSelectorMsg;
import com.mkulesh.onpc.iscp.messages.MenuStatusMsg;
import com.mkulesh.onpc.iscp.messages.NetworkServiceMsg;
import com.mkulesh.onpc.iscp.messages.OperationCommandMsg;
import com.mkulesh.onpc.iscp.messages.PlayQueueAddMsg;
import com.mkulesh.onpc.iscp.messages.PlayQueueRemoveMsg;
import com.mkulesh.onpc.iscp.messages.PlayQueueReorderMsg;
import com.mkulesh.onpc.iscp.messages.PowerStatusMsg;
import com.mkulesh.onpc.iscp.messages.PresetCommandMsg;
import com.mkulesh.onpc.iscp.messages.ReceiverInformationMsg;
import com.mkulesh.onpc.iscp.messages.ServiceType;
import com.mkulesh.onpc.iscp.messages.XmlListItemMsg;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatButton;
import androidx.appcompat.widget.AppCompatImageButton;
import androidx.appcompat.widget.AppCompatImageView;

public class MediaFragment extends BaseFragment implements AdapterView.OnItemClickListener
{
    private TextView titleBar;
    private ListView listView;
    private final MediaFilter mediaFilter = new MediaFilter();
    private MediaListAdapter listViewAdapter;
    private LinearLayout selectorPaletteLayout;
    private XmlListItemMsg selectedItem = null;
    private PresetCommandMsg selectedStation = null;
    int moveFrom = -1;
    private int filteredItems = 0;

    public MediaFragment()
    {
        // Empty constructor required for fragment subclasses
    }

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
    {
        initializeFragment(inflater, container, R.layout.media_fragment, CfgAppSettings.Tabs.MEDIA);
        rootView.setLayerType(View.LAYER_TYPE_HARDWARE, null);

        selectorPaletteLayout = rootView.findViewById(R.id.selector_palette);
        titleBar = rootView.findViewById(R.id.items_list_title_bar);
        titleBar.setClickable(true);
        titleBar.setOnClickListener(v ->
        {
            if (activity.isConnected())
            {
                if (!activity.getStateManager().getState().isTopLayer())
                {
                    activity.getStateManager().sendMessage(activity.getStateManager().getReturnMessage());
                }
            }
        });

        listView = rootView.findViewById(R.id.items_list_view);
        listView.setItemsCanFocus(false);
        listView.setFocusableInTouchMode(true);
        listView.setChoiceMode(ListView.CHOICE_MODE_MULTIPLE);
        listView.setOnItemClickListener(this);

        // media filter
        mediaFilter.init(activity, rootView, () ->
        {
            if (activity.isConnected())
            {
                updateListView(activity.getStateManager().getState());
            }
        });

        registerForContextMenu(listView);

        updateContent();
        return rootView;
    }

    @Override
    public void onResume()
    {
        if (activity != null && activity.isConnected())
        {
            final boolean keepPlaybackMode = activity.getConfiguration().keepPlaybackMode();
            activity.getStateManager().setPlaybackMode(keepPlaybackMode);
            final State state = activity.getStateManager().getState();
            if (!keepPlaybackMode && state.isUiTypeValid() && state.isPlaybackMode())
            {
                activity.getStateManager().sendMessage(StateManager.LIST_MSG);
            }
        }
        mediaFilter.setVisibility(false, true);
        super.onResume();
    }

    @Override
    public void onPause()
    {
        super.onPause();
        updateStandbyView(null);
    }

    @Override
    public void onCreateContextMenu(@NonNull ContextMenu menu, View v, ContextMenu.ContextMenuInfo menuInfo)
    {
        selectedItem = null;
        if (v.getId() == listView.getId() && activity.isConnected())
        {
            final State state = activity.getStateManager().getState();
            final ReceiverInformationMsg.Selector selector = state.getActualSelector();
            final ReceiverInformationMsg.NetworkService networkService = state.getNetworkService();
            if (selector != null)
            {
                Logging.info(this, "Context menu for selector " + selector +
                        (networkService != null ? " and service " + networkService : ""));
                ListView lv = (ListView) v;
                AdapterView.AdapterContextMenuInfo acmi = (AdapterView.AdapterContextMenuInfo) menuInfo;
                final Object item = lv.getItemAtPosition(acmi.position);
                final boolean isShortcut = state.isShortcutPossible();
                if (item instanceof XmlListItemMsg)
                {
                    selectedItem = (XmlListItemMsg) item;
                    final MenuInflater inflater = activity.getMenuInflater();
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
                    final boolean isPlaying = selectedItem.getIcon() == XmlListItemMsg.Icon.PLAY;
                    menu.findItem(R.id.playlist_track_menu).setVisible(isTrackMenu && isPlaying && !isQueue);
                    menu.findItem(R.id.cmd_playback_mode).setVisible(isPlaying && !state.isPlaybackMode());

                    menu.findItem(R.id.cmd_shortcut_create).setVisible(isShortcut);

                    if (selectedItem.getCmdMessage() instanceof DcpMediaContainerMsg)
                    {
                        final DcpMediaContainerMsg mc = (DcpMediaContainerMsg) selectedItem.getCmdMessage();
                        final boolean isDcpQueue = (mc.isContainer() || mc.isSong()) && mc.isPlayable();
                        menu.findItem(R.id.cmd_dcp_replace_and_play).setVisible(isDcpQueue);
                        menu.findItem(R.id.cmd_dcp_add_to_end).setVisible(isDcpQueue);
                        menu.findItem(R.id.cmd_playback_mode).setVisible(false);
                    }
                }
                else if (item instanceof PresetCommandMsg)
                {
                    selectedStation = (PresetCommandMsg) item;
                    final MenuInflater inflater = activity.getMenuInflater();
                    inflater.inflate(R.menu.playlist_context_menu, menu);
                    for (int i = 0; i < menu.size(); i++)
                    {
                        menu.getItem(i).setVisible(false);
                    }
                    menu.findItem(R.id.cmd_shortcut_create).setVisible(isShortcut);
                }
            }
        }
    }

    @Override
    public boolean onContextItemSelected(@NonNull MenuItem item)
    {
        if (selectedItem != null && activity.isConnected())
        {
            final State state = activity.getStateManager().getState();
            final int idx = selectedItem.getMessageId();
            final String title = selectedItem.getTitle();
            final DcpMediaContainerMsg dcpCmd = (selectedItem.getCmdMessage() instanceof DcpMediaContainerMsg) ?
                    (DcpMediaContainerMsg) selectedItem.getCmdMessage() : null;
            Logging.info(this, "Context menu '" + item.getTitle() + "'; " + selectedItem);
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
                activity.getStateManager().sendTrackCmd(OperationCommandMsg.Command.MENU, false);
                return true;
            case R.id.cmd_playback_mode:
                activity.getStateManager().sendMessage(StateManager.LIST_MSG);
                return true;
            case R.id.cmd_shortcut_create:
                addShortcut(state, title, title);
                return true;
            case R.id.cmd_dcp_replace_and_play:
                if (dcpCmd != null)
                {
                    activity.getStateManager().sendDcpMediaCmd(dcpCmd, 4 /* replace and play */);
                }
                return true;
            case R.id.cmd_dcp_add_to_end:
                if (dcpCmd != null)
                {
                    activity.getStateManager().sendDcpMediaCmd(dcpCmd, 3 /* add to end */);
                }
                return true;
            }
        }
        else if (selectedStation != null && activity.isConnected() && item.getItemId() == R.id.cmd_shortcut_create)
        {
            addShortcut(activity.getStateManager().getState(),
                    String.format("%02x", selectedStation.getPresetConfig().getId()),
                    selectedStation.getPresetConfig().displayedString(true));
            selectedStation = null;
            return true;
        }
        return super.onContextItemSelected(item);
    }

    private void addShortcut(final @NonNull State state, final String item, final String alias)
    {
        if (state.isShortcutPossible())
        {
            final CfgFavoriteShortcuts shortcutCfg = activity.getConfiguration().favoriteShortcuts;
            if (state.isPathItemsConsistent())
            {
                final ServiceType s = state.serviceType == null ? ServiceType.UNKNOWN : state.serviceType;
                final CfgFavoriteShortcuts.Shortcut shortcut = new CfgFavoriteShortcuts.Shortcut(
                        shortcutCfg.getNextId(),
                        state.inputType,
                        s,
                        item,
                        alias);
                if (!state.pathItems.isEmpty())
                {
                    Logging.info(this, "full path to the item: " + state.pathItems);
                    shortcut.setPathItems(state.pathItems, getActivity(), s);
                }
                shortcutCfg.updateShortcut(shortcut, shortcut.alias);
                Toast.makeText(activity, R.string.favorite_shortcut_added, Toast.LENGTH_LONG).show();
            }
            else
            {
                Toast.makeText(activity, R.string.favorite_shortcut_failed, Toast.LENGTH_LONG).show();
            }
        }
    }


    @Override
    protected void updateStandbyView(@Nullable final State state)
    {
        mediaFilter.disable();
        moveFrom = -1;
        if (state != null)
        {
            updateSelectorButtons(state);
        }
        else
        {
            selectorPaletteLayout.removeAllViews();
        }
        setTitleLayout(false);
        titleBar.setTag(null);
        titleBar.setText(R.string.dashed_string);
        listView.clearChoices();
        listView.invalidate();
        listView.setAdapter(new MediaListAdapter(this, activity, new ArrayList<>()));
        setProgressIndicator(state, false);
        updateTrackButtons(state);
    }

    @Override
    protected void updateActiveView(@NonNull final State state, @NonNull final HashSet<State.ChangeType> eventChanges)
    {
        if (eventChanges.contains(State.ChangeType.MEDIA_ITEMS) || eventChanges.contains(State.ChangeType.RECEIVER_INFO))
        {
            Logging.info(this, "Updating media fragment");
            mediaFilter.disable();
            moveFrom = -1;
            filteredItems = state.numberOfItems;
            updateSelectorButtons(state);
            updateListView(state);
            updateTitle(state, state.numberOfItems > 0 && state.isMediaEmpty());
            updateTrackButtons(state);
        }
        else if (eventChanges.contains(State.ChangeType.COMMON))
        {
            updateSelectorButtonsState(state);
            updateTitle(state, state.numberOfItems > 0 && state.isMediaEmpty());
        }
    }

    private void updateTrackButtons(State state)
    {
        if (state == null || state.isReceiverInformation()
                || state.isSimpleInput() || state.isMediaEmpty())
        {
            rootView.findViewById(R.id.track_buttons_layout).setVisibility(View.GONE);
        }
        else
        {
            rootView.findViewById(R.id.track_buttons_layout).setVisibility(View.VISIBLE);
            // Up button
            {
                final OperationCommandMsg msg = new OperationCommandMsg(OperationCommandMsg.Command.LEFT);
                final AppCompatImageButton buttonDown = rootView.findViewById(R.id.btn_track_down);
                prepareButton(buttonDown, msg, msg.getCommand().getImageId(), msg.getCommand().getDescriptionId());
                setButtonEnabled(buttonDown, state.isOn());
            }
            // Down button
            {
                final OperationCommandMsg msg = new OperationCommandMsg(OperationCommandMsg.Command.RIGHT);
                final AppCompatImageButton buttonUp = rootView.findViewById(R.id.btn_track_up);
                prepareButton(buttonUp, msg, msg.getCommand().getImageId(), msg.getCommand().getDescriptionId());
                setButtonEnabled(buttonUp, state.isOn());
            }
        }
    }

    private void updateSelectorButtons(@NonNull final State state)
    {
        selectorPaletteLayout.removeAllViews();
        List<ReceiverInformationMsg.Selector> deviceSelectors = state.cloneDeviceSelectors();
        if (deviceSelectors.isEmpty())
        {
            return;
        }

        // Top menu button
        {
            final OperationCommandMsg msg = new OperationCommandMsg(OperationCommandMsg.Command.TOP);
            final AppCompatImageButton b = createButton(
                    msg.getCommand().getImageId(), msg.getCommand().getDescriptionId(),
                    msg, msg.getCommand(), 0, buttonMarginHorizontal, R.dimen.button_margin_vertical);
            prepareButtonListeners(b, msg, () -> setProgressIndicator(state, true));
            selectorPaletteLayout.addView(b);
        }

        // Selectors
        AppCompatButton selectedButton = null;
        for (ReceiverInformationMsg.Selector s : activity.getConfiguration().getSortedDeviceSelectors(
                false, state.inputType, deviceSelectors))
        {
            if (s.getId().equals(InputSelectorMsg.InputType.SOURCE.getCode()) &&
                    !s.isActiveForZone(state.getActiveZone()))
            {
                // #265 Add new input selector "SOURCE":
                // Ignore SOURCE input for all not allowed zones
                continue;
            }
            final InputSelectorMsg msg = new InputSelectorMsg(state.getActiveZone(), s.getId());
            if (msg.getInputType() == InputSelectorMsg.InputType.NONE)
            {
                continue;
            }
            final AppCompatButton b = createButton(msg.getInputType().getDescriptionId(),
                    null, msg.getInputType(), () -> setProgressIndicator(state, true));
            prepareButtonListeners(b, null, () ->
            {
                if (!state.isOn())
                {
                    activity.getStateManager().sendMessage(
                            new PowerStatusMsg(state.getActiveZone(), PowerStatusMsg.PowerStatus.ON));
                }
                else
                {
                    setProgressIndicator(state, true);
                }
                activity.getStateManager().sendMessage(msg);
            });
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
            setButtonEnabled(v, activity.isConnected());
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
        if (state.protoType == Utils.ProtoType.DCP && !state.isTopLayer() && mediaItems.isEmpty())
        {
            mediaItems.add(new XmlListItemMsg(0,0,
                    getString(R.string.medialist_no_items), XmlListItemMsg.Icon.UNKNOWN,
                    false, null));
        }

        final List<NetworkServiceMsg> serviceItems = state.cloneServiceItems();

        ArrayList<ISCPMessage> newItems = new ArrayList<>();
        int playing = -1;

        if (state.isRadioInput())
        {
            // Add band selectors for Denon
            if (state.protoType == Utils.ProtoType.DCP)
            {
                for (DcpTunerModeMsg.TunerMode t : DcpTunerModeMsg.TunerMode.values())
                {
                    if (t != DcpTunerModeMsg.TunerMode.NONE)
                    {
                        newItems.add(new DcpTunerModeMsg(t));
                    }
                }
            }

            // #270 Empty FM/DAB preset list: process radio input first
            // since mediaItems can be not empty due to remaining track menu items
            // or active playback mode
            for (ReceiverInformationMsg.Preset p : state.presetList)
            {
                if ((state.isFm() && p.isFm())
                        || (state.isDab() && p.isDab())
                        || (state.inputType == InputSelectorMsg.InputType.AM && p.isAm()))
                {
                    final boolean isPlaying = (p.getId() == state.preset);
                    newItems.add(new PresetCommandMsg(
                            state.getActiveZone(), p, isPlaying ? state.preset : PresetCommandMsg.NO_PRESET));
                    if (isPlaying)
                    {
                        playing = newItems.size() - 1;
                    }
                }
            }
            filteredItems = newItems.size();
        }
        else if (state.isSimpleInput())
        {
            // Nothing to do: no media items for simple input
        }
        else if (!mediaItems.isEmpty())
        {
            if (mediaItems.size() > 1)
            {
                mediaFilter.enable();
            }
            for (XmlListItemMsg i : mediaItems)
            {
                if (i.getTitle() != null && mediaFilter.ignore(i.getTitle()))
                {
                    continue;
                }
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

        final boolean isPlayback = state.isOn() && newItems.isEmpty() && (state.isPlaybackMode() || state.isSimpleInput());

        // Add "Return" button if necessary
        if (!state.isTopLayer() && !activity.getConfiguration().isBackAsReturn())
        {
            newItems.add(0, activity.getStateManager().getReturnMessage());
        }

        // Add "Playback" indication if necessary
        if (isPlayback)
        {
            final XmlListItemMsg nsMsg = new XmlListItemMsg(-1, 0,
                    activity.getResources().getString(R.string.medialist_playback_mode),
                    XmlListItemMsg.Icon.PLAY, false, null);
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
                mediaFilter.setVisibility(false, true);
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
        final ReceiverInformationMsg.Selector selector = state.getActualSelector();
        if (state.isSimpleInput())
        {
            if (selector != null && activity.getConfiguration().isFriendlyNames())
            {
                title.append(selector.getName());
            }
            else
            {
                title.append(activity.getResources().getString(state.inputType.getDescriptionId()));
            }
            if (state.isRadioInput())
            {
                title.append(" | ")
                        .append(activity.getResources().getString(R.string.medialist_items))
                        .append(": ").append(filteredItems);
            }
            else if (!state.title.isEmpty())
            {
                title.append(": ").append(state.title);
            }
        }
        else if (state.isPlaybackMode() || state.isMenuMode())
        {
            title.append(state.title);
        }
        else if (state.inputType.isMediaList())
        {
            if (selector != null && state.isTopLayer() && activity.getConfiguration().isFriendlyNames())
            {
                title.append(selector.getName());
            }
            else
            {
                title.append(state.titleBar);
            }
            if (state.numberOfItems > 0)
            {
                if (title.length() > 0)
                {
                    title.append(" | ");
                }
                title.append(activity.getResources().getString(R.string.medialist_items)).append(": ");
                if (filteredItems != state.numberOfItems)
                {
                    title.append(filteredItems).append("/");
                }
                title.append(state.numberOfItems);
            }
        }
        else
        {
            title.append(state.titleBar);
            if (title.length() > 0)
            {
                title.append(" | ");
            }
            title.append(activity.getResources().getString(R.string.medialist_no_items));
        }
        setTitleLayout(true);
        titleBar.setTag("VISIBLE");
        titleBar.setText(title.toString());
        titleBar.setEnabled(!state.isTopLayer());
        setProgressIndicator(state, state.inputType.isMediaList() && processing);
    }

    public boolean onBackPressed()
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
        mediaFilter.setVisibility(false, true);
        updateTitle(stateManager.getState(), true);
        stateManager.sendMessage(activity.getStateManager().getReturnMessage());
        return true;
    }

    private void setProgressIndicator(@Nullable final State state, boolean showProgress)
    {
        // Progress indicator
        {
            final AppCompatImageView btn = rootView.findViewById(R.id.progress_indicator);
            btn.setVisibility(showProgress ? View.VISIBLE : View.GONE);
            Utils.setImageViewColorAttr(activity, btn, R.attr.colorButtonDisabled);
        }

        // Filter button
        {
            final AppCompatImageButton btn = rootView.findViewById(R.id.cmd_filter);
            btn.setVisibility(!showProgress && mediaFilter.isEnabled() ? View.VISIBLE : View.GONE);
            if (btn.getVisibility() == View.VISIBLE)
            {
                prepareButtonListeners(btn, null, () ->
                {
                    mediaFilter.setVisibility(!mediaFilter.isVisible(), false);
                    setTitleLayout(titleBar.getTag() != null);
                });
                setButtonEnabled(btn, true);
            }
        }

        // Sort button
        {
            final AppCompatImageButton btn = rootView.findViewById(R.id.cmd_sort);
            btn.setVisibility(View.GONE);
            if (state != null && state.isOn())
            {
                final ReceiverInformationMsg.NetworkService networkService = state.getNetworkService();
                final boolean sort = networkService != null && networkService.isSort();
                if (!showProgress && sort)
                {
                    btn.setVisibility(View.VISIBLE);
                    final OperationCommandMsg msg = new OperationCommandMsg(OperationCommandMsg.Command.SORT);
                    prepareButton(btn, msg, msg.getCommand().getImageId(), msg.getCommand().getDescriptionId());
                    setButtonEnabled(btn, true);
                }
            }
        }
    }

    private void setTitleLayout(boolean titleVisible)
    {
        titleBar.setVisibility(!mediaFilter.isVisible() && titleVisible ? View.VISIBLE : View.GONE);
    }
}
