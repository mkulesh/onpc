/*
 * Enhanced Music Controller
 * Copyright (C) 2018-2025 by Mikhail Kulesh
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

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../config/CfgFavoriteShortcuts.dart';
import '../config/Configuration.dart';
import '../constants/Dimens.dart';
import '../constants/Strings.dart';
import '../dialogs/PopupManager.dart';
import '../dialogs/TextEditDialog.dart';
import '../iscp/ConnectionIf.dart';
import '../iscp/ISCPMessage.dart';
import "../iscp/State.dart" as remote_state;
import '../iscp/StateManager.dart';
import '../iscp/messages/DcpMediaContainerMsg.dart';
import '../iscp/messages/DcpPlaylistCmdMsg.dart';
import '../iscp/messages/OperationCommandMsg.dart';
import '../iscp/messages/PlayQueueAddMsg.dart';
import '../iscp/messages/PlayQueueRemoveMsg.dart';
import '../iscp/messages/PresetCommandMsg.dart';
import '../iscp/messages/ReceiverInformationMsg.dart';
import '../iscp/messages/XmlListItemMsg.dart';
import '../iscp/state/MediaListState.dart';
import '../utils/Logging.dart';
import '../widgets/CustomDivider.dart';
import '../widgets/CustomTextLabel.dart';
import '../widgets/PositionedTapDetector.dart';
import 'UpdatableView.dart';

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
    SO_ADD_AND_PLAY_ALL,
    // #352 filter out duplicate artists from search results
    HIDE_EMPTY_ITEMS,
    RENAME_PLAYLIST,
    DELETE_PLAYLIST,
}

class ShortcutInfo
{
    String? item;
    String? alias;
    String actionFlag = "";

    bool get isValid
    => item != null && alias != null;
}

class MediaListContextMenu
{
    final ViewContext viewContext;
    late Configuration configuration;
    late StateManager stateManager;
    late remote_state.State state;
    final String _PLAYBACK_STRING;

    MediaListContextMenu(this.viewContext, this._PLAYBACK_STRING)
    {
        configuration = viewContext.configuration;
        stateManager = viewContext.stateManager;
        state = stateManager.state;
    }

    void onCreateContextMenu(final BuildContext context, final TapPosition position, final ISCPMessage cmd)
    {
        final List<PopupMenuItem<MediaContextMenu>> contextMenu = [];
        final Selector? selector = state.getActualSelector;
        final NetworkService? networkService = state.getNetworkService;
        final DcpMediaContainerMsg? dcpCmd = state.mediaListState.getDcpContainerMsg(cmd);

        final bool isMediaItem = (cmd is XmlListItemMsg && cmd.iconType != _PLAYBACK_STRING) || cmd is PresetCommandMsg;
        final bool isPlaying = cmd is XmlListItemMsg && cmd.getIcon.key == ListItemIcon.PLAY;
        final bool isDcpItem = dcpCmd != null;
        final bool isDcpPlayable = dcpCmd != null && dcpCmd.isPlayable();
        final bool isQueue = state.mediaListState.isQueue;
        final bool isPlaylist = state.mediaListState.isPlaylist && dcpCmd != null && dcpCmd.isContainer();

        final ShortcutInfo shortcutInfo = ShortcutInfo();
        shortcutInfo.item = cmd is XmlListItemMsg ? cmd.getTitle : cmd is PresetCommandMsg ? cmd.getData : null;
        shortcutInfo.alias = cmd is XmlListItemMsg ? cmd.getTitle : cmd is PresetCommandMsg && cmd.getPresetConfig != null ? cmd.getPresetConfig!.displayedString() : null;
        shortcutInfo.actionFlag = isDcpPlayable? Shortcut.DCP_PLAYABLE_TAG : "";
        final List<DcpMediaContainerMsg> dcpDuplicates = state.protoType == ProtoType.DCP? state.mediaListState.getDcpDuplicates(cmd) : [];

        if (isMediaItem && selector != null)
        {
            final bool addToQueue = selector.isAddToQueue ||
                (networkService != null && networkService.isAddToQueue) ||
                isDcpPlayable;
            final bool isAdvQueue = configuration.isAdvancedQueue ||
                isDcpPlayable;

            Logging.info(this, "Context menu for selector " + selector.toString() +
                (networkService != null ? " and service " + networkService.toString() : "") +
                ", isMediaItem=" + isMediaItem.toString() +
                ", isPlaying=" + isPlaying.toString() +
                ", isDcpItem=" + isDcpItem.toString() +
                ", isDcpPlayable=" + isDcpPlayable.toString() +
                ", isQueue=" + isQueue.toString() +
                ", isPlaylist=" + isPlaylist.toString() +
                ", addToQueue=" + addToQueue.toString() +
                ", isAdvQueue=" + isAdvQueue.toString() +
                ", dcpDuplicates=" + dcpDuplicates.length.toString() +
                (shortcutInfo.item != null? (", item=" + shortcutInfo.item.toString()) : "")
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
                        child: CustomTextLabel.normal(Strings.playlist_replace_and_play), value: MediaContextMenu.REPLACE_AND_PLAY));
                }
                contextMenu.add(PopupMenuItem<MediaContextMenu>(
                    child: CustomTextLabel.normal(Strings.playlist_add), value: MediaContextMenu.ADD));
                if (isAdvQueue && !isDcpItem)
                {
                    contextMenu.add(PopupMenuItem<MediaContextMenu>(
                        child: CustomTextLabel.normal(Strings.playlist_replace), value: MediaContextMenu.REPLACE));
                }
                contextMenu.add(PopupMenuItem<MediaContextMenu>(
                    child: CustomTextLabel.normal(Strings.playlist_add_and_play), value: MediaContextMenu.ADD_AND_PLAY));
            }

            if (isQueue)
            {
                contextMenu.add(PopupMenuItem<MediaContextMenu>(
                    child: CustomTextLabel.normal(Strings.playlist_remove), value: MediaContextMenu.REMOVE));
                contextMenu.add(PopupMenuItem<MediaContextMenu>(
                    child: CustomTextLabel.normal(Strings.playlist_remove_all), value: MediaContextMenu.REMOVE_ALL));
            }

            // DCP options
            if (isDcpItem)
            {
                final List<XmlListItemMsg> menuItems = state.mediaListState.cloneDcpTrackMenuItems(null);
                final oldLength = contextMenu.length;

                if (isPlaylist)
                {
                    contextMenu.add(PopupMenuItem<MediaContextMenu>(
                        child: CustomTextLabel.normal(Strings.playlist_rename),
                        value: MediaContextMenu.RENAME_PLAYLIST));
                    contextMenu.add(PopupMenuItem<MediaContextMenu>(
                        child: CustomTextLabel.normal(Strings.playlist_delete),
                        value: MediaContextMenu.DELETE_PLAYLIST));
                }

                if (_findDcpMenuItem(menuItems, DcpMediaContainerMsg.SO_ADD_TO_HEOS) != null)
                {
                    contextMenu.add(PopupMenuItem<MediaContextMenu>(
                        child: CustomTextLabel.normal(Strings.playlist_add_to_heos_favourites),
                        value: MediaContextMenu.SO_ADD_TO_HEOS));
                }

                if (_findDcpMenuItem(menuItems, DcpMediaContainerMsg.SO_REMOVE_FROM_HEOS) != null)
                {
                    contextMenu.add(PopupMenuItem<MediaContextMenu>(
                        child: CustomTextLabel.normal(Strings.playlist_remove_from_heos_favourites),
                        value: MediaContextMenu.SO_REMOVE_FROM_HEOS));
                }

                if (_findDcpMenuItem(menuItems, DcpMediaContainerMsg.SO_REPLACE_AND_PLAY_ALL) != null)
                {
                    contextMenu.add(PopupMenuItem<MediaContextMenu>(
                        child: CustomTextLabel.normal(Strings.playlist_replace_and_play_all),
                        value: MediaContextMenu.SO_REPLACE_AND_PLAY_ALL));
                }

                if (_findDcpMenuItem(menuItems, DcpMediaContainerMsg.SO_ADD_ALL) != null)
                {
                    contextMenu.add(PopupMenuItem<MediaContextMenu>(
                        child: CustomTextLabel.normal(Strings.playlist_add_all),
                        value: MediaContextMenu.SO_ADD_ALL));
                }

                if (_findDcpMenuItem(menuItems, DcpMediaContainerMsg.SO_ADD_AND_PLAY_ALL) != null)
                {
                    contextMenu.add(PopupMenuItem<MediaContextMenu>(
                        child: CustomTextLabel.normal(Strings.playlist_add_and_play_all),
                        value: MediaContextMenu.SO_ADD_AND_PLAY_ALL));
                }

                if (dcpDuplicates.length > 1)
                {
                    contextMenu.add(PopupMenuItem<MediaContextMenu>(
                        child: CustomTextLabel.normal(Strings.medialist_hide_empty_items),
                        value: MediaContextMenu.HIDE_EMPTY_ITEMS));
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
                child: CustomTextLabel.normal(Strings.cmd_track_menu), value: MediaContextMenu.TRACK_MENU));
        }

        if (isMediaItem && isPlaying && !isDcpItem)
        {
            contextMenu.add(PopupMenuItem<MediaContextMenu>(
                child: CustomTextLabel.normal(Strings.medialist_playback_mode), value: MediaContextMenu.PLAYBACK_MODE));
        }

        if (state.isShortcutPossible && shortcutInfo.isValid)
        {
            contextMenu.add(PopupMenuItem<MediaContextMenu>(
                child: CustomTextLabel.normal(Strings.favorite_shortcut_create), value: MediaContextMenu.ADD_TO_FAVORITES));
        }

        if (contextMenu.isNotEmpty)
        {
            showMenu(
                context: context,
                position: RelativeRect.fromLTRB(position.global.dx, position.global.dy, position.global.dx, position.global.dy),
                items: contextMenu).then((m)
            => _onContextItemSelected(context, m, cmd, shortcutInfo, dcpDuplicates)
            );
        }
    }

    void _onContextItemSelected(final BuildContext context,
        final MediaContextMenu? m,
        final ISCPMessage cmd,
        final ShortcutInfo shortcutInfo,
        final List<DcpMediaContainerMsg> dcpDuplicates)
    {
        if (m == null)
        {
            return;
        }
        final int idx = cmd.getMessageId;
        final DcpMediaContainerMsg? dcpCmd = state.mediaListState.getDcpContainerMsg(cmd);
        Logging.info(this, "selected context menu: " + m.toString() + ", index: " + idx.toString());
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
                if (state.isShortcutPossible && shortcutInfo.isValid)
                {
                    _addShortcut(context, shortcutInfo);
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
            case MediaContextMenu.HIDE_EMPTY_ITEMS:
                stateManager.handleDcpDuplicates(dcpDuplicates);
                break;
            case MediaContextMenu.RENAME_PLAYLIST:
                if (cmd is XmlListItemMsg && dcpCmd != null)
                {
                    _renamePlaylist(context, cmd, dcpCmd);
                }
                break;
            case MediaContextMenu.DELETE_PLAYLIST:
                if (dcpCmd != null)
                {
                    stateManager.sendMessage(DcpPlaylistCmdMsg.delete(
                        dcpCmd.getParentSid(), dcpCmd.getCid()), waitingForMsg: DcpMediaContainerMsg.CODE);
                }
                break;
        }
    }

    void _addShortcut(final BuildContext context, final ShortcutInfo info)
    {
        final MediaListState ms = state.mediaListState;
        if (ms.isPathItemsConsistent())
        {
            final CfgFavoriteShortcuts shortcutCfg = configuration.favoriteShortcuts;
            final Shortcut shortcut = Shortcut(
                shortcutCfg.getNextId(), state.protoType, ms.inputType, ms.serviceType,
                info.item!, info.alias!, info.actionFlag);
            if (ms.pathItems.isNotEmpty)
            {
                Logging.info(this, "full path to the item: " + ms.pathItems.toString());
                shortcut.setPathItems(ms.pathItems, ms.serviceType);
            }
            shortcutCfg.updateShortcut(shortcut, shortcut.alias);
            PopupManager.showToast(Strings.favorite_shortcut_added, toastKey: viewContext.toastKey);
            stateManager.triggerStateEvent(StateManager.SHORTCUT_CHANGE_EVENT);
        }
        else
        {
            PopupManager.showToast(Strings.favorite_shortcut_failed, toastKey: viewContext.toastKey);
        }
    }

    void _sendDcpMediaCmd(DcpMediaContainerMsg mc, int aid)
    {
        final DcpMediaContainerMsg mc1 = DcpMediaContainerMsg.copy(mc);
        mc1.setAid(aid.toString());
        stateManager.sendMessage(mc1);
    }

    XmlListItemMsg? _findDcpMenuItem(List<XmlListItemMsg> menuItems, int id)
    => menuItems.firstWhereOrNull((item) => item.getMessageId == id);

    void _callDcpMenuItem(DcpMediaContainerMsg? dcpCmd, int id)
    {
        final List<XmlListItemMsg> menuItems = state.mediaListState.cloneDcpTrackMenuItems(dcpCmd);
        final XmlListItemMsg? item = _findDcpMenuItem(menuItems, id);
        if (item != null)
        {
            stateManager.sendMessage(item);
        }
    }

    void _renamePlaylist(final BuildContext context, final XmlListItemMsg cmd, final DcpMediaContainerMsg dcpCmd)
    {
        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext c)
            => TextEditDialog(cmd.getTitle, (newName)
            {
                Logging.info(this, "rename command for playlist: " + dcpCmd.toString());
                stateManager.sendMessage(DcpPlaylistCmdMsg.rename(
                    dcpCmd.getParentSid(), dcpCmd.getCid(), newName), waitingForMsg: DcpMediaContainerMsg.CODE);
            })
        );
    }
}
