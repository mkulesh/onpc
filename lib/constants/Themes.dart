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
import 'package:google_fonts/google_fonts.dart';

import "../Platform.dart";
import "Dimens.dart";
import "Strings.dart";

class BaseAppTheme
{
    final Brightness brightness; // dark or light
    final Color backgroundColor; // background for activities
    final Color primaryColor; // The color to use for the app bar's
    final Color primaryColorDark; // The color system status bar
    final Color accentColor; // Color of accent elements
    final Color textColor; // Color of normal text
    final Color textColorAppBar; // Color of text in the app bar
    final Color disabledColor; // Color of disabled elements
    final bool strong;

    BaseAppTheme({
        this.brightness,
        this.backgroundColor,
        this.primaryColor,
        this.primaryColorDark,
        this.accentColor,
        this.textColor,
        this.textColorAppBar,
        this.disabledColor,
        this.strong = false
    });

    ThemeData _getData()
    {
        final TextStyle mainStyle = Platform.isDesktop ? GoogleFonts.getFont('Roboto') : TextStyle();

        return ThemeData(
            brightness: brightness,
            primaryColor: primaryColor,
            primaryColorBrightness: Brightness.dark,
            primaryColorDark: primaryColorDark,
            accentColor: accentColor,
            canvasColor: brightness == Brightness.dark ? primaryColor : backgroundColor,
            scaffoldBackgroundColor: backgroundColor,
            bottomAppBarColor: textColorAppBar,
            dividerColor: primaryColor,
            disabledColor: disabledColor,
            backgroundColor: backgroundColor,
            toggleableActiveColor: accentColor,

            appBarTheme: AppBarTheme(
                color: strong ? backgroundColor : primaryColor,
                iconTheme: IconThemeData(color: textColorAppBar),
                elevation: ActivityDimens.elevation,
            ),

            tabBarTheme: TabBarTheme(
                labelStyle: mainStyle.copyWith(fontSize: ActivityDimens.secondaryFontSize),
                unselectedLabelStyle: mainStyle.copyWith(fontSize: ActivityDimens.secondaryFontSize),
            ),

            textTheme: TextTheme(
                // Title in activity and dialogs
                headline6: mainStyle.copyWith(color: textColor, fontSize: ActivityDimens.titleFontSize),
                // Main text in views, dialogs and drawer
                // Parameter names in the preference screen
                subtitle1: mainStyle.copyWith(color: textColor, fontSize: ActivityDimens.primaryFontSize, fontWeight: FontWeight.normal),
                // "Disabled" text in views, dialogs and drawer
                // Parameter descriptions in the preference screen
                bodyText2: mainStyle.copyWith(color: disabledColor, fontSize: ActivityDimens.secondaryFontSize),
                // Buttons
                button: mainStyle.copyWith(color: textColor, fontSize: ButtonDimens.textButtonFontSize),
            ),

            textSelectionTheme: TextSelectionThemeData(
                cursorColor: accentColor,
                selectionColor: accentColor,
            ),

            tooltipTheme:
                TooltipThemeData(waitDuration: Duration(seconds: 2)
            )
        );
    }

    static BaseAppTheme getTheme(final String name)
    {
        BaseAppTheme theme;
        switch (name)
        {
            case "black-lime":
                theme = ThemeBlackLime();
                break;
            case "dim-gray-cyan":
                theme = ThemeDimGrayCyan();
                break;
            case "dim-gray-yellow":
                theme = ThemeDimGrayYellow();
                break;
            case "gray-deep-purple":
                theme = ThemeGrayDeepPurple();
                break;
            case "indigo-orange":
                theme = ThemeIndigoOrange();
                break;
            case "teal-deep-orange":
                theme = ThemeTealDeepOrange();
                break;
            case "purple-green":
                theme = ThemePurpleGreen();
                break;
            default:
                theme = ThemeIndigoOrange();
                break;
        }
        return theme;
    }

    static ThemeData getThemeData(final String name, final String language, final String textSize)
    {
        Strings.setLanguage(language);
        DimensTransform.setScale(textSize);
        return getTheme(name)._getData();
    }
}

// Dark themes
class ThemeBlackLime extends BaseAppTheme
{
    ThemeBlackLime() : super(
        brightness: Brightness.dark,
        backgroundColor: Color(0xff000000),
        primaryColor: Color(0xff303030),
        primaryColorDark: Color(0xff000000),
        accentColor: Color(0xFFAFB42B),
        textColor: Color(0xFFFFFFFF),
        textColorAppBar: Color(0xfffafafa),
        disabledColor: Color(0xff757575),
        strong: true
    );
}

class ThemeDimGrayCyan extends BaseAppTheme
{
    ThemeDimGrayCyan() : super(
        brightness: Brightness.dark,
        backgroundColor: Color(0xff303030),
        primaryColor: Color(0xff424242),
        primaryColorDark: Color(0xff303030),
        accentColor: Color(0xFF0097A7),
        textColor: Color(0xffffffff),
        textColorAppBar: Color(0xfffafafa),
        disabledColor: Color(0xffb0b0b0)
    );
}

class ThemeDimGrayYellow extends BaseAppTheme
{
    ThemeDimGrayYellow() : super(
        brightness: Brightness.dark,
        backgroundColor: Color(0xff303030),
        primaryColor: Color(0xff424242),
        primaryColorDark: Color(0xff303030),
        accentColor: Color(0xFFFBC02D),
        textColor: Color(0xffffffff),
        textColorAppBar: Color(0xfffafafa),
        disabledColor: Color(0xffb0b0b0)
    );
}

// Light themes
class ThemeGrayDeepPurple extends BaseAppTheme
{
    ThemeGrayDeepPurple() : super(
        brightness: Brightness.light,
        backgroundColor: Color(0xFFFAFAFA),
        primaryColor: Color(0xFF9E9E9E),
        primaryColorDark: Color(0xFF616161),
        accentColor: Color(0xFF7C4DFF),
        textColor: Color(0xFF212121),
        textColorAppBar: Color(0xFFFFFFFF),
        disabledColor: Color(0xFF757575)
    );
}

class ThemeTealDeepOrange extends BaseAppTheme
{
    ThemeTealDeepOrange() : super(
        brightness: Brightness.light,
        backgroundColor: Color(0xFFFAFAFA),
        primaryColor: Color(0xFF009688),
        primaryColorDark: Color(0xFF00796B),
        accentColor: Color(0xFFFF5722),
        textColor: Color(0xFF212121),
        textColorAppBar: Color(0xFFFFFFFF),
        disabledColor: Color(0xFF757575)
    );
}

class ThemeIndigoOrange extends BaseAppTheme
{
    ThemeIndigoOrange() : super(
        brightness: Brightness.light,
        backgroundColor: Color(0xFFFAFAFA),
        primaryColor: Color(0xFF3F51B5),
        primaryColorDark: Color(0xFF303F9F),
        accentColor: Color(0xFFFF9800),
        textColor: Color(0xFF212121),
        textColorAppBar: Color(0xFFFFFFFF),
        disabledColor: Color(0xFF757575)
    );
}

class ThemePurpleGreen extends BaseAppTheme
{
    ThemePurpleGreen() : super(
        brightness: Brightness.light,
        backgroundColor: Color(0xFFFAFAFA),
        primaryColor: Color(0xFFccbada),
        primaryColorDark: Color(0xFF785a9f),
        accentColor: Color(0xFF388e3c),
        textColor: Color(0xFF47296f),
        textColorAppBar: Color(0xFFFFFFFF),
        disabledColor: Color(0xFF6e6e6e)
    );
}
