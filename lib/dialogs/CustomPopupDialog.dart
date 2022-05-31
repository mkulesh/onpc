/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2022 by Mikhail Kulesh
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
import "package:flutter/material.dart";
import "package:xml/xml.dart" as xml;

import "../constants/Dimens.dart";
import "../iscp/messages/CustomPopupMsg.dart";
import "../iscp/messages/EnumParameterMsg.dart";
import "../iscp/messages/ServiceType.dart";
import "../utils/Logging.dart";
import "../utils/Pair.dart";
import "../views/UpdatableView.dart";
import "../widgets/CustomDialogTitle.dart";
import "../widgets/CustomTextField.dart";
import "../widgets/CustomTextLabel.dart";

class CustomPopupDialog extends StatefulWidget
{
    final ViewContext _viewContext;
    final void Function() _onDispose;

    static const List<String> UPDATE_TRIGGERS = [
        CustomPopupMsg.CODE
    ];

    CustomPopupDialog(this._viewContext, this._onDispose);

    @override _CustomPopupDialogState createState()
    => _CustomPopupDialogState(_viewContext, UPDATE_TRIGGERS);
}

class _CustomPopupDialogState extends WidgetStreamState<CustomPopupDialog>
{
    xml.XmlDocument _popupDocument;
    String _popupText = "";
    xml.XmlElement _popupElement;
    String _dialogTitle;
    final List<Pair<xml.XmlElement, TextEditingController>> _textFields = [];

    _CustomPopupDialogState(final ViewContext _viewContext, final List<String> _updateTriggers): super(_viewContext, _updateTriggers);

    void _initData()
    {
        _popupDocument = state.popupDocument;
        final String newText = _popupDocument.toString();
        if (_popupText == newText)
        {
            return;
        }

        _popupText = newText;
        _popupElement = _popupDocument.findElements("popup").first;
        _dialogTitle = _popupElement.getAttribute("title");

        _textFields.clear();
        _popupElement.findElements("textboxgroup").forEach((group)
        {
            group.findElements("textbox").forEach((textBox)
            {
                final xml.XmlAttribute attr = textBox.getAttributeNode("value");
                if (attr != null)
                {
                    final TextEditingController field = TextEditingController();
                    final String defValue = _getDefaultValue(textBox);
                    field.text = (defValue != null) ? defValue : attr.text;
                    _textFields.add(Pair(textBox, field));
                }
            });
        });

        Logging.info(this.widget, "initialize popup: " + _dialogTitle + " with " + _textFields.length.toString() + " fields");
    }

    @override
    void initState()
    {
        super.initState();
        _initData();
    }

    @override
    void dispose()
    {
        super.dispose();
        _textFields.forEach((t) => t.item2.dispose());
        widget._onDispose();
    }

    @override
    Widget createView(BuildContext context, VoidCallback _updateCallback)
    {
        _initData();
        Logging.logRebuild(this.widget);

        final ThemeData td = viewContext.getThemeData();

        Widget _content;
        try
        {
            _content = _buildContent(td, context);
        }
        on Exception catch (e)
        {
            _content = Text("Cannot create dialog: " + e.toString());
        }

        final Widget dialog = AlertDialog(
            title: CustomDialogTitle(_dialogTitle, viewContext.state.getServiceIcon()),
            contentPadding: DialogDimens.contentPadding,
            content: _content,
        );

        return Theme(data: td, child: dialog);
    }

    Widget _buildContent(final ThemeData td, BuildContext context)
    {
        PopupUiType uiType;

        final List<Widget> elements = [];

        // labels
        _popupElement.findElements("label").forEach((label)
        {
            label.findElements("line").forEach((line)
                => elements.add(CustomTextLabel.normal(line.getAttribute("text"))));
        });

        // text boxes
        bool isFocused = true;
        _textFields.forEach((t)
        {
            elements.add(CustomTextLabel.small(t.item1.getAttribute("text")));
            elements.add(CustomTextField(t.item2, isFocused: isFocused));
            uiType = PopupUiType.KEYBOARD;
            isFocused = false;
        });

        // buttons
        _popupElement.findElements("buttongroup").forEach((group)
        {
            group.findElements("button").forEach((button)
            {
                if (uiType == null)
                {
                    uiType = PopupUiType.POPUP;
                }
                elements.add(_createButton(td, context, button, uiType));
            });
        });

        return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: elements
        );
    }

    Widget _createButton(final ThemeData td, BuildContext context, final xml.XmlElement button, final PopupUiType uiType)
    {
        final Widget btn = MaterialButton(
            child: CustomTextLabel.normal(button.getAttribute("text")),
            color: td.canvasColor,
            elevation: 1,
            minWidth: 0,
            onPressed: ()
            {
                _processButton(button, uiType);
                Navigator.of(context).pop();
            }
        );

        final Widget row = Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Expanded(child: btn)]
        );

        return Padding(padding: DialogDimens.rowPadding, child: row);
    }

    void _processButton(final xml.XmlElement button, final PopupUiType uiType)
    {
        try
        {
            _textFields.forEach((t)
            {
                t.item1.getAttributeNode("value").value = t.item2.text;
            });
            button.getAttributeNode("selected").value = "true";
            Logging.info(this.widget, "new doc: " + _popupDocument.toXmlString());
            viewContext.stateManager.sendMessage(CustomPopupMsg.output(uiType, _popupDocument));
        }
        on Exception catch (e)
        {
            Logging.info(this.widget, "cannot build new popup: " + e.toString());
        }
    }

    String _getDefaultValue(final xml.XmlElement box)
    {
        final EnumItem<ServiceType> _serviceType = viewContext.state.mediaListState.serviceType;
        final String _artist = viewContext.state.trackState.artist;
        if (_serviceType != null && _serviceType.key == ServiceType.DEEZER &&
            _artist != null && _artist.isNotEmpty &&
            box.getAttribute("text") == "Search")
        {
            return _artist.contains("(") ? _artist.substring(0, _artist.indexOf("(")).trim() : _artist.trim();
        }
        return null;
    }
}