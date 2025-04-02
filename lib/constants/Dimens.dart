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

class DimensTransform
{
    static double deviceScaleFactor = 1.0;
    static double scaleFactor = 1.0;
    static double switchScaleFactor = 1.0;

    static T rotate<T>(BuildContext context, T port, T land)
    {
        return MediaQuery
            .of(context)
            .orientation == Orientation.portrait ? port : land;
    }

    static double scale(double d)
    => d * scaleFactor;

    static void setScale(String textSize)
    {
        switch (textSize)
        {
            case "small": scaleFactor = 0.85; break;
            case "normal": scaleFactor = 1.0; break;
            case "big": scaleFactor = 1.15; break;
            case "huge": scaleFactor = 1.3; break;
            default: scaleFactor = deviceScaleFactor; break;
        }
    }
}

class ActivityDimens
{
    static const double elevation = 3.0;

    // AppBar
    static const double _appBarHeightPort = 56.0;
    static const double _appBarHeightLand = 46.0;

    static double appBarHeight(BuildContext context)
    => DimensTransform.rotate(context, _appBarHeightPort, _appBarHeightLand);

    // TabBar
    // Note that a Tab has fixed height _kTabHeight + indicatorWeight (46 + 2 points);
    // i.e this height shall greater than this parameter
    static const double _tabBarHeightPort = 48;
    static const double _tabBarHeightLand = 48;

    static double tabBarHeight(BuildContext context)
    => 1.0 /* divider height*/ + DimensTransform.rotate(context, _tabBarHeightPort, _tabBarHeightLand);

    // Activity margins
    static double get activityMarginStep
    => DimensTransform.scale(8.0);

    // Fonts: title text
    static double get titleFontSize
    => DimensTransform.scale(18);

    // Fonts: primary text
    static double get primaryFontSize
    => DimensTransform.scale(18);

    // Fonts: secondary text
    static double get secondaryFontSize
    => DimensTransform.scale(15);

    static double get progressBarHeight
    => DimensTransform.scale(36.0);

    static double get progressBarRadius
    => DimensTransform.scale(8.0);

    // Cover image
    static double get _coverImagePadding
    => DimensTransform.scale(5);

    static EdgeInsetsGeometry coverImagePadding(BuildContext context)
    => EdgeInsets.all(DimensTransform.rotate(context, _coverImagePadding, _coverImagePadding));

    static EdgeInsetsGeometry get headerPadding
    => EdgeInsets.symmetric(vertical: DimensTransform.scale(10));

    static EdgeInsetsGeometry get headerPaddingTop
    => EdgeInsets.only(top: DimensTransform.scale(10));

    static EdgeInsetsGeometry get deviceDisplayPadding
    => EdgeInsets.symmetric(horizontal: DimensTransform.scale(24), vertical: DimensTransform.scale(6));

    static const EdgeInsets noPadding
    = EdgeInsets.all(0);
}

class DrawerDimens
{
    static EdgeInsetsGeometry get iconPadding
    => EdgeInsets.only(left: DimensTransform.scale(8), right: DimensTransform.scale(16));

    static EdgeInsetsGeometry get labelPadding
    => EdgeInsets.symmetric(horizontal: DimensTransform.scale(16), vertical: DimensTransform.scale(8));

    static EdgeInsetsGeometry get itemPadding
    => EdgeInsets.symmetric(horizontal: DimensTransform.scale(16), vertical: DimensTransform.scale(8));
}

class ButtonDimens
{
    // App bar menu button (is not scalable)
    static const double menuButtonSize = 26.0;

    // Small button (like in DEVICE ta)
    static double get smallButtonSize
    => DimensTransform.scale(26.0);

    // Normal button
    static double get normalButtonSize
    => DimensTransform.scale(28.0);

    // Big button (like in RC tab)
    static double get bigButtonSize
    => DimensTransform.scale(48.0);

    // Default padding used instead of material offsets
    static EdgeInsetsGeometry get imgButtonPadding
    => EdgeInsets.symmetric(horizontal: DimensTransform.scale(12), vertical: DimensTransform.scale(8));

    // Text buttons
    static double get textButtonFontSize
    => DimensTransform.scale(15);

    static EdgeInsetsGeometry get textButtonPadding
    => EdgeInsets.symmetric(horizontal: DimensTransform.scale(12), vertical: DimensTransform.scale(10));

    static EdgeInsetsGeometry get smallButtonPadding
    => EdgeInsets.all(DimensTransform.scale(4));
}

class ListDimens
{
    // Padding of media item
    static double get horizontalPadding
    => DimensTransform.scale(6);

    static EdgeInsets verticalPadding(final String textSize)
    {
        final double s = 16 * (DimensTransform.scaleFactor - 0.85);
        return EdgeInsets.symmetric(vertical: DimensTransform.scale(s));
    }
}

class DialogDimens
{
    // Icon size
    static double get iconSize
    => DimensTransform.scale(26.0);

    // Icon padding
    static EdgeInsetsGeometry get iconPadding
    => EdgeInsets.only(right: DimensTransform.scale(8));

    // padding of dialog content
    static EdgeInsets get contentPadding
    => EdgeInsets.symmetric(horizontal: DimensTransform.scale(24.0), vertical: DimensTransform.scale(12.0));

    // padding of a row
    static EdgeInsetsGeometry get rowPadding
    => EdgeInsets.symmetric(vertical: DimensTransform.scale(8.0));

    // Top and bottom padding of TextField
    static EdgeInsetsGeometry get textFieldPadding
    => EdgeInsets.symmetric(
        vertical: DimensTransform.scale(8.0),
        horizontal: DimensTransform.scale(0));
}

class ControlViewDimens
{
    // The height of the device image
    static double get imageWidth
    => DimensTransform.scale(300.0);
}

class VerticalSliderDimens
{
    static double get sliderWidth
    => DimensTransform.scale(42.0);

    static EdgeInsetsGeometry get sliderGroupPaddingAll
    => EdgeInsets.all(DimensTransform.scale(8.0));

    static EdgeInsetsGeometry get sliderGroupPaddingVer
    => EdgeInsets.symmetric(vertical: DimensTransform.scale(8.0));

    static EdgeInsetsGeometry get labelPadding
    => EdgeInsets.symmetric(vertical: DimensTransform.scale(6.0));
}