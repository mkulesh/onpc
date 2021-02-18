/*
 * Enhanced Controller for Onkyo and Pioneer Pro
 * Copyright (C) 2019-2021 by Mikhail Kulesh
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
import "package:positioned_tap_detector/positioned_tap_detector.dart";
import "package:sprintf/sprintf.dart";

import "../Platform.dart";
import "../config/CfgAppSettings.dart";
import "../config/CfgFavoriteShortcuts.dart";
import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../dialogs/FavoriteShortcutEditDialog.dart";
import "../iscp/StateManager.dart";
import "../utils/Logging.dart";
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
        FavoriteShortcutEditDialog.SHORTCUT_CHANGE_EVENT
    ];

    ShortcutsView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.logRebuild(this);

        Widget tab;
        if (configuration.favoriteShortcuts.shortcuts.isEmpty)
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
            configuration.favoriteShortcuts.shortcuts.forEach((s)
            => rows.add(_buildRow(context, s)));

            tab = Scrollbar(child: ReorderableListView(
                onReorder: _onReorder,
                reverse: false,
                scrollDirection: Axis.vertical,
                children: rows));
        }

        return Expanded(flex: 1, child: tab);
    }

    Widget _buildRow(final BuildContext context, final Shortcut s)
    {
        final Widget w = ContextMenuListener(
            child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                removeBottom: true,
                removeLeft: true,
                removeRight: true,
                child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: MediaListDimens.itemPadding),
                    dense: configuration.appSettings.textSize != "huge",
                    leading: CustomImageButton.normal(
                        s.getIcon(), null,
                        isEnabled: false,
                        padding: EdgeInsets.symmetric(vertical: MediaListDimens.itemPadding),
                    ),
                    title: CustomTextLabel.normal(s.alias),
                    onTap: ()
                    => _selectShortcut(s)),
                ),
            onContextMenu: (position)
            => _onCreateContextMenu(context, position, s),
        );
        return ReorderableItem(key: Key(s.id.toString()), child: w);
    }

    void _onCreateContextMenu(final BuildContext context, final TapPosition position, final Shortcut s)
    {
        final List<PopupMenuItem<_ShortcutContextMenu>> contextMenu = [];
        contextMenu.add(PopupMenuItem<_ShortcutContextMenu>(
            child: CustomTextLabel.small(Strings.favorite_shortcut_edit), enabled: false));
        contextMenu.add(PopupMenuItem<_ShortcutContextMenu>(
            child: Text(Strings.favorite_update), value: _ShortcutContextMenu.EDIT));
        contextMenu.add(PopupMenuItem<_ShortcutContextMenu>(
            child: Text(Strings.favorite_delete), value: _ShortcutContextMenu.DELETE));
        contextMenu.add(PopupMenuItem<_ShortcutContextMenu>(
            child: Text(Strings.favorite_copy_to_clipboard), value: _ShortcutContextMenu.COPY_TO_CLIPBOARD));

        showMenu(
            context: context,
            position: RelativeRect.fromLTRB(position.global.dx, position.global.dy, position.global.dx, position.global.dy),
            items: contextMenu).then((m)
        => _onContextItemSelected(context, m, s)
        );
    }

    void _onContextItemSelected(final BuildContext context, final _ShortcutContextMenu m, final Shortcut s)
    {
        if (m == null)
        {
            return;
        }
        Logging.info(this, "selected context menu: " + m.toString() + ", shortcut: " + s.toString());
        switch (m)
        {
            case _ShortcutContextMenu.EDIT:
                showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext c)
                    => FavoriteShortcutEditDialog(viewContext, s)
                );
                break;
            case _ShortcutContextMenu.DELETE:
                configuration.favoriteShortcuts.deleteShortcut(s);
                stateManager.triggerStateEvent(FavoriteShortcutEditDialog.SHORTCUT_CHANGE_EVENT);
                break;
            case _ShortcutContextMenu.COPY_TO_CLIPBOARD:
                Clipboard.setData(ClipboardData(text: s.toScript()));
                break;
        }
    }

    void _onReorder(int oldIndex, int newIndex)
    {
        if (newIndex > oldIndex)
        {
            newIndex -= 1;
        }
        configuration.favoriteShortcuts.reorder(oldIndex, newIndex);
        stateManager.triggerStateEvent(FavoriteShortcutEditDialog.SHORTCUT_CHANGE_EVENT);
    }

    void _selectShortcut(Shortcut s)
    {
        if (state.isConnected)
        {
            stateManager.applyShortcut(s);
            stateManager.triggerStateEvent(StateManager.APPLY_FAVORITE_EVENT);
        }
    }
}