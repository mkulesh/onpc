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
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

class CustomDivider extends StatelessWidget
{
    final Color color;
    final double height;
    final double thickness;

    CustomDivider({this.color, this.height = 1, this.thickness = 0.3});

    @override
    Widget build(BuildContext context)
    {
        final Color c = this.color ?? Theme.of(context).disabledColor;
        return Divider(height: height, thickness: thickness, color: c);
    }
}