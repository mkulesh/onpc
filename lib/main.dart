/*
 * Enhanced Controller for Onkyo and Pioneer Pro
 * Copyright (C) 2019-2021 by Mikhail Kulesh
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
import 'dart:async';
import 'dart:typed_data';

import "package:back_button_interceptor/back_button_interceptor.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:flutter/scheduler.dart" show timeDilation;
import "package:flutter/services.dart";
import "package:shared_preferences/shared_preferences.dart";

import "Platform.dart";
import "config/CfgAppSettings.dart";
import "config/CfgTabSettings.dart";
import "config/Configuration.dart";
import "config/DeviceSelectors.dart";
import "config/ListeningModes.dart";
import "config/NetworkServices.dart";
import "config/PreferencesMain.dart";
import "config/TabLayoutLandscape.dart";
import "config/TabLayoutPortrait.dart";
import "config/VisibleTabs.dart";
import "constants/Activities.dart";
import "constants/Dimens.dart";
import "constants/Strings.dart";
import "dialogs/DeviceSearchDialog.dart";
import "dialogs/PopupManager.dart";
import "iscp/StateManager.dart";
import "iscp/messages/CustomPopupMsg.dart";
import "iscp/messages/ReceiverInformationMsg.dart";
import "iscp/messages/TimeInfoMsg.dart";
import "utils/Convert.dart";
import "utils/Logging.dart";
import "views/AboutScreen.dart";
import "views/AppBarView.dart";
import "views/AppTabView.dart";
import "views/DrawerView.dart";
import "views/UpdatableView.dart";

void main() async
{
    debugPaintSizeEnabled = Logging.isVisualLayout;

    // Will slow down animations by this factor
    timeDilation = 1.0;

    WidgetsFlutterBinding.ensureInitialized();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Configuration configuration = Configuration(prefs);
    configuration.read();

    final StateManager stateManager = StateManager(configuration.favoriteConnections.getDevices);
    final ViewContext viewContext = ViewContext(configuration, stateManager, StreamController.broadcast());

    runApp(MaterialApp(
        debugShowCheckedModeBanner: Logging.isDebugBanner,
        title: Strings.app_short_name,
        theme: viewContext.getThemeData(),
        home: MusicControllerApp(viewContext),
        localeResolutionCallback: (Locale locale, Iterable<Locale> supportedLocales)
        {
            if (locale != null)
            {
                configuration.appSettings.systemLocale = locale;
            }
            return CfgAppSettings.DEFAULT_LOCALE;
        },
        routes: <String, WidgetBuilder>
        {
            Activities.activity_preferences: (BuildContext context) => PreferencesMain(configuration),
            Activities.activity_visible_tabs: (BuildContext context) => VisibleTabs(configuration),
            Activities.activity_device_selectors: (BuildContext context) => DeviceSelectors(configuration),
            Activities.activity_listening_modes: (BuildContext context) => ListeningModes(configuration),
            Activities.activity_network_services: (BuildContext context) => NetworkServices(configuration),
            Activities.activity_about_screen: (BuildContext context) => AboutScreen(viewContext),
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

enum ConnectionState
{
    NONE,
    CONNECTING_TO_SAVED,
    CONNECTING_TO_INTENT,
    CONNECTING_TO_ANY,
    CONNECTED
}

class MusicControllerAppState extends State<MusicControllerApp>
    with WidgetsBindingObserver, TickerProviderStateMixin
{
    final ViewContext _viewContext;
    final List<AppTabs> _tabs = [];
    TabController _tabController;
    final PopupManager _popupManager = PopupManager();

    ConnectionState _connectionState;
    bool _exitConfirm, _searchDialog;
    int _tabBarId = 0, _tabId = 0;

    final _toastKey = GlobalKey<ScaffoldState>();

    MusicControllerAppState(this._viewContext);

    Configuration get _configuration
    => _viewContext.configuration;

    StateManager get _stateManager
    => _viewContext.stateManager;

    @override
    void initState()
    {
        super.initState();
        BackButtonInterceptor.add(_onBackPressed);

        _applyConfiguration(informPlatform: false, updScripts: false);

        _stateManager.addListeners(_onStateChanged, _onConnectionError);

        _connectionState = ConnectionState.NONE;
        _exitConfirm = false;
        _searchDialog = false;
        WidgetsBinding.instance.addObserver(this);

        _onResume(autoPower: _configuration.autoPower).then((value)
        {
            // Prepare platform channel after connection data are processed in order
            // to prevent unnecessary NetworkStateChange handling
            ServicesBinding.instance.defaultBinaryMessenger.setMessageHandler(Platform.PLATFORM_CHANNEL, (ByteData message) async
            {
                final PlatformCmd cmd = Platform.readPlatformCommand(message);
                if (cmd == PlatformCmd.NETWORK_STATE)
                {
                    _processNetworkStateChange(message);
                }
                else if (_configuration.audioControl.volumeKeys && _stateManager.isConnected)
                {
                    if (cmd == PlatformCmd.VOLUME_UP)
                    {
                        _stateManager.changeMasterVolume(_configuration.audioControl.soundControl, true);
                    }
                    if (cmd == PlatformCmd.VOLUME_DOWN)
                    {
                        _stateManager.changeMasterVolume(_configuration.audioControl.soundControl, false);
                    }
                }
                return null;
            });
        });
    }

    @override
    void dispose()
    {
        WidgetsBinding.instance.removeObserver(this);
        _viewContext.updateNotifier.close();
        _tabController.dispose();
        BackButtonInterceptor.remove(_onBackPressed);
        _stateManager.usbSerial.dispose();
        super.dispose();
    }

    @override
    void didChangeAppLifecycleState(AppLifecycleState state)
    {
        Logging.info(this.widget, "Application state change: " + state.toString());
        if (state == AppLifecycleState.resumed)
        {
            _onResume(autoPower: false);
        }
        else
        {
            _disconnect();
        }
    }

    Future<void> _onResume({bool autoPower = false}) async
    {
        Logging.info(this.widget, "resuming application");
        await Platform.requestIntent().then((replay)
        {
            _stateManager.updateScripts(
                autoPower: autoPower,
                intent: Platform.parseIntent(replay),
                shortcuts: _configuration.favoriteShortcuts.shortcuts);
        });

        bool connect = _configuration.isDeviceValid;
        if (_stateManager.intentHost != null)
        {
            if (_stateManager.intentHost.isValidConnection())
            {
                connect = true;
            }
            // process optional intent data like target zone and app tab
            _stateManager.state.activeZone = _stateManager.intentHost.zone;
            for (AppTabs t in AppTabs.values)
            {
                if (_stateManager.intentHost.tab.toUpperCase() == Convert.enumToString(t).toUpperCase())
                {
                    _setActiveTab(t);
                    break;
                }
            }
        }
        else
        {
            _stateManager.state.activeZone = _configuration.activeZone;
        }

        if (connect)
        {
            await Platform.requestNetworkState().then((replay)
            {
                _processNetworkStateChange(replay, noChangeCheck: true);
            });
        }
        else
        {
            WidgetsBinding.instance.addPostFrameCallback((_)
            => _stateManager.triggerStateEvent(StateManager.START_SEARCH_EVENT));
        }
        return Future.value();
    }

    @override
    Widget build(BuildContext context)
    {
        Logging.logRebuild(this.widget);

        final ThemeData td = _viewContext.getThemeData();

        final UpdatableAppBarWidget appBarView = UpdatableAppBarWidget(context,
            AppBarView(_viewContext, _tabController, _tabs)
        );

        if (!_stateManager.state.mediaFilterVisible)
        {
            _tabId++;
        }
        final Widget tabBar = TabBarView(
            key: Key(_tabBarId.toString()),
            controller: _tabController,
            children: _tabs.map((AppTabs tab)
            {
                return Container(
                    margin: ActivityDimens.activityMargins(context, Platform.isIOS, Platform.isAndroid),
                    child: UpdatableWidget(
                        child: AppTabView(_tabId, _viewContext, _configuration.appSettings.tabSettings(tab))
                    )
                );
            }).toList(),
        );

        double appBarHeight = ActivityDimens.appBarHeight(context);
        if (!_configuration.appSettings.isSingleTab)
        {
            appBarHeight += ActivityDimens.tabBarHeight(context);
        }

        final Widget scaffold = Scaffold(
            key: _toastKey,
            // Disable activity resize when a software keyboard is open:
            // The keyboard is placed above the activity view
            resizeToAvoidBottomInset: false,
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(appBarHeight), // desired height of appBar + tabBar
                child: appBarView),
            drawer: UpdatableWidget(child:
                DrawerView(context, (context)
                {
                    final bool portrait = MediaQuery.of(context).orientation == Orientation.portrait;
                    return portrait ?
                        TabLayoutPortrait(_configuration, _configuration.appSettings.tabSettings(_getActiveTab())) :
                        TabLayoutLandscape(_configuration, _configuration.appSettings.tabSettings(_getActiveTab()));
                },
                _viewContext)),
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
                        _applyConfiguration(informPlatform: true, updScripts: true);
                    });
                    break;
                case StateManager.START_SEARCH_EVENT:
                    _startSearch();
                    break;
                case StateManager.CONNECTION_EVENT:
                    if (_stateManager.isConnected)
                    {
                        _connectionState = ConnectionState.CONNECTED;
                        final String host = _stateManager.manualHost ?? _stateManager.getConnection().getHost;
                        _configuration.saveDevice(host, _stateManager.getConnection().getPort);
                        if (_stateManager.manualAlias != null)
                        {
                            _configuration.favoriteConnections.updateDevice(
                                _stateManager.getConnection(), _stateManager.manualAlias, null);
                        }
                        _configuration.setReceiverInformation(_viewContext.stateManager);
                        // startSearch calls multiroomState.updateFavorites
                        _stateManager.startSearch(limited: true);
                    }
                    break;
                case StateManager.APPLY_FAVORITE_EVENT:
                    _setActiveTab(AppTabs.MEDIA);
                    break;
                case ReceiverInformationMsg.CODE:
                    if (_stateManager.isConnected && !changes.contains(StateManager.CONNECTION_EVENT))
                    {
                        _configuration.setReceiverInformation(_viewContext.stateManager);
                        _viewContext.state.multiroomState.updateFavorites();
                    }
                    break;
            }
        });
        // update dialogs
        if (_stateManager.state.isConnected)
        {
            // Track menu
            if (_isControlActive(AppControl.TRACK_FILE_INFO))
            {
                final bool isTrackMenu = _stateManager.state.mediaListState.isMenuMode
                    && !_stateManager.state.mediaListState.isMediaEmpty;
                if (isTrackMenu)
                {
                    _popupManager.showTrackMenuDialog(context, _viewContext);
                }
                else
                {
                    _popupManager.closeTrackMenuDialog(context);
                }
            }
            // popup
            {
                if (changes.contains(CustomPopupMsg.CODE))
                {
                    Timer(StateManager.GUI_UPDATE_DELAY, ()
                    => _popupManager.showPopupDialog(context, _viewContext, toastKey: _toastKey));
                }
                if (!_stateManager.state.mediaListState.isPopupMode)
                {
                    _popupManager.closePopupDialog(context);
                }
            }
        }

        _viewContext.updateNotifier.sink.add(changes);
    }

    void _startSearch()
    {
        Platform.requestNetworkState().then((replay)
        {
            final NetworkState n = Platform.parseNetworkState(replay);
            _stateManager.setNetworkState(n);
            _stateManager.startSearch(limited: false);
            if (!_searchDialog)
            {
                _searchDialog = true;
                showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext c)
                    => DeviceSearchDialog(_viewContext, ()
                    {
                        _searchDialog = false;
                    })
                );
            }
        });
    }

    void _connectToDevice(final NetworkState n)
    {
        if (_stateManager.isConnected)
        {
            // nothing to do
            return;
        }
        if (_configuration.isDeviceValid)
        {
            Logging.info(this.widget, "Use stored connection data: "
                + Convert.ipToString(_configuration.getDeviceName, _configuration.getDevicePort.toString()));
            _connectionState = ConnectionState.CONNECTING_TO_SAVED;
            _stateManager.connect(_configuration.getDeviceName, _configuration.getDevicePort,
                manualHost: _configuration.getDeviceName);
        }
        else if (_stateManager.intentHost != null && _stateManager.intentHost.isValidConnection())
        {
            Logging.info(this.widget, "Use intent connection data: " + _stateManager.intentHost.getHostAndPort);
            _connectionState = ConnectionState.CONNECTING_TO_INTENT;
            _stateManager.connect(_stateManager.intentHost.getHost, _stateManager.intentHost.getPort);
        }
    }

    void _disconnect()
    {
        _connectionState = ConnectionState.NONE;
        _stateManager.disconnect(false);
        _stateManager.stopSearch();
        _stateManager.state.clear();
    }

    void _onConnectionError(String result)
    {
        PopupManager.showToast(result, toastKey: _toastKey);
        if (_connectionState == ConnectionState.CONNECTING_TO_SAVED)
        {
            Logging.info(this.widget, "Searching for any device to connect");
            _connectionState = ConnectionState.CONNECTING_TO_ANY;
            _startSearch();
        }
    }

    bool _onBackPressed(bool stopDefaultButtonEvent, RouteInfo routeInfo)
    {
        if (Navigator.canPop(context) || !_stateManager.isConnected || !_stateManager.state.isOn)
        {
            // For pushed activities we always allow back
            return false;
        }
        // Processing on "Back" button
        if (_isControlActive(AppControl.MEDIA_LIST) && !_viewContext.state.mediaListState.isTopLayer() && _configuration.backAsReturn)
        {
            _stateManager.state.closeMediaFilter();
            _stateManager.sendMessage(StateManager.RETURN_MSG, waitingForData: true);
            return true;
        }
        else if (_configuration.exitConfirm)
        {
            if (!_exitConfirm)
            {
                _exitConfirm = true;
                PopupManager.showToast(Strings.action_exit_confirm, toastKey: _toastKey);
                Timer(Duration(seconds: PopupManager.TOAST_DURATION), ()
                {
                    _exitConfirm = false;
                });
                return true;
            }
        }
        return false;
    }

    void _processNetworkStateChange(final ByteData state, {final bool noChangeCheck = false})
    {
        final NetworkState n = Platform.parseNetworkState(state);
        if (_stateManager.setNetworkState(n) || noChangeCheck)
        {
            switch(n)
            {
                case NetworkState.NONE:
                    setState(()
                    {
                        _disconnect();
                    });
                    PopupManager.showToast(Strings.error_connection_no_network, toastKey: _toastKey);
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
    }

    void _applyConfiguration({bool informPlatform = false, bool updScripts = false})
    {
        // Update logging
        Logging.logSize = _configuration.developerMode ? Logging.DEFAULT_LOG_SIZE : 0;

        // Update tabs
        final bool tabChanged = !listEquals(_configuration.appSettings.visibleTabs, _tabs);

        _tabs.clear();
        _tabs.addAll(_configuration.appSettings.visibleTabs);
        final int _index = _configuration.appSettings.getTabIndex(_configuration.appSettings.openedTab);
        if (_tabController == null || tabChanged)
        {
            _updateTabs(_index);
        }

        // Inform state manager about configuration change
        _stateManager.keepPlaybackMode = _index < _tabs.length && _tabs[_index] == AppTabs.LISTEN;
        _stateManager.state.soundControlState.forceAudioControl = _configuration.audioControl.isForceAudioControl;

        // Inform platform code about configuration change.
        // Depending on new setting, app may be restarted by platform code here
        if (informPlatform)
        {
            Platform.sendPlatformCommand(_configuration.audioControl.volumeKeys ?
                PlatformCmd.VOLUME_KEYS_ENABLED : PlatformCmd.VOLUME_KEYS_DISABLED);
            Platform.sendPlatformCommand(_configuration.keepScreenOn ?
                PlatformCmd.KEEP_SCREEN_ON_ENABLED : PlatformCmd.KEEP_SCREEN_ON_DISABLED);
        }

        if (updScripts)
        {
            _stateManager.updateScripts(autoPower: _configuration.autoPower);
        }

        if (Platform.isDesktop)
        {
            _stateManager.usbSerial.dispose();
            _stateManager.usbSerial.openPort(_configuration.riCommands.usbPort);
        }
    }

    void _updateTabs(int index)
    {
        if (_tabController != null)
        {
            _tabController.dispose();
        }
        _tabController = TabController(vsync: this, length: _tabs.length, initialIndex: index);
        _tabController.addListener(_handleTabSelection);
        _configuration.appSettings.openedTab = _getActiveTab();
        _tabBarId++; // force re-creation of tabBar
    }

    AppTabs _getActiveTab()
    {
        final List<AppTabs> tabs = _configuration.appSettings.visibleTabs;
        return _tabController != null && _tabController.index < tabs.length ? tabs[_tabController.index] : null;
    }

    void _setActiveTab(AppTabs tab)
    {
        setState(()
        {
            _tabController.index = _configuration.appSettings.getTabIndex(tab);
        });
    }

    bool _isControlActive(final AppControl c)
    {
        final bool portrait = MediaQuery.of(context).orientation == Orientation.portrait;
        final CfgTabSettings tab = _configuration.appSettings.tabSettings(_getActiveTab());
        return (tab != null) ? tab.isControlActive(c, portrait) : false;
    }

    void _handleTabSelection()
    {
        final AppTabs tab = _getActiveTab();
        if (!_tabController.indexIsChanging && tab != null)
        {
            _configuration.appSettings.openedTab = tab;

            if([AppTabs.LISTEN, AppTabs.MEDIA].contains(tab) && _stateManager.isConnected)
            {
                final bool desiredPlayback = tab == AppTabs.LISTEN || _configuration.keepPlaybackMode;
                _stateManager.keepPlaybackMode = desiredPlayback;
                if (_stateManager.state.mediaListState.isUiTypeValid &&
                    desiredPlayback != _stateManager.state.mediaListState.isPlaybackMode)
                {
                    _stateManager.sendMessage(StateManager.LIST_MSG);
                }
            }

            _stateManager.state.closeMediaFilter();
        }
    }
}
