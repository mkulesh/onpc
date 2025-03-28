/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2024 by Mikhail Kulesh
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
import "package:flutter/services.dart";
import "package:sprintf/sprintf.dart";

import "../config/CfgAppSettings.dart";
import "../config/CfgFavoriteShortcuts.dart";
import "../constants/Dimens.dart";
import "../constants/Strings.dart";
import "../dialogs/FavoriteShortcutEditDialog.dart";
import "../iscp/StateManager.dart";
import "../utils/Logging.dart";
import "../utils/Pair.dart";
import "../utils/Platform.dart";
import "../views/UpdatableView.dart";
import "../widgets/ContextMenuListener.dart";
import "../widgets/CustomImageButton.dart";
import "../widgets/CustomTextLabel.dart";
import "../widgets/ReorderableItem.dart";

enum _ShortcutContextMenu
{
    EDIT,
    DELETE,
    COPY_TO_CLIPBOARD
}

class ShortcutsView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        StateManager.SHORTCUT_CHANGE_EVENT
    ];

    final List<int> _shortcutIds = [];

    ShortcutsView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.logRebuild(this);
        _shortcutIds.clear();

        Widget tab;
        final List<Shortcut> shortcuts = [];
        configuration.favoriteShortcuts.shortcuts.forEach((s)
        {
            if (s.protoType == stateManager.protoType)
            {
                shortcuts.add(s);
            }
        });

        if (shortcuts.isEmpty)
        {
            final String message = sprintf(Strings.favorite_shortcut_howto, [
                CfgAppSettings.getTabName(AppTabs.MEDIA),
                Platform.isDesktop ? Strings.action_context_desktop : Strings.action_context_mobile,
                Strings.favorite_shortcut_create
            ]);
            tab = CustomTextLabel.small(message, textAlign: TextAlign.center);
        }
        else
        {
            final List<Widget> rows = [];
            for (int i = 0; i < shortcuts.length; i++)
            {
                rows.add(_buildRow(context, i, shortcuts[i]));
                _shortcutIds.add(shortcuts[i].id);
            }

            tab = Scrollbar(child: ReorderableListView(
                primary: true,
                onReorder: _onReorder,
                reverse: false,
                scrollDirection: Axis.vertical,
                children: rows));
        }

        return Expanded(flex: 1, child: tab);
    }

    Widget _buildRow(final BuildContext context, final int index, final Shortcut s)
    {
        final Widget w = ContextMenuListener<_ShortcutContextMenu>(
            child: Padding(padding: ListDimens.verticalPadding(viewContext.configuration.appSettings.textSize), child:
                MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    removeBottom: true,
                    removeLeft: true,
                    removeRight: true,
                    child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: ListDimens.horizontalPadding),
                        dense: true,
                        leading: CustomImageButton.normal(
                            s.getIcon(), null,
                            isEnabled: false,
                            padding: ActivityDimens.noPadding,
                        ),
                        title: CustomTextLabel.normal(s.alias),
                        onTap: ()
                        => _selectShortcut(s)
                    ),
                )
            ),
            menuName: s.alias + ":",
            menuItems: [
                Pair(Strings.pref_item_update, _ShortcutContextMenu.EDIT),
                Pair(Strings.pref_item_delete, _ShortcutContextMenu.DELETE),
                Pair(Strings.favorite_copy_to_clipboard, _ShortcutContextMenu.COPY_TO_CLIPBOARD)
            ],
            onItemSelected: (BuildContext c, _ShortcutContextMenu m)
            => _onContextItemSelected(context, m, s)
        );
        return ReorderableItem(key: Key(index.toString()), child: w);
    }

    void _onContextItemSelected(final BuildContext context, final _ShortcutContextMenu m, final Shortcut s)
    {
        Logging.info(this, "selected context menu: " + m.toString() + ", shortcut: " + s.toString());
        switch (m)
        {
            case _ShortcutContextMenu.EDIT:
                viewContext.showRootDialog(context, FavoriteShortcutEditDialog(viewContext, s));
                break;
            case _ShortcutContextMenu.DELETE:
                configuration.favoriteShortcuts.deleteShortcut(s);
                stateManager.triggerStateEvent(StateManager.SHORTCUT_CHANGE_EVENT);
                break;
            case _ShortcutContextMenu.COPY_TO_CLIPBOARD:
                Clipboard.setData(ClipboardData(text: s.toScript(state.protoType, state.receiverInformation.model, state.mediaListState)));
                break;
        }
    }

    void _onReorder(int oldIndex, int newIndex)
    {
        if (newIndex > oldIndex)
        {
            newIndex -= 1;
        }
        if (oldIndex < _shortcutIds.length && newIndex < _shortcutIds.length)
        {
            configuration.favoriteShortcuts.reorder(_shortcutIds[oldIndex], _shortcutIds[newIndex]);
            stateManager.triggerStateEvent(StateManager.SHORTCUT_CHANGE_EVENT);
        }
    }

    void _selectShortcut(Shortcut s)
    {
        if (state.isConnected)
        {
            stateManager.applyShortcut(s);
            stateManager.triggerStateEvent(StateManager.OPEN_MEDIA_VIEW);
        }
    }
}