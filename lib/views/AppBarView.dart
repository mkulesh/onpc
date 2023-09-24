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

import "package:flutter/material.dart";

import "../config/CfgAppSettings.dart";
import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/FriendlyNameMsg.dart";
import "../iscp/messages/PowerStatusMsg.dart";
import "../iscp/messages/ReceiverInformationMsg.dart";
import "../utils/Logging.dart";
import "../utils/Platform.dart";
import "../widgets/CustomActivityTitle.dart";
import "../widgets/CustomDialogTitle.dart";
import "../widgets/CustomDivider.dart";
import "../widgets/CustomImageButton.dart";
import "../widgets/CustomTextLabel.dart";
import "UpdatableView.dart";

class AppBarView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        StateManager.CONNECTION_EVENT,
        StateManager.ZONE_EVENT,
        ReceiverInformationMsg.CODE,
        FriendlyNameMsg.CODE,
        PowerStatusMsg.CODE
    ];

    final TabController _tabController;
    final List<AppTabs> _tabs;

    AppBarView(final ViewContext viewContext, this._tabController, this._tabs) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.logRebuild(this);
        final ThemeData td = Theme.of(context);

        // Logo
        String? subTitle = "";
        if (!state.isConnected)
        {
            subTitle = Strings.state_not_connected;
        }
        else
        {
            subTitle = state.receiverInformation.getDeviceName(configuration.friendlyNames);
            if (subTitle.isEmpty)
            {
                subTitle = stateManager.getConnection().getHostAndPort;
            }
            if (state.isExtendedZone && state.getActiveZoneInfo != null)
            {
                if (subTitle.isNotEmpty)
                {
                    subTitle += "/";
                }
                subTitle += state.getActiveZoneInfo!.getName;
            }
            if (!state.isOn)
            {
                subTitle += " (" + Strings.state_standby + ")";
            }
        }

        final double tabBarHeight = ActivityDimens.tabBarHeight(context);

        final PreferredSizeWidget? tabBar = configuration.appSettings.isSingleTab ? null : PreferredSize(
            preferredSize: Size.fromHeight(tabBarHeight), // desired height of tabBar
            child: SizedBox(
                height: tabBarHeight,
                child: _buildTabs(td))
        );

        final String title = Platform.isDesktop ? subTitle : Strings.app_short_name;
        if (Platform.isDesktop)
        {
            subTitle = null;
        }

        return AppBar(
            title: CustomActivityTitle(title, subTitle),
            actions: <Widget>[
                CustomImageButton.menu(Drawables.menu_power_standby, Strings.menu_power_standby,
                    isEnabled: state.isConnected,
                    isSelected: !state.isOn,
                    onPressed: ()
                    => _powerOnOff(context)),
            ],
            bottom: tabBar
        );
    }

    void _powerOnOff(BuildContext context)
    {
        Logging.info(this, "App bar menu: " + Strings.menu_power_standby);
        final PowerStatus p = state.isOn ? PowerStatus.STB : PowerStatus.ON;
        final PowerStatusMsg cmdMsg = PowerStatusMsg.output(state.getActiveZone, p);
        if (state.isOn && stateManager.isMultiroomAvailable() && stateManager.sourceDevice!.isMasterDevice)
        {
            final ThemeData td = Theme.of(context);
            final Widget dialog = AlertDialog(
                title: CustomDialogTitle(Strings.menu_power_standby, Drawables.menu_power_standby),
                contentPadding: DialogDimens.contentPadding,
                content: CustomTextLabel.normal(Strings.menu_switch_off_group),
                actions: <Widget>[
                    TextButton(
                        child: Text(Strings.action_cancel.toUpperCase(), style: td.textTheme.labelLarge),
                        onPressed: ()
                        {
                            Navigator.of(context).pop();
                        }
                    ),
                    TextButton(
                        child: Text(Strings.action_no.toUpperCase(), style: td.textTheme.labelLarge),
                        onPressed: ()
                        {
                            Navigator.of(context).pop();
                            stateManager.sendMessage(cmdMsg);
                        }
                    ),
                    TextButton(
                        child: Text(Strings.action_ok.toUpperCase(), style: td.textTheme.labelLarge),
                        onPressed: ()
                        {
                            Navigator.of(context).pop();
                            stateManager.sendMessageToGroup(cmdMsg);
                        }
                    )
                ]
            );

            showDialog(
                context: context,
                builder: (BuildContext context)
                => dialog);
        }
        else
        {
            stateManager.sendMessage(cmdMsg);
        }
    }

    Widget _buildTabs(final ThemeData td)
    {
        return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
                CustomDivider(color: td.primaryColorDark.withAlpha(175)),
                TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabs: _tabs.map((AppTabs tab)
                    {
                        final String tabName = CfgAppSettings.getTabName(tab);
                        return Tab(text: tabName.toUpperCase());
                    }).toList(),
                )
            ]
        );
    }
}