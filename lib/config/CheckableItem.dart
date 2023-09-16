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
import 'package:flutter/material.dart';

import "../Platform.dart";
import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../constants/Themes.dart";
import "../utils/Pair.dart";
import "../widgets/ContextMenuListener.dart";
import "../widgets/CustomActivityTitle.dart";
import "../widgets/CustomDialogEditField.dart";
import "../widgets/CustomDialogTitle.dart";
import "../widgets/CustomTextLabel.dart";
import "../widgets/ReorderableItem.dart";
import "CfgModule.dart";
import "Configuration.dart";

enum _CheckableItemContextMenu
{
    EDIT
}

class CheckableItem
{
    final String code;
    final String text;
    bool checked;
    final void Function(String name) onRename;

    CheckableItem(this.code, this.text, this.checked, { this.onRename });

    CheckableItem.fromCode(this.code, this.checked, { this.text = "", this.onRename });

    static void reorder(final CfgModule configuration, final String parameter, final List<CheckableItem> items, int oldIndex, int newIndex)
    {
        if (newIndex > oldIndex)
        {
            newIndex -= 1;
        }
        final CheckableItem item = items.removeAt(oldIndex);
        items.insert(newIndex, item);
        CheckableItem.writeToPreference(configuration, parameter, items);
    }

    static void writeToPreference(final CfgModule configuration,
        final String parameter,
        final List<CheckableItem> items)
    {
        String selectedItems = "";
        for (CheckableItem d in items)
        {
            if (d != null)
            {
                if (selectedItems.toString().isNotEmpty)
                {
                    selectedItems += ";";
                }
                selectedItems += d.code + "," + (d.checked ? "true" : "false");
            }
        }
        configuration.saveTokens(parameter, selectedItems);
    }

    static List<CheckableItem> readFromPreference(final CfgModule configuration,
        final String parameter,
        final List<String> defItems)
    {
        final List<CheckableItem> retValue = [];

        final String cfg = configuration.getStringDef(parameter, "");

        // Add items stored in the configuration
        if (cfg.isNotEmpty)
        {
            final List<String> items = cfg.split(";");
            if (items.isEmpty)
            {
                for (String d in defItems)
                {
                    retValue.add(CheckableItem.fromCode(d, true));
                }
            }
            else
            {
                for (String d in items)
                {
                    final List<String> item = d.split(",");
                    if (item.length == 1)
                    {
                        retValue.add(CheckableItem.fromCode(item[0], true));
                    }
                    else if (item.length == 2)
                    {
                        retValue.add(CheckableItem.fromCode(item[0], item[1].toLowerCase() == 'true'));
                    }
                }
            }
        }

        // Add missed default items
        for (String d in defItems)
        {
            bool found = false;
            for (CheckableItem p in retValue)
            {
                if (d == p.code)
                {
                    found = true;
                    break;
                }
            }
            if (!found)
            {
                retValue.add(CheckableItem.fromCode(d, true));
            }
        }

        return retValue;
    }

    static Widget buildPanel(List<Widget> rows, ReorderCallback onReorder, {final ScrollController scrollController})
    {
        final bool primary = scrollController == null;
        return Scrollbar(
            child: ReorderableListView(
                primary: primary,
                onReorder: onReorder,
                reverse: false,
                scrollController: scrollController,
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                children: rows,
            ),
            controller: scrollController,
        );
    }

    static Widget buildScaffold(BuildContext context, String title, final Widget body, final Configuration configuration)
    {
        final ThemeData td = BaseAppTheme.getThemeData(
            configuration.appSettings.theme, configuration.appSettings.language, configuration.appSettings.textSize);

        final Widget scaffold = Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(ActivityDimens.appBarHeight(context)), // desired height of appBar + tabBar
                child: AppBar(title: CustomActivityTitle(Strings.drawer_app_settings, title))),
            body: Container(
                margin: ActivityDimens.activityMargins(context, Platform.isIOS, Platform.isAndroid),
                child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    removeBottom: true,
                    removeLeft: true,
                    removeRight: true,
                    child: body)
            )
        );

        return Theme(data: td, child: scaffold);
    }

    static Widget buildList(BuildContext context, List<Widget> rows, String title, ReorderCallback onReorder, final Configuration configuration)
    => buildScaffold(context, title, buildPanel(rows, onReorder), configuration);

    Widget buildListItem(ValueChanged<bool> _onChanged,
        { final BuildContext context, final ThemeData theme })
    {
        final bool val = this.checked ?? false;

        final Widget checkBox = Checkbox(
            value: val,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: _onChanged
        );

        Widget listTile = ListTile(
            contentPadding: ActivityDimens.noPadding,
            leading: checkBox,
            title: CustomTextLabel.normal(this.text),
            onTap: ()
            => _onChanged(!val)
        );

        if (onRename != null && context != null && theme != null)
        {
            listTile = ContextMenuListener<_CheckableItemContextMenu>(
                child: listTile,
                menuName: this.text,
                menuItems: [Pair(Strings.pref_item_update, _CheckableItemContextMenu.EDIT)],
                onItemSelected: (BuildContext c, _CheckableItemContextMenu m)
                => _onContextItemSelected(c, theme, m, this)
            );
        }
        return ReorderableItem(key: Key(this.code), child: listTile);
    }

    static void _onContextItemSelected(final BuildContext context, final ThemeData theme,
        final _CheckableItemContextMenu m, final CheckableItem item)
    {
        if (m != _CheckableItemContextMenu.EDIT)
        {
            return;
        }

        final _alias = TextEditingController();
        _alias.text = item.text;

        final Widget dialog = AlertDialog(
            title: CustomDialogTitle(Strings.pref_item_update, Drawables.drawer_edit_item),
            contentPadding: DialogDimens.contentPadding,
            content: CustomDialogEditField(_alias,
                textLabel: Strings.pref_item_name,
                isFocused: true),
            actions: <Widget>[
                TextButton(
                    child: Text(Strings.action_cancel.toUpperCase(), style: theme.textTheme.labelLarge),
                    onPressed: ()
                    {
                        Navigator.of(context).pop();
                    }),
                TextButton(
                    child: Text(Strings.action_ok.toUpperCase(), style: theme.textTheme.labelLarge),
                    onPressed: ()
                    {
                        if (item.onRename  != null)
                        {
                            item.onRename(_alias.text);
                        }
                        Navigator.of(context).pop();
                    }),
            ]
        );

        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext c) => Theme(data: theme, child: dialog)
        );
    }
}
