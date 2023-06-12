/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2023 by Mikhail Kulesh
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
// @dart=2.9
import "package:draggable_scrollbar/draggable_scrollbar.dart";
import "package:flutter/material.dart";

import "../Platform.dart";
import "../config/CfgFavoriteShortcuts.dart";
import "../config/CheckableItem.dart";
import "../config/Configuration.dart";
import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../dialogs/FavoriteShortcutEditDialog.dart";
import "../dialogs/PopupManager.dart";
import "../iscp/ISCPMessage.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/DcpMediaContainerMsg.dart";
import "../iscp/messages/DcpMediaItemMsg.dart";
import "../iscp/messages/DcpTunerModeMsg.dart";
import "../iscp/messages/EnumParameterMsg.dart";
import "../iscp/messages/InputSelectorMsg.dart";
import "../iscp/messages/ListInfoMsg.dart";
import "../iscp/messages/ListTitleInfoMsg.dart";
import "../iscp/messages/NetworkServiceMsg.dart";
import "../iscp/messages/OperationCommandMsg.dart";
import "../iscp/messages/PlayQueueAddMsg.dart";
import "../iscp/messages/PlayQueueRemoveMsg.dart";
import "../iscp/messages/PlayQueueReorderMsg.dart";
import "../iscp/messages/PowerStatusMsg.dart";
import "../iscp/messages/PresetCommandMsg.dart";
import "../iscp/messages/ReceiverInformationMsg.dart";
import "../iscp/messages/ServiceType.dart";
import "../iscp/messages/TitleNameMsg.dart";
import "../iscp/messages/XmlListInfoMsg.dart";
import "../iscp/messages/XmlListItemMsg.dart";
import "../iscp/state/MediaListSorter.dart";
import "../iscp/state/MediaListState.dart";
import "../utils/Logging.dart";
import "../widgets/ContextMenuListener.dart";
import "../widgets/CustomDivider.dart";
import "../widgets/CustomImageButton.dart";
import "../widgets/CustomTextField.dart";
import "../widgets/CustomTextLabel.dart";
import "../widgets/PositionedTapDetector.dart";
import "../widgets/ReorderableItem.dart";
import "UpdatableView.dart";

enum MediaContextMenu
{
    // Common commands
    REPLACE_AND_PLAY,
    ADD,
    REPLACE,
    ADD_AND_PLAY,
    REMOVE,
    REMOVE_ALL,
    TRACK_MENU,
    PLAYBACK_MODE,
    ADD_TO_FAVORITES,
    // Heos commands
    SO_ADD_TO_HEOS,
    SO_REMOVE_FROM_HEOS,
    SO_REPLACE_AND_PLAY_ALL,
    SO_ADD_ALL,
    SO_ADD_AND_PLAY_ALL
}

class MediaListButtons
{
    bool filter = false;
    bool remoteSort = false;
    bool appSort = false;
    bool progress = false;
}

class MediaListView extends StatefulWidget
{
    final ViewContext viewContext;

    static const List<String> UPDATE_TRIGGERS = [
        Configuration.CONFIGURATION_EVENT,
        StateManager.WAITING_FOR_DATA_EVENT,
        InputSelectorMsg.CODE,
        ListInfoMsg.CODE,
        ListTitleInfoMsg.CODE,
        PowerStatusMsg.CODE,
        ReceiverInformationMsg.CODE,
        TitleNameMsg.CODE,
        XmlListInfoMsg.CODE,
        PresetCommandMsg.CODE,
        DcpMediaContainerMsg.CODE,
        DcpMediaItemMsg.CODE
    ];

    MediaListView({Key key, this.viewContext}) : super(key: key);

    @override
    String toStringShort() => "MediaListView";

    @override
    _MediaListViewState createState()
    => _MediaListViewState(viewContext, UPDATE_TRIGGERS);
}

class _MediaListViewState extends WidgetStreamState<MediaListView>
{
    static final String _PLAYBACK_STRING = "_PLAYBACK_STRING_";
    static final String _DEEZER_ALBUMS = "MY ALBUMS";

    final List<int> _playQueueIds = [];
    ScrollController _scrollController;
    int _currentLayer = -1;
    final MediaListButtons _headerButtons = MediaListButtons();
    final MediaListSorter _mediaListSorter = MediaListSorter();
    TextEditingController _mediaFilterController;

    _MediaListViewState(final ViewContext _viewContext, final List<String> _updateTriggers) : super(_viewContext, _updateTriggers);

    @override
    void initState()
    {
        super.initState();
        _scrollController = ScrollController();
        Logging.info(this.widget, "saved scroll positions: " + state.mediaListPosition.toString());
        _mediaFilterController = TextEditingController();
    }

    @override
    void dispose()
    {
        _scrollController.dispose();
        _mediaFilterController.dispose();
        super.dispose();
    }

    @override
    Widget createView(BuildContext context, VoidCallback _updateCallback)
    {
        Logging.logRebuild(this.widget);
        final ThemeData td = Theme.of(context);
        final MediaListState ms = state.mediaListState;

        // Get items
        List<ISCPMessage> items =
            ms.isNetworkServices ? _getSortedNetworkServices(state.playbackState.serviceIcon, ms.mediaItems) :
            ms.isMenuMode ? ms.retrieveMenu() :
            ms.mediaItems;
        final int dataItems = items.length;

        final bool isPlayback = state.isOn && items.isEmpty && (ms.isPlaybackMode || ms.isSimpleInput);

        // Header buttons
        _headerButtons.filter = state.isOn && ms.isListMode && dataItems > 1;
        _headerButtons.remoteSort = state.isOn && state.getNetworkService != null && state.getNetworkService.isSort;
        _headerButtons.appSort = state.isOn && !_headerButtons.remoteSort && ms.isDeezer && _DEEZER_ALBUMS == ms.titleBar.toUpperCase();
        _headerButtons.progress = state.isOn && stateManager.waitingForData;

        // Apply filter
        if (ms.numberOfLayers != _currentLayer)
        {
            _mediaFilterController.clear();
        }
        final String filter = _mediaFilterController.text;
        final bool applyFilter = _headerButtons.filter && filter != null && filter.isNotEmpty;
        if (applyFilter)
        {
            Logging.info(this.widget, "apply filter: " + filter);
            final List<ISCPMessage> filteredItems = List.from(items.where((msg)
            => !_ignoreItem(msg, filter)));
            items = filteredItems;
        }

        if (!_headerButtons.remoteSort && ms.isDeezer && _mediaListSorter.isSortableItem(items))
        {
            items = _mediaListSorter.sortDeezerItems(items, configuration.appSettings.mediaSortMode);
        }

        // Add "Return" button if necessary
        if (state.isOn && ms.layerInfo != null && !ms.isTopLayer()
            && !configuration.backAsReturn && !_returnMessageExists(items))
        {
            items.insert(0, stateManager.getReturnMessage());
        }

        // Add "Playback" indication if necessary
        if (isPlayback)
        {
            final XmlListItemMsg playbackIndicationItem = XmlListItemMsg.details(
                0xFFFF, 0, Strings.medialist_playback_mode, _PLAYBACK_STRING, ListItemIcon.PLAY, false, null);
            items.add(playbackIndicationItem);
        }

        // Scroll positions
        _scrollController.removeListener(_saveScrollPosition);
        if (!applyFilter)
        {
            _processLayerInfo(ms, dataItems);
        }

        // Create list
        final int visibleItems = _returnMessageExists(items) ? items.length - 1 : items.length;
        final int totalItems = _returnMessageExists(ms.mediaItems) ? ms.numberOfItems - 1 : ms.numberOfItems;
        final bool isAdvancedQueue = ms.isQueue && configuration.isAdvancedQueue;
        final Widget mediaList = isAdvancedQueue ? _buildPlayQueueList(context, items) : _buildMediaList(td, items);
        final List<Widget> elements = [
            _buildHeaderLine(td, _headerButtons, _buildTitle(visibleItems, totalItems)),
            CustomDivider(),
            Expanded(child: mediaList, flex: 1)
        ];

        if (state.isOn && !state.receiverInformation.isReceiverInformation && !state.mediaListState.isSimpleInput && !state.mediaListState.isMediaEmpty)
        {
            elements.add(CustomDivider());
            elements.add(_buildTrackButtons());
        }

        return Expanded(
            flex: 1,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: elements)
        );
    }

    Widget _buildMediaList(final ThemeData td, List<ISCPMessage> items)
    {
        final Widget list = ListView.builder(
            padding: ActivityDimens.noPadding,
            scrollDirection: Axis.vertical,
            itemCount: items.length,
            physics: ClampingScrollPhysics(),
            controller: _scrollController,
            itemBuilder: (BuildContext itemContext, int index)
            {
                final ISCPMessage rowMsg = items[index];
                if (rowMsg is NetworkServiceMsg)
                {
                    return _buildNetworkServiceRow(itemContext, rowMsg);
                }
                else if (rowMsg is XmlListItemMsg)
                {
                    return _buildXmlListItemMsg(itemContext, rowMsg);
                }
                else if (rowMsg is PresetCommandMsg)
                {
                    return _buildPresetCommandMsg(itemContext, rowMsg);
                }
                else if (rowMsg is OperationCommandMsg)
                {
                    return _buildOperationCommandMsg(itemContext, rowMsg);
                }
                else if (rowMsg is DcpTunerModeMsg)
                {
                    return _buildDcpTunerModeMsg(itemContext, rowMsg);
                }
                else if (rowMsg is DcpMediaContainerMsg)
                {
                    return _buildDcpMediaContainerMsg(itemContext, rowMsg);
                }
                else
                {
                    return null;
                }
            }
        );

        return Platform.isDesktop ? list : DraggableScrollbar.rrect(
            controller: _scrollController,
            backgroundColor: td.colorScheme.secondary,
            child: list);
        }

    Widget _buildPlayQueueList(BuildContext context, List<ISCPMessage> items)
    {
        final List<Widget> _rows = [];
        _playQueueIds.clear();

        Widget header;
        items.forEach((rowMsg)
        {
            if (rowMsg is XmlListItemMsg)
            {
                _rows.add(_buildXmlListItemMsg(context, rowMsg, reorderId: rowMsg.getMessageId.toString()));
                _playQueueIds.add(rowMsg.getMessageId);
            }
            else if (rowMsg is OperationCommandMsg)
            {
                final Widget row = _buildOperationCommandMsg(context, rowMsg);
                if (rowMsg.getValue.key == OperationCommand.RETURN)
                {
                    header = row;
                }
                else
                {
                    _rows.add(row);
                    _playQueueIds.add(rowMsg.getMessageId);
                }
            }
        });

        return ReorderableListView(
            onReorder: _onReorder,
            header: header,
            reverse: false,
            padding: ActivityDimens.noPadding,
            scrollController: _scrollController,
            scrollDirection: Axis.vertical,
            children: _rows
        );
    }

    void _onReorder(int oldIndex, int newIndex)
    {
        if (newIndex > oldIndex)
        {
            newIndex -= 1;
        }
        if (oldIndex < _playQueueIds.length && newIndex < _playQueueIds.length)
        {
            setState(()
            {
                state.mediaListState.reorderMediaItems(_playQueueIds[oldIndex], _playQueueIds[newIndex]);
            });
            stateManager.sendPlayQueueMsg(PlayQueueReorderMsg.output(_playQueueIds[oldIndex], _playQueueIds[newIndex]), false);
        }
    }

    Widget _buildRow(final BuildContext context, final String icon, final bool iconEnabled, final bool isPlaying, final String title, final ISCPMessage cmd, {final String reorderId})
    {
        final ThemeData td = Theme.of(context);
        final bool isMoved = cmd is XmlListItemMsg && cmd.getMessageId == state.mediaListState.movedItem;
        final Widget iconImg = icon == null || icon == Drawables.media_item_unknown ? null :
            CustomImageButton.normal(
                icon, null,
                isEnabled: iconEnabled || isPlaying,
                isSelected: isPlaying,
                padding: EdgeInsets.symmetric(vertical: MediaListDimens.itemPadding),
            );

        final Widget w = ContextMenuListener(
            key: Key(reorderId),
            child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                removeBottom: true,
                removeLeft: true,
                removeRight: true,
                child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: MediaListDimens.itemPadding),
                    dense: configuration.appSettings.textSize != "huge",
                    leading: iconImg,
                    title: CustomTextLabel.normal(title, color: isMoved ? td.disabledColor : null),
                    onTap: ()
                    {
                        state.closeMediaFilter();
                        final rowMsg = (cmd is XmlListItemMsg && cmd.iconType == _PLAYBACK_STRING) ? StateManager.DISPLAY_MSG : cmd;
                        stateManager.sendMessage(rowMsg, waitingForData: rowMsg != StateManager.DISPLAY_MSG && icon != Drawables.media_item_unknown);
                    }),
                ),
            onContextMenu: (position)
            => _onCreateContextMenu(context, position, cmd)
        );
        if (cmd is XmlListItemMsg && cmd.iconType != _PLAYBACK_STRING && reorderId != null)
        {
            return ReorderableItem(key: Key(reorderId), child: w);
        }
        else
        {
            return w;
        }
    }

    Widget _buildNetworkServiceRow(final BuildContext context, NetworkServiceMsg rowMsg)
    {
        String serviceIcon = rowMsg.getValue.icon;
        if (serviceIcon == null)
        {
            serviceIcon = Drawables.media_item_unknown;
        }
        final bool isPlaying = state.playbackState.serviceIcon.getCode == rowMsg.getValue.getCode;
        return _buildRow(context, serviceIcon, false, isPlaying, rowMsg.getValue.description, rowMsg);
    }

    Widget _buildXmlListItemMsg(final BuildContext context, XmlListItemMsg rowMsg, {final String reorderId})
    {
        String serviceIcon = rowMsg.getIcon.icon;
        if (serviceIcon == null)
        {
            serviceIcon = Drawables.media_item_unknown;
        }
        final bool isPlaying = rowMsg.getIcon.key == ListItemIcon.PLAY;
        return _buildRow(context, serviceIcon, false, isPlaying, rowMsg.getTitle, rowMsg, reorderId: reorderId);
    }

    Widget _buildPresetCommandMsg(BuildContext context, PresetCommandMsg rowMsg)
    {
        String serviceIcon = Drawables.media_item_music;
        final bool isPlaying = rowMsg.getPresetConfig.getId == state.radioState.preset;
        if (isPlaying)
        {
            serviceIcon = Drawables.media_item_play;
        }
        return _buildRow(context, serviceIcon, false, isPlaying, rowMsg.getPresetConfig.displayedString(), rowMsg);
    }

    Widget _buildOperationCommandMsg(BuildContext context, OperationCommandMsg rowMsg)
    {
        return _buildRow(context, rowMsg.getValue.icon, false, false, rowMsg.getValue.description, rowMsg);
    }

    Widget _buildDcpTunerModeMsg(BuildContext itemContext, DcpTunerModeMsg rowMsg)
    {
        final bool isPlaying = rowMsg.getValue == state.mediaListState.dcpTunerMode;
        return _buildRow(context, Drawables.media_item_radio, false, isPlaying, rowMsg.getValue.description, rowMsg);
    }

    Widget _buildDcpMediaContainerMsg(BuildContext itemContext, DcpMediaContainerMsg rowMsg)
    {
        final EnumItem<OperationCommand> item = OperationCommandMsg.ValueEnum.valueByKey(OperationCommand.RETURN);
        return _buildRow(context, item.icon, false, false, item.description, rowMsg);
    }

    void _onCreateContextMenu(final BuildContext context, final TapPosition position, final ISCPMessage cmd)
    {
        final List<PopupMenuItem<MediaContextMenu>> contextMenu = [];
        final Selector selector = state.getActualSelector;
        final NetworkService networkService = state.getNetworkService;
        final DcpMediaContainerMsg dcpCmd = state.mediaListState.getDcpContainerMsg(cmd);

        final bool isMediaItem = (cmd is XmlListItemMsg && cmd.iconType != _PLAYBACK_STRING) || cmd is PresetCommandMsg;
        final bool isPlaying = cmd is XmlListItemMsg && cmd.getIcon.key == ListItemIcon.PLAY;
        final bool isDcpItem = dcpCmd != null;
        final bool isDcpPlayable = dcpCmd != null && dcpCmd.isPlayable();
        final bool isQueue = state.mediaListState.isQueue;
        final String shortcutItem = cmd is XmlListItemMsg ? cmd.getTitle : cmd is PresetCommandMsg ? cmd.getData : null;
        final String shortcutAlias = cmd is XmlListItemMsg ? cmd.getTitle : cmd is PresetCommandMsg ? cmd.getPresetConfig.displayedString() : null;

        if (isMediaItem && selector != null)
        {
            final bool addToQueue = selector.isAddToQueue ||
                (networkService != null && networkService.isAddToQueue) ||
                isDcpPlayable;
            final bool isAdvQueue = configuration.isAdvancedQueue ||
                isDcpPlayable;

            Logging.info(this.widget, "Context menu for selector " + selector.toString() +
                (networkService != null ? " and service " + networkService.toString() : "") +
                ", isMediaItem=" + isMediaItem.toString() +
                ", isPlaying=" + isPlaying.toString() +
                ", isDcpItem=" + isDcpItem.toString() +
                ", isDcpPlayable=" + isDcpPlayable.toString() +
                ", isQueue=" + isQueue.toString() +
                ", addToQueue=" + addToQueue.toString() +
                ", isAdvQueue=" + isAdvQueue.toString()
            );

            if (isQueue || addToQueue)
            {
                contextMenu.add(PopupMenuItem<MediaContextMenu>(
                    child: CustomTextLabel.small(Strings.playlist_options),
                    height: ButtonDimens.menuButtonSize, enabled: false));
            }

            if (!isQueue && addToQueue)
            {
                if (isAdvQueue)
                {
                    contextMenu.add(PopupMenuItem<MediaContextMenu>(
                        child: Text(Strings.playlist_replace_and_play), value: MediaContextMenu.REPLACE_AND_PLAY));
                }
                contextMenu.add(PopupMenuItem<MediaContextMenu>(
                    child: Text(Strings.playlist_add), value: MediaContextMenu.ADD));
                if (isAdvQueue && !isDcpItem)
                {
                    contextMenu.add(PopupMenuItem<MediaContextMenu>(
                        child: Text(Strings.playlist_replace), value: MediaContextMenu.REPLACE));
                }
                contextMenu.add(PopupMenuItem<MediaContextMenu>(
                    child: Text(Strings.playlist_add_and_play), value: MediaContextMenu.ADD_AND_PLAY));
            }

            if (isQueue)
            {
                contextMenu.add(PopupMenuItem<MediaContextMenu>(
                    child: Text(Strings.playlist_remove), value: MediaContextMenu.REMOVE));
                contextMenu.add(PopupMenuItem<MediaContextMenu>(
                    child: Text(Strings.playlist_remove_all), value: MediaContextMenu.REMOVE_ALL));
            }

            // DCP options
            if (isDcpItem)
            {
                final List<XmlListItemMsg> menuItems = state.mediaListState.cloneDcpTrackMenuItems(null);
                final oldLength = contextMenu.length;
                if (_findDcpMenuItem(menuItems, DcpMediaContainerMsg.SO_ADD_TO_HEOS) != null)
                {
                    contextMenu.add(PopupMenuItem<MediaContextMenu>(
                        child: Text(Strings.playlist_add_to_heos_favourites), 
                        value: MediaContextMenu.SO_ADD_TO_HEOS));
                }

                if (_findDcpMenuItem(menuItems, DcpMediaContainerMsg.SO_REMOVE_FROM_HEOS) != null)
                {
                    contextMenu.add(PopupMenuItem<MediaContextMenu>(
                        child: Text(Strings.playlist_remove_from_heos_favourites), 
                        value: MediaContextMenu.SO_REMOVE_FROM_HEOS));
                }

                if (_findDcpMenuItem(menuItems, DcpMediaContainerMsg.SO_REPLACE_AND_PLAY_ALL) != null)
                {
                    contextMenu.add(PopupMenuItem<MediaContextMenu>(
                        child: Text(Strings.playlist_replace_and_play_all), 
                        value: MediaContextMenu.SO_REPLACE_AND_PLAY_ALL));
                }

                if (_findDcpMenuItem(menuItems, DcpMediaContainerMsg.SO_ADD_ALL) != null)
                {
                    contextMenu.add(PopupMenuItem<MediaContextMenu>(
                        child: Text(Strings.playlist_add_all), 
                        value: MediaContextMenu.SO_ADD_ALL));
                }

                if (_findDcpMenuItem(menuItems, DcpMediaContainerMsg.SO_ADD_AND_PLAY_ALL) != null)
                {
                    contextMenu.add(PopupMenuItem<MediaContextMenu>(
                        child: Text(Strings.playlist_add_and_play_all), 
                        value: MediaContextMenu.SO_ADD_AND_PLAY_ALL));
                }
                if (oldLength > 0 && oldLength != contextMenu.length)
                {
                    contextMenu.insert(oldLength, PopupMenuItem<MediaContextMenu>(
                        child: CustomDivider(), height: 1, enabled: false));
                }
            }
        }

        if (state.playbackState.isTrackMenuActive && isPlaying && !isQueue && !isDcpItem)
        {
            contextMenu.add(PopupMenuItem<MediaContextMenu>(
                child: Text(Strings.cmd_track_menu), value: MediaContextMenu.TRACK_MENU));
        }

        if (isMediaItem && isPlaying && !isDcpItem)
        {
            contextMenu.add(PopupMenuItem<MediaContextMenu>(
                child: Text(Strings.medialist_playback_mode), value: MediaContextMenu.PLAYBACK_MODE));
        }

        if (state.isShortcutPossible && shortcutItem != null && shortcutAlias != null)
        {
            contextMenu.add(PopupMenuItem<MediaContextMenu>(
                child: Text(Strings.favorite_shortcut_create), value: MediaContextMenu.ADD_TO_FAVORITES));
        }

        if (contextMenu.isNotEmpty)
        {
            showMenu(
                context: context,
                position: RelativeRect.fromLTRB(position.global.dx, position.global.dy, position.global.dx, position.global.dy),
                items: contextMenu).then((m)
            => _onContextItemSelected(context, m, cmd, shortcutItem, shortcutAlias)
            );
        }
    }

    void _onContextItemSelected(final BuildContext context, final MediaContextMenu m, final ISCPMessage cmd, final String shortcutItem, final String shortcutAlias)
    {
        if (m == null)
        {
            return;
        }
        final int idx = cmd.getMessageId;
        final DcpMediaContainerMsg dcpCmd = state.mediaListState.getDcpContainerMsg(cmd);
        Logging.info(this.widget, "selected context menu: " + m.toString() + ", index: " + idx.toString());
        switch (m)
        {
            case MediaContextMenu.REPLACE_AND_PLAY:
                if (dcpCmd != null)
                {
                    _sendDcpMediaCmd(dcpCmd, 4 /* replace and play */);
                }
                else
                {
                    stateManager.sendPlayQueueMsg(PlayQueueRemoveMsg.output(1, 0), false);
                    stateManager.sendPlayQueueMsg(PlayQueueAddMsg.output(idx, 0), false);
                }
                break;
            case MediaContextMenu.ADD:
                if (dcpCmd != null)
                {
                    _sendDcpMediaCmd(dcpCmd, 3 /* add to end */);
                }
                else
                {
                    stateManager.sendPlayQueueMsg(PlayQueueAddMsg.output(idx, 2), false);
                }
                break;
            case MediaContextMenu.REPLACE:
                stateManager.sendPlayQueueMsg(PlayQueueRemoveMsg.output(1, 0), false);
                stateManager.sendPlayQueueMsg(PlayQueueAddMsg.output(idx, 2), false);
                break;
            case MediaContextMenu.ADD_AND_PLAY:
                if (dcpCmd != null)
                {
                    _sendDcpMediaCmd(dcpCmd, 1 /* play now */);
                }
                else
                {
                    stateManager.sendPlayQueueMsg(PlayQueueAddMsg.output(idx, 0), false);
                }
                break;
            case MediaContextMenu.REMOVE:
                stateManager.sendPlayQueueMsg(PlayQueueRemoveMsg.output(0, idx), false);
                break;
            case MediaContextMenu.REMOVE_ALL:
                if (dcpCmd != null || configuration.isAdvancedQueue)
                {
                    stateManager.sendPlayQueueMsg(PlayQueueRemoveMsg.output(1, 0), false);
                }
                else
                {
                    stateManager.sendPlayQueueMsg(PlayQueueRemoveMsg.output(0, 0), true);
                }
                break;
            case MediaContextMenu.TRACK_MENU:
                stateManager.sendTrackCmd(ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE, OperationCommand.MENU, false);
                break;
            case MediaContextMenu.PLAYBACK_MODE:
                stateManager.sendMessage(StateManager.LIST_MSG);
                break;
            case MediaContextMenu.ADD_TO_FAVORITES:
                if (state.isShortcutPossible && shortcutItem != null && shortcutAlias != null)
                {
                    _addShortcut(context, shortcutItem, shortcutAlias);
                }
                break;
            case MediaContextMenu.SO_ADD_TO_HEOS:
                _callDcpMenuItem(dcpCmd, DcpMediaContainerMsg.SO_ADD_TO_HEOS);
                break;
            case MediaContextMenu.SO_REMOVE_FROM_HEOS:
                _callDcpMenuItem(dcpCmd, DcpMediaContainerMsg.SO_REMOVE_FROM_HEOS);
                break;
            case MediaContextMenu.SO_REPLACE_AND_PLAY_ALL:
                _callDcpMenuItem(dcpCmd, DcpMediaContainerMsg.SO_REPLACE_AND_PLAY_ALL);
                break;
            case MediaContextMenu.SO_ADD_ALL:
                _callDcpMenuItem(dcpCmd, DcpMediaContainerMsg.SO_ADD_ALL);
                break;
            case MediaContextMenu.SO_ADD_AND_PLAY_ALL:
                _callDcpMenuItem(dcpCmd, DcpMediaContainerMsg.SO_ADD_AND_PLAY_ALL);
                break;
        }
    }

    String _buildTitle(final int _visibleItems, final int _numberOfItems)
    {
        String title = "";
        if (!state.isOn)
        {
            return Strings.medialist_no_items;
        }
        final MediaListState ms = state.mediaListState;
        final Selector selector = state.getActualSelector;
        if (ms.isSimpleInput)
        {
            if (selector != null && configuration.friendlyNames)
            {
                title += selector.getName;
            }
            else
            {
                title += ms.inputType.description;
            }
            if (ms.isRadioInput)
            {
                if (_visibleItems > 0)
                {
                    title += " | " + Strings.medialist_items + ": " + _visibleItems.toString();
                }
            }
            else if (state.trackState.title.isNotEmpty)
            {
                title += ": " + state.trackState.title;
            }
        }
        else if (ms.isPlaybackMode || ms.isMenuMode)
        {
            title += state.trackState.title;
        }
        else if (ms.inputType.isMediaList)
        {
            if (selector != null && ms.isTopLayer() && configuration.friendlyNames)
            {
                title += selector.getName;
            }
            else
            {
                title += ms.titleBar;
            }
            if (_numberOfItems > 0)
            {
                title += " | " + Strings.medialist_items + ": ";
                if (_visibleItems < _numberOfItems)
                {
                    title += _visibleItems.toString() + "/";
                }
                title += _numberOfItems.toString();
            }
        }
        else
        {
            title += ms.titleBar;
            if (ms.titleBar.isNotEmpty)
            {
                title += " | ";
            }
            title += Strings.medialist_no_items;
        }
        return title;
    }

    List<ISCPMessage> _getSortedNetworkServices(EnumItem<ServiceType> activeItem, final List<ISCPMessage> defaultItems)
    {
        final List<ISCPMessage> result = [];
        final List<String> defItems = [];
        for (ISCPMessage i in defaultItems)
        {
            if (i is NetworkServiceMsg)
            {
                defItems.add(i.getValue.getCode);
            }
        }
        final String par = configuration.getModelDependentParameter(Configuration.SELECTED_NETWORK_SERVICES);
        for (CheckableItem sp in CheckableItem.readFromPreference(configuration, par, defItems))
        {
            final bool visible = sp.checked || (activeItem.key != ServiceType.UNKNOWN && activeItem.getCode == sp.code);
            for (ISCPMessage i in defaultItems)
            {
                if (visible && i is NetworkServiceMsg && i.getValue.getCode == sp.code)
                {
                    result.add(i);
                }
            }
        }
        return result;
    }

    void _processLayerInfo(final MediaListState ms, final int numberOfItems)
    {
        if (state.isOn && ms.isListMode && numberOfItems > 0)
        {
            if (_currentLayer < 0 || ms.numberOfLayers != _currentLayer)
            {
                state.mediaListPosition.removeWhere((key, v)
                => (key > ms.numberOfLayers));
                WidgetsBinding.instance.addPostFrameCallback((_)
                {
                    _scrollToPosition(ms);
                    _scrollController.addListener(_saveScrollPosition);
                });
            }
            else
            {
                _scrollController.addListener(_saveScrollPosition);
            }
            _currentLayer = ms.numberOfLayers;
        }
        else
        {
            _currentLayer = -1;
        }
    }

    void _saveScrollPosition()
    {
        if (_scrollController.hasClients)
        {
            state.mediaListPosition[state.mediaListState.numberOfLayers] = _scrollController.offset;
        }
    }

    void _scrollToPosition(MediaListState ms)
    {
        try
        {
            final double pos = state.mediaListPosition.containsKey(ms.numberOfLayers) ? state.mediaListPosition[ms.numberOfLayers] : 0.0;
            _scrollController.jumpTo(pos);
            Logging.info(this.widget, "scrolling to positions: " + pos.toString() + "/" + state.mediaListPosition.toString());
        }
        catch (e)
        {
            // nothing to do
        }
    }

    Widget _buildHeaderLine(final ThemeData td, final MediaListButtons buttons, final String titleStr)
    {
        final List<Widget> elements = [];

        final OperationCommandMsg commandTopMsg = OperationCommandMsg.output(
            ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE, OperationCommand.TOP);

        elements.add(CustomImageButton.small(
            commandTopMsg.getValue.icon,
            commandTopMsg.getValue.description,
            onPressed: ()
            => stateManager.sendMessage(commandTopMsg, waitingForData: true),
            isEnabled: state.isOn && !state.mediaListState.isTopLayer()
        ));

        Widget title = CustomTextLabel.small(titleStr, padding: ActivityDimens.headerPadding);
        if (state.isOn && !state.mediaListState.isTopLayer())
        {
            title = InkWell(
                child: title,
                onTap: ()
                => stateManager.sendMessage(stateManager.getReturnMessage(), waitingForData: true));
        }

        final Widget field = !state.mediaFilterVisible ? title :
        CustomTextField(_mediaFilterController,
            isFocused: true,
            isBorder: false,
            onChanged: (v)
            {
                setState(()
                {
                    // just rebuild widget
                });
            }
        );

        elements.add(Flexible(
            child: Container(
                constraints: BoxConstraints(minHeight: ButtonDimens.smallButtonSize + ButtonDimens.smallButtonPadding.vertical),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: field
                )
            )
        ));

        // Filter button
        if (!buttons.progress && buttons.filter)
        {
            elements.add(CustomImageButton.small(
                Drawables.media_item_filter,
                Strings.medialist_filter,
                onPressed: ()
                {
                    setState(()
                    {
                        state.toggleMediaFilter();
                    });
                }));
        }

        // Sort button
        if (!buttons.progress && buttons.remoteSort)
        {
            // show sort button
            final OperationCommandMsg cmd = OperationCommandMsg.output(
                ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE, OperationCommand.SORT);
            elements.add(CustomImageButton.small(
                cmd.getValue.icon,
                cmd.getValue.description,
                onPressed: ()
                => stateManager.sendMessage(cmd)));
        }
        else if (buttons.appSort)
        {
            elements.add(CustomImageButton.small(
                Drawables.cmd_sort,
                Strings.cmd_description_sort,
                onPressed: ()
                {
                    setState(()
                    {
                        configuration.appSettings.toggleSortMode();
                    });
                }));
        }

        // Progress indicator
        if (buttons.progress)
        {
            // show progress indicator
            elements.add(UpdatableView.createTimerSand());
        }

        return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: elements,
        );
    }

    bool _ignoreItem(final ISCPMessage msg, final String filter)
    {
        String title = "";
        if (msg is NetworkServiceMsg)
        {
            title = msg.getValue.description;
        }
        else if (msg is XmlListItemMsg)
        {
            title = msg.getTitle;
        }
        else if (msg is PresetCommandMsg)
        {
            title = msg.getPresetConfig.displayedString();
        }
        else
        {
            return false;
        }
        if (filter.isEmpty || filter == "*")
        {
            return false;
        }
        if (title.toUpperCase().startsWith(filter.toUpperCase()))
        {
            return false;
        }
        if (filter.startsWith("*"))
        {
            final String f = filter.substring(filter.lastIndexOf('*') + 1);
            return !title.toUpperCase().contains(f.toUpperCase());
        }
        return true;
    }

    Widget _buildTrackButtons()
    {
        final List<Widget> buttons = [];
        [
            OperationCommandMsg.output(state.getActiveZone, OperationCommand.LEFT),
            OperationCommandMsg.output(state.getActiveZone, OperationCommand.RIGHT),
        ].forEach((cmd)
        => buttons.add(CustomImageButton.normal(
            cmd.getValue.icon,
            cmd.getValue.description,
            onPressed: ()
            => stateManager.sendMessage(cmd)))
        );

        return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: buttons,
        );
    }

    void _addShortcut(final BuildContext context, final String item, final String alias)
    {
        final MediaListState ms = state.mediaListState;
        if (ms.isPathItemsConsistent())
        {
            final CfgFavoriteShortcuts shortcutCfg = configuration.favoriteShortcuts;
            final Shortcut shortcut = Shortcut(
                shortcutCfg.getNextId(), ms.inputType, ms.serviceType, item, alias);
            if (ms.pathItems.isNotEmpty)
            {
                Logging.info(this.widget, "full path to the item: " + ms.pathItems.toString());
                shortcut.setPathItems(ms.pathItems, ms.serviceType);
            }
            shortcutCfg.updateShortcut(shortcut, shortcut.alias);
            PopupManager.showToast(Strings.favorite_shortcut_added, context: context);
            stateManager.triggerStateEvent(FavoriteShortcutEditDialog.SHORTCUT_CHANGE_EVENT);
        }
        else
        {
            PopupManager.showToast(Strings.favorite_shortcut_failed, context: context);
        }
    }

    bool _returnMessageExists(final List<ISCPMessage> items)
    => items.isNotEmpty && state.mediaListState.isReturnMsg(items.first);

    void _sendDcpMediaCmd(DcpMediaContainerMsg mc, int aid)
    {
        final DcpMediaContainerMsg mc1 = DcpMediaContainerMsg.copy(mc);
        mc1.setAid(aid.toString());
        stateManager.sendMessage(mc1);
    }

    XmlListItemMsg _findDcpMenuItem(List<XmlListItemMsg> menuItems, int id)
    => menuItems.firstWhere((item) => item.getMessageId == id, orElse: () => null);

    void _callDcpMenuItem(DcpMediaContainerMsg dcpCmd, int id)
    {
        final List<XmlListItemMsg> menuItems = state.mediaListState.cloneDcpTrackMenuItems(dcpCmd);
        final XmlListItemMsg item = _findDcpMenuItem(menuItems, id);
        if (item != null)
        {
            stateManager.sendMessage(item);
        }
    }
}