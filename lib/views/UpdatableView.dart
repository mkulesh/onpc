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

import "dart:async";

import "package:flutter/material.dart";

import "../constants/Drawables.dart";
import "../config/Configuration.dart";
import "../constants/Dimens.dart";
import "../constants/Themes.dart";
import "../iscp/State.dart" as remote_state;
import "../iscp/StateManager.dart";
import "../utils/Logging.dart";
import "../widgets/CustomImageButton.dart";

class ViewContext
{
    final Configuration configuration;
    final StateManager stateManager;
    final StreamController updateNotifier;

    ViewContext(this.configuration, this.stateManager, this.updateNotifier);

    remote_state.State get state
    => stateManager.state;

    ThemeData getThemeData()
    => BaseAppTheme.getThemeData(configuration.appSettings.theme, configuration.appSettings.language, configuration.appSettings.textSize);
}

mixin WidgetStreamContext
{
    ViewContext get viewContext;

    Configuration get configuration
    => viewContext.configuration;

    StateManager get stateManager
    => viewContext.stateManager;

    remote_state.State get state
    => viewContext.state;
}

abstract class WidgetStreamState<T extends StatefulWidget> extends State<T> with WidgetStreamContext
{
    final ViewContext _viewContext;

    @override
    ViewContext get viewContext
    => _viewContext;

    final List<String> _updateTriggers;
    final bool clearFocus;
    StreamSubscription _updateStream;

    WidgetStreamState(this._viewContext, this._updateTriggers, {this.clearFocus = false});

    @override
    initState()
    {
        super.initState();
        _updateStream = _viewContext.updateNotifier.stream.listen((code)
        => _update(code));
    }

    @override
    dispose()
    {
        _updateStream.cancel();
        super.dispose();
    }

    void updateStream(StreamController updateNotifier)
    {
        if (_updateStream != null)
        {
            _updateStream.cancel();
            _updateStream = updateNotifier.stream.listen((code)
            => _update(code));
        }
    }

    _update(Set<String> changes)
    {
        if (changes.where((s) => _updateTriggers.contains(s)).isNotEmpty)
        {
            _updateCallback();
        }
    }

    void _updateCallback()
    {
        setState(()
        {
            // nothing to do: build will be called
        });
    }

    Widget createView(BuildContext context, VoidCallback updateCallback);

    @override
    Widget build(BuildContext context)
    {
        try
        {
            if (clearFocus)
            {
                FocusScope.of(context).unfocus();
            }
            return createView(context, _updateCallback);
        }
        catch (e)
        {
            Logging.info(this, "ERROR: " + e.toString());
            return Logging.isEnabled ? Text(e.toString()) : SizedBox.shrink();
        }
    }
}

abstract class UpdatableView with WidgetStreamContext
{
    final ViewContext _viewContext;

    @override
    ViewContext get viewContext
    => _viewContext;

    final List<String> _updateTriggers;

    UpdatableView(this._viewContext, this._updateTriggers);

    Widget createView(BuildContext context, VoidCallback updateCallback);

    static Widget createTimerSand()
    => CustomImageButton.small(
        Drawables.timer_sand, "",
        isEnabled: false);
}

class UpdatableWidget extends StatefulWidget
{
    final UpdatableView child;
    final bool clearFocus;

    UpdatableWidget({this.child, this.clearFocus = false});

    @override _UpdatableWidgetState createState()
    => _UpdatableWidgetState(child._viewContext, child._updateTriggers, clearFocus);
}

class UpdatableAppBarWidget extends UpdatableWidget
    implements PreferredSizeWidget
{
    final BuildContext _context;

    UpdatableAppBarWidget(this._context, UpdatableView child) : super(child: child);

    @override _UpdatableWidgetState createState()
    => _UpdatableWidgetState(child._viewContext, child._updateTriggers, clearFocus);

    @override
    Size get preferredSize
    => Size.fromHeight(ActivityDimens.appBarHeight(_context));
}

class _UpdatableWidgetState extends WidgetStreamState<UpdatableWidget>
{
    _UpdatableWidgetState(final ViewContext _viewContext, final List<String> _updateTriggers, final bool _clearFocus) :
            super(_viewContext, _updateTriggers, clearFocus: _clearFocus);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    => widget.child.createView(context, updateCallback);

    @override
    didUpdateWidget(UpdatableWidget old)
    {
        super.didUpdateWidget(old);
        // in case the stream instance changed, subscribe to the new one
        if (widget.child.viewContext.updateNotifier != old.child.viewContext.updateNotifier)
        {
            _updateStream.cancel();
            _updateStream = widget.child.viewContext.updateNotifier.stream.listen((code)
            => _update(code));
        }
    }
}