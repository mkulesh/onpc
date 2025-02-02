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
import "package:google_fonts/google_fonts.dart";

import "../constants/Dimens.dart";
import "../iscp/messages/DeviceDisplayMsg.dart";
import "../utils/Logging.dart";
import "UpdatableView.dart";

class DeviceDisplayView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        DeviceDisplayMsg.CODE
    ];

    DeviceDisplayView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.logRebuild(this);

        if (state.receiverInformation.deviceDisplayValue.isEmpty)
        {
            return SizedBox.shrink();
        }

        final ThemeData td = Theme.of(context);

        TextStyle textStyle = td.textTheme.titleMedium!;
        try
        {
            textStyle = GoogleFonts.getFont('DotGothic16',
                fontSize: ActivityDimens.titleFontSize,
                letterSpacing: 3.0,
                color: td.iconTheme.color);
        }
        catch (ex)
        {
            Logging.info(this, ex.toString());
        }

        final Widget text = Container(
            padding: ActivityDimens.deviceDisplayPadding,
            margin: DialogDimens.rowPadding,
            decoration: BoxDecoration(
                border: Border.all(color: td.disabledColor)
            ),
            alignment: Alignment.centerLeft,
            child: Text(state.receiverInformation.deviceDisplayValue, style: textStyle, textAlign: TextAlign.start),
        );

        final Widget field = InkWell(child: text,
            onTap: () => stateManager.sendQueries([DeviceDisplayMsg.CODE])
        );

        return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [ Expanded(child: field, flex: 1) ]
        );
    }
}