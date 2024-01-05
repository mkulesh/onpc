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
import "package:flutter_svg/svg.dart";

import "../config/Configuration.dart";
import "../constants/Activities.dart";
import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../dialogs/DeviceConnectDialog.dart";
import "../dialogs/FavoriteConnectionEditDialog.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/BroadcastResponseMsg.dart";
import "../iscp/messages/FriendlyNameMsg.dart";
import "../iscp/messages/PowerStatusMsg.dart";
import "../iscp/messages/ReceiverInformationMsg.dart";
import "../iscp/state/MultiroomState.dart";
import "../utils/Logging.dart";
import "../utils/Platform.dart";
import "../views/UpdatableView.dart";
import "../widgets/CustomDivider.dart";
import "../widgets/CustomImageButton.dart";
import "../widgets/CustomTextLabel.dart";


typedef OnTabListener = void Function(BuildContext context);

class DrawerView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        BroadcastResponseMsg.CODE,
        FriendlyNameMsg.CODE,
    ];

    final BuildContext _appContext;
    final WidgetBuilder tabLayoutBuilder;

    DrawerView(this._appContext, this.tabLayoutBuilder, final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.logRebuild(this);
        FocusScope.of(context).unfocus();

        final Widget header = _buildDrawerHeader(context);

        final List<Widget> drawerItems = [];
        {
            drawerItems.add(header);
            // Device
            drawerItems.add(CustomTextLabel.small(Strings.drawer_device, padding: DrawerDimens.labelPadding));
            drawerItems.add(_buildDrawerItem(
                context, Drawables.cmd_search, Strings.drawer_device_search, onTabListener: _showDeviceSearchDialog));
            drawerItems.add(_buildDrawerItem(
                context, Drawables.drawer_connect, Strings.drawer_device_connect, onTabListener: _showDeviceConnectDialog));

            // Zones
            drawerItems.add(CustomDivider());
            drawerItems.add(CustomTextLabel.small(Strings.drawer_group_zone, padding: DrawerDimens.labelPadding));
            state.receiverInformation.zones.forEach((z)
            {
                final bool active = (state.getActiveZoneInfo != null) ?
                    state.getActiveZoneInfo!.getId == z.getId : false;
                drawerItems.add(_buildDrawerItem(
                    context, Drawables.drawerZone(z.getId), z.getName, isSelected: active,
                    onTabListener: (context)
                    {
                        configuration.activeZone = stateManager.changeZone(z.getId);
                    }
                ));
            });
            if (state.receiverInformation.zones.length > 1)
            {
                drawerItems.add(_buildDrawerItem(
                    context,
                    Drawables.drawer_all_standby,
                    Strings.drawer_all_standby,
                    onTabListener: _navigationAllStandby
                ));
            }

            // Multiroom
            final List<DeviceInfo> devices = state.multiroomState.getSortedDevices();
            final int favorites = devices.where((d) => d.isFavorite).length;
            if (devices.length > 1 || favorites > 0)
            {
                drawerItems.add(CustomDivider());
                drawerItems.add(CustomTextLabel.small(Strings.drawer_multiroom, padding: DrawerDimens.labelPadding));
                for (final DeviceInfo di in devices)
                {
                    final BroadcastResponseMsg msg = di.responseMsg;
                    final String icon = di.isFavorite ? Drawables.drawer_favorite_device : Drawables.drawer_found_device;
                    drawerItems.add(_buildDrawerItem(
                        context, icon, di.getDeviceName(configuration.friendlyNames),
                        isSelected: stateManager.isMasterDevice(di),
                        editButton: di.isFavorite ? CustomImageButton.small(
                            Drawables.drawer_edit_item,
                            Strings.favorite_connection_edit,
                            onPressed: () => _showFavoriteConnectionEditDialog(context, msg),
                        ) : null,
                        onTabListener: (context)
                        {
                            stateManager.connect(msg.getHost, msg.getPort);
                        }
                    ));
                }
            }

            // Application
            drawerItems.add(CustomDivider());
            drawerItems.add(CustomTextLabel.small(Strings.drawer_application, padding: DrawerDimens.labelPadding));
            if (configuration.appSettings.visibleTabs.isNotEmpty)
            {
                drawerItems.add(_buildDrawerItem(
                    context, Drawables.drawer_tab_layout, Strings.drawer_tab_layout, onTabListener: _openTabLayout));
            }
            drawerItems.add(_buildDrawerItem(
                context, Drawables.drawer_app_settings, Strings.drawer_app_settings, onTabListener: _openAppSettings));
            drawerItems.add(_buildDrawerItem(
                context, Drawables.drawer_about, Strings.drawer_about, onTabListener: _openAboutScreen));
        }

        return Drawer(
            child: MediaQuery.removePadding(
                context: context,
                // Remove padding that corresponds to status bar height.
                removeTop: true,
                child: ListView(children: drawerItems, controller: ScrollController()))
        );
    }

    Widget _buildDrawerHeader(final BuildContext context)
    {
        final ThemeData td = Theme.of(context);

        final SvgPicture drawerHeaderImage = SvgPicture.asset(
            Drawables.drawer_header,
            color: td.colorScheme.secondary,
            fit: BoxFit.fitHeight
        );

        Widget content = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                Expanded(
                    child: Container(
                        padding: ActivityDimens.noPadding,
                        child: FittedBox(
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                            child: drawerHeaderImage)
                    )
                ),
                CustomTextLabel.small(Strings.app_name_pro,
                    color: td.colorScheme.secondary, textAlign: TextAlign.center, bold: true),
                CustomTextLabel.small(configuration.appVersion,
                    color: td.colorScheme.secondary, textAlign: TextAlign.center),
            ],
        );

        if (Platform.isDesktop)
        {
            content = InkWell(child: content, onTap: () => Navigator.pop(context));
        }

        return DrawerHeader(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.only(top: 16, bottom: 8),
            decoration: BoxDecoration(color: td.primaryColor),
            child: content
        );
    }

    Widget _buildDrawerItem(final BuildContext context, final String iconName, final String title,
        {bool isSelected = false, OnTabListener? onTabListener, Widget? editButton})
    {
        final ThemeData td = Theme.of(context);
        final Widget item = InkWell(child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
                CustomImageButton.small(
                    iconName, title,
                    padding: DrawerDimens.iconPadding,
                    isEnabled: false,
                ),
                Expanded(child: CustomTextLabel.small(title,
                    color: isSelected ? td.colorScheme.secondary :
                    (td.brightness == Brightness.dark ? td.bottomAppBarTheme.color : td.textTheme.titleMedium!.color))
                )
            ]),
            onTap: ()
            {
                Logging.info(this, "Drawer menu: " + title);
                Navigator.pop(context);
                if (onTabListener != null)
                {
                    onTabListener(_appContext);
                }
            }
        );

        if (editButton == null)
        {
            return Padding(
                padding: DrawerDimens.itemPadding,
                child: item
            );
        }
        else
        {
            return Padding(
                padding: DrawerDimens.itemPadding,
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [Expanded(child: item), editButton]
                )
            );
        }
    }

    void _showDeviceSearchDialog(final BuildContext context)
    {
        stateManager.triggerStateEvent(StateManager.START_SEARCH_EVENT);
    }

    void _showDeviceConnectDialog(final BuildContext context)
    {
        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext c)
            => DeviceConnectDialog(viewContext)
        );
    }

    void _navigationAllStandby(BuildContext context)
    {
        if (state.isConnected)
        {
            stateManager.sendMessage(PowerStatusMsg.output(
                ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE, PowerStatus.ALL_STB));
        }
    }

    void _showFavoriteConnectionEditDialog(final BuildContext context, final BroadcastResponseMsg msg)
    {
        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext c)
            => FavoriteConnectionEditDialog(viewContext, msg)
        );
    }

    void _openTabLayout(final BuildContext context)
    {
        Navigator.push(context,MaterialPageRoute(builder: tabLayoutBuilder)).then((_)
        {
            stateManager.triggerStateEvent(Configuration.CONFIGURATION_EVENT);
        });
    }

    void _openAppSettings(final BuildContext context)
    {
        Navigator.pushNamed(context, Activities.activity_preferences).then((_)
        {
            stateManager.triggerStateEvent(Configuration.CONFIGURATION_EVENT);
        });
    }

    void _openAboutScreen(final BuildContext context)
    {
        Navigator.pushNamed(context, Activities.activity_about_screen);
    }
}