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

import "../config/Configuration.dart";
import "../constants/Dimens.dart";
import "../constants/Strings.dart";
import "../constants/Themes.dart";
import "../utils/Logging.dart";
import "../widgets/CustomActivityTitle.dart";
import "../widgets/CustomDivider.dart";

enum AboutScreenTabs
{
    ABOUT, RECEIVER, LOGGING
}

class AboutScreen extends StatefulWidget
{
    final Configuration _configuration;
    final String _receiverInformation;

    AboutScreen(this._configuration, this._receiverInformation, {Key key}) : super(key: key);

    @override
    AboutScreenState createState()
    => AboutScreenState(_configuration, _receiverInformation);
}

class AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin
{
    final Configuration _configuration;
    final String _receiverInformation;
    final List<AboutScreenTabs> _tabs = [AboutScreenTabs.ABOUT, AboutScreenTabs.RECEIVER, AboutScreenTabs.LOGGING];
    TabController _tabController;

    AboutScreenState(this._configuration, this._receiverInformation);

    @override
    initState()
    {
        _tabController = TabController(vsync: this, length: _tabs.length);
        super.initState();
    }

    @override
    Widget build(BuildContext context)
    {
        final ThemeData td = BaseAppTheme.getThemeData(
            _configuration.theme, _configuration.language, _configuration.textSize);

        final double tabBarHeight = ActivityDimens.tabBarHeight(context);
        final Widget tabBar = TabBarView(
            controller: _tabController,
            children: _tabs.map((AboutScreenTabs tab)
            {
                Widget tabContent;
                switch (tab)
                {
                    case AboutScreenTabs.ABOUT:
                        tabContent = _buildMarkdownView(td, Strings.about_text);
                        break;
                    case AboutScreenTabs.RECEIVER:
                        tabContent = _buildTextView(td, _receiverInformation);
                        break;
                    case AboutScreenTabs.LOGGING:
                        tabContent = _buildTextView(td, Logging.getLatestLogging());
                        break;
                }
                return Container(
                    margin: ActivityDimens.activityMargins(context),
                    child: tabContent
                );
            }).toList(),
        );

        final Widget scaffold = Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(ActivityDimens.appBarHeight(context) + tabBarHeight), // desired height of appBar + tabBar
                child: _buildAppBar(td, tabBarHeight)),
            body: tabBar
        );

        return Theme(data: td, child: scaffold);
    }

    @override
    void dispose()
    {
        _tabController.dispose();
        super.dispose();
    }

    Widget _buildAppBar(final ThemeData td, final double tabBarHeight)
    {
        final List<String> TAB_NAMES = [
            Strings.drawer_about,
            Strings.menu_receiver_information,
            Strings.menu_latest_logging
        ];

        final Widget tabBar = Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
                CustomDivider(color: td.primaryColorDark.withAlpha(175)),
                TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: td.bottomAppBarColor,
                    unselectedLabelColor: td.bottomAppBarColor.withAlpha(175),
                    tabs: _tabs.map((AboutScreenTabs tab)
                    => Tab(text: TAB_NAMES[tab.index].toUpperCase())).toList(),
                )
            ]
        );

        return AppBar(
            title: CustomActivityTitle(Strings.drawer_about, null),
            bottom: PreferredSize(
                preferredSize: Size.fromHeight(tabBarHeight), // desired height of tabBar
                child: SizedBox(height: tabBarHeight, child: tabBar))
        );
    }

    Widget _buildTextView(final ThemeData td, final String data)
    {
        return SingleChildScrollView(child:
            SelectableText(data,
                style: td.textTheme.body1.copyWith(color: td.textTheme.subhead.color))
        );
    }

    Widget _buildMarkdownView(final ThemeData td, final String data)
    {
        final MarkdownStyleSheet styleSheet = MarkdownStyleSheet.fromTheme(td).copyWith(
            h1: td.textTheme.subhead.copyWith(fontWeight: FontWeight.bold),
            h2: td.textTheme.subhead.copyWith(fontWeight: FontWeight.bold),
            p: td.textTheme.body1.copyWith(color: td.textTheme.subhead.color),
            a: td.textTheme.body1.copyWith(color: td.accentColor),
        );
        return Markdown(
            data: data,
            styleSheet: styleSheet,
            padding: ActivityDimens.noPadding,
            onTapLink: (String href)
            {
                Logging.info(this, "Pressed " + href);
                _launchURL(href);
            });
    }

    _launchURL(final String url) async
    {
        if (await canLaunch(url))
        {
            await launch(url);
        }
    }
}