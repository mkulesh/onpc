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

import 'dart:async';
import 'dart:io';
import "dart:ui";

import "package:back_button_interceptor/back_button_interceptor.dart";
import "package:collection/collection.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:flutter/scheduler.dart" show timeDilation;
import "package:flutter/services.dart";
import "package:google_fonts/google_fonts.dart";
import "package:shared_preferences/shared_preferences.dart";

import "config/CfgAppSettings.dart";
import "config/CfgTabSettings.dart";
import "config/Configuration.dart";
import "config/DeviceSelectors.dart";
import "config/KeyboardShortcuts.dart";
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
import "homeWidget.dart";
import "iscp/ConnectionIf.dart";
import "iscp/StateManager.dart";
import "iscp/messages/CustomPopupMsg.dart";
import "iscp/messages/DcpReceiverInformationMsg.dart";
import "iscp/messages/FriendlyNameMsg.dart";
import "iscp/messages/OperationCommandMsg.dart";
import "iscp/messages/ReceiverInformationMsg.dart";
import "iscp/messages/TimeInfoMsg.dart";
import "utils/CompatUtils.dart";
import "utils/Convert.dart";
import "utils/Logging.dart";
import "utils/Platform.dart";
import "utils/UrlLoader.dart";
import "views/AboutScreen.dart";
import "views/AppBarView.dart";
import "views/AppTabView.dart";
import "views/DrawerView.dart";
import "views/UpdatableView.dart";
import "widgets/ScaffoldBody.dart";

void main() async
{
    debugPaintSizeEnabled = Logging.isVisualLayout;

    // Ignore CERTIFICATE_VERIFY_FAILED error for Deezer cover art on older Android and Windows
    if (Platform.isAndroid || Platform.isWindows)
    {
        HttpOverrides.global = OncpHttpOverrides();
    }

    // we do not want the GoogleFonts library to make any HTTP requests for fonts
    GoogleFonts.config.allowRuntimeFetching = false;

    // Will slow down animations by this factor
    timeDilation = 1.0;

    WidgetsFlutterBinding.ensureInitialized();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Configuration configuration = Configuration(prefs);
    configuration.read();

    final WindowManagerWrapper windowManager = WindowManagerWrapper(configuration);
    windowManager.restoreWindow();

    final StateManager stateManager = StateManager(configuration.favoriteConnections.getDevices);
    final ViewContext viewContext = ViewContext(configuration, stateManager, StreamController.broadcast());

    final Set<PointerDeviceKind> dragDevices = Platform.isMacOS ?
        {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad} :
        {PointerDeviceKind.touch, PointerDeviceKind.mouse};

    runApp(MaterialApp(
        builder: (context, child) {
            DimensTransform.deviceScaleFactor = MediaQuery.of(context).textScaler.scale(1);
            return MediaQuery.withNoTextScaling(child: child!);
        },
        scrollBehavior: MyCustomScrollBehavior(dragDevices),
        debugShowCheckedModeBanner: Logging.isDebugBanner,
        title: Strings.app_short_name,
        theme: viewContext.getThemeData(),
        home: MusicControllerApp(windowManager, viewContext),
        localeResolutionCallback: (Locale? locale, Iterable<Locale> supportedLocales)
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
            Activities.activity_keyboard_shortcuts: (BuildContext context) => KeyboardShortcuts(configuration),
            Activities.activity_about_screen: (BuildContext context) => AboutScreen(viewContext),
        },
        navigatorKey: viewContext.navigatorKey));
}

class MusicControllerApp extends StatefulWidget
{
    final WindowManagerWrapper _windowManager;
    final ViewContext _viewContext;

    ViewContext get viewContext
    => _viewContext;

    MusicControllerApp(this._windowManager, this._viewContext, {Key? key}) : super(key: key);

    @override
    MusicControllerAppState createState()
    => MusicControllerAppState(_windowManager, _viewContext);
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
    final WindowManagerWrapper _windowManager;
    final ViewContext _viewContext;
    final List<AppTabs> _tabs = [];
    TabController? _tabController;
    final PopupManager _popupManager = PopupManager();
    static const MethodChannel _methodChannel = MethodChannel('platform_method_channel');

    ConnectionState? _connectionState;
    bool _exitConfirm = false;
    bool _searchDialog = false;
    int _tabBarId = 0, _tabId = 0;

    // On Android a strange behaviour is observed:
    // 1. A pair of state changes inactive/resumed is triggered twice when app
    //    is started from the widget. As a result, the second call of _onResume
    //    may prevent successful connect.
    // 2. platform_method_channel can trigger callback before resuming.
    // This variable is aimed to skip the second call of _onResume and
    // early callbacks of platform_method_channel
    bool _isResumed = false;

    MusicControllerAppState(this._windowManager, this._viewContext);

    Configuration get _configuration
    => _viewContext.configuration;

    StateManager get _stateManager
    => _viewContext.stateManager;

    @override
    void initState()
    {
        super.initState();
        _windowManager.initState();
        BackButtonInterceptor.add(_onBackPressed);

        _applyConfiguration(informPlatform: false, updScripts: false);

        _stateManager.addListeners(_onStateChanged, _onConnectionError);

        _connectionState = ConnectionState.NONE;
        _exitConfirm = false;
        _searchDialog = false;
        WidgetsBinding.instance.addObserver(this);

        if (Platform.isAndroid)
        {
            registerWidgetPlaybackCallback(_methodChannel);
        }

        _onResume().then((value)
        {
            // Prepare platform channel after connection data are processed in order
            // to prevent unnecessary NetworkStateChange handling
            _methodChannel.setMethodCallHandler(_onPlatformMethodCall);
        });
    }

    @override
    void dispose()
    {
        WidgetsBinding.instance.removeObserver(this);
        _viewContext.updateNotifier.close();
        _tabController?.dispose();
        BackButtonInterceptor.remove(_onBackPressed);
        _windowManager.dispose();
        _stateManager.usbSerial.dispose();
        super.dispose();
    }

    @override
    void didChangeAppLifecycleState(AppLifecycleState state)
    {
        super.didChangeAppLifecycleState(state);
        Logging.info(this.widget, "Application state change: " + state.toString());
        switch (state)
        {
            case AppLifecycleState.resumed:
                if (_isResumed || _stateManager.isConnected)
                {
                    Logging.info(this.widget, "Resuming triggered, but the app is already " +
                        (_isResumed? "resumed" : "connected") + " -> Ignore resuming.");
                    if (Platform.isIOS && _searchDialog && _stateManager.isSearching)
                    {
                        _stateManager.startSearch(limited: false, restart: true);
                    }
                }
                else
                {
                    _onResume();
                }
                break;
            case AppLifecycleState.inactive:
                // Skip inactive on Android: the app still be active when showed in the taskbar
                if (!Platform.isAndroid)
                {
                    _isResumed = false;
                }
                // On iOS, also disconnect in this stage
                if (Platform.isIOS)
                {
                    _disconnect();
                }
                break;
            default:
                _isResumed = false;
                // On all desktop platforms: the app still be active when minimized into the taskbar
                // On all mobile platforms, also disconnect in this stage
                if (Platform.isMobile)
                {
                    _disconnect();
                }
        }
    }

    Future<void> _onResume() async
    {
        Logging.info(this.widget, "resuming application");
        _isResumed = true;
        await Platform.requestIntent(_methodChannel).then((replay)
        {
            if (replay != null)
            {
                Logging.info(this.widget, "received intent: " + replay);
            }
            if (replay != null && replay.startsWith(Platform.TARGET_CONTROL))
            {
                final AppControl c = CfgTabSettings.ValueEnum.valueByCode(replay.replaceAll(Platform.TARGET_CONTROL, "")).key;
                Logging.info(this.widget, "set active tab for control: " + c.toString());
                final AppTabs? tab = _configuration.appSettings.visibleTabs.firstWhereOrNull(
                        (t) => _isControlActive(c, appTab: t));
                if (tab != null)
                {
                    _setActiveTab(tab);
                }
            }
            _stateManager.updateScripts(
                autoPower: _configuration.autoPower,
                intent: replay,
                shortcuts: _configuration.favoriteShortcuts.shortcuts);
        });

        final bool connect = _configuration.isDeviceValid ||
            (_stateManager.intentHost != null && _stateManager.intentHost!.isValidConnection());
        if (connect)
        {
            await Platform.requestNetworkState(_methodChannel).then((String? replay)
            {
                if (replay != null)
                {
                    _processNetworkStateChange(replay, noChangeCheck: true);
                }
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

        final UpdatableAppBarWidget? appBarView = _tabController != null?
            UpdatableAppBarWidget(context, AppBarView(_viewContext, _tabController!, _tabs)) :
            null;

        if (!_stateManager.state.mediaFilterVisible)
        {
            _tabId++;
        }
        final Widget tabBar = TabBarView(
            key: Key(_tabBarId.toString()),
            controller: _tabController,
            children: _tabs.map((AppTabs tab)
            {
                return UpdatableWidget(
                    child: AppTabView(_tabId, _viewContext, _configuration.appSettings.tabSettings(tab))
                );
            }).toList(),
        );

        double appBarHeight = ActivityDimens.appBarHeight(context);
        if (!_configuration.appSettings.isSingleTab)
        {
            appBarHeight += ActivityDimens.tabBarHeight(context);
        }

        final Widget scaffold = Scaffold(
            // Disable activity resize when a software keyboard is open:
            // The keyboard is placed above the activity view
            resizeToAvoidBottomInset: false,
            appBar: appBarView != null? PreferredSize(
                preferredSize: Size.fromHeight(appBarHeight), // desired height of appBar + tabBar
                child: appBarView) : null,
            drawer: UpdatableWidget(child:
                DrawerView(context, (context)
                {
                    final bool portrait = MediaQuery.of(context).orientation == Orientation.portrait;
                    return portrait ?
                        TabLayoutPortrait(_configuration, _configuration.appSettings.tabSettings(_getActiveTab())) :
                        TabLayoutLandscape(_configuration, _configuration.appSettings.tabSettings(_getActiveTab()));
                },
                _viewContext)),
            body: ScaffoldBody(tabBar)
        );

        return Theme(data: td,
            child: ScaffoldMessenger(
                key: _viewContext.toastKey,
                child: scaffold)
        );
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
                        _configuration.read(protoType: _stateManager.protoType);
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
                        _applyConfiguration(informPlatform: false, updScripts: false);
                        // startSearch calls multiroomState.updateFavorites
                        _stateManager.startSearch(limited: true);
                    }
                    setState(() {});
                    break;
                case StateManager.ZONE_EVENT:
                    _configuration.activeZone = _stateManager.state.getActiveZone;
                    Platform.updateWidgets(_methodChannel);
                    break;
                case StateManager.OPEN_MEDIA_VIEW:
                    final AppTabs? tab = _configuration.appSettings.visibleTabs.firstWhereOrNull(
                        (t) => _isControlActive(AppControl.MEDIA_LIST, appTab: t));
                    if (tab != null)
                    {
                        _setActiveTab(tab);
                    }
                    break;
                case ReceiverInformationMsg.CODE:
                case DcpReceiverInformationMsg.CODE:
                    if (_stateManager.isConnected)
                    {
                        _viewContext.stateManager.validateZone();
                        if (!changes.contains(StateManager.CONNECTION_EVENT))
                        {
                            _configuration.setReceiverInformation(_viewContext.stateManager);
                            _viewContext.state.multiroomState.updateFavorites();
                        }
                    }
                    Platform.updateWidgets(_methodChannel);
                    break;
                case StateManager.SHORTCUT_CHANGE_EVENT:
                case StateManager.ZONE_RENAMED:
                    Platform.updateWidgets(_methodChannel);
                    break;
                case FriendlyNameMsg.CODE:
                    _configuration.saveDeviceFriendlyName(_stateManager.state.receiverInformation);
                    Platform.updateWidgets(_methodChannel);
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
                    => _popupManager.showPopupDialog(context, _viewContext, toastKey: _viewContext.toastKey));
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
        Platform.requestNetworkState(_methodChannel).then((String? replay)
        {
            if (replay != null)
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
        if (_stateManager.intentHost != null && _stateManager.intentHost!.isValidConnection())
        {
            Logging.info(this.widget, "Use intent connection data: " + _stateManager.intentHost!.getHostAndPort);
            _connectionState = ConnectionState.CONNECTING_TO_INTENT;
            _stateManager.state.activeZone = _stateManager.intentHost!.zone;
            for (AppTabs t in AppTabs.values)
            {
                if (_stateManager.intentHost!.tab.toUpperCase() == Convert.enumToString(t).toUpperCase())
                {
                    _setActiveTab(t);
                    break;
                }
            }
            _stateManager.connect(_stateManager.intentHost!.getHost, _stateManager.intentHost!.getPort);
        }
        else if (_configuration.isDeviceValid)
        {
            Logging.info(this.widget, "Use stored connection data: "
                + Convert.ipToString(_configuration.getDeviceName, _configuration.getDevicePort.toString()));
            _connectionState = ConnectionState.CONNECTING_TO_SAVED;
            _stateManager.state.activeZone = _configuration.activeZone;
            _stateManager.connect(_configuration.getDeviceName, _configuration.getDevicePort,
                manualHost: _configuration.getDeviceName);
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
        PopupManager.showToast(result, toastKey: _viewContext.toastKey);
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
            _stateManager.sendMessage(_stateManager.getReturnMessage(), waitingForData: true);
            return true;
        }
        else if (_configuration.exitConfirm)
        {
            if (!_exitConfirm)
            {
                _exitConfirm = true;
                PopupManager.showToast(Strings.action_exit_confirm, toastKey: _viewContext.toastKey);
                Timer(Duration(seconds: PopupManager.TOAST_DURATION), ()
                {
                    _exitConfirm = false;
                });
                return true;
            }
        }
        return false;
    }

    void _processNetworkStateChange(final String state, {final bool noChangeCheck = false})
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
                    PopupManager.showToast(Strings.error_connection_no_network, toastKey: _viewContext.toastKey);
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
            Platform.updateWidgets(_methodChannel);
            final arguments = <dynamic>[];
            arguments.add(_configuration.audioControl.volumeKeys);
            arguments.add(_configuration.keepScreenOn);
            arguments.add(_configuration.showWhenLocked);
            Platform.sendPlatformCommand(_methodChannel, Platform.SET_ACTIVITY_STATE, arguments);
        }

        if (updScripts)
        {
            _stateManager.updateScripts(autoPower: _configuration.autoPower);
        }

        if (_stateManager.usbSerial.isChanged(_configuration.riCommands.usbPort))
        {
            _stateManager.usbSerial.dispose();
            if (Platform.isDesktop && _stateManager.protoType == ProtoType.ISCP)
            {
                _stateManager.usbSerial.openPort(_configuration.riCommands.usbPort);
            }
        }
    }

    void _updateTabs(int index)
    {
        if (_tabController != null)
        {
            _tabController!.dispose();
        }
        _tabController = TabController(vsync: this, length: _tabs.length, initialIndex: index);
        _tabController!.addListener(_handleTabSelection);
        _configuration.appSettings.openedTab = _getActiveTab();
        _tabBarId++; // force re-creation of tabBar
    }

    AppTabs _getActiveTab()
    {
        final List<AppTabs> tabs = _configuration.appSettings.visibleTabs;
        return _tabController != null && _tabController!.index < tabs.length ? tabs[_tabController!.index] : AppTabs.LISTEN;
    }

    void _setActiveTab(AppTabs tab)
    {
        if (_tabController != null)
        {
            setState(()
            {
                _tabController!.index = _configuration.appSettings.getTabIndex(tab);
            });
        }
    }

    bool _isControlActive(final AppControl c, {AppTabs? appTab})
    {
        final bool portrait = MediaQuery.of(context).orientation == Orientation.portrait;
        final CfgTabSettings tab = _configuration.appSettings.tabSettings(
            appTab == null ? _getActiveTab() : appTab);
        return tab.isControlActive(c, portrait);
    }

    void _handleTabSelection()
    {
        final AppTabs tab = _getActiveTab();
        if (!_tabController!.indexIsChanging)
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

    Future<void> _onPlatformMethodCall(MethodCall call) async
    {
        if (!Platform.isWindows && !_isResumed)
        {
            // On Windows, always process platform callback due to keyboard shortcuts
            return;
        }
        String par = "";
        if (call.arguments is String)
        {
            par = call.arguments;
        }
        if (call.method != Platform.SHORTCUT)
        {
            Logging.info(this.widget, "Call from platform: " + call.method + "(" + par + ")");
        }
        switch(call.method)
        {
            case Platform.PLATFORM_LOG:
                break;
            case Platform.SHORTCUT:
                _processGlobalShortcut(call.method, par);
                break;
            case Platform.VOLUME_UP:
                _stateManager.changeMasterVolume(_configuration.audioControl, 0);
                break;
            case Platform.VOLUME_DOWN:
                _stateManager.changeMasterVolume(_configuration.audioControl, 1);
                break;
            case Platform.NETWORK_STATE_CHANGE:
                _processNetworkStateChange(par);
                break;
        }
    }

    void _processGlobalShortcut(final String method, final String par)
    {
        if (par.isEmpty)
        {
            return;
        }
        if (_configuration.appSettings.processKeyboardShortcut(par))
        {
            // nothing to do: shortcut processed
        }
        else if (par == _configuration.appSettings.getKeyboardShortcut("ks_volume_up"))
        {
            Logging.info(this.widget, "Call from platform: " + method + "(" + par + ") -> volume up");
            _stateManager.changeMasterVolume(_configuration.audioControl, 0);
        }
        else if (par == _configuration.appSettings.getKeyboardShortcut("ks_volume_down"))
        {
            Logging.info(this.widget, "Call from platform: " + method + "(" + par + ") -> volume down");
            _stateManager.changeMasterVolume(_configuration.audioControl, 1);
        }
        else if (par == _configuration.appSettings.getKeyboardShortcut("ks_volume_mute"))
        {
            Logging.info(this.widget, "Call from platform: " + method + "(" + par + ") -> volume mute");
            _stateManager.changeMasterVolume(_configuration.audioControl, 2);
        }
        else if (par == _configuration.appSettings.getKeyboardShortcut("ks_volume_trdn"))
        {
            Logging.info(this.widget, "Call from platform: " + method + "(" + par + ") -> track down");
            _stateManager.changePlaybackState(OperationCommand.TRDN);
        }
        else if (par == _configuration.appSettings.getKeyboardShortcut("ks_volume_play"))
        {
            Logging.info(this.widget, "Call from platform: " + method + "(" + par + ") -> play");
            _stateManager.changePlaybackState(OperationCommand.PLAY);
        }
        else if (par == _configuration.appSettings.getKeyboardShortcut("ks_volume_stop"))
        {
            Logging.info(this.widget, "Call from platform: " + method + "(" + par + ") -> stop");
            _stateManager.changePlaybackState(OperationCommand.STOP);
        }
        else if (par == _configuration.appSettings.getKeyboardShortcut("ks_volume_trup"))
        {
            Logging.info(this.widget, "Call from platform: " + method + "(" + par + ") -> track up");
            _stateManager.changePlaybackState(OperationCommand.TRUP);
        }
    }
}
