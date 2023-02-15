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
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../constants/Dimens.dart';
import '../utils/Logging.dart';
import 'CustomTextButton.dart';

class TextButtonScroll extends StatefulWidget
{
    final List<CustomTextButton> _items;
    final CustomTextButton _selected;
    TextButtonScroll(this._items, this._selected);

    @override
    _TextButtonScrollState createState()
    => _TextButtonScrollState();
}

class _TextButtonScrollState extends State<TextButtonScroll>
{
    ScrollController _scrollController;

    _TextButtonScrollState();

    @override
    void initState()
    {
        super.initState();
        _scrollController = ScrollController();
    }

    @override
    void dispose()
    {
        _scrollController.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context)
    {
        Logging.logRebuild(this.widget);

        double left = 0, width = 0, sumWidth = 0;
        widget._items.forEach((element)
        {
            final double _width = element.getWidth(context);
            if (element == widget._selected)
            {
                left = sumWidth;
                width = _width;
            }
            sumWidth += _width;
        });

        final Widget scroll = SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: ActivityDimens.noPadding,
            child: Row(children: widget._items));

        if (left >= 0 && width > 0)
        {
            WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToPosition(left, width));
        }

        return scroll;
    }

    void _scrollToPosition(double left, double width)
    {
        final double right = left + width;
        if (_scrollController.hasClients && _scrollController.position != null)
        {
            if (left < _scrollController.position.pixels)
            {
                _scrollController.jumpTo(left);
            }
            else if (right > _scrollController.position.pixels + _scrollController.position.viewportDimension)
            {
                _scrollController.jumpTo(right - _scrollController.position.viewportDimension);
            }
        }
    }
}