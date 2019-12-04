/*
 * Copyright (C) 2019. Mikhail Kulesh
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

import "package:flutter/cupertino.dart";
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
    final xml.XmlDocument _popupDocument;

    CustomPopupDialog(this._viewContext, this._popupDocument);

    @override _CustomPopupDialogState createState()
    => _CustomPopupDialogState(_viewContext, _popupDocument);
}

class _CustomPopupDialogState extends State<CustomPopupDialog>
{
    final ViewContext _viewContext;
    final xml.XmlDocument _popupDocument;
    final xml.XmlElement _popupElement;

    _CustomPopupDialogState(this._viewContext, this._popupDocument) :
            _popupElement = _popupDocument.findElements("popup").first;

    EnumItem<ServiceType> _serviceType;
    String _artist;
    String _dialogTitle;
    final List<Pair<xml.XmlElement, TextEditingController>> _textFields = List();

    @override
    void initState()
    {
        super.initState();
        _serviceType = _viewContext.state.mediaListState.serviceType;
        _artist = _viewContext.state.trackState.artist;
        _dialogTitle = _popupElement.getAttribute("title");
        Logging.info(this, "received popup: " + _dialogTitle);

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
    }

    @override
    void dispose()
    {
        _textFields.forEach((t) => t.item2.dispose());
        super.dispose();
    }

    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = _viewContext.getThemeData();

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
            title: CustomDialogTitle(_dialogTitle, _viewContext.state.getServiceIcon()),
            contentPadding: DialogDimens.contentPadding,
            content: _content,
        );

        return Theme(data: td, child: dialog);
    }

    Widget _buildContent(final ThemeData td, BuildContext context)
    {
        PopupUiType uiType;

        final List<Widget> elements = List();

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
            Logging.info(this, "new doc: " + _popupDocument.toXmlString());
            _viewContext.stateManager.sendMessage(CustomPopupMsg.output(uiType, _popupDocument));
        }
        on Exception catch (e)
        {
            Logging.info(this, "cannot build new popup: " + e.toString());
        }
    }

    String _getDefaultValue(final xml.XmlElement box)
    {
        if (_serviceType != null && _serviceType.key == ServiceType.DEEZER &&
            _artist != null && _artist.isNotEmpty &&
            box.getAttribute("text") == "Search")
        {
            return _artist.contains("(") ? _artist.substring(0, _artist.indexOf("(")) : _artist.trim();
        }
        return null;
    }
}