/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2023 by Mikhail Kulesh
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
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import "../Platform.dart";
import "../constants/Dimens.dart";
import "../constants/Strings.dart";
import "../iscp/messages/ReceiverInformationMsg.dart";
import "../utils/Logging.dart";
import "../widgets/CustomActivityTitle.dart";
import "../widgets/CustomDivider.dart";
import "../widgets/CustomTextButton.dart";
import "UpdatableView.dart";

enum AboutScreenTabs
{
    ABOUT, RECEIVER, LOGGING
}

class AboutScreen extends StatefulWidget
{
    final ViewContext _viewContext;

    static const List<String> UPDATE_TRIGGERS = [
        ReceiverInformationMsg.CODE
    ];

    AboutScreen(this._viewContext);

    @override
    AboutScreenState createState()
    => AboutScreenState(_viewContext, UPDATE_TRIGGERS);
}

class AboutScreenState extends WidgetStreamState<AboutScreen>
    with SingleTickerProviderStateMixin
{
    final List<AboutScreenTabs> _tabs = [AboutScreenTabs.ABOUT, AboutScreenTabs.RECEIVER, AboutScreenTabs.LOGGING];
    TabController _tabController;

    AboutScreenState(final ViewContext _viewContext, final List<String> _updateTriggers): super(_viewContext, _updateTriggers);

    @override
    void initState()
    {
        super.initState();
        _tabController = TabController(vsync: this, length: _tabs.length);
    }

    @override
    void dispose()
    {
        _tabController.dispose();
        super.dispose();
    }

    @override
    Widget createView(BuildContext context, VoidCallback _updateCallback)
    {
        final ThemeData td = viewContext.getThemeData();

        double tabBarHeight = 0;
        Widget scaffoldBody;
        if (configuration.developerMode)
        {
            tabBarHeight = ActivityDimens.tabBarHeight(context);
            scaffoldBody = TabBarView(
                controller: _tabController,
                children: _tabs.map((AboutScreenTabs tab)
                {
                    Widget tabContent;
                    switch (tab)
                    {
                        case AboutScreenTabs.ABOUT:
                            tabContent = _buildMarkdownView(td, Strings.about_text, ActivityDimens.noPadding);
                            break;
                        case AboutScreenTabs.RECEIVER:
                            tabContent = _buildTextView(td, state.receiverInformation.xml);
                            break;
                        case AboutScreenTabs.LOGGING:
                            tabContent = _buildTextView(td, Logging.getLatestLogging());
                            break;
                    }
                    return Container(
                        margin: ActivityDimens.activityMargins(context, Platform.isIOS, Platform.isAndroid),
                        child: tabContent
                    );
                }).toList(),
            );
        }
        else
        {
            scaffoldBody = _buildMarkdownView(
                td, Strings.about_text, ActivityDimens.activityMargins(context, Platform.isIOS, Platform.isAndroid));
        }

        final Widget scaffold = Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(ActivityDimens.appBarHeight(context) + tabBarHeight), // desired height of appBar + tabBar
                child: _buildAppBar(td, tabBarHeight)),
            body: scaffoldBody
        );

        return Theme(data: td, child: scaffold);
    }

    Widget _buildAppBar(final ThemeData td, final double tabBarHeight)
    {
        if (tabBarHeight == 0)
        {
            return AppBar(title: CustomActivityTitle(Strings.drawer_about, null));
        }

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
        final Widget text = Expanded(flex: 1, child:
            SingleChildScrollView(child: SelectableText(data,
                style: td.textTheme.bodyText2.copyWith(color: td.textTheme.subtitle1.color),
                toolbarOptions: ToolbarOptions(selectAll: true, copy: true),
                showCursor: true))
        );

        final Widget copyButton = CustomTextButton(
            Strings.favorite_copy_to_clipboard,
            isEnabled: true,
            onPressed: ()
            {
                Clipboard.setData(ClipboardData(text: data));
            }
        );

        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                text,
                CustomDivider(height: 1),
                Row(mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [copyButton])
            ]
        );
    }

    Widget _buildMarkdownView(final ThemeData td, final String data, final EdgeInsetsGeometry padding)
    {
        final MarkdownStyleSheet styleSheet = MarkdownStyleSheet.fromTheme(td).copyWith(
            h1: td.textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
            h2: td.textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
            p: td.textTheme.bodyText2.copyWith(color: td.textTheme.subtitle1.color),
            a: td.textTheme.bodyText2.copyWith(color: td.colorScheme.secondary));
        return Markdown(data: data,
            styleSheet: styleSheet,
            padding: padding,
            onTapLink: (String text, String href, String title)
            {
                if (href != null)
                {
                    _launchURL(href);
                }
            });
    }

    static void _launchURL(final String url) async
    {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri))
        {
            await launchUrl(uri);
        }
    }
}