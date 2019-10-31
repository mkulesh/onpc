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

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import "../constants/Dimens.dart";
import "../constants/Strings.dart";
import "../utils/Logging.dart";
import "../widgets/CustomActivityTitle.dart";

class AboutScreen extends StatelessWidget
{
    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = Theme.of(context);

        final MarkdownStyleSheet styleSheet = MarkdownStyleSheet.fromTheme(td).copyWith(
            h1: td.textTheme.subhead.copyWith(fontWeight: FontWeight.bold),
            h2: td.textTheme.subhead.copyWith(fontWeight: FontWeight.bold),
            p: td.textTheme.body1.copyWith(color: td.textTheme.subhead.color),
            a: td.textTheme.body1.copyWith(color: td.accentColor),
        );

        return Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(ActivityDimens.appBarHeight(context)), // desired height of appBar + tabBar
                child: AppBar(title: CustomActivityTitle(Strings.drawer_about, null))),
            body: Markdown(
                data: Strings.about_text,
                styleSheet: styleSheet,
                onTapLink: (String href)
                {
                    Logging.info(this, "Pressed " + href);
                    _launchURL(href);
                })
        );
    }

    _launchURL(final String url) async
    {
        if (await canLaunch(url))
        {
            await launch(url);
        }
    }
}