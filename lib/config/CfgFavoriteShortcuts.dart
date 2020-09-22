/*
 * Copyright (C) 2020. Mikhail Kulesh
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU
 * General License as published by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
 * even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General License for more details. You should have received a copy of the GNU General
 * License along with this program.
 */

import 'dart:math';

import "package:shared_preferences/shared_preferences.dart";
import "package:xml/xml.dart" as xml;

import "../iscp/ISCPMessage.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/EnumParameterMsg.dart";
import "../iscp/messages/InputSelectorMsg.dart";
import "../iscp/messages/ServiceType.dart";
import "../utils/Logging.dart";
import "../utils/Pair.dart";
import "CfgModule.dart";

class Shortcut
{
    static String FAVORITE_SHORTCUT_TAG = "favoriteShortcut";

    int _id;

    int get id
    => _id;

    EnumItem<InputSelector> _input;

    EnumItem<InputSelector> get input
    => _input;

    EnumItem<ServiceType> _service;

    EnumItem<ServiceType> get service
    => _service;

    String _item;

    String get item
    => _item;

    String _alias;

    String get alias
    => _alias;

    final List<String> _pathItems = List();

    List<String> get pathItems
    => _pathItems;

    Shortcut.fromXml(xml.XmlElement e)
    {
        _id = ISCPMessage.nonNullInteger(e.getAttribute("id"), 10, 0);
        _input = InputSelectorMsg.ValueEnum.valueByCode(ISCPMessage.nonNullString(e.getAttribute("input")));
        _service = Services.ServiceTypeEnum.valueByCode(ISCPMessage.nonNullString(e.getAttribute("service")));
        _item = ISCPMessage.nonNullString(e.getAttribute("item"));
        _alias = ISCPMessage.nonNullString(e.getAttribute("alias"));
        e.findAllElements("dir").forEach((dir) => _pathItems.add(ISCPMessage.nonNullString(dir.getAttribute("name"))));
    }

    Shortcut.copy(final Shortcut old, final String alias)
    {
        this._id = old._id;
        this._input = old._input;
        this._service = old._service;
        this._item = old._item;
        this._alias = alias;
        this._pathItems.addAll(old._pathItems);
    }

    Shortcut(final int id, final EnumItem<InputSelector> input, final EnumItem<ServiceType> service, final String item, final String alias)
    {
        this._id = id;
        this._input = input;
        this._service = service;
        this._item = item;
        this._alias = alias;
    }

    void setPathItems(final List<String> path)
    {
        _pathItems.clear();
        for (int i = 1; i < path.length; i++)
        {
            _pathItems.add(path[i]);
        }
    }

    @override
    String toString()
    {
        String label = "";
        label += "<" + FAVORITE_SHORTCUT_TAG;
        label += " id=\"" + _id.toString() + "\"";
        label += " input=\"" + _input.getCode + "\"";
        label += " service=\"" + _service.getCode + "\"";
        label += " item=\"" + _item + "\"";
        label += " alias=\"" + _alias + "\">";
        for (String dir in _pathItems)
        {
            label += "<dir name=\"" + dir + "\"/>";
        }
        label += "</" + FAVORITE_SHORTCUT_TAG + ">";
        return label.toString();
    }

    String getLabel()
    {
        String label = "";
        if (_input.key != InputSelector.NONE)
        {
            label += _input.description + "/";
        }
        if (_input.key == InputSelector.NET && _service.key != ServiceType.UNKNOWN)
        {
            label += _service.description + "/";
        }
        _pathItems.forEach((dir) => label += dir + "/");
        label += _item;
        return label.toString();
    }
}

class CfgFavoriteShortcuts extends CfgModule
{
    static const Pair<String, int> FAVORITE_SHORTCUT_NUMBER = Pair<String, int>("favorite_shortcut_number", 0);
    static String FAVORITE_SHORTCUT_ITEM = "favorite_shortcut_item";
    final List<Shortcut> _shortcuts = List();

    // methods
    CfgFavoriteShortcuts(SharedPreferences preferences) : super(preferences);

    @override
    void read()
    {
        _shortcuts.clear();
        final int fcNumber = getInt(FAVORITE_SHORTCUT_NUMBER, doLog: true);
        for (int i = 0; i < fcNumber; i++)
        {
            final Pair<String, String> key = Pair<String, String>(FAVORITE_SHORTCUT_ITEM + "_" + i.toString(), "");
            final String val = getString(key, doLog: true);
            try
            {
                final xml.XmlDocument document = xml.XmlDocument.parse(val);
                document.findAllElements(Shortcut.FAVORITE_SHORTCUT_TAG).forEach((xml.XmlElement e)
                => _shortcuts.add(Shortcut.fromXml(e)));
            }
            on Exception catch (e)
            {
                Logging.info(this, "can not create shortcut: " + e.toString());
            }
        }
    }

    @override
    void setReceiverInformation(StateManager stateManager)
    {
        // empty
    }

    void write()
    {
        final int fcNumber = _shortcuts.length;
        preferences.setInt(FAVORITE_SHORTCUT_NUMBER.item1, fcNumber);
        for (int i = 0; i < fcNumber; i++)
        {
            final String key = FAVORITE_SHORTCUT_ITEM + "_" + i.toString();
            preferences.setString(key, _shortcuts[i].toString());
        }
    }

    List<Shortcut> get shortcuts
    => _shortcuts;

    int _find(final int id)
    {
        for (int i = 0; i < _shortcuts.length; i++)
        {
            final Shortcut item = _shortcuts[i];
            if (item._id == id)
            {
                return i;
            }
        }
        return -1;
    }

    Shortcut updateShortcut(final Shortcut shortcut, final String alias)
    {
        Shortcut newMsg;
        final int idx = _find(shortcut._id);
        if (idx >= 0)
        {
            final Shortcut oldMsg = _shortcuts[idx];
            newMsg = Shortcut.copy(oldMsg, alias);
            Logging.info(this, "Update favorite shortcut: " + oldMsg.toString() + " -> " + newMsg.toString());
            _shortcuts[idx] = newMsg;
        }
        else
        {
            newMsg = Shortcut.copy(shortcut, alias);
            Logging.info(this, "Add favorite shortcut: " + newMsg.toString());
            _shortcuts.add(newMsg);
        }
        write();
        return newMsg;
    }

    void deleteShortcut(final Shortcut shortcut)
    {
        final int idx = _find(shortcut._id);
        if (idx >= 0)
        {
            final Shortcut oldMsg = _shortcuts[idx];
            Logging.info(this, "Delete favorite shortcut: " + oldMsg.toString());
            _shortcuts.remove(oldMsg);
            write();
        }
    }

    int getNextId()
    {
        int id = 0;
        shortcuts.forEach((s) => id = max(id, s.id));
        return id + 1;
    }

    void reorder(int oldIndex, int newIndex)
    {
        final Shortcut item = shortcuts.removeAt(oldIndex);
        shortcuts.insert(newIndex, item);
        write();
    }
}
