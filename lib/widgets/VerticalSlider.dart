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

import "../constants/Dimens.dart";
import "../widgets/CustomProgressBar.dart";
import "CustomTextLabel.dart";

class VerticalSlider extends StatelessWidget
{
    final String caption;
    final int currValue;
    final int maxValueNum;
    final int divisions;
    final NewValueCallback onChanged;

    VerticalSlider({
        required this.caption,
        required this.currValue,
        required this.maxValueNum,
        required this.divisions,
        required this.onChanged
    });

    @override
    Widget build(BuildContext context)
    {
        final Widget slider = RotatedBox(
            quarterTurns: 3,
            child: CustomProgressBar(
                minValueStr: "",
                maxValueStr: "",
                maxValueNum: maxValueNum,
                currValue: currValue,
                divisions: divisions,
                onChanged: onChanged
            )
        );

        return Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                Expanded(child: slider),
                SizedBox(
                    width: VerticalSliderDimens.sliderWidth,
                    child: CustomTextLabel.small(caption, textAlign: TextAlign.center)
                )
            ]
        );
    }
}