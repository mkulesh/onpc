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

import "../config/TextLabelStyle.dart";
import "../constants/Dimens.dart";
import "../constants/Strings.dart";
import "../dialogs/TextLabelStyleDialog.dart";
import "../utils/Pair.dart";
import "../views/UpdatableView.dart";
import "ContextMenuListener.dart";

enum _CustomTextLabelContextMenu
{
    STYLE
}

class CustomTextLabel extends StatelessWidget
{
    final String description;
    final EdgeInsetsGeometry padding;
    final TextAlign textAlign;
    final int size;
    final bool bold;
    final bool underline;
    final Color? color;
    final ViewContext? viewContext;
    final TextLabelParName? parName;

    CustomTextLabel.small(this.description,
    {
        this.padding = ActivityDimens.noPadding,
        this.textAlign = TextAlign.left,
        this.size = 1,
        this.bold = false,
        this.underline = false,
        this.color,
        this.viewContext,
        this.parName
    });

    CustomTextLabel.normal(this.description,
    {
        this.padding = ActivityDimens.noPadding,
        this.textAlign = TextAlign.left,
        this.size = 2,
        this.bold = false,
        this.underline = false,
        this.color,
        this.viewContext,
        this.parName
    });

    CustomTextLabel.adaptive(this.description, this.viewContext, this.parName,
    {
        this.padding = ActivityDimens.noPadding,
        this.textAlign = TextAlign.center,
        this.size = 2,
        this.bold = false,
        this.underline = false,
        this.color
    });

    bool get isAdaptive
    => viewContext != null && parName != null;

    FontWeight _fontWeight(final TextLabelStyle? cfgStyle)
    {
        final bool b = cfgStyle != null ? cfgStyle.bold : bold;
        return b ? FontWeight.bold : FontWeight.normal;
    }

    FontStyle _fontStyle(final TextLabelStyle? cfgStyle)
    => cfgStyle != null && cfgStyle.italic ? FontStyle.italic : FontStyle.normal;

    double _fontSize(final TextStyle style, final TextLabelStyle? cfgStyle)
    => cfgStyle != null ? style.fontSize! * cfgStyle.doubleScale : style.fontSize!;

    Color _fontColor(final TextStyle style)
    => this.color ?? style.color!;

    TextDecoration? _fontDecoration(final TextLabelStyle? cfgStyle)
    => cfgStyle != null && cfgStyle.underline ? TextDecoration.underline : null;

    List<Shadow>? _getShadows(final TextLabelStyle? cfgStyle, final ThemeData td)
    {
        if (cfgStyle != null && cfgStyle.shadow)
        {
            return [
                Shadow(
                    offset: Offset(2.0, 3),
                    blurRadius: 6.0,
                    color: td.disabledColor.withAlpha((255.0 * 0.75).round())
                ),
            ];
        }
        return null;
    }

    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = Theme.of(context);

        final TextStyle defStyle = size == 1 ? td.textTheme.bodyMedium! : td.textTheme.titleMedium!;

        final TextLabelStyle? cfgStyle = isAdaptive ?
            viewContext!.configuration.appSettings.getTextLabelStyle(parName!) : null;

        final TextStyle targetStyle = defStyle.copyWith(
            fontSize: _fontSize(defStyle, cfgStyle),
            fontWeight: _fontWeight(cfgStyle),
            fontStyle: _fontStyle(cfgStyle),
            color: _fontColor(defStyle),
            decoration: _fontDecoration(cfgStyle),
            shadows: _getShadows(cfgStyle, td)
        );

        final Widget t1 = Text(description, style: targetStyle, textAlign: textAlign, softWrap: true);
        final Widget t2 = (padding.vertical > 0 || padding.horizontal > 0) ? Padding(padding: padding, child: t1) : t1;
        final Widget t3 = cfgStyle != null ? ContextMenuListener<_CustomTextLabelContextMenu>(
            child: t2,
            menuItems: [Pair(Strings.pref_text_style, _CustomTextLabelContextMenu.STYLE)],
            onItemSelected: (BuildContext c, _CustomTextLabelContextMenu m)
            {
                if (viewContext != null && parName != null && m == _CustomTextLabelContextMenu.STYLE)
                {
                    viewContext!.showRootDialog(context, TextLabelStyleDialog(viewContext!, parName!, cfgStyle));
                }
            }
        ) : t2;

        if (underline)
        {
            return Container(
                padding: EdgeInsets.symmetric(vertical: DimensTransform.scale(1.0)),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: td.textTheme.titleMedium!.color!))),
                child: t3);
        }
        else
        {
            return t3;
        }
    }
}