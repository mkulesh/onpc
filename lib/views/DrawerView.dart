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

import 'dart:math';

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
import "../iscp/state/MultiroomState.dart";
import "../utils/Logging.dart";
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
        FavoriteConnectionEditDialog.FAVORITE_CHANGE_EVENT,
    ];

    final BuildContext _appContext;

    DrawerView(this._appContext, final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.info(this, "rebuild widget");
        final ThemeData td = Theme.of(context);

        final Widget header = DrawerHeader(child: _buildDrawerHeader(context), decoration: BoxDecoration(color: td.primaryColor));

        final List<Widget> drawerItems = List<Widget>();
        {
            drawerItems.add(header);
            // Device
            drawerItems.add(CustomTextLabel.small(Strings.drawer_device, padding: DrawerDimens.labelPadding));
            drawerItems.add(_buildDrawerItem(
                context, Drawables.drawer_search, Strings.drawer_device_search, onTabListener: _showDeviceSearchDialog));
            drawerItems.add(_buildDrawerItem(
                context, Drawables.drawer_connect, Strings.drawer_device_connect, onTabListener: _showDeviceConnectDialog));

            // Zones
            drawerItems.add(CustomDivider());
            drawerItems.add(CustomTextLabel.small(Strings.drawer_group_zone, padding: DrawerDimens.labelPadding));
            state.receiverInformation.zones.forEach((z)
            {
                final bool active = state.getActiveZoneInfo.getId == z.getId;
                drawerItems.add(_buildDrawerItem(
                    context, Drawables.drawerZone(z.getId), z.getName, isSelected: active,
                    onTabListener: (context)
                    {
                        configuration.activeZone = stateManager.changeZone(z.getId);
                    }
                ));
            });

            // Multiroom
            final List<DeviceInfo> devices = state.multiroomState.getMultiroomDevices(
                configuration.favoriteConnections.getDevices, false);
            if (devices.length > 1 || configuration.favoriteConnections.getDevices.isNotEmpty)
            {
                drawerItems.add(CustomDivider());
                drawerItems.add(CustomTextLabel.small(Strings.drawer_multiroom, padding: DrawerDimens.labelPadding));
                for (int i = 0; i < min(devices.length, 6); i++)
                {
                    final DeviceInfo di = devices[i];
                    final BroadcastResponseMsg msg = di.responseMsg;
                    final String icon = di.isFavorite ? Drawables.drawer_favorite_device : Drawables.drawer_found_device;
                    drawerItems.add(_buildDrawerItem(
                        context, icon, di.getDeviceName(configuration.friendlyNames),
                        isSelected: stateManager.isMasterDevice(di),
                        editButton: di.isFavorite ? CustomImageButton.small(
                            Drawables.drawer_edit_item,
                            Strings.favorite_connection_edit,
                            onPressed: () => _showFavoriteConnectionEditDialog(context, msg, updateCallback),
                        ) : null,
                        onTabListener: (context)
                        {
                            stateManager.connect(msg.sourceHost, msg.getPort);
                        }
                    ));
                }
            }

            // Application
            drawerItems.add(CustomDivider());
            drawerItems.add(CustomTextLabel.small(Strings.drawer_device_application, padding: DrawerDimens.labelPadding));
            drawerItems.add(_buildDrawerItem(
                context, Drawables.drawer_app_settings, Strings.drawer_app_settings, onTabListener: _openConfiguration));
            drawerItems.add(_buildDrawerItem(
                context, Drawables.drawer_about, Strings.drawer_about, onTabListener: _openAboutScreen));
        }

        return Drawer(
            child: MediaQuery.removePadding(
                context: context,
                // Remove padding that corresponds to status bar height.
                removeTop: true,
                child: ListView(children: drawerItems))
        );
    }

    Widget _buildDrawerHeader(final BuildContext context)
    {
        final ThemeData td = Theme.of(context);

        final SvgPicture drawerHeaderImage = SvgPicture.asset(
            Drawables.drawer_header,
            color: td.accentColor,
            fit: BoxFit.fitHeight
        );

        return DrawerHeader(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.only(top: 16),
            child: Column(
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
                    CustomTextLabel.small(Strings.app_name,
                        color: td.accentColor, textAlign: TextAlign.center, bold: true),
                    CustomTextLabel.small(configuration.appVersion,
                        color: td.accentColor, textAlign: TextAlign.center),
                ],
            )
        );
    }

    Widget _buildDrawerItem(final BuildContext context, final String iconName, final String title,
        {bool isSelected = false, OnTabListener onTabListener, Widget editButton})
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
                    color: isSelected ? td.accentColor :
                    (td.brightness == Brightness.dark ? td.bottomAppBarColor : td.textTheme.subhead.color))
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

    void _showFavoriteConnectionEditDialog(final BuildContext context,
        final BroadcastResponseMsg msg, VoidCallback updateCallback)
    {
        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext c)
            => FavoriteConnectionEditDialog(viewContext, msg)
        );
    }

    void _openConfiguration(final BuildContext context)
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