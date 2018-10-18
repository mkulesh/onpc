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

import android.content.Context;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v7.widget.AppCompatImageButton;
import android.util.TypedValue;
import android.view.ContextMenu;
import android.view.LayoutInflater;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;

import com.mkulesh.onpc.iscp.ISCPMessage;
import com.mkulesh.onpc.iscp.messages.InputSelectorMsg;
import com.mkulesh.onpc.iscp.messages.ListTitleInfoMsg;
import com.mkulesh.onpc.iscp.messages.NetworkServiceMsg;
import com.mkulesh.onpc.iscp.messages.OperationCommandMsg;
import com.mkulesh.onpc.iscp.messages.PlayQueueAddMsg;
import com.mkulesh.onpc.iscp.messages.PlayQueueRemoveMsg;
import com.mkulesh.onpc.iscp.messages.PlayQueueReorderMsg;
import com.mkulesh.onpc.iscp.messages.ReceiverInformationMsg;
import com.mkulesh.onpc.iscp.messages.XmlListItemMsg;
import com.mkulesh.onpc.utils.Logging;
import com.mkulesh.onpc.utils.Utils;

import java.util.ArrayList;
import java.util.List;

public class MediaFragment extends BaseFragment implements AdapterView.OnItemClickListener
{
    private TextView titleBar;
    private ListView listView;
    private XmListItemMsgAdapter listViewAdapter;
    private LinearLayout selectorPaletteLayout = null;
    private XmlListItemMsg selectedItem = null;
    private int moveFrom = -1;

    public MediaFragment()
    {
        // Empty constructor required for fragment subclasses
    }

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
    {
        initializeFragment(inflater, container, R.layout.media_fragment);
        rootView.setLayerType(View.LAYER_TYPE_HARDWARE, null);

        titleBar = rootView.findViewById(R.id.items_list_title_bar);
        listView = rootView.findViewById(R.id.items_list_view);
        listView.setItemsCanFocus(false);
        listView.setFocusableInTouchMode(true);
        listView.setChoiceMode(ListView.CHOICE_MODE_MULTIPLE);
        listView.setOnItemClickListener(this);

        registerForContextMenu(listView);

        update(null);
        return rootView;
    }

    @Override
    public void onCreateContextMenu(ContextMenu menu, View v, ContextMenu.ContextMenuInfo menuInfo)
    {
        selectedItem = null;
        if (v.getId() == listView.getId() && activity.getStateManager() != null)
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

                    final boolean isQueue = state.serviceType == ListTitleInfoMsg.ServiceType.PLAYQUEUE;
                    menu.findItem(R.id.playlist_menu_remove).setVisible(isQueue);
                    menu.findItem(R.id.playlist_menu_remove_all).setVisible(isQueue);
                    menu.findItem(R.id.playlist_menu_move_from).setVisible(isQueue);
                    menu.findItem(R.id.playlist_menu_move_to).setVisible(
                            isQueue && isMoveToValid(selectedItem.getMessageId()));

                    final boolean isRadio = state.serviceType == ListTitleInfoMsg.ServiceType.TUNEIN_RADIO;
                    menu.findItem(R.id.playlist_track_menu).setVisible(isRadio &&
                            selectedItem.getIcon() == XmlListItemMsg.Icon.PLAY);
                }
            }
        }
    }

    @Override
    public boolean onContextItemSelected(MenuItem item)
    {
        if (selectedItem != null && activity.getStateManager() != null)
        {
            final State state = activity.getStateManager().getState();
            final int idx = selectedItem.getMessageId();
            Logging.info(this, "Context menu: " + item.toString() + "; " + selectedItem.toString());
            selectedItem = null;
            switch (item.getItemId())
            {
            case R.id.playlist_menu_add:
                activity.getStateManager().sendPlayQueueMsg(new PlayQueueAddMsg(idx, 1), false);
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
    protected void updateStandbyView(@Nullable final State state)
    {
        moveFrom = -1;
        if (selectorPaletteLayout != null)
        {
            selectorPaletteLayout.removeAllViews();
            selectorPaletteLayout = null;
        }
        titleBar.setText("");
        listView.clearChoices();
        listView.invalidate();
        listView.setAdapter(new XmListItemMsgAdapter(activity, new ArrayList<ISCPMessage>()));
    }

    @Override
    protected void updateActiveView(@NonNull final State state)
    {
        if (selectorPaletteLayout == null)
        {
            addSelectorButtons(state);
        }
        updateSelectorButtons(state);
        updateTitle(state, state.numberOfItems > 0 && state.isMediaEmpty());
        if (state.itemsChanged)
        {
            moveFrom = -1;
            updateListView(state);
            state.itemsChanged = false;
        }
    }

    private void addSelectorButtons(@NonNull final State state)
    {
        if (state.deviceSelectors.isEmpty())
        {
            return;
        }
        if (selectorPaletteLayout == null)
        {
            selectorPaletteLayout = rootView.findViewById(R.id.selector_palette);
        }
        selectorPaletteLayout.removeAllViews();

        final int buttonSize = activity.getResources().getDimensionPixelSize(R.dimen.btn_size);
        final int buttonMargin = activity.getResources().getDimensionPixelSize(R.dimen.btn_margin);
        final int selNumber = state.deviceSelectors.size();
        for (int i = 0; i < selNumber; i++)
        {
            final ReceiverInformationMsg.Selector s = state.deviceSelectors.get(i);
            final InputSelectorMsg msg = new InputSelectorMsg(s.getId());
            if (msg.getInputType() == InputSelectorMsg.InputType.NONE)
            {
                continue;
            }
            final AppCompatImageButton b = new AppCompatImageButton(activity);
            final ViewGroup.MarginLayoutParams lp = new ViewGroup.MarginLayoutParams(buttonSize, buttonSize);
            lp.setMargins((i == 0 ? 0 : buttonMargin), buttonMargin, (i == selNumber - 1 ? 0 : buttonMargin), buttonMargin);
            b.setLayoutParams(lp);
            b.setTag(msg.getInputType());

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

            b.setContentDescription(activity.getResources().getString(msg.getInputType().getDescriptionId()));
            b.setLongClickable(true);
            b.setOnLongClickListener(new View.OnLongClickListener()
            {
                @Override
                public boolean onLongClick(View v)
                {
                    return Utils.showButtonDescription(activity, v);
                }
            });

            b.setImageResource(msg.getInputType().getImageId());

            selectorPaletteLayout.addView(b);
        }
    }

    private void updateSelectorButtons(@NonNull final State state)
    {
        if (selectorPaletteLayout == null)
        {
            return;
        }
        for (int i = 0; i < selectorPaletteLayout.getChildCount(); i++)
        {
            if (selectorPaletteLayout.getChildAt(i) instanceof AppCompatImageButton)
            {
                final AppCompatImageButton b = (AppCompatImageButton) selectorPaletteLayout.getChildAt(i);
                setButtonSelected(b, state.inputType == b.getTag());
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
            Logging.info(this, "Updating media items list: " + mediaItems.size());
            for (XmlListItemMsg i : mediaItems)
            {
                newItems.add(new XmlListItemMsg(i));
                if (i.getIcon() == XmlListItemMsg.Icon.PLAY)
                {
                    playing = newItems.size() - 1;
                }
            }
        }
        else if (!serviceItems.isEmpty())
        {
            Logging.info(this, "Updating service items list: " + serviceItems.size());
            for (NetworkServiceMsg i : serviceItems)
            {
                newItems.add(new NetworkServiceMsg(i));
            }
        }
        listViewAdapter = new XmListItemMsgAdapter(activity, newItems);
        listView.setAdapter(listViewAdapter);
        if (playing >= 0)
        {
            setSelection(playing, listView.getHeight() / 2);
        }
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id)
    {
        if (activity.getStateManager() != null && listViewAdapter != null && position < listViewAdapter.getCount())
        {
            final ISCPMessage selectedItem = listViewAdapter.getItem(position);
            if (selectedItem != null)
            {
                moveFrom = -1;
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
        if (state.uiType == ListTitleInfoMsg.UIType.PLAYBACK ||
                state.uiType == ListTitleInfoMsg.UIType.MENU)
        {
            title.append(state.title);
        }
        else
        {
            title.append(state.titleBar);
            if (state.numberOfItems > 0)
            {
                title.append("/").append(state.numberOfItems).append(" ").append(
                        activity.getResources().getString(R.string.medialist_items));
            }
        }
        if (processing)
        {
            if (!title.toString().isEmpty())
            {
                title.append(". ");
            }
            title.append(activity.getResources().getString(R.string.medialist_processing));
        }
        titleBar.setText(title.toString());
    }

    private final class XmListItemMsgAdapter extends ArrayAdapter<ISCPMessage>
    {
        XmListItemMsgAdapter(Context context, ArrayList<ISCPMessage> list)
        {
            super(context, 0, list);
        }

        @NonNull
        @Override
        public View getView(int position, View convertView, @NonNull ViewGroup parent)
        {
            // Get the data item for this position
            ISCPMessage item = getItem(position);

            // Check if an existing view is being reused, otherwise inflate the view
            if (convertView == null)
            {
                convertView = LayoutInflater.from(getContext()).inflate(R.layout.media_item, parent, false);
            }

            final ImageView icon = convertView.findViewById(R.id.media_item_icon);
            final TextView tvTitle = convertView.findViewById(R.id.media_item_title);

            if (item instanceof XmlListItemMsg)
            {
                final XmlListItemMsg msg = (XmlListItemMsg) item;
                if (msg.getIcon() != XmlListItemMsg.Icon.UNKNOWN)
                {
                    icon.setImageResource(msg.getIcon().getImageId());
                    icon.setVisibility(View.VISIBLE);
                    Utils.setImageViewColorAttr(activity, icon, R.attr.colorButtonDisabled);
                }
                else if (!msg.isSelectable())
                {
                    icon.setImageDrawable(null);
                    icon.setVisibility(View.GONE);
                }
                tvTitle.setText(msg.getTitle());
                tvTitle.setTextColor(Utils.getThemeColorAttr(activity,
                        (moveFrom == msg.getMessageId() || !msg.isSelectable()) ?
                                android.R.attr.textColorSecondary : android.R.attr.textColor));
            }
            else if (item instanceof NetworkServiceMsg)
            {
                final NetworkServiceMsg msg = (NetworkServiceMsg) item;
                if (msg.getService().isImageValid())
                {
                    icon.setImageResource(msg.getService().getImageId());
                    Utils.setImageViewColorAttr(activity, icon, R.attr.colorButtonDisabled);
                }
                tvTitle.setText(msg.getService().getDescriptionId());
            }
            else if (item instanceof OperationCommandMsg)
            {
                final OperationCommandMsg msg = (OperationCommandMsg) item;
                if (msg.getCommand().isImageValid())
                {
                    icon.setImageResource(msg.getCommand().getImageId());
                    Utils.setImageViewColorAttr(activity, icon, android.R.attr.textColor);
                }
                tvTitle.setText(msg.getCommand().getDescriptionId());
            }

            return convertView;
        }
    }
}
