/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2025 by Mikhail Kulesh
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

import "package:flutter/material.dart";

import "../config/CheckableItem.dart";
import "../config/Configuration.dart";
import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../dialogs/DcpSearchDialog.dart";
import "../dialogs/TextEditDialog.dart";
import "../dialogs/UrlLauncher.dart";
import "../iscp/ConnectionIf.dart";
import "../iscp/ISCPMessage.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/DcpMediaContainerMsg.dart";
import "../iscp/messages/DcpMediaItemMsg.dart";
import "../iscp/messages/DcpPlaylistCmdMsg.dart";
import "../iscp/messages/DcpSearchCriteriaMsg.dart";
import "../iscp/messages/DcpTunerModeMsg.dart";
import "../iscp/messages/EnumParameterMsg.dart";
import "../iscp/messages/InputSelectorMsg.dart";
import "../iscp/messages/ListInfoMsg.dart";
import "../iscp/messages/ListTitleInfoMsg.dart";
import "../iscp/messages/NetworkServiceMsg.dart";
import "../iscp/messages/OperationCommandMsg.dart";
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
import "../utils/Platform.dart";
import "../widgets/ContextMenuListener.dart";
import "../widgets/CustomDialogTitle.dart";
import "../widgets/CustomDivider.dart";
import "../widgets/CustomImageButton.dart";
import "../widgets/CustomTextField.dart";
import "../widgets/CustomTextLabel.dart";
import "../widgets/ReorderableItem.dart";
import "MediaListContextMenu.dart";
import "UpdatableView.dart";

class MediaListButtons
{
    bool filter = false;
    bool remoteSort = false;
    bool appSort = false;
    bool progress = false;
    bool dcpSearch = false;
    bool dcpPlaylist = false;
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
        DcpMediaItemMsg.CODE,
        DcpSearchCriteriaMsg.CODE
    ];

    MediaListView({Key? key, required this.viewContext}) : super(key: key);

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
    late ScrollController _scrollController;
    int _currentLayer = -1;
    final MediaListButtons _headerButtons = MediaListButtons();
    final MediaListSorter _mediaListSorter = MediaListSorter();
    late TextEditingController _mediaFilterController;
    late MediaListContextMenu _mediaListContextMenu;

    _MediaListViewState(final ViewContext _viewContext, final List<String> _updateTriggers) : super(_viewContext, _updateTriggers);

    @override
    void initState()
    {
        super.initState();
        _scrollController = ScrollController();
        Logging.info(this.widget, "saved scroll positions: " + state.mediaListPosition.toString());
        _mediaFilterController = TextEditingController();
        _mediaListContextMenu = MediaListContextMenu(viewContext, _PLAYBACK_STRING);
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
        _headerButtons.remoteSort = state.isOn && state.getNetworkService != null && state.getNetworkService!.isSort;
        _headerButtons.appSort = state.isOn && !_headerButtons.remoteSort && ms.isDeezer && _DEEZER_ALBUMS == ms.titleBar.toUpperCase();
        _headerButtons.progress = state.isOn && stateManager.waitingForData;
        _headerButtons.dcpSearch = state.isOn &&
            state.protoType == ProtoType.DCP &&
            ms.getDcpSearchCriteria().isNotEmpty;
        _headerButtons.dcpPlaylist = state.protoType == ProtoType.DCP && state.mediaListState.isQueue;
        
        // Apply filter
        if (ms.numberOfLayers != _currentLayer)
        {
            _mediaFilterController.clear();
        }
        final String filter = _mediaFilterController.text;
        final bool applyFilter = _headerButtons.filter && filter.isNotEmpty;
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

        // Add "Playback" indication if necessary
        if (isPlayback)
        {
            final XmlListItemMsg playbackIndicationItem = XmlListItemMsg.details(
                0xFFFF, 0, Strings.medialist_playback_mode, _PLAYBACK_STRING, ListItemIcon.PLAY, false, null);
            items.add(playbackIndicationItem);
        }

        // List items
        final int visibleItems = items.length;
        final int totalItems = ms.getTotalItems();

        // Scroll positions
        _scrollController.removeListener(_saveScrollPosition);
        if (!applyFilter && ms.downloadCtrl.downloadFinished)
        {
            _processLayerInfo(ms, dataItems);
        }

        // Create list
        final bool isAdvancedQueue = ms.isQueue && configuration.isAdvancedQueue;
        final Widget mediaList = isAdvancedQueue ? _buildPlayQueueList(context, items) : _buildMediaList(td, items);
        final List<Widget> elements = [
            _buildHeaderLine(context, td, _headerButtons, _buildTitle(visibleItems, totalItems)),
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
        final ISCPMessage? retMsg = _getReturnMessage();
        final itemCount = retMsg != null ? items.length + 1 : items.length;
        final ListView list = ListView.builder(
            padding: ActivityDimens.noPadding,
            scrollDirection: Axis.vertical,
            itemCount: itemCount,
            physics: ClampingScrollPhysics(),
            controller: _scrollController,
            itemBuilder: (BuildContext itemContext, int index)
            {
                final ISCPMessage? rowMsg = retMsg != null ?
                    (index == 0 ? retMsg : _getItemOrNull(items, index - 1)) :
                    _getItemOrNull(items, index);
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

        return Scrollbar(
            controller: _scrollController,
            interactive: true,
            child: list);
    }

    ISCPMessage? _getItemOrNull(List<ISCPMessage> items, int i) 
    => i < items.length ? items[i] : null; 

    Widget _buildPlayQueueList(BuildContext context, List<ISCPMessage> items)
    {
        final List<Widget> _rows = [];
        _playQueueIds.clear();

        Widget? header;
        final ISCPMessage? retMsg = _getReturnMessage();
        if (retMsg != null && retMsg is OperationCommandMsg)
        {
            header = _buildOperationCommandMsg(context, retMsg);
        }
        items.forEach((rowMsg)
        {
            if (rowMsg is XmlListItemMsg)
            {
                _rows.add(_buildXmlListItemMsg(context, rowMsg, reorderId: rowMsg.getMessageId.toString()));
                _playQueueIds.add(rowMsg.getMessageId);
            }
            else if (rowMsg is OperationCommandMsg)
            {
                _rows.add(_buildOperationCommandMsg(context, rowMsg));
                _playQueueIds.add(rowMsg.getMessageId);
            }
        });

        return Scrollbar(
            controller: _scrollController,
            interactive: true,
            child: ReorderableListView(
                onReorder: _onReorder,
                header: header,
                reverse: false,
                padding: ActivityDimens.noPadding,
                scrollController: _scrollController,
                scrollDirection: Axis.vertical,
                children: _rows
            )
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

    Widget _buildRow(final BuildContext context, final String? icon, final bool iconEnabled, final bool isPlaying, final String title, final ISCPMessage cmd, {final String? reorderId})
    {
        final ThemeData td = Theme.of(context);
        final bool isMoved = cmd is XmlListItemMsg && cmd.getMessageId == state.mediaListState.movedItem;
        final Widget? iconImg = icon == null || icon == Drawables.media_item_unknown ? null :
            CustomImageButton.normal(
                icon, null,
                isEnabled: iconEnabled || isPlaying,
                isSelected: isPlaying,
                padding: ActivityDimens.noPadding,
            );

        final Widget w = ContextMenuListener(
            key: reorderId != null? Key(reorderId) : null,
            child: Padding(padding: ListDimens.verticalPadding(viewContext.configuration.appSettings.textSize),
                child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    removeBottom: true,
                    removeLeft: true,
                    removeRight: true,
                    child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: ListDimens.horizontalPadding),
                        dense: true,
                        leading: iconImg,
                        title: CustomTextLabel.normal(title, color: isMoved ? td.disabledColor : null),
                        onTap: () => _processItemTap(context, cmd, icon)
                    ),
                )
            ),
            onContextMenu: (position)
            => _mediaListContextMenu.onCreateContextMenu(context, position, cmd)
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

    void _processItemTap(final BuildContext context, ISCPMessage cmd, final String? icon)
    {
        if (Platform.isMobile && cmd is NetworkServiceMsg &&
            [ServiceType.SPOTIFY, ServiceType.DCP_SPOTIFY].contains(cmd.getValue.key))
        {
            Logging.info(this.widget, "Selected media item: " + cmd.toString() + " -> launch Spotify app");
            UrlLauncher.launchURL("spotify://", errorMsg: Strings.service_spotify_missing_app, toastKey: viewContext.toastKey);
            return;
        }
        state.closeMediaFilter();
        final rowMsg = (cmd is XmlListItemMsg && cmd.iconType == _PLAYBACK_STRING) ? StateManager.DISPLAY_MSG : cmd;
        if (state.protoType == ProtoType.DCP && rowMsg is XmlListItemMsg)
        {
            state.mediaListState.storeSelectedDcpItem(rowMsg);
        }
        stateManager.sendMessage(rowMsg, waitingForData: rowMsg != StateManager.DISPLAY_MSG && icon != Drawables.media_item_unknown);
    }

    Widget _buildNetworkServiceRow(final BuildContext context, NetworkServiceMsg rowMsg)
    {
        String? serviceIcon = rowMsg.getValue.icon;
        if (serviceIcon == null)
        {
            serviceIcon = Drawables.media_item_unknown;
        }
        final bool isPlaying = state.playbackState.serviceIcon.getCode == rowMsg.getValue.getCode;
        return _buildRow(context, serviceIcon, false, isPlaying, rowMsg.getValue.description, rowMsg);
    }

    Widget _buildXmlListItemMsg(final BuildContext context, XmlListItemMsg rowMsg, {final String? reorderId})
    {
        String? serviceIcon = rowMsg.getIcon.icon;
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
        final bool isPlaying = rowMsg.getPresetConfig != null && rowMsg.getPresetConfig!.getId == state.radioState.preset;
        if (isPlaying)
        {
            serviceIcon = Drawables.media_item_play;
        }
        final String name = rowMsg.getPresetConfig != null? rowMsg.getPresetConfig!.displayedString() : Strings.dashed_string;
        return _buildRow(context, serviceIcon, false, isPlaying, name, rowMsg);
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

    String _buildTitle(final int _visibleItems, final int _numberOfItems)
    {
        String title = "";
        if (!state.isOn)
        {
            return Strings.medialist_no_items;
        }
        final MediaListState ms = state.mediaListState;
        final Selector? selector = state.getActualSelector;
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
            if (_numberOfItems >= 0)
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

    Widget _buildHeaderLine(final BuildContext context, final ThemeData td, final MediaListButtons buttons, final String titleStr)
    {
        final List<Widget> elements = [];

        final OperationCommandMsg commandTopMsg = OperationCommandMsg.output(
            ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE, OperationCommand.TOP);

        elements.add(CustomImageButton.small(
            commandTopMsg.getValue.icon!,
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

        // DCP Search button
        if (!buttons.progress && buttons.dcpSearch)
        {
            elements.add(CustomImageButton.small(
                Drawables.cmd_search,
                Strings.medialist_search,
                onPressed: ()
                {
                    if (state.mediaListState.getDcpSearchCriteria().isNotEmpty)
                    {
                        viewContext.showRootDialog(context,
                            DcpSearchDialog(viewContext, state.mediaListState.getDcpSearchCriteria())
                        );
                    }
                }));
        }

        // DCP playlist button
        if (!buttons.progress && buttons.dcpPlaylist)
        {
            elements.add(CustomImageButton.small(
                Drawables.media_item_playlist,
                Strings.playlist_save_queue_as,
                onPressed: ()
                {
                    viewContext.showRootDialog(context,
                        TextEditDialog("", (newName)
                        {
                            stateManager.sendMessage(DcpPlaylistCmdMsg.create(newName));
                        },
                        title: CustomDialogTitle(Strings.playlist_save_queue_as, Drawables.media_item_playlist))
                    );
                }
            ));
        }

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
                cmd.getValue.icon!,
                cmd.getValue.description,
                onPressed: ()
                => stateManager.sendMessage(cmd)));
        }
        else if (!buttons.progress && buttons.appSort)
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
        else if (msg is PresetCommandMsg && msg.getPresetConfig != null)
        {
            title = msg.getPresetConfig!.displayedString();
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
            cmd.getValue.icon!,
            cmd.getValue.description,
            onPressed: ()
            => stateManager.sendMessage(cmd)))
        );

        return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: buttons,
        );
    }

    ISCPMessage? _getReturnMessage()
    {
        if (state.isOn
            && state.mediaListState.layerInfo != null
            && !state.mediaListState.isTopLayer()
            && !configuration.backAsReturn)
        {
            return stateManager.getReturnMessage();
        }
        return null;
    }
}