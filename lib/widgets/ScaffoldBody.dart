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

import "../constants/Dimens.dart";
import "../utils/Platform.dart";

class ScaffoldBody extends StatelessWidget
{
    final Widget body;
    final bool defMargins;

    ScaffoldBody(this.body, {this.defMargins = true});

    @override
    Widget build(BuildContext context)
    {
        final double step = defMargins ? ActivityDimens.activityMarginStep : 0;
        final bool portrait = MediaQuery.of(context).orientation == Orientation.portrait;
        if (Platform.isDesktop)
        {
            final EdgeInsets margins = defMargins ?
                EdgeInsets.only(left: 2 * step, right: 2 * step, top: step, bottom: 2 * step) : ActivityDimens.noPadding;
            return Container(margin: margins, child: body);
        }
        else if (portrait) // portrait orientation on mobile
        {
            final EdgeInsets margins = defMargins ?
                EdgeInsets.only(left: step, right: step, top: 0, bottom: step) : ActivityDimens.noPadding;
            return SafeArea(child: Container(margin: margins, child: body), minimum : EdgeInsets.all(step));
        }
        else // landscape orientation on mobile
        {
            final EdgeInsets margins = defMargins ?
                EdgeInsets.symmetric(horizontal: step) : ActivityDimens.noPadding;
            return SafeArea(child: Container(margin: margins, child: body), minimum : EdgeInsets.all(step));
        }
    }
}