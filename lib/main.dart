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

import 'dart:async';
import 'dart:typed_data';

import "package:back_button_interceptor/back_button_interceptor.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:flutter/scheduler.dart" show timeDilation;
import "package:flutter/services.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:package_info/package_info.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:xml/xml.dart" as xml;

import "Platform.dart";
import "config/Configuration.dart";
import "config/DeviceSelectors.dart";
import "config/ListeningModes.dart";
import "config/NetworkServices.dart";
import "config/PreferencesMain.dart";
import "constants/Activities.dart";
import "constants/Dimens.dart";
import "constants/Strings.dart";
import "constants/Themes.dart";
import "dialogs/CustomPopupDialog.dart";
import "dialogs/DeviceSearchDialog.dart";
import "iscp/ISCPMessage.dart";
import "iscp/StateManager.dart";
import "iscp/messages/CustomPopupMsg.dart";
import "iscp/messages/OperationCommandMsg.dart";
import "iscp/messages/ReceiverInformationMsg.dart";
import "iscp/messages/TimeInfoMsg.dart";
import "utils/Logging.dart";
import "views/AboutScreen.dart";
import "views/AppBarView.dart";
import "views/DrawerView.dart";
import "views/TabDeviceView.dart";
import "views/TabListenView.dart";
import "views/TabMediaView.dart";
import "views/TabRemoteControlView.dart";
import "views/TabRemoteInterfaceView.dart";
import "views/UpdatableView.dart";

void main() async
{
    debugPaintSizeEnabled = Logging.isVisualLayout;

    // Will slow down animations by this factor
    timeDilation = 1.0;

    WidgetsFlutterBinding.ensureInitialized();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final Configuration configuration = Configuration(prefs, packageInfo);
    configuration.read();

    final ViewContext viewContext = ViewContext(configuration, StateManager(), StreamController.broadcast());

    runApp(MaterialApp(title: Strings.app_short_name,
        theme: BaseAppTheme.getThemeData(
            configuration.theme, configuration.language, configuration.textSize),
        home: MusicControllerApp(viewContext),
        routes: <String, WidgetBuilder> {
            Activities.activity_preferences: (BuildContext context) => PreferencesMain(configuration),
            Activities.activity_device_selectors: (BuildContext context) => DeviceSelectors(configuration),
            Activities.activity_listening_modes: (BuildContext context) => ListeningModes(configuration),
            Activities.activity_network_services: (BuildContext context) => NetworkServices(configuration),
            Activities.activity_about_screen: (BuildContext context) => AboutScreen(configuration, viewContext.state.receiverInformation.xml),
        }));
}

class MusicControllerApp extends StatefulWidget
{
    final ViewContext _viewContext;

    MusicControllerApp(this._viewContext, {Key key}) : super(key: key);

    @override
    MusicControllerAppState createState()
    => MusicControllerAppState(_viewContext);
}

class MusicControllerAppState extends State<MusicControllerApp>
    with WidgetsBindingObserver, TickerProviderStateMixin
{
    final ViewContext _viewContext;
    TabController _tabController;
    bool _exitConfirm;

    MusicControllerAppState(this._viewContext);

    Configuration get _configuration
    => _viewContext.configuration;

    StateManager get _stateManager
    => _viewContext.stateManager;

    final List<AppTabs> _tabs = List();

    @override
    void initState()
    {
        super.initState();
        BackButtonInterceptor.add(_onBackPressed);

        _applyConfiguration(informPlatform: false);

        _stateManager.autoPower = _configuration.autoPower;
        _stateManager.addListeners(_onStateChanged, _onOutputMessage, _showToast);
        _exitConfirm = false;
        WidgetsBinding.instance.addObserver(this);
        defaultBinaryMessenger.setMessageHandler(Platform.PLATFORM_CHANNEL, (ByteData message) async
        {
            final PlatformCmd cmd = Platform.readPlatformCommand(message);
            if (cmd == PlatformCmd.NETWORK_STATE)
            {
                _processNetworkStateChange(message);
            }
            else if (_configuration.volumeKeys && _stateManager.isConnected)
            {
                if (cmd == PlatformCmd.VOLUME_UP)
                {
                    _stateManager.changeMasterVolume(_configuration.soundControl, true);
                }
                if (cmd == PlatformCmd.VOLUME_DOWN)
                {
                    _stateManager.changeMasterVolume(_configuration.soundControl, false);
                }
            }
            return null;
        });

        if (_configuration.isDeviceValid)
        {
            Platform.requestNetworkState().then((replay)
            {
                _processNetworkStateChange(replay);
            });
        }
        else
        {
            WidgetsBinding.instance.addPostFrameCallback((_)
            => _stateManager.triggerStateEvent(StateManager.START_SEARCH_EVENT));
        }
    }

    @override
    void dispose()
    {
        WidgetsBinding.instance.removeObserver(this);
        _viewContext.updateNotifier.close();
        _tabController.dispose();
        BackButtonInterceptor.remove(_onBackPressed);
        super.dispose();
    }

    @override
    void didChangeAppLifecycleState(AppLifecycleState state)
    {
        Logging.info(this.widget, "Application state change: " + state.toString());
        if (state == AppLifecycleState.resumed)
        {
            Platform.requestNetworkState().then((replay)
            {
                _processNetworkStateChange(replay);
            });
        }
        else
        {
            _disconnect();
        }
    }

    @override
    Widget build(BuildContext context)
    {
        Logging.info(this.widget, "Rebuild widget");

        final ThemeData td = BaseAppTheme.getThemeData(
            _configuration.theme, _configuration.language, _configuration.textSize);

        final UpdatableAppBarWidget appBarView = UpdatableAppBarWidget(context,
            AppBarView(_viewContext, _tabController, _tabs)
        );

        final Widget tabBar = TabBarView(
            controller: _tabController,
            children: _tabs.map((AppTabs tab)
            {
                Widget tabContent;
                switch (tab)
                {
                    case AppTabs.LISTEN:
                        tabContent = UpdatableWidget(
                            child: TabListenView(_viewContext));
                        break;
                    case AppTabs.MEDIA:
                        tabContent = UpdatableWidget(
                            child: TabMediaView(_viewContext));
                        break;
                    case AppTabs.DEVICE:
                        tabContent = UpdatableWidget(
                            child: TabDeviceView(_viewContext));
                        break;
                    case AppTabs.RC:
                        tabContent = UpdatableWidget(
                            child: TabRemoteControlView(_viewContext));
                        break;
                    case AppTabs.RI:
                        tabContent = UpdatableWidget(
                            child: TabRemoteInterfaceView(_viewContext));
                        break;
                }
                return Container(
                    margin: ActivityDimens.activityMargins(context),
                    child: tabContent
                );
            }).toList(),
        );

        final double appBarHeight = ActivityDimens.appBarHeight(context) + ActivityDimens.tabBarHeight(context);

        final Widget scaffold = Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(appBarHeight), // desired height of appBar + tabBar
                child: appBarView),
            drawer: UpdatableWidget(child: DrawerView(context, _viewContext)),
            body: tabBar
        );

        return Theme(data: td, child: scaffold);
    }

    void _onStateChanged(Set<String> changes)
    {
        if (!changes.every((c) => c == TimeInfoMsg.CODE))
        {
            Logging.info(this.widget, "Event changes: " + changes.toString());
        }
        changes.forEach((c)
        {
            switch (c)
            {
                case Configuration.CONFIGURATION_EVENT:
                    setState(()
                    {
                        _configuration.read();
                        _applyConfiguration(informPlatform: true);
                    });
                    break;
                case StateManager.START_SEARCH_EVENT:
                    _startSearch();
                    break;
                case StateManager.CONNECTION_EVENT:
                    if (_stateManager.isConnected)
                    {
                        _configuration.saveDevice(_stateManager.sourceHost, _stateManager.sourcePort);
                        _configuration.setReceiverInformation(_viewContext.state.receiverInformation);
                        _stateManager.startSearch(limited: true);
                    }
                    break;
                case ReceiverInformationMsg.CODE:
                    if (_stateManager.isConnected)
                    {
                        _configuration.setReceiverInformation(_viewContext.state.receiverInformation);
                    }
                    break;
                case CustomPopupMsg.CODE:
                    _onPopup();
                    break;
            }
        });

        _viewContext.updateNotifier.sink.add(changes);
    }

    void _startSearch()
    {
        Platform.requestNetworkState().then((replay)
        {
            final NetworkState n = Platform.parseNetworkState(replay);
            _stateManager.networkState = n;
            _stateManager.startSearch(limited: false);
            showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext c)
                => DeviceSearchDialog(_viewContext)
            );
        });
    }

    void _connectToDevice(final NetworkState n)
    {
        if (!_stateManager.isConnected && _configuration.isDeviceValid)
        {
            Logging.info(this.widget, "Use stored connection data: "
                + _configuration.getDeviceName + "/" + _configuration.getDevicePort.toString());
            _stateManager.connect(_configuration.getDeviceName, _configuration.getDevicePort);
        }
    }

    void _disconnect()
    {
        _stateManager.disconnect(false);
        _stateManager.stopSearch();
    }

    void _onOutputMessage(ISCPMessage msg)
    {
        // Switch tabs on OperationCommand.MENU
        if (msg is OperationCommandMsg && msg.getValue.key == OperationCommand.MENU)
        {
            _tabController.index = 1;
        }
    }

    void _showToast(String msg)
    {
        Fluttertoast.showToast(
            msg: msg,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 3
        );
    }

    bool _onBackPressed(bool stopDefaultButtonEvent)
    {
        if (Navigator.canPop(context))
        {
            // For pushed activities we always allow back
            return false;
        }
        // Processing on "Back" button
        final AppTabs tab = AppTabs.values[_tabController.index];
        final bool isTop = _viewContext.state.mediaListState.isTopLayer();
        Logging.info(this.widget, "pressed back button, tab=" + tab.toString() + ", top=" + isTop.toString());
        if (tab == AppTabs.MEDIA && !isTop && _configuration.backAsReturn)
        {
            _stateManager.sendMessage(StateManager.commandReturnMsg, waitingForData: true);
            return true;
        }
        else if (_configuration.exitConfirm)
        {
            if (!_exitConfirm)
            {
                _exitConfirm = true;
                _showToast(Strings.action_exit_confirm);
                Timer(Duration(seconds: 3), ()
                {
                    _exitConfirm = false;
                });
                return true;
            }
            else
            {
                Fluttertoast.cancel();
            }
        }
        return false;
    }

    void _onPopup()
    {
        final String simplePopupMessage = _viewContext.state.retrieveSimplePopupMessage();
        if (simplePopupMessage != null)
        {
            _showToast(simplePopupMessage);
            return;
        }

        final xml.XmlDocument popupDocument = _viewContext.state.retrievePopup();
        if (popupDocument != null)
        {
            showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext c)
                => CustomPopupDialog(_viewContext, popupDocument)
            );
        }
    }

    void _processNetworkStateChange(final ByteData state)
    {
        final NetworkState n = Platform.parseNetworkState(state);
        _stateManager.networkState = n;
        switch(n)
        {
        case NetworkState.NONE:
            _disconnect();
            setState(()
            {
                _stateManager.state.clear();
            });
            _showToast(Strings.error_connection_no_network);
            break;
        case NetworkState.CELLULAR:
        case NetworkState.WIFI:
            if (!_stateManager.isConnected)
            {
              _connectToDevice(n);
            }
            break;
        }
    }

    void _applyConfiguration({bool informPlatform = false})
    {
        // Update tabs
        int _index = 0;
        if (_tabController != null)
        {
            _index = _tabController.index;
        }
        _tabs.clear();
        _tabs.add(AppTabs.LISTEN);
        _tabs.add(AppTabs.MEDIA);
        _tabs.add(AppTabs.DEVICE);
        _tabs.add(AppTabs.RC);
        if (_configuration.riAmp || _configuration.riCd)
        {
            _tabs.add(AppTabs.RI);
        }

        if (_tabController == null || _tabs.length != _tabController.length)
        {
            _tabController = TabController(vsync: this, length: _tabs.length);
            _tabController.index = _index < _tabs.length ? _index : _tabs.length - 1;
        }

        // Inform state manager about configuration change
        _stateManager.keepPlaybackMode = _configuration.keepPlaybackMode;

        // Inform platform code about configuration change.
        // Depending on new setting, app may be restarted by platform code here
        if (informPlatform)
        {
            Platform.sendPlatformCommand(_configuration.volumeKeys ?
                PlatformCmd.VOLUME_KEYS_ENABLED : PlatformCmd.VOLUME_KEYS_DISABLED);
            Platform.sendPlatformCommand(_configuration.keepScreenOn ?
                PlatformCmd.KEEP_SCREEN_ON_ENABLED : PlatformCmd.KEEP_SCREEN_ON_DISABLED);
        }
    }
}
